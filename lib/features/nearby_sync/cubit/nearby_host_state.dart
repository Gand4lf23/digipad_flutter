import 'package:flutter/foundation.dart';

/// States for the TÓTEM (host) device using Nearby Connections.
@immutable
abstract class NearbyHostState {
  const NearbyHostState();
}

/// Idle — advertising not started.
class NearbyHostIdle extends NearbyHostState {
  const NearbyHostIdle();
}

/// Advertising — waiting for clients to discover and connect.
class NearbyHostAdvertising extends NearbyHostState {
  final List<String> connectedClientIds;
  final int photoCount;

  const NearbyHostAdvertising({
    this.connectedClientIds = const [],
    this.photoCount = 0,
  });

  NearbyHostAdvertising copyWith({
    List<String>? connectedClientIds,
    int? photoCount,
  }) {
    return NearbyHostAdvertising(
      connectedClientIds: connectedClientIds ?? this.connectedClientIds,
      photoCount: photoCount ?? this.photoCount,
    );
  }
}

/// A permission or platform error occurred.
class NearbyHostError extends NearbyHostState {
  final String message;
  const NearbyHostError(this.message);
}
