import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digipad_flutter/data/local/gallery_storage.dart';
import 'package:digipad_flutter/l10n/l10n.dart';
import '../cubit/photo_sync_host_cubit.dart';
import '../cubit/photo_sync_host_state.dart';
import '../cubit/photo_sync_client_cubit.dart';
import 'host/host_screen.dart';
import 'client/client_screen.dart';

/// Entry screen: choose HOST (TÓTEM) or CLIENT mode.
///
/// The [PhotoSyncHostCubit] is provided by the parent [HomeScreen] and lives
/// for the entire app session.  This screen simply reads it—it does NOT own it.
class PhotoSyncRoleScreen extends StatelessWidget {
  const PhotoSyncRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: BlocBuilder<PhotoSyncHostCubit, PhotoSyncHostState>(
          builder: (context, hostState) {
            final isTotemActive = hostState is PhotoSyncHostReady ||
                hostState is PhotoSyncHostStarting;

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── TOTEM card ──────────────────────────────────────
                        _buildRoleCard(
                          context: context,
                          icon: Icons.desktop_windows_rounded,
                          title: context.l10n.photoSyncHost,
                          subtitle: isTotemActive
                              ? context.l10n.photoSyncRoleHostActiveSubtitle
                              : context.l10n.photoSyncRoleHostInactiveSubtitle,
                          description: isTotemActive
                              ? context.l10n.photoSyncRoleHostActiveDesc
                              : context.l10n.photoSyncRoleHostInactiveDesc,
                          gradient: isTotemActive
                              ? const [Color(0xFF00BFA6), Color(0xFF007A68)]
                              : const [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
                          iconColor: isTotemActive
                              ? const Color(0xFF5EFCE8)
                              : const Color(0xFF9D97FF),
                          onTap: () => _navigateToHost(context),
                          badge: isTotemActive
                              ? context.l10n.photoSyncPhotosCount(
                                  hostState is PhotoSyncHostReady
                                      ? hostState.receivedImages.length
                                      : 0,
                                )
                              : null,
                          isActive: isTotemActive,
                        ),

                        const SizedBox(height: 20),

                        // ── Disconnect button (only when TOTEM is active) ───
                        if (isTotemActive) _buildDisconnectButton(context),

                        if (!isTotemActive) ...[
                          // ── Divider ─────────────────────────────────────────
                          _buildDivider(),
                          const SizedBox(height: 28),
                          // ── Client card ──────────────────────────────────────
                          _buildRoleCard(
                            context: context,
                            icon: Icons.phone_android_rounded,
                            title: context.l10n.photoSyncRoleClientTitle,
                            subtitle: context.l10n.photoSyncRoleClientSubtitle,
                            description: context.l10n.photoSyncRoleClientDesc,
                            gradient: const [
                              Color(0xFF00BFA6),
                              Color(0xFF008C7A),
                            ],
                            iconColor: const Color(0xFF5EFCE8),
                            onTap: () => _navigateToClient(context),
                          ),
                        ],
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

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white70,
              size: 48,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.photoSyncTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                context.l10n.photoSyncRoleSubtitle,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Divider row ────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return const SizedBox(height: 8);
  }

  // ── Big red Disconnect button ──────────────────────────────────────────────

  Widget _buildDisconnectButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<PhotoSyncHostCubit>().stopHosting();
        },
        icon: const Icon(Icons.wifi_off_rounded, size: 28),
        label: Text(
          context.l10n.photoSyncDisconnect,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: Colors.red.withOpacity(0.5),
        ),
      ),
    );
  }

  // ── Role card ──────────────────────────────────────────────────────────────

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required List<Color> gradient,
    required Color iconColor,
    required VoidCallback onTap,
    String? badge,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradient[0].withValues(alpha: isActive ? 0.30 : 0.15),
              gradient[1].withValues(alpha: isActive ? 0.18 : 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: gradient[0].withValues(alpha: isActive ? 0.7 : 0.3),
            width: isActive ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: isActive ? 0.3 : 0.1),
              blurRadius: isActive ? 30 : 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon column
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 64,
                  height: 150,
                  decoration: BoxDecoration(
                    color: gradient[0].withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 48),
                ),
                if (isActive)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF0D0D1A), width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            // Text
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
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: gradient[0].withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: iconColor.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _navigateToHost(BuildContext context) {
    final hostCubit = context.read<PhotoSyncHostCubit>();

    // If not yet active, start hosting now.
    final state = hostCubit.state;
    if (state is PhotoSyncHostInitial || state is PhotoSyncHostError) {
      hostCubit.startHosting();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: hostCubit,
          child: const HostScreen(),
        ),
      ),
    );
  }

  void _navigateToClient(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) {
            final storage = GalleryStorage();
            return PhotoSyncClientCubit(storage);
          },
          child: const ClientScreen(),
        ),
      ),
    );
  }
}
