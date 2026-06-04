import 'package:flutter/services.dart';

class DeviceCapabilities {
  final bool isAndroidTV;
  final bool hasBluetooth;
  final bool hasBle;
  final bool hasWifiDirect;
  final bool isLocationEnabled;
  final bool isBluetoothEnabled;
  final bool isWifiEnabled;

  DeviceCapabilities({
    required this.isAndroidTV,
    required this.hasBluetooth,
    required this.hasBle,
    required this.hasWifiDirect,
    required this.isLocationEnabled,
    required this.isBluetoothEnabled,
    required this.isWifiEnabled,
  });

  /// If the device doesn't have BLE or WiFi Direct, we cannot rely on Nearby Connections.
  bool get supportsNearby => hasBle && hasWifiDirect;
}

class CapabilitiesService {
  static const _channel = MethodChannel('ar.com.digipad.photosync/capabilities');

  static Future<DeviceCapabilities> getCapabilities() async {
    final caps = await _channel.invokeMapMethod<String, dynamic>('getCapabilities') ?? {};
    final isLocationEnabled = await _channel.invokeMethod<bool>('isLocationEnabled') ?? false;
    final isBluetoothEnabled = await _channel.invokeMethod<bool>('isBluetoothEnabled') ?? false;
    final isWifiEnabled = await _channel.invokeMethod<bool>('isWifiEnabled') ?? false;

    return DeviceCapabilities(
      isAndroidTV: caps['isAndroidTV'] ?? false,
      hasBluetooth: caps['hasBluetooth'] ?? false,
      hasBle: caps['hasBle'] ?? false,
      hasWifiDirect: caps['hasWifiDirect'] ?? false,
      isLocationEnabled: isLocationEnabled,
      isBluetoothEnabled: isBluetoothEnabled,
      isWifiEnabled: isWifiEnabled,
    );
  }

  static Future<void> startForegroundService() async {
    await _channel.invokeMethod('startForegroundService');
  }

  static Future<void> stopForegroundService() async {
    await _channel.invokeMethod('stopForegroundService');
  }
}
