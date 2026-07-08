abstract class TotemState {
  const TotemState();
}

class TotemIdle extends TotemState {
  const TotemIdle();
}

class TotemStarting extends TotemState {
  const TotemStarting();
}

class TotemActive extends TotemState {
  final String totemName;
  final List<String> connectedClientIds;
  final int photoCount;

  const TotemActive({
    required this.totemName,
    this.connectedClientIds = const [],
    this.photoCount = 0,
  });

  TotemActive copyWith({
    List<String>? connectedClientIds,
    int? photoCount,
  }) {
    return TotemActive(
      totemName: totemName,
      connectedClientIds: connectedClientIds ?? this.connectedClientIds,
      photoCount: photoCount ?? this.photoCount,
    );
  }
}

class TotemError extends TotemState {
  final String message;
  const TotemError(this.message);
}
