package ar.com.digipad

import android.content.Context
import android.graphics.BitmapFactory
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import ar.com.digipad.yolov8tflite.BoundingBox

class NativeYoloView(
    context: Context,
    messenger: BinaryMessenger,
    id: Int,
    args: Any?
) : PlatformView, MethodChannel.MethodCallHandler {

    private val yoloV8View: YoloV8View = YoloV8View(context)
    private val channel = MethodChannel(messenger, "native-left-view/$id")
    private var streamDetections: Boolean = false
    private var lastSendTime: Long = 0
    private var throttleMs: Long = 50L // Cap at ~20 FPS
    private var latestRawBoxes: List<BoundingBox> = emptyList()

    init {
        channel.setMethodCallHandler(this)
        
        yoloV8View.onDetections = { boxes, _ ->
            // 1. Always store locally (Fastest)
            latestRawBoxes = boxes
            val vWidth = yoloV8View.width.toFloat()
            val vHeight = yoloV8View.height.toFloat()

            if (vWidth > 0 && vHeight > 0) {
                // 2. Only stream to Flutter if requested AND throttled
                if (streamDetections) {
                    val currentTime = System.currentTimeMillis()
                    if (currentTime - lastSendTime >= throttleMs) {
                        lastSendTime = currentTime
                        if (boxes.isNotEmpty()) {
                            val data = processBoxesToFlatArray(boxes, vWidth, vHeight)
                            channel.invokeMethod("onDetections", data)
                        }
                    }
                }
            }
        }
    }

    /**
     * Optimization: Flattens data to Double Arrays [x1, y1, x2, y2...]
     * This is much faster to serialize over MethodChannel than List<Map>.
     */
    private fun processBoxesToFlatArray(boxes: List<BoundingBox>, vWidth: Float, vHeight: Float): Map<String, Any> {
        val maxVal = boxes.maxOfOrNull { it.cx } ?: 0f
        val isAlreadyNormalized = maxVal <= 1.0f

        // Use standard ArrayLists for speed, convert to DoubleArray at end
        val circlesList = ArrayList<Double>()
        val eyesList = ArrayList<Double>()

        for (b in boxes) {
            val normX = if (isAlreadyNormalized) b.cx else (b.cx / vWidth)
            val normY = if (isAlreadyNormalized) b.cy else (b.cy / vHeight)
            
            val name = b.clsName ?: ""
            if (name.contains("circle", ignoreCase = true)) {
                circlesList.add(normX.toDouble())
                circlesList.add(normY.toDouble())
            } else if (name.contains("eye", ignoreCase = true)) {
                eyesList.add(normX.toDouble())
                eyesList.add(normY.toDouble())
            }
        }

        return mapOf(
            "circles" to circlesList.toDoubleArray(),
            "eyes" to eyesList.toDoubleArray()
        )
    }

    override fun getView(): View = yoloV8View

    override fun dispose() {
        channel.setMethodCallHandler(null)
        yoloV8View.dispose()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "detectFromImage" -> {
                val path = call.argument<String>("path")
                if (path != null) {
                    // Call the new function in the view
                    val detections = yoloV8View.detectFromFile(path)
                    result.success(detections)
                } else {
                    result.error("INVALID_PATH", "Path was null", null)
                }
            }
            "capturePhoto" -> {
                yoloV8View.capturePhoto { path, error ->
                    if (error != null) {
                        result.error("capture_error", error, null)
                    } else {
                        val currentData = processBoxesToFlatArray(
                            latestRawBoxes, 
                            yoloV8View.width.toFloat(), 
                            yoloV8View.height.toFloat()
                        )
                        
                        val response = mapOf(
                            "path" to path,
                            "detections" to currentData
                        )
                        result.success(response)
                    }
                }
            }
            "setStreamDetections" -> {
                streamDetections = call.argument<Boolean>("enabled") ?: false
                throttleMs = (call.argument<Int>("throttleMs") ?: 50).toLong()
                result.success(null)
            }
            "setTorch" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                yoloV8View.setTorch(enabled)
                result.success(null)
            }
            "setDetectionEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                yoloV8View.setDetectionEnabled(enabled)
                result.success(null)
            }
            "setFrontCamera" -> {
                val front = call.argument<Boolean>("front") ?: false
                yoloV8View.switchCamera(front)
                result.success(null)
            }
            "setOverlayVisible" -> {
                val visible = call.argument<Boolean>("visible") ?: true
                yoloV8View.setOverlayVisible(visible)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}