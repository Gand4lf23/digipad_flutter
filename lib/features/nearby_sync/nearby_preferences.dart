import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last connected Totem endpoint so the client can
/// auto-reconnect without re-scanning or re-tapping.
class NearbyPreferences {
  static const _kEndpointId = 'nearby_last_endpoint_id';
  static const _kEndpointName = 'nearby_last_endpoint_name';

  Future<void> saveEndpoint(String id, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kEndpointId, id);
      await prefs.setString(_kEndpointName, name);
      debugPrint('[NearbyPreferences] Saved endpoint: $name ($id)');
    } catch (e) {
      debugPrint('[NearbyPreferences] Save error: $e');
    }
  }

  Future<({String id, String name})?> loadEndpoint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_kEndpointId);
      final name = prefs.getString(_kEndpointName);
      if (id != null && id.isNotEmpty) {
        return (id: id, name: name ?? id);
      }
    } catch (e) {
      debugPrint('[NearbyPreferences] Load error: $e');
    }
    return null;
  }

  Future<void> clearEndpoint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kEndpointId);
      await prefs.remove(_kEndpointName);
      debugPrint('[NearbyPreferences] Cleared saved endpoint');
    } catch (e) {
      debugPrint('[NearbyPreferences] Clear error: $e');
    }
  }
}
