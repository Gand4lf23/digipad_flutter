import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:digipad_flutter/screens/activation/data/activation_service.dart';

part 'activation_state.dart';

class ActivationCubit extends Cubit<ActivationState> {
  final ActivationService _service;
  StreamSubscription? _subscription;

  ActivationCubit(this._service) : super(const ActivationState());

  Future<void> init() async {
    emit(state.copyWith(status: ActivationStatus.checking));

    final hasInternet = await _service.checkInternetConnection();

    if (!hasInternet) {
      final interactions = await _service.getOfflineInteractionsCount();
      if (_service.isOfflineLimitReached(interactions)) {
        emit(
          state.copyWith(
            status: ActivationStatus.blockedOffline,
            errorMessage: null,
          ),
        );
        return;
      } else {
        final isLocallyApproved = await _service.isLocallyApproved();

        if (isLocallyApproved) {
          emit(state.copyWith(status: ActivationStatus.approved));
          return;
        } else {
          emit(
            state.copyWith(
              status: ActivationStatus.error,
              errorMessage: 'activationNoInternet',
            ),
          );
          return;
        }
      }
    }

    try {
      final stream = _service.getActivationStream();
      _subscription = stream.listen(
        (snapshot) async {
          if (snapshot == null || !snapshot.exists) {
            emit(state.copyWith(status: ActivationStatus.notRegistered));
          } else {
            final data = snapshot.data();
            final isApproved = data?['isApproved'] == true;
            final email = data?['email'] as String?;

            if (isApproved) {
              await _service.setLocallyApproved(true);
              await _service.resetOfflineInteractions();
              emit(
                state.copyWith(status: ActivationStatus.approved, email: email),
              );
            } else {
              await _service.setLocallyApproved(false);
              emit(
                state.copyWith(
                  status: ActivationStatus.pendingApproval,
                  email: email,
                ),
              );
            }
          }
        },
        onError: (e) {
          emit(
            state.copyWith(
              status: ActivationStatus.error,
              errorMessage: 'Error checking activation: $e',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ActivationStatus.error,
          errorMessage: 'Failed to start activation listener: $e',
        ),
      );
    }
  }

  Future<void> handleInteraction() async {
    final hasInternet = await _service.checkInternetConnection();

    if (!hasInternet) {
      final interactions = await _service.getOfflineInteractionsCount();

      if (_service.isOfflineLimitReached(interactions)) {
        if (state.status != ActivationStatus.blockedOffline) {
          emit(
            state.copyWith(
              status: ActivationStatus.blockedOffline,
              errorMessage: null,
            ),
          );
        }
        return;
      }

      await _service.incrementOfflineInteractions();

      if (_service.isOfflineLimitReached(interactions + 1)) {
        emit(
          state.copyWith(
            status: ActivationStatus.blockedOffline,
            errorMessage: null,
          ),
        );
      }
    }
  }

  Future<void> submitRequest(String email) async {
    if (email.isEmpty) return;

    final hasInternet = await _service.checkInternetConnection();
    if (!hasInternet) {
      emit(
        state.copyWith(
          status: ActivationStatus.error,
          errorMessage: 'activationNoInternet',
        ),
      );
      return;
    }

    emit(state.copyWith(status: ActivationStatus.checking));
    try {
      await _service
          .requestActivation(email)
          .timeout(const Duration(seconds: 15));

      emit(
        state.copyWith(status: ActivationStatus.pendingApproval, email: email),
      );
    } catch (e) {
      String msg = 'activationErrorTitle';

      if (e is TimeoutException) {
        msg = 'activationRetryConnection';

        msg = 'activationConnectionTimeout';
      } else if (e.toString().contains('email_already_used')) {
        emit(
          state.copyWith(
            status: ActivationStatus.pendingApproval,
            email: email,
            errorMessage: 'activationRequestExists',
          ),
        );
        return;
      } else if (e.toString().contains('UNAVAILABLE') ||
          e.toString().contains('UnknownHostException')) {
        msg = 'activationConnectionRequired';
      }

      emit(state.copyWith(status: ActivationStatus.error, errorMessage: msg));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
