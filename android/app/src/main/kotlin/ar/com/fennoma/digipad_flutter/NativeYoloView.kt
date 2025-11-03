package ar.com.fennoma.digipad_flutter

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView

class NativeYoloView(
    context: Context,
    args: Any?
) : PlatformView {

    private val yoloV8View: YoloV8View = YoloV8View(context)

    override fun getView(): View {
        return yoloV8View
    }

    override fun dispose() {
        // The YoloV8View's onDetachedFromWindow will handle disposal,
        // but calling it explicitly is good practice.
        yoloV8View.dispose()
    }
}