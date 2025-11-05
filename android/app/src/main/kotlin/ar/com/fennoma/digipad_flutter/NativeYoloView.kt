package ar.com.fennoma.digipad_flutter

import android.content.Context
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

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
        yoloV8View.onDetections = { boxes, time ->
            val list = boxes.map { b ->
                mapOf(
                    "x1" to b.x1,
                    "y1" to b.y1,
                    "x2" to b.x2,
                    "y2" to b.y2,
                    "cx" to b.cx,
                    "cy" to b.cy,
                    "w" to b.w,
                    "h" to b.h,
                    "cnf" to b.cnf,
                    "cls" to b.cls,
                    "clsName" to b.clsName
                )
            }
            channel.invokeMethod("onDetections", mapOf("boxes" to list, "time" to time))
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