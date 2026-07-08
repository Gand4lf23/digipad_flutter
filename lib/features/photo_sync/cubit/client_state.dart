abstract class ClientState {
  const ClientState();
}

class ClientIdle extends ClientState {
  const ClientIdle();
}

/// Waiting for the user to scan the Totem QR code.
class ClientScanning extends ClientState {
  const ClientScanning();
}

/// Found the saved/scanned Totem name — actively searching via Nearby discovery.
class ClientDiscovering extends ClientState {
  final String targetName;
  const ClientDiscovering({required this.targetName});
}

/// Discovery found the Totem; connection handshake in progress.
class ClientConnecting extends ClientState {
  const ClientConnecting();
}

class ClientConnected extends ClientState {
  final String endpointId;
  final String endpointName;
  final int sentCount;
  final bool isSending;

  const ClientConnected({
    required this.endpointId,
    required this.endpointName,
    this.sentCount = 0,
    this.isSending = false,
  });

  ClientConnected copyWith({bool? isSending, int? sentCount}) {
    return ClientConnected(
      endpointId: endpointId,
      endpointName: endpointName,
      sentCount: sentCount ?? this.sentCount,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ClientSendSuccess extends ClientState {
  final int totalSent;
  const ClientSendSuccess(this.totalSent);
}

class ClientError extends ClientState {
  final String message;
  /// If set, user can tap "Retry" to re-discover the same Totem.
  final String? lastTotemName;
  const ClientError(this.message, {this.lastTotemName});
}
