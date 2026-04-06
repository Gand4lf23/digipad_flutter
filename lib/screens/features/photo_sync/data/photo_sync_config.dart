import 'dart:convert';

/// Configuration model for photo sync connection.
/// Encapsulates all info needed to connect a CLIENT to a HOST.
class PhotoSyncConfig {
  final String ssid;
  final String password;
  final String hostIp;
  final int port;

  const PhotoSyncConfig({
    required this.ssid,
    required this.password,
    required this.hostIp,
    this.port = 8080,
  });

  /// Create from QR code JSON string.
  factory PhotoSyncConfig.fromQrData(String qrData) {
    final map = jsonDecode(qrData) as Map<String, dynamic>;
    return PhotoSyncConfig(
      ssid: map['ssid'] as String,
      password: map['password'] as String,
      hostIp: map['ip'] as String,
      port: (map['port'] as num?)?.toInt() ?? 8080,
    );
  }

  /// Convert to JSON string for QR code generation.
  String toQrData() {
    return jsonEncode({
      'ssid': ssid,
      'password': password,
      'ip': hostIp,
      'port': port,
    });
  }

  /// Create from SharedPreferences map.
  factory PhotoSyncConfig.fromMap(Map<String, dynamic> map) {
    return PhotoSyncConfig(
      ssid: map['ssid'] as String,
      password: map['password'] as String,
      hostIp: map['ip'] as String,
      port: (map['port'] as num?)?.toInt() ?? 8080,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ssid': ssid,
      'password': password,
      'ip': hostIp,
      'port': port,
    };
  }

  String get uploadUrl => 'http://$hostIp:$port/upload';

  @override
  String toString() =>
      'PhotoSyncConfig(ssid: $ssid, ip: $hostIp, port: $port)';
}
