package ar.com.fennoma.digipad_flutter

import android.content.Context
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import kotlin.math.max

class NativeYoloView(
    context: Context,
    messenger: BinaryMessenger,
    id: Int,
    args: Any?
) : PlatformView, MethodChannel.MethodCallHandler {

    private val yoloV8View: YoloV8View = YoloV8View(context)
    private val channel = MethodChannel(messenger, "native-left-view/$id")

    init {
        channel.setMethodCallHandler(this)
        
        yoloV8View.onDetections = { boxes, _ ->
            val vWidth = yoloV8View.width.toFloat()
            val vHeight = yoloV8View.height.toFloat()

            if (vWidth > 0 && vHeight > 0 && boxes.isNotEmpty()) {
                
                // 1. SMART CHECK: Are coordinates already normalized?
                // We check the maximum X value in the batch. 
                // If the max X is <= 1.0, it's normalized. If it's > 1.0 (e.g. 500), it's pixels.
                val maxVal = boxes.maxOfOrNull { it.cx } ?: 0f
                val isAlreadyNormalized = maxVal <= 1.0f

                val circlesList = ArrayList<Map<String, Float>>()
                val eyesList = ArrayList<Map<String, Float>>()

                for (b in boxes) {
                    // 2. Normalize if needed
                    val normX = if (isAlreadyNormalized) b.cx else (b.cx / vWidth)
                    val normY = if (isAlreadyNormalized) b.cy else (b.cy / vHeight)
                    
                    val point = mapOf("x" to normX, "y" to normY)

                    val name = b.clsName ?: ""
                    if (name.contains("circle", ignoreCase = true)) {
                        circlesList.add(point)
                    } else if (name.contains("eye", ignoreCase = true)) {
                        eyesList.add(point)
                    }
                }

                val resultData = mapOf(
                    "circles" to circlesList,
                    "eyes" to eyesList,
                    "isNormalized" to isAlreadyNormalized // Optional debug info
                )

                channel.invokeMethod("onDetections", resultData)
            }
        }
    }

    override fun getView(): View = yoloV8View

    override fun dispose() {
        channel.setMethodCallHandler(null)
        yoloV8View.dispose()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "capturePhoto" -> {
                yoloV8View.capturePhoto { path, error ->
                    if (error != null) result.error("capture_error", error, null)
                    else result.success(path)
                }
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