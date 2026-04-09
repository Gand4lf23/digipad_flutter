import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:digipad_flutter/features/nearby_sync/cubit/nearby_host_cubit.dart';
import 'package:digipad_flutter/features/nearby_sync/cubit/nearby_host_state.dart';
import 'package:digipad_flutter/features/nearby_sync/presentation/widgets/host_gallery.dart';
import 'package:digipad_flutter/data/local/gallery_storage.dart';
import 'package:digipad_flutter/features/nearby_sync/debug_logger.dart';

/// TÓTEM screen — advertises via Nearby and shows received photos.
class NearbyHostScreen extends StatefulWidget {
  const NearbyHostScreen({super.key});

  @override
  State<NearbyHostScreen> createState() => _NearbyHostScreenState();
}

class _NearbyHostScreenState extends State<NearbyHostScreen> {
  // Local gallery images loaded from Sembast
  List<File> _images = [];
  final GalleryStorage _storage = GalleryStorage();

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    await _storage.init();
    final imgs = await _storage.loadImages();
    if (mounted) setState(() => _images = imgs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Stack(
          children: [
            BlocConsumer<NearbyHostCubit, NearbyHostState>(
              listener: (context, state) {
                // Refresh gallery whenever a new photo arrives
                if (state is NearbyHostAdvertising) _loadImages();
              },
              builder: (context, state) {
                if (state is NearbyHostAdvertising) {
                  return _buildAdvertising(context, state);
                } else if (state is NearbyHostError) {
                  return _buildError(context, state);
                }
                return _buildLoading(context);
              },
            ),
            const DebugConsoleToggle(),
          ],
        ),
      ),
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BFA6)),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Iniciando Tótem…',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Habilitando Bluetooth y WiFi',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Advertising ────────────────────────────────────────────────────────────

  Widget _buildAdvertising(BuildContext context, NearbyHostAdvertising state) {
    return Column(
      children: [
        _buildTopBar(context, state),
        _buildStatusCard(state),
        Expanded(
          child: HostGallery(images: _images),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, NearbyHostAdvertising state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00BFA6).withValues(alpha: 0.15),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white60, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'TÓTEM ACTIVO',
                      style: TextStyle(
                        color: Color(0xFF00BFA6),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.photoCount} foto${state.photoCount == 1 ? '' : 's'} recibidas',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Client count badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: state.connectedClientIds.isEmpty
                  ? Colors.white10
                  : const Color(0xFF00BFA6).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: state.connectedClientIds.isEmpty
                    ? Colors.white24
                    : const Color(0xFF00BFA6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_rounded,
                  size: 14,
                  color: state.connectedClientIds.isEmpty
                      ? Colors.white38
                      : const Color(0xFF5EFCE8),
                ),
                const SizedBox(width: 4),
                Text(
                  '${state.connectedClientIds.length}',
                  style: TextStyle(
                    color: state.connectedClientIds.isEmpty
                        ? Colors.white38
                        : Colors.white,
                    fontSize: 13,
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

  Widget _buildStatusCard(NearbyHostAdvertising state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00BFA6).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF00BFA6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sensors_rounded,
              color: Color(0xFF5EFCE8),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buscando dispositivos…',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.connectedClientIds.isEmpty
                      ? 'Los celulares conectados enviarán fotos aquí'
                      : '${state.connectedClientIds.length} celular${state.connectedClientIds.length == 1 ? '' : 'es'} conectado${state.connectedClientIds.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.read<NearbyHostCubit>().stopTotem(),
                      icon: const Icon(Icons.stop_rounded, size: 16),
                      label: const Text('Detener Tótem', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => context.read<NearbyHostCubit>().restartTotem(),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Reiniciar', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA6).withOpacity(0.2),
                        foregroundColor: const Color(0xFF00BFA6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, NearbyHostError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.redAccent,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'No se pudo iniciar el Tótem',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<NearbyHostCubit>().startAdvertising(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
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
