import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/photo_sync_host_cubit.dart';
import '../../cubit/photo_sync_host_state.dart';
import 'package:digipad_flutter/l10n/l10n.dart';
import 'host_qr_display.dart';
import 'host_gallery.dart';

/// Main HOST screen showing QR code and received photos gallery.
class HostScreen extends StatelessWidget {
  const HostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: BlocBuilder<PhotoSyncHostCubit, PhotoSyncHostState>(
          builder: (context, state) {
            if (state is PhotoSyncHostStarting) {
              return _buildLoading(context);
            } else if (state is PhotoSyncHostReady) {
              return _buildReady(context, state);
            } else if (state is PhotoSyncHostError) {
              return _buildError(context, state);
            }
            return _buildLoading(context);
          },
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF6C63FF),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.photoSyncStarting,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.photoSyncStartingDesc,
            style: const TextStyle(color: Colors.white30, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildReady(BuildContext context, PhotoSyncHostReady state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return _buildLandscapeLayout(context, state, screenWidth);
    } else {
      return _buildPortraitLayout(context, state);
    }
  }

  Widget _buildPortraitLayout(BuildContext context, PhotoSyncHostReady state) {
    return Column(
      children: [
        _buildTopBar(context, state),
        const SizedBox(height: 8),
        // QR Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: HostQrDisplay(qrData: state.qrData, ssid: state.ssid),
        ),
        const SizedBox(height: 16),
        // Connection status
        _buildConnectionStatus(context, state),
        const SizedBox(height: 12),
        // Gallery
        Expanded(child: HostGallery(images: state.receivedImages)),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    PhotoSyncHostReady state,
    double screenWidth,
  ) {
    return Row(
      children: [
        // Left: QR + status
        SizedBox(
          width: screenWidth * 0.4,
          child: Column(
            children: [
              _buildTopBar(context, state),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: HostQrDisplay(
                          qrData: state.qrData,
                          ssid: state.ssid,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildConnectionStatus(context, state),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Divider
        Container(width: 1, color: Colors.white10),
        // Right: Gallery
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  context.l10n.photoSyncReceivedPhotos,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: HostGallery(images: state.receivedImages)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, PhotoSyncHostReady state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              '${context.l10n.photoSyncHost} - ${context.l10n.photoSyncTitle}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Received count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_library_rounded,
                  color: const Color(0xFF9D97FF),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${state.receivedImages.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context, PhotoSyncHostReady state) {
    final clientCount = state.connectedClients.length;
    final isConnected = clientCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isConnected
              ? const Color(0xFF00BFA6).withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnected
                ? const Color(0xFF00BFA6).withValues(alpha: 0.3)
                : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isConnected ? Icons.wifi_rounded : Icons.wifi_find_rounded,
              color: isConnected ? const Color(0xFF5EFCE8) : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              isConnected
                  ? context.l10n.photoSyncDevicesConnected(clientCount)
                  : context.l10n.photoSyncNoConnections,
              style: TextStyle(
                color: isConnected ? const Color(0xFF5EFCE8) : Colors.white38,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, PhotoSyncHostError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.activationErrorTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 15),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PhotoSyncHostCubit>().startHosting();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.photoSyncRetry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
