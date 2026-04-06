import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let nativeFactory = NativeYoloViewFactory(messenger: controller.binaryMessenger)
    
    registrar(forPlugin: "<DigipadFlutterPlugin>")?.register(
        nativeFactory,
        withId: "native-left-view"
    )
    
    // Register Photo Sync WiFi plugin
    PhotoSyncWifiPlugin.register(with: registrar(forPlugin: "PhotoSyncWifiPlugin")!)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}