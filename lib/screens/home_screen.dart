import 'dart:ui';
import 'package:digipad_flutter/common/components/d_image.dart';
import 'package:digipad_flutter/data/local/gallery_storage.dart';
import 'package:digipad_flutter/screens/features/simulations/cubit/simulations_cubit.dart';
import 'package:digipad_flutter/screens/features/simulations/presentation/main_simulations_grid_screen.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/cubit/virtual_mirror_cubit.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/presentation/virtual_mirror_screen.dart';
import 'package:digipad_flutter/screens/native_impl/native_split_screen.dart';
import 'package:digipad_flutter/screens/tflite/detector_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
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
                title: 'Virtual Mirror',
                icon: Icons.face_retouching_natural, // Face/Mirror icon
                color: Colors.white,
                top: screenHeight * 0.05,
                left: 60,
                onTap: () => _navigateToModule(context, 'Virtual Mirror'),
              ),
              _buildArchMenuItem(
                context: context,
                title: 'Simulations',
                icon: Icons.auto_fix_high, // Magic/Simulation icon
                color: const Color(0xFF4CAF50),
                top: screenHeight * 0.17,
                left: 35,
                onTap: () => _navigateToModule(context, 'Simulations'),
              ),
              _buildArchMenuItem(
                context: context,
                title: 'Lenses 3D',
                icon: Icons.view_in_ar, // 3D/AR icon
                color: Colors.white,
                top: screenHeight * 0.30,
                left: 20,
                onTap: () => _navigateToModule(context, 'Lenses 3D'),
              ),
              _buildArchMenuItem(
                context: context,
                title: 'Cosmetic Lenses',
                icon: Icons.remove_red_eye_outlined, // Eye icon
                color: const Color(0xFF2196F3),
                top: screenHeight * 0.43,
                left: 30,
                onTap: () => _navigateToModule(context, 'Cosmetic Lenses'),
              ),
              _buildArchMenuItem(
                context: context,
                title: 'Measurements',
                icon: Icons.straighten, // Ruler/Measurement icon
                color: const Color(0xFFFB8C00),
                top: screenHeight * 0.55,
                left: 45,
                onTap: () => _navigateToModule(context, 'Measurements'),
              ),
              _buildArchMenuItem(
                context: context,
                title: 'Visual Health',
                icon: Icons.health_and_safety_outlined, // Health icon
                color: const Color(0xFFFFD600),
                top: screenHeight * 0.67,
                left: 70,
                onTap: () => _navigateToModule(context, 'Visual Health'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon, // Changed from svgName to IconData
    required Color color,
    required double top,
    required double left,
    required VoidCallback onTap,
  }) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.42;
    final buttonHeight = MediaQuery.of(context).size.height * 0.06;
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
                        fontSize: 16,

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
          builder: (context) => BlocProvider(
            create: (_) => SimulationsCubit(),
            child: const MainSimulationsGridScreen(),
          ),
        ),
      );
    } else if (moduleName == 'Measurements') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NativeSplitScreen()),
      );
    } else if (moduleName == 'AR Camera') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetectorWidget()),
      );
    } else if (moduleName == 'Visual Health') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NativeSplitScreen()),
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
