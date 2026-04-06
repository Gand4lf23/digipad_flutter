package ar.com.digipad

import ar.com.digipad.photosync.HotspotManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var hotspotManager: HotspotManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "native-left-view",
                NativeYoloViewFactory(flutterEngine.dartExecutor.binaryMessenger)
            )

        // Register Photo Sync platform channel
        hotspotManager = HotspotManager(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ar.com.digipad/photo_sync"
        ).setMethodCallHandler(hotspotManager)
    }

    override fun onDestroy() {
        hotspotManager?.dispose()
        super.onDestroy()
    }
}