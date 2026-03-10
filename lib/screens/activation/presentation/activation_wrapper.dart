import 'package:digipad_flutter/l10n/l10n.dart';
import 'package:digipad_flutter/screens/activation/cubit/activation_cubit.dart';
import 'package:digipad_flutter/screens/activation/presentation/activation_screen.dart';
import 'package:digipad_flutter/screens/activation/presentation/language_selector.dart';
import 'package:digipad_flutter/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivationWrapper extends StatefulWidget {
  const ActivationWrapper({super.key});

  @override
  State<ActivationWrapper> createState() => _ActivationWrapperState();
}

class _ActivationWrapperState extends State<ActivationWrapper> {
  @override
  void initState() {
    super.initState();
    context.read<ActivationCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivationCubit, ActivationState>(
      builder: (context, state) {
        if (state.status == ActivationStatus.checking) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == ActivationStatus.approved) {
          return const HomeScreen();
        }

        if (state.status == ActivationStatus.blockedOffline) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: LanguageSelector(),
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      size: 80,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.activationConnectionRequired,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getLocalizedErrorMessage(context, state.errorMessage) ??
                          context.l10n.activationOfflineLimitReached,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ActivationCubit>().init();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(context.l10n.activationRetryConnection),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // pending, notRegistered, error
        return const ActivationScreen();
      },
    );
  }

  String? _getLocalizedErrorMessage(BuildContext context, String? errorKey) {
    if (errorKey == null) return null;

    switch (errorKey) {
      case 'activationNoInternet':
        return context.l10n.activationNoInternet;
      case 'activationRequestExists':
        return context.l10n.activationRequestExists;
      case 'activationConnectionTimeout':
        return context.l10n.activationConnectionTimeout;
      case 'activationConnectionRequired':
        return context.l10n.activationConnectionRequired;
      case 'activationEmailInvalid':
        return context.l10n.activationEmailInvalid;
      case 'activationErrorTitle':
        return context.l10n.activationErrorTitle;
      default:
        // If the error message is not a known key (e.g. raw exception), return it as is or generic error
        // But since we want to avoid raw English errors, we might fallback to generic error if it looks like technical jargon.
        if (errorKey.contains('Exception') || errorKey.contains('Error')) {
          return context.l10n.activationErrorTitle;
        }
        return errorKey;
    }
  }
}
