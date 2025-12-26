package ar.com.digipad

import android.graphics.BitmapFactory
import androidx.exifinterface.media.ExifInterface
import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.Matrix
import android.util.AttributeSet
import android.util.Log
import android.view.Gravity
import android.os.Environment
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import android.widget.FrameLayout
import android.widget.TextView
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.core.content.ContextCompat
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import ar.com.digipad.yolov8tflite.BoundingBox
import ar.com.digipad.yolov8tflite.Constants
import ar.com.digipad.yolov8tflite.Detector
import ar.com.digipad.yolov8tflite.OverlayView
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean


class YoloV8View @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : FrameLayout(context, attrs, defStyleAttr), Detector.DetectorListener {

    // UI and Core Components
    private val previewView: PreviewView
    private val overlayView: OverlayView
    private val inferenceTimeTextView: TextView
    private val detector: Detector
    private val cameraExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private var cameraProvider: ProcessCameraProvider? = null
    private var imageAnalyzer: ImageAnalysis? = null
    private var imageCapture: ImageCapture? = null
    private var camera: Camera? = null
    private var cameraSelector: CameraSelector = CameraSelector.DEFAULT_BACK_CAMERA
    private var isFrontCamera: Boolean = false
    var onDetections: ((List<BoundingBox>, Long) -> Unit)? = null
    private var lifecycleOwner: LifecycleOwner? = null
    private val isDisposed = AtomicBoolean(false)
    private val isCameraBound = AtomicBoolean(false)
    private val isBinding = AtomicBoolean(false)

    private val lifecycleObserver = object : DefaultLifecycleObserver {
        override fun onResume(owner: LifecycleOwner) {
            super.onResume(owner)
            if (!isDisposed.get()) {
                Log.d("YoloV8View", "Lifecycle: ON_RESUME. Attempting to bind camera use cases.")
                bindCameraUseCases()
            }
        }

        override fun onPause(owner: LifecycleOwner) {
            super.onPause(owner)
            if (!isDisposed.get()) {
                Log.d("YoloV8View", "Lifecycle: ON_PAUSE. Unbinding camera use cases.")
                unbindCamera()
            }
        }
    }

    fun detectImageSync(bitmap: Bitmap): List<BoundingBox> {
        return detector.detectSync(bitmap)
    }

    init {
        Log.d("YoloV8View", "Initializing new YoloV8View instance. Hash: ${this.hashCode()}")
        setBackgroundColor(Color.BLACK)
        
        previewView = PreviewView(context).apply {
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
            implementationMode = PreviewView.ImplementationMode.COMPATIBLE
            scaleType = PreviewView.ScaleType.FILL_CENTER
        }
        addView(previewView)

        overlayView = OverlayView(context, null).apply {
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        }
        addView(overlayView)

        inferenceTimeTextView = TextView(context).apply {
            layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply {
                gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
                bottomMargin = 48
            }
            setTextColor(Color.WHITE)
            textSize = 18f
        }
        addView(inferenceTimeTextView)

        detector = Detector(context, Constants.MODEL_PATH, Constants.LABELS_PATH, this)
        detector.setup()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        Log.d("YoloV8View", "onAttachedToWindow")
        
        ProcessCameraProvider.getInstance(context).addListener({
            if (isDisposed.get()) {
                Log.d("YoloV8View", "View disposed during camera initialization, skipping.")
                return@addListener
            }
            
            try {
                cameraProvider = ProcessCameraProvider.getInstance(context).get()
                findActivity()?.let { activity ->
                    if (activity is LifecycleOwner) {
                        lifecycleOwner = activity
                        activity.lifecycle.addObserver(lifecycleObserver)
                        Log.d("YoloV8View", "Lifecycle observer attached.")
                    }
                }
            } catch (e: Exception) {
                Log.e("YoloV8View", "Error initializing camera provider", e)
            }
        }, ContextCompat.getMainExecutor(context))
    }

