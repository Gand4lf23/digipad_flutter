import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/photo_sync_client_cubit.dart';
import '../../cubit/photo_sync_client_state.dart';
import 'client_qr_scanner.dart';

/// Main CLIENT screen — manages the full flow:
/// 1. Initial: choose "Connect" or "Auto-reconnect"
/// 2. Scanning: QR scanner
/// 3. Connecting: loading indicator
/// 4. Connected: camera button
/// 5. Error: retry options
class ClientScreen extends StatelessWidget {
  const ClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: BlocBuilder<PhotoSyncClientCubit, PhotoSyncClientState>(
          builder: (context, state) {
            if (state is PhotoSyncClientInitial) {
              return _buildInitial(context, state);
            } else if (state is PhotoSyncClientScanning) {
              return _buildScanning(context);
            } else if (state is PhotoSyncClientConnecting) {
              return _buildConnecting(context, state);
            } else if (state is PhotoSyncClientConnected) {
              return _buildConnected(context, state);
            } else if (state is PhotoSyncClientError) {
              return _buildError(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInitial(BuildContext context, PhotoSyncClientInitial state) {
    return Column(
      children: [
        _buildTopBar(context, title: 'Conectar al Tótem'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFF00BFA6).withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Color(0xFF5EFCE8),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 32),
                // Primary action: Scan QR
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<PhotoSyncClientCubit>().startScanning();
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 24),
                    label: const Text(
                      'Escanear código QR',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: const Color(
                        0xFF00BFA6,
                      ).withValues(alpha: 0.4),
                    ),
                  ),
                ),
                // Auto-reconnect button (if config exists)
                if (state.hasSavedConfig) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<PhotoSyncClientCubit>().autoReconnect();
                      },
                      icon: const Icon(Icons.wifi_rounded, size: 22),
                      label: const Text(
                        'Reconectar automáticamente',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5EFCE8),
                        side: BorderSide(
                          color: const Color(0xFF00BFA6).withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Instruction
                Text(
                  'Apuntá la cámara al código QR\nque aparece en el tótem',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanning(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(context, title: 'Escaneá el código QR'),
        Expanded(
          child: ClientQrScanner(
            onScanned: (data) {
              context.read<PhotoSyncClientCubit>().onQrScanned(data);
            },
            onCancel: () {
              context.read<PhotoSyncClientCubit>().reset();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConnecting(
    BuildContext context,
    PhotoSyncClientConnecting state,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated WiFi icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Opacity(
                opacity: 0.4 + (value * 0.6),
                child: Icon(
                  Icons.wifi_rounded,
                  color: const Color(0xFF5EFCE8),
                  size: 72,
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          Text(
            'Conectando...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Red: ${state.ssid}',
            style: TextStyle(
              color: const Color(0xFF5EFCE8),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esto puede tomar unos segundos',
            style: TextStyle(color: Colors.white30, fontSize: 14),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF00BFA6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnected(BuildContext context, PhotoSyncClientConnected state) {
    return Column(
      children: [
        _buildTopBar(context, title: 'Conectado'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00BFA6).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BFA6),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF00BFA6,
                              ).withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Conectado al tótem',
                        style: TextStyle(
                          color: Color(0xFF5EFCE8),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Camera button
                GestureDetector(
                  onTap: state.isUploading
                      ? null
                      : () {
                          context
                              .read<PhotoSyncClientCubit>()
                              .captureAndUpload();
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: state.isUploading
                          ? LinearGradient(
                              colors: [
                                Colors.grey.shade700,
                                Colors.grey.shade800,
                              ],
                            )
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF00BFA6), Color(0xFF008C7A)],
                            ),
                      boxShadow: [
                        if (!state.isUploading)
                          BoxShadow(
                            color: const Color(
                              0xFF00BFA6,
                            ).withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                      ],
                    ),
                    child: state.isUploading
                        ? const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white70,
                                ),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 56,
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  state.isUploading ? 'Enviando foto...' : 'Sacar foto',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Status message
                if (state.statusMessage != null) ...[
                  const SizedBox(height: 24),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: state.uploadSuccess == true
                          ? const Color(0xFF00BFA6).withValues(alpha: 0.15)
                          : Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: state.uploadSuccess == true
                            ? const Color(0xFF00BFA6).withValues(alpha: 0.3)
                            : Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.uploadSuccess == true
                              ? Icons.check_circle_rounded
                              : Icons.error_outline_rounded,
                          color: state.uploadSuccess == true
                              ? const Color(0xFF5EFCE8)
                              : Colors.redAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          state.statusMessage!,
                          style: TextStyle(
                            color: state.uploadSuccess == true
                                ? const Color(0xFF5EFCE8)
                                : Colors.redAccent.shade100,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, PhotoSyncClientError state) {
    return Column(
      children: [
        _buildTopBar(context, title: 'Error'),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.redAccent.shade100,
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<PhotoSyncClientCubit>().startScanning();
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text(
                        'Escanear de nuevo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () {
                      context.read<PhotoSyncClientCubit>().reset();
                    },
                    child: const Text(
                      'Volver',
                      style: TextStyle(color: Colors.white38, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, {required String title}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
