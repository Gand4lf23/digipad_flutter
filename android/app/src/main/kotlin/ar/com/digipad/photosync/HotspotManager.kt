package ar.com.digipad.photosync

import android.content.Context
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.Inet4Address
import java.net.NetworkInterface

/**
 * Manages the Android local-only hotspot for photo sync HOST mode.
 * Uses WifiManager.startLocalOnlyHotspot() which does not require root
 * and generates a random SSID/password automatically.
 */
class HotspotManager(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "HotspotManager"
    }

    private var hotspotReservation: WifiManager.LocalOnlyHotspotReservation? = null
    private val wifiManager: WifiManager =
        context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startHotspot" -> startHotspot(result)
            "stopHotspot" -> stopHotspot(result)
            "getLocalIpAddress" -> getLocalIpAddress(result)
            "connectToWifi" -> connectToWifi(call, result)
            else -> result.notImplemented()
        }
    }

    private fun startHotspot(result: MethodChannel.Result) {
        try {
            if (hotspotReservation != null) {
                // Already running, return current config
                val config = hotspotReservation!!.wifiConfiguration
                if (config != null) {
                    val map = HashMap<String, String>()
                    map["ssid"] = config.SSID ?: ""
                    map["password"] = config.preSharedKey ?: ""
                    map["gateway"] = getGatewayIp() ?: "192.168.43.1"
                    result.success(map)
                    return
                }
            }

            wifiManager.startLocalOnlyHotspot(object : WifiManager.LocalOnlyHotspotCallback() {
                override fun onStarted(reservation: WifiManager.LocalOnlyHotspotReservation?) {
                    hotspotReservation = reservation
                    val config = reservation?.wifiConfiguration

                    if (config != null) {
                        var retries = 0
                        fun checkIpAndReturn() {
                            val ip = getGatewayIp()
                            val isValid = ip != null && ip != "0.0.0.0" && ip != "127.0.0.1"
                            // If we find a valid IP, or we tried enough times (10 times = 5 seconds)
                            if (isValid || retries > 10) {
                                val map = HashMap<String, String>()
                                map["ssid"] = config.SSID ?: ""
                                map["password"] = config.preSharedKey ?: ""
                                map["gateway"] = ip ?: "192.168.43.1"
                                Log.d(TAG, "Hotspot started: SSID=${config.SSID}, IP=$ip")
                                result.success(map)
                            } else {
                                retries++
                                Handler(Looper.getMainLooper()).postDelayed(::checkIpAndReturn, 500)
                            }
                        }
                        checkIpAndReturn()
                    } else {
                        result.error("NO_CONFIG", "Hotspot started but no config available", null)
                    }
                }

                override fun onStopped() {
                    Log.d(TAG, "Hotspot stopped callback")
                    hotspotReservation = null
                }

                override fun onFailed(reason: Int) {
                    Log.e(TAG, "Hotspot failed with reason: $reason")
                    result.error("HOTSPOT_FAILED", "Failed to start hotspot, reason: $reason", null)
                }
            }, Handler(Looper.getMainLooper()))
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException: ${e.message}")
            result.error("PERMISSION_DENIED", "Location permission required for hotspot", e.message)
        } catch (e: Exception) {
            Log.e(TAG, "Exception: ${e.message}")
            result.error("HOTSPOT_ERROR", e.message, null)
        }
    }

    private fun stopHotspot(result: MethodChannel.Result) {
        try {
            hotspotReservation?.close()
            hotspotReservation = null
            Log.d(TAG, "Hotspot stopped")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping hotspot: ${e.message}")
            result.error("STOP_ERROR", e.message, null)
        }
    }

    private fun getLocalIpAddress(result: MethodChannel.Result) {
        val ip = getGatewayIp()
        if (ip != null) {
            result.success(ip)
        } else {
            result.error("NO_IP", "Could not determine local IP address", null)
        }
    }

    private fun connectToWifi(call: MethodCall, result: MethodChannel.Result) {
        val ssid = call.argument<String>("ssid")
        val password = call.argument<String>("password")

        if (ssid == null || password == null) {
            result.error("INVALID_ARGS", "SSID and password required", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10+ uses NetworkSpecifier
            try {
                val specifier = android.net.wifi.WifiNetworkSpecifier.Builder()
                    .setSsid(ssid)
                    .setWpa2Passphrase(password)
                    .build()

                val networkRequest = android.net.NetworkRequest.Builder()
                    .addTransportType(android.net.NetworkCapabilities.TRANSPORT_WIFI)
                    .setNetworkSpecifier(specifier)
                    .build()

                val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as android.net.ConnectivityManager
                connectivityManager.requestNetwork(networkRequest, object : android.net.ConnectivityManager.NetworkCallback() {
                    override fun onAvailable(network: android.net.Network) {
                        connectivityManager.bindProcessToNetwork(network)
                        Log.d(TAG, "Connected to WiFi: $ssid")
                        Handler(Looper.getMainLooper()).post {
                            result.success(true)
                        }
                    }

                    override fun onUnavailable() {
                        Log.e(TAG, "WiFi unavailable: $ssid")
                        Handler(Looper.getMainLooper()).post {
                            result.success(false)
                        }
                    }
                })
            } catch (e: Exception) {
                Log.e(TAG, "WiFi connect error: ${e.message}")
                result.success(false)
            }
        } else {
            // Pre-Android 10
            @Suppress("DEPRECATION")
            val wifiConfig = android.net.wifi.WifiConfiguration().apply {
                SSID = "\"$ssid\""
                preSharedKey = "\"$password\""
            }
            @Suppress("DEPRECATION")
            val networkId = wifiManager.addNetwork(wifiConfig)
            if (networkId != -1) {
                @Suppress("DEPRECATION")
                wifiManager.enableNetwork(networkId, true)
                result.success(true)
            } else {
                result.success(false)
            }
        }
    }

    private fun getGatewayIp(): String? {
        try {
            val interfaces = NetworkInterface.getNetworkInterfaces()
            while (interfaces.hasMoreElements()) {
                val networkInterface = interfaces.nextElement()
                if (networkInterface.isLoopback || !networkInterface.isUp) continue
                
                // Prefer swlan/ap/wlan interfaces for hotspot
                val name = networkInterface.name.lowercase()
                if (name.contains("swlan") || name.contains("ap") || 
                    name.contains("wlan") || name.contains("eth")) {
                    for (addr in networkInterface.inetAddresses) {
                        if (addr is Inet4Address && !addr.isLoopbackAddress && addr.hostAddress != "0.0.0.0" && addr.hostAddress != "127.0.0.1") {
                            return addr.hostAddress
                        }
                    }
                }
            }
            // Fallback: return any non-loopback IPv4
            val interfaces2 = NetworkInterface.getNetworkInterfaces()
            while (interfaces2.hasMoreElements()) {
                val networkInterface = interfaces2.nextElement()
                if (networkInterface.isLoopback || !networkInterface.isUp) continue
                for (addr in networkInterface.inetAddresses) {
                    if (addr is Inet4Address && !addr.isLoopbackAddress && addr.hostAddress != "0.0.0.0" && addr.hostAddress != "127.0.0.1") {
                        return addr.hostAddress
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting IP: ${e.message}")
        }
        return null
    }

    fun dispose() {
        try {
            hotspotReservation?.close()
            hotspotReservation = null
        } catch (_: Exception) {}
    }
}