    private fun bindCameraUseCases() {
        // Prevent concurrent binding attempts
        if (!isBinding.compareAndSet(false, true)) {
            Log.d("YoloV8View", "Binding already in progress, skipping.")
            return
        }

        try {
            if (isCameraBound.get() || isDisposed.get()) {
                Log.d("YoloV8View", "bindCameraUseCases skipped: already bound or disposed.")
                return
            }

            val provider = cameraProvider ?: run {
                Log.e("YoloV8View", "CameraProvider is null, cannot bind.")
                return
            }
            
            val activity = findActivity() as? LifecycleOwner ?: run {
                Log.e("YoloV8View", "LifecycleOwner (Activity) not found, cannot bind.")
                return
            }
            
            if (ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                Log.e("YoloV8View", "Camera permission not granted, cannot bind.")
                return
            }

            val preview = Preview.Builder().build().apply {
                setSurfaceProvider(previewView.surfaceProvider)
            }
            
            
            imageAnalyzer = ImageAnalysis.Builder()
                .setTargetAspectRatio(AspectRatio.RATIO_4_3)
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .setTargetRotation(display.rotation)
                .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                .build()

            imageAnalyzer?.setAnalyzer(cameraExecutor) { imageProxy ->
                if (isDisposed.get()) {
                    imageProxy.close()
                    return@setAnalyzer
                }
                try {
                    val bitmapBuffer = Bitmap.createBitmap(imageProxy.width, imageProxy.height, Bitmap.Config.ARGB_8888)
                    imageProxy.planes[0].buffer.rewind()
                    bitmapBuffer.copyPixelsFromBuffer(imageProxy.planes[0].buffer)
                    val matrix = Matrix().apply { postRotate(imageProxy.imageInfo.rotationDegrees.toFloat()) }
                    val rotatedBitmap = Bitmap.createBitmap(bitmapBuffer, 0, 0, bitmapBuffer.width, bitmapBuffer.height, matrix, true)
                    detector.detect(rotatedBitmap)
                } finally {
                    imageProxy.close()
                }
            }

            // Unbind all before rebinding
            imageCapture = ImageCapture.Builder()
                .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
                .setTargetRotation(display.rotation)
                .build()

            provider.unbindAll()
            camera = provider.bindToLifecycle(activity, cameraSelector, preview, imageAnalyzer, imageCapture)
            isCameraBound.set(true)
            Log.d("YoloV8View", "Camera use cases bound successfully.")
            
        } catch (e: Exception) {
            Log.e("YoloV8View", "Failed to bind camera use cases", e)
        } finally {
            isBinding.set(false)
        }
    }

    private fun unbindCamera() {
        try {
            // Clear the analyzer first to stop processing
            imageAnalyzer?.clearAnalyzer()
            
            // Unbind all use cases
            cameraProvider?.unbindAll()
            isCameraBound.set(false)
            camera = null
            
            Log.d("YoloV8View", "Camera unbound successfully.")
        } catch (e: Exception) {
            Log.e("YoloV8View", "Error unbinding camera", e)
        }
    }

    fun dispose() {
        if (!isDisposed.compareAndSet(false, true)) {
            Log.d("YoloV8View", "Already disposed, skipping.")
            return
        }
        
        Log.d("YoloV8View", "Starting disposal...")
        
        try {
            // Remove lifecycle observer first
            lifecycleOwner?.lifecycle?.removeObserver(lifecycleObserver)
            lifecycleOwner = null
            Log.d("YoloV8View", "Lifecycle observer removed.")
            
            // Unbind camera
            unbindCamera()
            
            // Clear analyzer reference
            imageAnalyzer = null
            imageCapture = null
            
            // Shutdown executor and wait for tasks to complete
            cameraExecutor.shutdown()
            try {
                if (!cameraExecutor.awaitTermination(1000, TimeUnit.MILLISECONDS)) {
                    cameraExecutor.shutdownNow()
                    Log.w("YoloV8View", "Executor did not terminate in time, forcing shutdown.")
                }
            } catch (e: InterruptedException) {
                cameraExecutor.shutdownNow()
                Thread.currentThread().interrupt()
            }
            Log.d("YoloV8View", "Camera executor shut down.")
            
            // Clear detector resources
            detector.clear()
            Log.d("YoloV8View", "Detector cleared.")
            
            // Clear provider reference
            cameraProvider = null
            
            Log.d("YoloV8View", "Disposal completed successfully.")
            
        } catch (e: Exception) {
            Log.e("YoloV8View", "Error during disposal", e)
        }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        Log.d("YoloV8View", "onDetachedFromWindow called.")
        dispose()
    }

