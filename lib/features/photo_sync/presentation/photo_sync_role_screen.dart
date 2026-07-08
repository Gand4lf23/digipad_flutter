import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:digipad_flutter/features/photo_sync/cubit/client_cubit.dart';
import 'package:digipad_flutter/features/photo_sync/cubit/totem_cubit.dart';
import 'package:digipad_flutter/features/photo_sync/cubit/totem_state.dart';
import 'package:digipad_flutter/features/photo_sync/presentation/client_screen.dart';
import 'package:digipad_flutter/features/photo_sync/presentation/totem_screen.dart';

class PhotoSyncRoleScreen extends StatelessWidget {
  const PhotoSyncRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white60,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Sincronización de Fotos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Seleccioná el rol de este dispositivo',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
              ),
            ),

            const Spacer(),

            // ── Totem card ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<TotemCubit, TotemState>(
                builder: (context, totemState) {
                  final isActive = totemState is TotemActive;
                  return _RoleCard(
                    icon: Icons.tv_rounded,
                    title: 'Tótem (Receptor)',
                    subtitle: isActive
                        ? 'Activo · ${(totemState).photoCount} foto${(totemState).photoCount == 1 ? '' : 's'} recibida${(totemState).photoCount == 1 ? '' : 's'}'
                        : 'Pantalla grande o tablet que recibe fotos',
                    color: const Color(0xFF00BFA6),
                    badge: isActive ? 'ACTIVO' : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<TotemCubit>(),
                          child: const TotemScreen(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Client card ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _RoleCard(
                icon: Icons.smartphone_rounded,
                title: 'Operador (Emisor)',
                subtitle: 'Smartphone que captura y envía fotos al Tótem',
                color: const Color(0xFF6C63FF),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => ClientCubit()..init(),
                      child: const ClientScreen(),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  const Icon(
                    Icons.bluetooth_searching_rounded,
                    color: Colors.white24,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Conexión P2P via Nearby Connections — funciona sin WiFi',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.25),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.18),
              color.withValues(alpha: 0.07),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
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
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF00E676),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
