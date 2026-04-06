import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digipad_flutter/data/local/gallery_storage.dart';
import '../cubit/photo_sync_host_cubit.dart';
import '../cubit/photo_sync_client_cubit.dart';
import 'host/host_screen.dart';
import 'client/client_screen.dart';

/// Entry screen: choose HOST or CLIENT mode.
/// Designed for non-technical users (~60 years old).
class PhotoSyncRoleScreen extends StatelessWidget {
  const PhotoSyncRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRoleCard(
                      context: context,
                      icon: Icons.desktop_windows_rounded,
                      title: 'TÓTEM',
                      subtitle: 'Este dispositivo recibe fotos',
                      description:
                          'Mostrará un código QR para que otros\ndispositivos se conecten',
                      gradient: const [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
                      iconColor: const Color(0xFF9D97FF),
                      onTap: () => _navigateToHost(context),
                    ),
                    const SizedBox(height: 28),
                    // Divider row
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 1, color: Colors.white12),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ó',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(height: 1, color: Colors.white12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _buildRoleCard(
                      context: context,
                      icon: Icons.phone_android_rounded,
                      title: 'CELULAR',
                      subtitle: 'Este dispositivo envía fotos',
                      description:
                          'Escaneá el QR del tótem para\nconectarte y sacar fotos',
                      gradient: const [Color(0xFF00BFA6), Color(0xFF008C7A)],
                      iconColor: const Color(0xFF5EFCE8),
                      onTap: () => _navigateToClient(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                'Photo Sync',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Sincronización de fotos',
                style: TextStyle(
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

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required List<Color> gradient,
    required Color iconColor,
    required VoidCallback onTap,
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
              gradient[0].withValues(alpha: 0.15),
              gradient[1].withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: gradient[0].withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 64,
              height: 150,
              decoration: BoxDecoration(
                color: gradient[0].withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 48),
            ),
            const SizedBox(width: 20),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
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
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) {
            final storage = GalleryStorage();
            return PhotoSyncHostCubit(storage)..startHosting();
          },
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
