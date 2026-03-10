part of 'activation_cubit.dart';

enum ActivationStatus {
  initial,
  checking,
  notRegistered, // Need to input email
  pendingApproval, // Waiting for admin
  approved, // Go to Home
  error,
  blockedOffline, // Blocked due to offline limit
}

class ActivationState {
  final ActivationStatus status;
  final String? errorMessage;
  final String? email;

  const ActivationState({
    this.status = ActivationStatus.initial,
    this.errorMessage,
    this.email,
  });

  ActivationState copyWith({
    ActivationStatus? status,
    String? errorMessage,
    String? email,
  }) {
    return ActivationState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      email: email ?? this.email,
    );
  }
}