    override fun onEmptyDetect() {
        if (isDisposed.get()) return
        post { 
            if (!isDisposed.get()) {
                overlayView.invalidate()
            }
        }
    }

    override fun onDetect(boundingBoxes: List<BoundingBox>, inferenceTime: Long) {
        if (isDisposed.get()) return
        post {
            if (!isDisposed.get()) {
                // Mirror boxes horizontally when using the front camera so overlay aligns with preview
                val adjustedBoxes = if (isFrontCamera) {
                    boundingBoxes.map { b ->
                        BoundingBox(
                            x1 = 1f - b.x2,
                            y1 = b.y1,
                            x2 = 1f - b.x1,
                            y2 = b.y2,
                            cx = 1f - b.cx,
                            cy = b.cy,
                            w = b.w,
                            h = b.h,
                            cnf = b.cnf,
                            cls = b.cls,
                            clsName = b.clsName
                        )
                    }
                } else boundingBoxes

                inferenceTimeTextView.text = "${inferenceTime}ms"
                overlayView.setResults(adjustedBoxes)
                overlayView.invalidate()
                onDetections?.invoke(adjustedBoxes, inferenceTime)
            }
        }
    }

    private fun findActivity(): Activity? {
        var currentContext = context
        while (currentContext is ContextWrapper) {
            if (currentContext is Activity) return currentContext
            currentContext = currentContext.baseContext
        }
        return null
    }

    // region: Flutter control API
    fun setTorch(enabled: Boolean) {
        try {
            camera?.cameraControl?.enableTorch(enabled)
        } catch (_: Exception) {}
    }

    fun switchCamera(front: Boolean) {
        isFrontCamera = front
        cameraSelector = if (front) CameraSelector.DEFAULT_FRONT_CAMERA else CameraSelector.DEFAULT_BACK_CAMERA
        unbindCamera()
        bindCameraUseCases()
    }

    fun setDetectionEnabled(enabled: Boolean) {
        if (enabled) {
            imageAnalyzer?.setAnalyzer(cameraExecutor) { imageProxy ->
                if (isDisposed.get()) { imageProxy.close(); return@setAnalyzer }
                try {
                    val bitmapBuffer = Bitmap.createBitmap(imageProxy.width, imageProxy.height, Bitmap.Config.ARGB_8888)
                    imageProxy.planes[0].buffer.rewind()
                    bitmapBuffer.copyPixelsFromBuffer(imageProxy.planes[0].buffer)
                    val matrix = Matrix().apply { postRotate(imageProxy.imageInfo.rotationDegrees.toFloat()) }
                    val rotatedBitmap = Bitmap.createBitmap(bitmapBuffer, 0, 0, bitmapBuffer.width, bitmapBuffer.height, matrix, true)
                    detector.detect(rotatedBitmap)
                } finally { imageProxy.close() }
            }
        } else {
            imageAnalyzer?.clearAnalyzer()
        }
    }

    fun setOverlayVisible(visible: Boolean) {
        overlayView.visibility = if (visible) VISIBLE else GONE
    }

