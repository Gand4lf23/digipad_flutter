import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:digipad_flutter/data/local/gallery_storage.dart';
import 'package:digipad_flutter/features/nearby_sync/cubit/nearby_client_cubit.dart';
import 'package:digipad_flutter/features/nearby_sync/cubit/nearby_host_cubit.dart';
import 'package:digipad_flutter/features/nearby_sync/cubit/nearby_host_state.dart';
import 'package:digipad_flutter/features/nearby_sync/nearby_preferences.dart';
import 'package:digipad_flutter/features/nearby_sync/presentation/nearby_host_screen.dart';
import 'package:digipad_flutter/features/nearby_sync/presentation/nearby_client_screen.dart';

/// Entry screen: choose TÓTEM (host) or CLIENTE mode.
/// The NearbyHostCubit is provided from HomeScreen (session-scoped).
class NearbySyncRoleScreen extends StatelessWidget {
  const NearbySyncRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: BlocBuilder<NearbyHostCubit, NearbyHostState>(
          builder: (context, hostState) {
            final isActive = hostState is NearbyHostAdvertising;
            final advertisingState =
                isActive ? hostState : null;

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── TÓTEM card ──────────────────────────────────────
                        _RoleCard(
                          icon: Icons.desktop_windows_rounded,
                          title: 'Tótem',
                          subtitle: isActive
                              ? 'Activo · ${advertisingState!.photoCount} fotos'
                              : 'Recibir fotos de los celulares',
                          description: isActive
                              ? 'Esperando conexiones Nearby…'
                              : 'Este dispositivo actúa como receptor y pantalla.',
                          isActive: isActive,
                          gradient: isActive
                              ? const [Color(0xFF00BFA6), Color(0xFF007A68)]
                              : const [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
                          iconColor: isActive
                              ? const Color(0xFF5EFCE8)
                              : const Color(0xFF9D97FF),
                          badge: isActive
                              ? '${advertisingState!.connectedClientIds.length} conectado(s)'
                              : null,
                          onTap: () => _navigateToHost(context),
                        ),

                        const SizedBox(height: 20),

                        // ── CLIENTE card ────────────────────────────────────
                        _RoleCard(
                          icon: Icons.camera_alt_rounded,
                          title: 'Cliente',
                          subtitle: 'Sacar y enviar fotos al Tótem',
                          description:
                              'Este dispositivo busca, conecta y envía fotos.',
                          isActive: false,
                          gradient: const [
                            Color(0xFFE91E8C),
                            Color(0xFF9C1360)
                          ],
                          iconColor: const Color(0xFFFF8CE8),
                          onTap: () => _navigateToClient(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white60, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sincronización de Fotos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Vía Nearby Connections · 100% offline',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToHost(BuildContext context) {
    final cubit = context.read<NearbyHostCubit>();
    if (cubit.state is NearbyHostIdle) {
      cubit.startAdvertising();
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const NearbyHostScreen()),
      ),
    );
  }

  void _navigateToClient(BuildContext context) {
    final storage = GalleryStorage();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => NearbyClientCubit(
            storage: storage,
            prefs: NearbyPreferences(),
          ),
          child: const NearbyClientScreen(),
        ),
      ),
    );
  }
}

// ── Role card ─────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final bool isActive;
  final List<Color> gradient;
  final Color iconColor;
  final String? badge;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isActive,
    required this.gradient,
    required this.iconColor,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient.map((c) => c.withValues(alpha: 0.15)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: gradient.first.withValues(alpha: isActive ? 0.6 : 0.3),
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: gradient.first.withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: gradient.first.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: gradient.first.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  gradient.first.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: iconColor.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white24,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
