import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'photo_sync_config.dart';

/// Persists the last-used PhotoSyncConfig so the CLIENT
/// can auto-reconnect without scanning QR again.
class PhotoSyncPreferences {
  static const _key = 'photo_sync_config';

  /// Save config for future auto-reconnect.
  Future<void> saveConfig(PhotoSyncConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(config.toMap()));
  }

  /// Load previously saved config (null if none).
  Future<PhotoSyncConfig?> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PhotoSyncConfig.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  /// Clear saved config.
  Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Check if a config exists.
  Future<bool> hasConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }
}