    fun capturePhoto(callback: (path: String?, error: String?) -> Unit) {
        val capture = imageCapture ?: run { callback(null, "ImageCapture not initialized"); return }
        val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        val outputDir = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES) ?: context.filesDir
        val photoFile = File(outputDir, "IMG_${timeStamp}.jpg")
        val outputOptions = ImageCapture.OutputFileOptions.Builder(photoFile).build()
        try {
            capture.takePicture(outputOptions, cameraExecutor, object : ImageCapture.OnImageSavedCallback {
                override fun onImageSaved(outputFileResults: ImageCapture.OutputFileResults) {
                    callback(photoFile.absolutePath, null)
                }
                override fun onError(exception: ImageCaptureException) {
                    callback(null, exception.message ?: "Capture failed")
                }
            })
        } catch (e: Exception) {
            callback(null, e.message ?: "Capture error")
        }
    }

    fun detectFromFile(path: String): Map<String, Any> {
        val file = File(path)
        if (!file.exists()) return emptyMap()

        var originalBitmap: Bitmap? = null
        var rotatedBitmap: Bitmap? = null

        try {
            // 1. Calculate optimal sample size
            // We target ~2560px for better detection quality (1024 was too small)
            val options = BitmapFactory.Options()
            options.inJustDecodeBounds = true
            BitmapFactory.decodeFile(path, options)

            val reqSize = 2560
            var inSampleSize = 1
            if (options.outHeight > reqSize || options.outWidth > reqSize) {
                val halfHeight = options.outHeight / 2
                val halfWidth = options.outWidth / 2
                while ((halfHeight / inSampleSize) >= reqSize && (halfWidth / inSampleSize) >= reqSize) {
                    inSampleSize *= 2
                }
            }

            // 2. Decode with sample size
            options.inJustDecodeBounds = false
            options.inSampleSize = inSampleSize
            options.inPreferredConfig = Bitmap.Config.ARGB_8888
            
            originalBitmap = BitmapFactory.decodeFile(path, options) ?: return emptyMap()

            // 3. Handle Rotation (Exif)
            val exif = ExifInterface(path)
            val orientation = exif.getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_NORMAL
            )

            val matrix = Matrix()
            when (orientation) {
                ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
                ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
                ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
            }

            rotatedBitmap = Bitmap.createBitmap(
                originalBitmap, 0, 0, originalBitmap.width, originalBitmap.height, matrix, true
            )

            // 4. Run Detection
            val boxes = detector.detectSync(rotatedBitmap)

            // 5. Format for Flutter (Always 4 Circles, Always 2 Eyes)
            
            // --- CIRCLES (Target: 4 items / 8 coordinates) ---
            val circlesList = boxes.filter { it.clsName.contains("circle", ignoreCase = true) }
                .sortedByDescending { it.cnf } // Select highest match
                .take(4)                       // Limit to top 4
                .flatMap { listOf(it.cx.toDouble(), it.cy.toDouble()) }
                .toMutableList()

            // Pad with 0.0 if we found fewer than 4 circles
            while (circlesList.size < 8) {
                circlesList.add(0.0)
            }

            // --- EYES (Target: 2 items / 4 coordinates) ---
            val eyesList = boxes.filter { it.clsName.contains("eye", ignoreCase = true) }
                .sortedByDescending { it.cnf } // Select highest match
                .take(2)                       // Limit to top 2
                .flatMap { listOf(it.cx.toDouble(), it.cy.toDouble()) }
                .toMutableList()

            // Pad with 0.0 if we found fewer than 2 eyes
            while (eyesList.size < 4) {
                eyesList.add(0.0)
            }

            return mapOf(
                "circles" to circlesList,
                "eyes" to eyesList
            )

        } catch (e: Exception) {
            Log.e("YoloV8View", "Error in detectFromFile", e)
            return emptyMap()
        } finally {
            // Safe cleanup
            try {
                if (originalBitmap != rotatedBitmap) originalBitmap?.recycle()
                rotatedBitmap?.recycle()
            } catch (e: Exception) {
                Log.e("YoloV8View", "Error cleaning up bitmaps", e)
            }
        }
    }
}