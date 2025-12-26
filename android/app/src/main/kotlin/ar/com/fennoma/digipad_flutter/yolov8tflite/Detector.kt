package ar.com.digipad.yolov8tflite

import android.content.Context
import android.graphics.Bitmap
import android.os.SystemClock
import org.tensorflow.lite.DataType
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.support.common.FileUtil
import org.tensorflow.lite.support.common.ops.CastOp
import org.tensorflow.lite.support.common.ops.NormalizeOp
import org.tensorflow.lite.support.image.ImageProcessor
import org.tensorflow.lite.support.image.TensorImage
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStream
import java.io.InputStreamReader
import kotlin.math.max
import kotlin.math.min

class Detector(
    private val context: Context,
    private val modelPath: String,
    private val labelPath: String,
    private val detectorListener: DetectorListener
) {

    private var interpreter: Interpreter? = null
    private var labels = mutableListOf<String>()

    private var tensorWidth = 0
    private var tensorHeight = 0
    private var numChannel = 0
    private var numElements = 0
    
    // Automatic Type Detection
    private var inputDataType: DataType = DataType.FLOAT32
    private var outputDataType: DataType = DataType.FLOAT32

    private var imageProcessor: ImageProcessor? = null

    fun setup() {
        try {
            // Carga directa desde la raíz de assets de Android
            val model = FileUtil.loadMappedFile(context, "model3.tflite") 
            val options = Interpreter.Options()
            options.numThreads = 4
            interpreter = Interpreter(model, options)

            val inputTensor = interpreter?.getInputTensor(0) ?: return
            val outputTensor = interpreter?.getOutputTensor(0) ?: return

            // 1. AUTO-DETECT TENSOR TYPES
            inputDataType = inputTensor.dataType()
            outputDataType = outputTensor.dataType()

            val inputShape = inputTensor.shape()
            val outputShape = outputTensor.shape()

            tensorWidth = inputShape[1]
            tensorHeight = inputShape[2]
            numChannel = outputShape[1]
            numElements = outputShape[2]

            // 2. BUILD PROCESSOR
            val builder = ImageProcessor.Builder()
                .add(CastOp(inputDataType))

            if (inputDataType == DataType.FLOAT32) {
                builder.add(NormalizeOp(0f, 255f))
            }
            
            imageProcessor = builder.build()

            // Cargar etiquetas
            loadLabels("labels.txt")

        } catch (e: Exception) {
            e.printStackTrace()
            // Importante: Si falla, verás el error en el logcat filtrando por "System.err"
        }
    }

    private fun loadLabels(path: String) {
        try {
            val inputStream: InputStream = context.assets.open(path)
            val reader = BufferedReader(InputStreamReader(inputStream))
            var line: String? = reader.readLine()
            while (line != null && line != "") {
                labels.add(line)
                line = reader.readLine()
            }
            reader.close()
            inputStream.close()
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }

    fun clear() {
        interpreter?.close()
        interpreter = null
    }

    fun detect(frame: Bitmap) {
        if (interpreter == null) return

        var inferenceTime = SystemClock.uptimeMillis()
        val boxes = detectSync(frame)
        inferenceTime = SystemClock.uptimeMillis() - inferenceTime

        if (boxes.isEmpty()) {
            detectorListener.onEmptyDetect()
            return
        }

        detectorListener.onDetect(boxes, inferenceTime)
    }

    fun detectSync(frame: Bitmap): List<BoundingBox> {
        interpreter ?: return emptyList()
        if (tensorWidth == 0 || tensorHeight == 0) return emptyList()

        val resizedBitmap = Bitmap.createScaledBitmap(frame, tensorWidth, tensorHeight, false)
        
        // Load image into the correct Tensor Type (auto-detected)
        val tensorImage = TensorImage(inputDataType)
        tensorImage.load(resizedBitmap)
        
        val processedImage = imageProcessor?.process(tensorImage) ?: return emptyList()
        val imageBuffer = processedImage.buffer

        // Prepare output buffer
        val outputBuffer = TensorBuffer.createFixedSize(intArrayOf(1, numChannel, numElements), outputDataType)
        
        interpreter?.run(imageBuffer, outputBuffer.buffer)

        // Decode results (Handle INT8 output if necessary)
        val floats = outputBuffer.floatArray // TensorBuffer handles conversion automatically
        
        val allBoxes = bestBox(floats) ?: return emptyList()

        // 3. APPLY "4 CIRCLES, 2 EYES" RULE
        return filterStructuredScene(allBoxes)
    }

    private fun bestBox(array: FloatArray): List<BoundingBox>? {
        val boundingBoxes = mutableListOf<BoundingBox>()

        for (c in 0 until numElements) {
            var maxConf = -1.0f
            var maxIdx = -1
            var j = 4
            var arrayIdx = c + numElements * j
            
            while (j < numChannel){
                if (array[arrayIdx] > maxConf) {
                    maxConf = array[arrayIdx]
                    maxIdx = j - 4
                }
                j++
                arrayIdx += numElements
            }

            if (maxConf > CONFIDENCE_THRESHOLD) {
                val clsName = labels.getOrElse(maxIdx) { "Unknown" }
                val cx = array[c]
                val cy = array[c + numElements]
                val w = array[c + numElements * 2]
                val h = array[c + numElements * 3]
                val x1 = cx - (w/2F)
                val y1 = cy - (h/2F)
                val x2 = cx + (w/2F)
                val y2 = cy + (h/2F)
                
                if (x1 in 0F..1F && y1 in 0F..1F && x2 in 0F..1F && y2 in 0F..1F) {
                    boundingBoxes.add(
                        BoundingBox(
                            x1 = x1, y1 = y1, x2 = x2, y2 = y2,
                            cx = cx, cy = cy, w = w, h = h,
                            cnf = maxConf, cls = maxIdx, clsName = clsName
                        )
                    )
                }
            }
        }

        if (boundingBoxes.isEmpty()) return null

        return applyNMS(boundingBoxes)
    }

    // Logic to enforce exactly 4 circles and 2 eyes
    private fun filterStructuredScene(boxes: List<BoundingBox>): List<BoundingBox> {
        val circles = boxes.filter { it.clsName.contains("circle", ignoreCase = true) }
            .sortedByDescending { it.cnf }
            .take(4) // Only top 4 circles

        val eyes = boxes.filter { it.clsName.contains("eye", ignoreCase = true) }
            .sortedByDescending { it.cnf }
            .take(2) // Only top 2 eyes

        // If you have other classes (like glasses frame), add them here:
        val others = boxes.filter { 
            !it.clsName.contains("circle", ignoreCase = true) && 
            !it.clsName.contains("eye", ignoreCase = true) 
        }

        return circles + eyes + others
    }

    private fun applyNMS(boxes: List<BoundingBox>) : MutableList<BoundingBox> {
        val sortedBoxes = boxes.sortedByDescending { it.cnf }.toMutableList()
        val selectedBoxes = mutableListOf<BoundingBox>()

        while(sortedBoxes.isNotEmpty()) {
            val first = sortedBoxes.first()
            selectedBoxes.add(first)
            sortedBoxes.remove(first)

            val iterator = sortedBoxes.iterator()
            while (iterator.hasNext()) {
                val nextBox = iterator.next()
                val iou = calculateIoU(first, nextBox)
                if (iou >= IOU_THRESHOLD) {
                    iterator.remove()
                }
            }
        }
        return selectedBoxes
    }

    private fun calculateIoU(box1: BoundingBox, box2: BoundingBox): Float {
        val x1 = max(box1.x1, box2.x1)
        val y1 = max(box1.y1, box2.y1)
        val x2 = min(box1.x2, box2.x2)
        val y2 = min(box1.y2, box2.y2)
        val intersectionArea = max(0F, x2 - x1) * max(0F, y2 - y1)
        val box1Area = box1.w * box1.h
        val box2Area = box2.w * box2.h
        return intersectionArea / (box1Area + box2Area - intersectionArea)
    }

    interface DetectorListener {
        fun onEmptyDetect()
        fun onDetect(boundingBoxes: List<BoundingBox>, inferenceTime: Long)
    }

    companion object {
        private const val CONFIDENCE_THRESHOLD = 0.70F
        private const val IOU_THRESHOLD = 0.5F
    }
}