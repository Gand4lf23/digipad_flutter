package ar.com.digipad

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class NativeYoloView(
    context: Context,
    messenger: BinaryMessenger,
    id: Int,
    args: Any?
) : PlatformView, MethodChannel.MethodCallHandler {

    private val yoloV8View: YoloV8View = YoloV8View(context)
    private val channel = MethodChannel(messenger, "native-left-view/$id")
    private val detectionExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    init {
        channel.setMethodCallHandler(this)
    }

    override fun getView(): View = yoloV8View

    override fun dispose() {
        detectionExecutor.shutdown()
        channel.setMethodCallHandler(null)
        yoloV8View.dispose()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "detectFromImage" -> {
                val path = call.argument<String>("path")
                if (path != null) {
                    try {
                        detectionExecutor.execute {
                            val detections = try {
                                yoloV8View.detectFromFile(path)
                            } catch (e: Throwable) {
                                android.util.Log.e("NativeYoloView", "detectFromFile error", e)
                                emptyMap<String, Any>()
                            }
                            mainHandler.post { result.success(detections) }
                        }
                    } catch (e: Exception) {
                        // Executor shut down (view disposed during lifecycle change) — return empty.
                        android.util.Log.e("NativeYoloView", "Executor rejected detectFromImage", e)
                        result.success(emptyMap<String, Any>())
                    }
                } else {
                    result.error("INVALID_PATH", "Path was null", null)
                }
            }
            "capturePhoto" -> {
                yoloV8View.capturePhoto { path, error ->
                    if (error != null) {
                        result.error("capture_error", error, null)
                    } else {
                        result.success(mapOf("path" to path))
                    }
                }
            }
            "setTorch" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                yoloV8View.setTorch(enabled)
                result.success(null)
            }
            "setFrontCamera" -> {
                val front = call.argument<Boolean>("front") ?: false
                yoloV8View.switchCamera(front)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}