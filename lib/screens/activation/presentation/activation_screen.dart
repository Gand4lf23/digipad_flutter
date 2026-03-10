import 'package:digipad_flutter/l10n/l10n.dart';
import 'package:digipad_flutter/screens/activation/cubit/activation_cubit.dart';
import 'package:digipad_flutter/screens/activation/presentation/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && email.contains('@')) {
      setState(() => _isSubmitting = true);
      context.read<ActivationCubit>().submitRequest(email);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.activationEmailInvalid)),
      );
    }
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
        if (errorKey.contains('Exception') || errorKey.contains('Error')) {
          return context.l10n.activationErrorTitle;
        }
        return errorKey;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: BlocConsumer<ActivationCubit, ActivationState>(
        listener: (context, state) {
          if (state.status == ActivationStatus.error) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _getLocalizedErrorMessage(context, state.errorMessage) ??
                      context.l10n.activationErrorTitle,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ActivationStatus.checking) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ActivationStatus.pendingApproval) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.hourglass_empty,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.activationAwaitingApproval,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.activationPendingMessage(
                        state.email ?? "Unknown",
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // Re-check or just stay here.
                        context.read<ActivationCubit>().init();
                      },
                      child: Text(context.l10n.activationRefreshStatus),
                    ),
                  ],
                ),
              ),
            );
          }

          // Default: Not Registered (Input Email)
          return Center(
            child: Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.activationTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.activationEnterEmail,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: context.l10n.activationEmailLabel,
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(context.l10n.activationRequestAccess),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
