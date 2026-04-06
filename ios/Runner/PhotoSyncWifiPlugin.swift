import Foundation
import Flutter
import NetworkExtension

/// iOS plugin for connecting to WiFi networks via NEHotspotConfiguration.
/// Used by CLIENT devices to join the HOST's hotspot.
class PhotoSyncWifiPlugin: NSObject, FlutterPlugin {
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "ar.com.digipad/photo_sync",
            binaryMessenger: registrar.messenger()
        )
        let instance = PhotoSyncWifiPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "connectToWifi":
            guard let args = call.arguments as? [String: Any],
                  let ssid = args["ssid"] as? String,
                  let password = args["password"] as? String else {
                result(FlutterError(code: "INVALID_ARGS",
                                    message: "SSID and password required",
                                    details: nil))
                return
            }
            connectToWifi(ssid: ssid, password: password, result: result)
            
        case "startHotspot":
            // iOS cannot create hotspots programmatically
            result(FlutterError(code: "UNSUPPORTED",
                                message: "iOS cannot create hotspots. Only Android can be HOST.",
                                details: nil))
            
        case "stopHotspot":
            result(FlutterError(code: "UNSUPPORTED",
                                message: "iOS cannot manage hotspots.",
                                details: nil))
            
        case "getLocalIpAddress":
            let ip = getLocalIPAddress()
            if let ip = ip {
                result(ip)
            } else {
                result(FlutterError(code: "NO_IP",
                                    message: "Could not determine IP",
                                    details: nil))
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func connectToWifi(ssid: String, password: String, result: @escaping FlutterResult) {
        let configuration = NEHotspotConfiguration(
            ssid: ssid,
            passphrase: password,
            isWEP: false
        )
        configuration.joinOnce = false
        
        NEHotspotConfigurationManager.shared.apply(configuration) { error in
            if let error = error as NSError? {
                if error.domain == NEHotspotConfigurationErrorDomain {
                    switch error.code {
                    case NEHotspotConfigurationError.alreadyAssociated.rawValue:
                        // Already connected — success
                        print("[PhotoSyncWifi] Already connected to \(ssid)")
                        result(true)
                    case NEHotspotConfigurationError.userDenied.rawValue:
                        print("[PhotoSyncWifi] User denied WiFi join")
                        result(false)
                    default:
                        print("[PhotoSyncWifi] WiFi error: \(error.localizedDescription)")
                        result(false)
                    }
                } else {
                    print("[PhotoSyncWifi] Unknown error: \(error.localizedDescription)")
                    result(false)
                }
            } else {
                print("[PhotoSyncWifi] Connected to \(ssid)")
                result(true)
            }
        }
    }
    
    private func getLocalIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return nil
        }
        
        var ptr = firstAddr
        while true {
            let interface_ = ptr.pointee
            let addrFamily = interface_.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: interface_.ifa_name)
                if name == "en0" || name == "en1" || name.hasPrefix("bridge") {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface_.ifa_addr, socklen_t(interface_.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, 0, NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
            
            guard let next = interface_.ifa_next else { break }
            ptr = next
        }
        
        freeifaddrs(ifaddr)
        return address
    }
}
