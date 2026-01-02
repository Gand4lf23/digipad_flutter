import 'dart:ui';
import 'package:digipad_flutter/common/components/d_image.dart';
import 'package:digipad_flutter/common/utils/responsive_utils.dart';
import 'package:digipad_flutter/data/local/gallery_storage.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/presentation/lenses_3d_screen.dart';
import 'package:digipad_flutter/screens/features/simulations/presentation/main_simulations_grid_screen.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/cubit/virtual_mirror_cubit.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/presentation/virtual_mirror_screen.dart';
import 'package:digipad_flutter/screens/native_impl/native_split_screen.dart';
import 'package:digipad_flutter/screens/features/visual_health/cubit/visual_health_cubit.dart';
import 'package:digipad_flutter/screens/features/visual_health/presentation/visual_health_screen.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_cubit.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/presentation/cosmetic_lenses_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return OrientationBuilder(
            builder: (context, orientation) {
              final responsive = context.responsive(constraints, orientation);
              final screenHeight = constraints.maxHeight;

              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: DImage(imageName: 'background').provider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      _buildArchMenuItem(
                        context: context,
                        responsive: responsive,
                        title: 'Virtual Mirror',
                        icon: Icons.face_retouching_natural,
                        color: Colors.white,
                        top: screenHeight * 0.05,
                        left: responsive.isPhone ? 40 : 60,
                        onTap: () =>
                            _navigateToModule(context, 'Virtual Mirror'),
                      ),
                      _buildArchMenuItem(
                        context: context,
                        responsive: responsive,
                        title: 'Simulations',
                        icon: Icons.auto_fix_high,
                        color: const Color(0xFF4CAF50),
                        top: screenHeight * 0.17,
                        left: responsive.isPhone ? 25 : 35,
                        onTap: () => _navigateToModule(context, 'Simulations'),
                      ),
                      _buildArchMenuItem(
                        context: context,
                        responsive: responsive,
                        title: 'Lenses 3D',
                        icon: Icons.view_in_ar,
                        color: Colors.white,
                        top: screenHeight * 0.30,
                        left: responsive.isPhone ? 15 : 20,
                        onTap: () => _navigateToModule(context, 'Lenses 3D'),
                      ),
                      _buildArchMenuItem(
                        context: context,
                        responsive: responsive,
                        title: 'Cosmetic Lenses',
                        icon: Icons.remove_red_eye_outlined,
                        color: const Color(0xFF2196F3),
                        top: screenHeight * 0.43,
                        left: responsive.isPhone ? 20 : 30,
                        onTap: () =>
                            _navigateToModule(context, 'Cosmetic Lenses'),
                      ),
                      _buildArchMenuItem(
                        context: context,
                        responsive: responsive,
                        title: 'Measurements',
                        icon: Icons.straighten,
                        color: const Color(0xFFFB8C00),
                        top: screenHeight * 0.55,
                        left: responsive.isPhone ? 30 : 45,
                        onTap: () => _navigateToModule(context, 'Measurements'),
                      ),
                      _buildArchMenuItem(
                        context: context,
                        responsive: responsive,
                        title: 'Visual Health',
                        icon: Icons.health_and_safety_outlined,
                        color: const Color(0xFFFFD600),
                        top: screenHeight * 0.67,
                        left: responsive.isPhone ? 50 : 70,
                        onTap: () =>
                            _navigateToModule(context, 'Visual Health'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildArchMenuItem({
    required BuildContext context,
    required ResponsiveUtils responsive,
    required String title,
    required IconData icon,
    required Color color,
    required double top,
    required double left,
    required VoidCallback onTap,
  }) {
    final buttonWidth = responsive.isPhone
        ? responsive.width * 0.50
        : responsive.width * 0.42;
    final buttonHeight = responsive.isPhone
        ? responsive.height * 0.05
        : responsive.height * 0.06;
    // Use a dark color for the icon when the button color is white
    final iconColor = color;

    return Positioned(
      top: top,
      left: left,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: buttonWidth,
              height: buttonHeight,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: color.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(left: 8, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    // Center the icon inside the circular container
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    // Replaced DSvg with Icon
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: responsive.fontSize(16),
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                            blurRadius: 4.0,
                            color: Colors.black87,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToModule(BuildContext context, String moduleName) {
    if (moduleName == 'Virtual Mirror') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => VirtualMirrorCubit(GalleryStorage()..init()),
            child: const VirtualMirrorScreen(),
          ),
        ),
      );
    } else if (moduleName == 'Simulations') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MainSimulationsGridScreen(),
        ),
      );
    } else if (moduleName == 'Measurements') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NativeSplitScreen()),
      );
    } else if (moduleName == 'Lenses 3D') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Lenses3DScreen()),
      );
    } else if (moduleName == 'Cosmetic Lenses') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => CosmeticLensesCubit(GalleryStorage()..init()),
            child: const CosmeticLensesScreen(),
          ),
        ),
      );
    } else if (moduleName == 'Visual Health') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => VisualHealthCubit(),
            child: const VisualHealthScreen(),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2c2c2c),
            title: Text(
              moduleName,
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              'Navigating to the $moduleName module.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.cyanAccent),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
