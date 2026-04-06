import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform channel abstraction for native hotspot and WiFi operations.
/// Android: startLocalOnlyHotspot, get config
/// iOS: join WiFi network via NEHotspotConfiguration
class PhotoSyncPlatform {
  static const _channel = MethodChannel('ar.com.digipad/photo_sync');

  /// [Android HOST only] Start a local-only hotspot.
  /// Returns a map with {ssid, password, gateway} on success.
  Future<Map<String, String>?> startHotspot() async {
    if (!Platform.isAndroid) {
      debugPrint('[PhotoSyncPlatform] startHotspot only available on Android');
      return null;
    }
    try {
      final result = await _channel.invokeMapMethod<String, String>('startHotspot');
      debugPrint('[PhotoSyncPlatform] Hotspot started: $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint('[PhotoSyncPlatform] Failed to start hotspot: ${e.message}');
      return null;
    }
  }

  /// [Android HOST only] Stop the local-only hotspot.
  Future<void> stopHotspot() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('stopHotspot');
      debugPrint('[PhotoSyncPlatform] Hotspot stopped');
    } on PlatformException catch (e) {
      debugPrint('[PhotoSyncPlatform] Failed to stop hotspot: ${e.message}');
    }
  }

  /// [Android HOST only] Get the device's local IP address on the hotspot.
  Future<String?> getLocalIpAddress() async {
    if (!Platform.isAndroid) return null;
    try {
      final ip = await _channel.invokeMethod<String>('getLocalIpAddress');
      debugPrint('[PhotoSyncPlatform] Local IP: $ip');
      return ip;
    } on PlatformException catch (e) {
      debugPrint('[PhotoSyncPlatform] Failed to get IP: ${e.message}');
      return null;
    }
  }

  /// [iOS CLIENT only] Connect to a WiFi network.
  /// Uses NEHotspotConfiguration on iOS.
  Future<bool> connectToWifi(String ssid, String password) async {
    if (Platform.isIOS) {
      try {
        final result = await _channel.invokeMethod<bool>('connectToWifi', {
          'ssid': ssid,
          'password': password,
        });
        debugPrint('[PhotoSyncPlatform] iOS WiFi connect result: $result');
        return result ?? false;
      } on PlatformException catch (e) {
        debugPrint('[PhotoSyncPlatform] iOS WiFi connect failed: ${e.message}');
        return false;
      }
    } else if (Platform.isAndroid) {
      // On Android CLIENT, we use wifi_iot or system settings.
      // For now, instruct user to connect manually or use wifi_iot.
      try {
        final result = await _channel.invokeMethod<bool>('connectToWifi', {
          'ssid': ssid,
          'password': password,
        });
        return result ?? false;
      } on PlatformException catch (e) {
        debugPrint(
            '[PhotoSyncPlatform] Android WiFi connect failed: ${e.message}');
        return false;
      }
    }
    return false;
  }

  /// Get the local IP address using Dart's NetworkInterface (cross-platform fallback).
  static Future<String?> getLocalIpDart() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final interface_ in interfaces) {
        for (final addr in interface_.addresses) {
          if (!addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      debugPrint('[PhotoSyncPlatform] Dart IP lookup failed: $e');
    }
    return null;
  }
}
