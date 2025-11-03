import 'package:digipad_flutter/screens/native_impl/split_screen.dart';
import 'package:digipad_flutter/screens/tflite/detector_widget.dart';
import 'package:flutter/material.dart';
import 'package:digipad_flutter/common/components/d_image.dart';
import 'package:digipad_flutter/common/components/d_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const DImage(imageName: 'background').provider,
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildArchMenuItem(
                context: context,
                title: 'Virtual Mirror',
                svgName: 'virtual_mirror',
                iconColor: const Color(0xFFa0a0a0),
                top: screenHeight * 0.05,
                left: 60,
                onTap: () => _navigateToModule(context, 'Virtual Mirror'),
              ),
              _buildArchMenuItem(
                context: context,
                title: 'Simulations',
                svgName: 'simulations',
                iconColor: const Color(0xFF4CAF50),
                top: screenHeight * 0.17,
                left: 35,
                onTap: () => _navigateToModule(context, 'Simulations'),
              ),
              _buildArchMenuItem(
                context: context,
                title: 'Lenses 3D',
                svgName: 'lenses_3d',
                iconColor: const Color(0xFF3b3b3b),
                top: screenHeight * 0.30,
                left: 20,
                onTap: () => _navigateToModule(context, 'Lenses 3D'),
              ),
              _buildArchMenuItem(
                context: context,
                title: 'Cosmetic Lenses',
                svgName: 'cosmetic_lenses',
                iconColor: const Color(0xFF2196F3),
                top: screenHeight * 0.43,
                left: 30,
                onTap: () => _navigateToModule(context, 'Cosmetic Lenses'),
              ),
              _buildArchMenuItem(
                context: context,
                title: 'Measurements',
                svgName: 'measurements',
                iconColor: const Color(0xFFFB8C00),
                top: screenHeight * 0.55,
                left: 45,
                onTap: () => _navigateToModule(context, 'Measurements'),
              ),
              _buildArchMenuItem(
                context: context,
                title: 'Visual Health',
                svgName: 'visual_health',
                iconColor: const Color(0xFFFFD600),
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
    required String svgName,
    required Color iconColor,
    required double top,
    required double left,
    required VoidCallback onTap,
  }) {
    return Positioned(
      top: top,
      left: left,

      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: DSvg(
                    svgName: svgName,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black54,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToModule(BuildContext context, String moduleName) {
    if (moduleName == 'Measurements') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NativeSplitScreen()),
      );
    } else if (moduleName == 'AR Camera') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetectorWidget()),
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
