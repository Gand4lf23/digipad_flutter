import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static const String _collectionName = 'device_activations';
  static const String _offlineInteractionsKey = 'offline_interactions_count';
  static const int _maxOfflineInteractions = 25;
  static const String _isApprovedKey = 'is_device_approved_locally';

  SharedPreferences? _prefs;
  Future<SharedPreferences> get _sharedPrefs async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  String? _cachedDeviceId;

  Future<bool> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  Future<int> getOfflineInteractionsCount() async {
    final prefs = await _sharedPrefs;
    return prefs.getInt(_offlineInteractionsKey) ?? 0;
  }

  Future<void> incrementOfflineInteractions() async {
    final prefs = await _sharedPrefs;
    int current = prefs.getInt(_offlineInteractionsKey) ?? 0;
    await prefs.setInt(_offlineInteractionsKey, current + 1);
  }

  Future<void> resetOfflineInteractions() async {
    final prefs = await _sharedPrefs;
    await prefs.setInt(_offlineInteractionsKey, 0);
  }

  bool isOfflineLimitReached(int count) {
    return count >= _maxOfflineInteractions;
  }

  Future<bool> isLocallyApproved() async {
    final prefs = await _sharedPrefs;
    return prefs.getBool(_isApprovedKey) ?? false;
  }

  Future<void> setLocallyApproved(bool approved) async {
    final prefs = await _sharedPrefs;
    await prefs.setBool(_isApprovedKey, approved);
  }

  Future<String> _getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      _cachedDeviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      _cachedDeviceId = iosInfo.identifierForVendor ?? 'unknown_ios_id';
    } else {
      _cachedDeviceId = 'unknown_device';
    }

    return _cachedDeviceId!;
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    late final PackageInfo packageInfo;
    AndroidDeviceInfo? androidInfo;
    IosDeviceInfo? iosInfo;

    final futures = <Future>[
      PackageInfo.fromPlatform().then((value) => packageInfo = value),
    ];

    if (Platform.isAndroid) {
      futures.add(_deviceInfo.androidInfo.then((value) => androidInfo = value));
    } else if (Platform.isIOS) {
      futures.add(_deviceInfo.iosInfo.then((value) => iosInfo = value));
    }

    await Future.wait(futures);

    Map<String, dynamic> deviceData = {
      'appVersion': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'platform': Platform.operatingSystem,
    };

    if (Platform.isAndroid && androidInfo != null) {
      deviceData.addAll({
        'brand': androidInfo!.brand,
        'model': androidInfo!.model,
        'device': androidInfo!.device,
        'version': androidInfo!.version.release,
        'sdkInt': androidInfo!.version.sdkInt,
        'manufacturer': androidInfo!.manufacturer,
      });
    } else if (Platform.isIOS && iosInfo != null) {
      deviceData.addAll({
        'name': iosInfo!.name,
        'systemName': iosInfo!.systemName,
        'systemVersion': iosInfo!.systemVersion,
        'model': iosInfo!.model,
        'localizedModel': iosInfo!.localizedModel,
        'isPhysicalDevice': iosInfo!.isPhysicalDevice,
      });
    }
    return deviceData;
  }

  Future<String?> _getIpAddress() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org'));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      // Ignore errors fetching IP
    }
    return null;
  }

  Future<Position?> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>?> getActivationStream() async* {
    final deviceId = await _getDeviceId();
    yield* _firestore
        .collection(_collectionName)
        .where('deviceId', isEqualTo: deviceId)
        .limit(1)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : null,
        );
  }

  Future<bool> checkApprovalStatus() async {
    try {
      final deviceId = await _getDeviceId();
      final query = await _firestore
          .collection(_collectionName)
          .where('deviceId', isEqualTo: deviceId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        _updateLastAccess(query.docs.first.reference);
        return data['isApproved'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateLastAccess(DocumentReference ref) async {
    try {
      await ref.update({'lastAccess': FieldValue.serverTimestamp()});
    } catch (_) {}
  }

  /// Requests activation for the device.
  Future<void> requestActivation(String email) async {
    final deviceId = await _getDeviceId();

    // OPTIMIZATION: Removed the emailQuery block. Since an email CAN have
    // multiple devices, throwing an exception here was incorrect.
    // Removing it fixes the bug AND saves 1 full Firestore Read query!

    // Check if *this device* already has a record
    final deviceQuery = await _firestore
        .collection(_collectionName)
        .where('deviceId', isEqualTo: deviceId)
        .limit(
          1,
        ) // OPTIMIZATION: Added limit(1) to save Firestore reads/bandwidth
        .get();

    if (deviceQuery.docs.isNotEmpty) {
      final existingDoc = deviceQuery.docs.first;
      final existingData = existingDoc.data();

      if (existingData['email'] == email) {
        // Same email, same device. Update timestamp.
        await existingDoc.reference.update({
          'lastRequestDate': FieldValue.serverTimestamp(),
          'lastAccess': FieldValue.serverTimestamp(),
        });
        return; // Exits early!
      } else {
        // Different email for this device. Delete old doc.
        await existingDoc.reference.delete();
      }
    }

    // New doc ID format allows for email_deviceId combination naturally
    final docId = '${email}_$deviceId';
    final docRef = _firestore.collection(_collectionName).doc(docId);

    // Fetch Device Info, IP, and Location concurrently
    late final Map<String, dynamic> deviceInfo;
    late final String? ipAddress;
    late final Position? position;

    await Future.wait([
      _getDeviceInfo().then((value) => deviceInfo = value),
      _getIpAddress().then((value) => ipAddress = value),
      _getLocation().then((value) => position = value),
    ]);

    final data = {
      'deviceId': deviceId,
      'email': email,
      'deviceInfo': deviceInfo,
      'ipAddress': ipAddress,
      'location': position != null
          ? {'latitude': position?.latitude, 'longitude': position?.longitude}
          : null,
      'isApproved': false,
      'requestDate': FieldValue.serverTimestamp(),
      'lastAccess': FieldValue.serverTimestamp(),
    };

    await docRef.set(data);
  }
}
