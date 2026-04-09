import 'package:flutter/foundation.dart';

/// States for the CLIENTE device using Nearby Connections.
@immutable
abstract class NearbyClientState {
  const NearbyClientState();
}

/// Nothing started yet.
class NearbyClientIdle extends NearbyClientState {
  const NearbyClientIdle();
}

/// Scanning for nearby Totem devices.
class NearbyClientDiscovering extends NearbyClientState {
  /// Endpoints found so far: endpointId → endpoint display name
  final Map<String, String> foundEndpoints;
  const NearbyClientDiscovering({this.foundEndpoints = const {}});

  NearbyClientDiscovering copyWith({Map<String, String>? foundEndpoints}) {
    return NearbyClientDiscovering(
      foundEndpoints: foundEndpoints ?? this.foundEndpoints,
    );
  }
}

/// Connecting to a chosen Totem.
class NearbyClientConnecting extends NearbyClientState {
  const NearbyClientConnecting();
}

/// Connected to a Totem and ready to send photos.
class NearbyClientConnected extends NearbyClientState {
  final String endpointId;
  final String endpointName;
  final int sentCount;
  final bool isSending;

  const NearbyClientConnected({
    required this.endpointId,
    required this.endpointName,
    this.sentCount = 0,
    this.isSending = false,
  });

  NearbyClientConnected copyWith({
    int? sentCount,
    bool? isSending,
  }) {
    return NearbyClientConnected(
      endpointId: endpointId,
      endpointName: endpointName,
      sentCount: sentCount ?? this.sentCount,
      isSending: isSending ?? this.isSending,
    );
  }
}

/// Photo sent successfully — shown briefly before returning to Connected.
class NearbyClientSendSuccess extends NearbyClientState {
  final int totalSent;
  const NearbyClientSendSuccess(this.totalSent);
}

/// An error occurred (display message and let user retry).
class NearbyClientError extends NearbyClientState {
  final String message;
  const NearbyClientError(this.message);
}
