import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_cubit.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digipad_flutter/l10n/l10n.dart';

class IrisSelectorWidget extends StatefulWidget {
  final bool isLeftEye;

  const IrisSelectorWidget({super.key, required this.isLeftEye});

  @override
  State<IrisSelectorWidget> createState() => _IrisSelectorWidgetState();
}

class _IrisSelectorWidgetState extends State<IrisSelectorWidget> {
  String? selectedBrand;
  String? selectedIris;

  // Helper function to extract clean color name from file path
  String _getColorName(String path) {
    final filename = path.split('/').last.replaceAll('.webp', '');

    // Manual mapping for better display names
    final colorMappings = {
      // Acuvue
      'acuvue2_colors_blue': 'Blue',
      'acuvue2_colors_gray': 'Gray',
      'acuvue2_colors_honey': 'Honey',
      'acuvue2_colors_green': 'Green',

      // Fresh Look
      'fresh_look_color_blends_amethyst': 'Amethyst',
      'fresh_look_color_blends_blue': 'Blue',
      'fresh_look_color_blends_brown': 'Brown',
      'fresh_look_color_blends_gray': 'Gray',
      'fresh_look_colors_blue': 'Blue',
      'fresh_look_colors_green': 'Green',
      'fresh_look_colors_hazel': 'Hazel',
      'fresh_look_wild_alien': 'Alien',
      'fresh_look_wild_black': 'Black',
      'fresh_look_wild_cateye': 'Cat Eye',
      'fresh_look_wild_hypnotica': 'Hypnotica',
      'fresh_look_wild_icefire': 'Ice Fire',
      'fresh_look_wild_jaguar': 'Jaguar',
      'fresh_look_wild_knockout': 'Knockout',
      'fresh_look_wild_redhot': 'Red Hot',
      'fresh_look_wild_whiteout': 'Whiteout',
      'fresh_look_wild_wildfire': 'Wildfire',
      'fresh_look_wild_zebra': 'Zebra',
      'fresh_look_wild_zoomin': 'Zoom In',

      // Normal
      'aqua': 'Aqua',
      'blue': 'Blue',
      'brown': 'Brown',
      'gray': 'Gray',
      'green': 'Green',
      'hazel': 'Hazel',
      'jade': 'Jade',
      'topaz': 'Topaz',

      // Optima
      'optima_natural_look_blue': 'Blue',
      'optima_natural_look_gray': 'Gray',
      'optima_natural_look_green': 'Green',
      'optima_natural_look_hazel': 'Hazel',
      'optima_natural_look_light_green': 'Light Green',

      // Durasoft
      'durasoft2_colorsblends_blue': 'Blue',
      'durasoft2_colorsblends_brown': 'Brown',
      'durasoft2_colorsblends_gray': 'Gray',
      'durasoft2_colorsblends_green': 'Green',
      'durasoft3_colors_aqua': 'Aqua',
      'durasoft3_colors_sky_blue': 'Sky Blue',
      'durasoft3_colors_sapphire_blue': 'Sapphire Blue',
      'durasoft3_colors_chestnut_brown': 'Chestnut Brown',
      'durasoft3_colors_mist_gray': 'Mist Gray',
      'durasoft3_colors_emerald_green': 'Emerald Green',
      'durasoft3_colors_jade_green': 'Jade Green',
      'durasoft3_complements_blue': 'Blue',
      'durasoft3_complements_violet_blue': 'Violet Blue',
      'durasoft3_complements_brown': 'Brown',
      'durasoft3_complements_shadow_gray': 'Shadow Gray',
      'durasoft3_complements_green': 'Green',

      // Devlyn
      'devlyn_color_sky_blue': 'Sky Blue',
      'devlyn_color_gray': 'Gray',
      'devlyn_color_honey': 'Honey',
      'devlyn_color_green': 'Green',
      'devlyn2_color_honey': 'Honey',
      'devlyn3_color_blue': 'Blue',
      'devlyn3_color_gray': 'Gray',
      'devlyn3_color_green': 'Green',

      // Star Colors
      'star_colors_2_blue': 'Blue',
      'star_colors_2_blue_topaz': 'Blue Topaz',
      'star_colors_2_dark_green': 'Dark Green',
      'star_colors_2_green_amazon': 'Green Amazon',
      'star_colors_2_green_turquoise': 'Green Turquoise',
      'star_colors_2_grey': 'Grey',
      'star_colors_2_hazel': 'Hazel',
      'star_colors_2_light_green': 'Light Green',

      // Tricolor
      'tricolor_blue': 'Blue',
      'tricolor_green': 'Green',
      'tricolor_grey': 'Grey',
      'tricolor_honey': 'Honey',
      'tricolor_purple': 'Purple',
    };

    return colorMappings[filename] ?? filename;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CosmeticLensesCubit, CosmeticLensesState>(
      builder: (context, state) {
        if (!state.isInitialized || state.availableIris.isEmpty) {
          return const SizedBox.shrink();
        }

        // Get filtered iris options based on selected brand
        final filteredIrisOptions = <Map<String, String>>[];
        if (selectedBrand != null &&
            state.availableIris.containsKey(selectedBrand)) {
          for (final irisPath in state.availableIris[selectedBrand]!) {
            filteredIrisOptions.add({
              'brand': selectedBrand!,
              'path': irisPath,
              'color': _getColorName(irisPath),
            });
          }
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isLeftEye ? context.l10n.leftEye : context.l10n.rightEye,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Brand dropdown
              DropdownButton<String>(
                value: selectedBrand,
                hint: Text(
                  context.l10n.selectBrand,
                  style: const TextStyle(color: Colors.white70),
                ),
                isExpanded: true,
                dropdownColor: Colors.grey.shade900,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                items: state.availableIris.keys.map((brand) {
                  return DropdownMenuItem(value: brand, child: Text(brand));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBrand = value;
                    selectedIris =
                        null; // Reset iris selection when brand changes
                  });
                },
              ),

              if (selectedBrand != null) ...[
                const SizedBox(height: 8),
                // Iris color dropdown (only shown when brand is selected)
                DropdownButton<String>(
                  value: selectedIris,
                  hint: Text(
                    context.l10n.selectColor,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  isExpanded: true,
                  dropdownColor: Colors.grey.shade900,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  items: filteredIrisOptions.map((irisData) {
                    final color = irisData['color']!;
                    final path = irisData['path']!;

                    return DropdownMenuItem(
                      value: path,
                      child: Row(
                        children: [
                          Image.asset(
                            path,
                            width: 30,
                            height: 30,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(color, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedIris = value;
                      });
                      if (widget.isLeftEye) {
                        context.read<CosmeticLensesCubit>().selectLeftIris(
                          value,
                        );
                      } else {
                        context.read<CosmeticLensesCubit>().selectRightIris(
                          value,
                        );
                      }
                    }
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
