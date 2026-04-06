import 'dart:ui';
import 'package:digipad_flutter/common/components/d_image.dart';
import 'package:digipad_flutter/data/local/gallery_storage.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_cubit.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/presentation/lenses_3d_screen.dart';
import 'package:digipad_flutter/screens/features/simulations/presentation/main_simulations_grid_screen.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/cubit/virtual_mirror_cubit.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/presentation/virtual_mirror_screen.dart';
import 'package:digipad_flutter/screens/native_impl/native_split_screen.dart';
import 'package:digipad_flutter/screens/features/visual_health/cubit/visual_health_cubit.dart';
import 'package:digipad_flutter/screens/features/visual_health/presentation/visual_health_screen.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_cubit.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/presentation/cosmetic_lenses_screen.dart';
import 'package:digipad_flutter/screens/features/photo_sync/presentation/photo_sync_role_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digipad_flutter/l10n/l10n.dart';
import 'package:digipad_flutter/main.dart';
import 'package:digipad_flutter/digi_locale.dart';

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
                title: context.l10n.menuVirtualMirror,
                moduleId: 'virtual_mirror',
                icon: Icons.face_retouching_natural, // Face/Mirror icon
                color: Colors.white,
                top: screenHeight * 0.05,
                left: 60,
                onTap: () => _navigateToModule(context, 'virtual_mirror'),
              ),
              _buildArchMenuItem(
                context: context,
                title: context.l10n.menuSimulations,
                moduleId: 'simulations',
                icon: Icons.auto_fix_high, // Magic/Simulation icon
                color: const Color(0xFF4CAF50),
                top: screenHeight * 0.17,
                left: 35,
                onTap: () => _navigateToModule(context, 'simulations'),
              ),
              _buildArchMenuItem(
                context: context,
                title: context.l10n.menuLenses3D,
                moduleId: 'lenses_3d',
                icon: Icons.view_in_ar, // 3D/AR icon
                color: Colors.white,
                top: screenHeight * 0.30,
                left: 20,
                onTap: () => _navigateToModule(context, 'lenses_3d'),
              ),
              _buildArchMenuItem(
                context: context,
                title: context.l10n.menuCosmeticLenses,
                moduleId: 'cosmetic_lenses',
                icon: Icons.remove_red_eye_outlined, // Eye icon
                color: const Color(0xFF2196F3),
                top: screenHeight * 0.43,
                left: 30,
                onTap: () => _navigateToModule(context, 'cosmetic_lenses'),
              ),
              _buildArchMenuItem(
                context: context,
                title: context.l10n.menuMeasurements,
                moduleId: 'measurements',
                icon: Icons.straighten, // Ruler/Measurement icon
                color: const Color(0xFFFB8C00),
                top: screenHeight * 0.55,
                left: 45,
                onTap: () => _navigateToModule(context, 'measurements'),
              ),
              _buildArchMenuItem(
                context: context,
                title: context.l10n.menuVisualHealth,
                moduleId: 'visual_health',
                icon: Icons.health_and_safety_outlined, // Health icon
                color: const Color(0xFFFFD600),
                top: screenHeight * 0.67,
                left: 70,
                onTap: () => _navigateToModule(context, 'visual_health'),
              ),
              _buildArchMenuItem(
                context: context,
                title: 'Photo Sync',
                moduleId: 'photo_sync',
                icon: Icons.sync_alt_rounded,
                color: const Color(0xFF00BFA6),
                top: screenHeight * 0.79,
                left: 55,
                onTap: () => _navigateToModule(context, 'photo_sync'),
              ),
              Positioned(
                top: 8,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<LanguageCodeType>(
                      dropdownColor: Colors.grey.shade900,
                      iconEnabledColor: Colors.white,
                      value: LanguageCodeType.values.firstWhere(
                        (e) =>
                            e.name ==
                            Localizations.localeOf(context).languageCode,
                        orElse: () => LanguageCodeType.en,
                      ),
                      items: LanguageCodeType.values.map((e) {
                        final code = e.name;
                        final label = code == 'en'
                            ? context.l10n.languageEnglish
                            : code == 'es'
                            ? context.l10n.languageSpanish
                            : context.l10n.languagePortuguese;
                        return DropdownMenuItem(
                          value: e,
                          child: Text(
                            label,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        MyApp.setLocale(context, Locale(val.name));
                      },
                    ),
                  ),
                ),
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
    required String moduleId,
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

  void _navigateToModule(BuildContext context, String moduleId) {
    if (moduleId == 'virtual_mirror') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => VirtualMirrorCubit(GalleryStorage()..init()),
            child: const VirtualMirrorScreen(),
          ),
        ),
      );
    } else if (moduleId == 'simulations') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MainSimulationsGridScreen(),
        ),
      );
    } else if (moduleId == 'measurements') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NativeSplitScreen()),
      );
    } else if (moduleId == 'lenses_3d') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => Lenses3DCubit(),
            child: const Lenses3DScreen(),
          ),
        ),
      );
    } else if (moduleId == 'cosmetic_lenses') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => CosmeticLensesCubit(GalleryStorage()..init()),
            child: const CosmeticLensesScreen(),
          ),
        ),
      );
    } else if (moduleId == 'visual_health') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => VisualHealthCubit(),
            child: const VisualHealthScreen(),
          ),
        ),
      );
    } else if (moduleId == 'photo_sync') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PhotoSyncRoleScreen(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2c2c2c),
            title: const Text('Info', style: TextStyle(color: Colors.white)),
            content: Text(
              context.l10n.dialogNavigatingContent(moduleId),
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  context.l10n.ok,
                  style: const TextStyle(color: Colors.cyanAccent),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
