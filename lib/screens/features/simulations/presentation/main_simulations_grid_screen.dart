import 'package:auto_size_text/auto_size_text.dart';
import 'package:digipad_flutter/common/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/simulations_cubit.dart';
import '../cubit/simulations_state.dart';
import '../data/simulation_data.dart';
import '../models/simulation_scenario.dart';
import 'simulation_viewer_screen.dart';

/// Main grid screen for selecting visual problems and scenarios.
class MainSimulationsGridScreen extends StatelessWidget {
  const MainSimulationsGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SimulationsCubit(),
      child: const _SimulationsGridView(),
    );
  }
}

class _SimulationsGridView extends StatelessWidget {
  const _SimulationsGridView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimulationsCubit, SimulationsState>(
      builder: (context, state) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, state),
              if (state.selectedCategory == null)
                _buildCategoryGrid(context)
              else
                _buildScenarioGrid(context, state.selectedCategory!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, SimulationsState state) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      leading: LayoutBuilder(
        builder: (context, constraints) {
          return OrientationBuilder(
            builder: (context, orientation) {
              final responsive = context.responsive(constraints, orientation);
              return IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: responsive.iconSize(24),
                ),
                onPressed: () {
                  if (state.selectedCategory != null) {
                    context.read<SimulationsCubit>().goToCategories();
                  } else {
                    Navigator.pop(context);
                  }
                },
              );
            },
          );
        },
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          return OrientationBuilder(
            builder: (context, orientation) {
              final responsive = context.responsive(constraints, orientation);
              return FlexibleSpaceBar(
                title: Text(
                  state.selectedCategory?.displayName ?? 'Lens Simulator',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.fontSize(22),
                    shadows: const [
                      Shadow(blurRadius: 8, color: Colors.black54),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                        Colors.deepPurple.shade700,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: 20,
                        child: Icon(
                          Icons.visibility_outlined,
                          size: 150,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      if (state.selectedCategory != null)
                        Positioned(
                          left: 20,
                          bottom: 60,
                          right: 20,
                          child: Text(
                            state.selectedCategory!.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: responsive.fontSize(16),
                            ),
                          ),
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

  Widget _buildCategoryGrid(BuildContext context) {
    final allCategories = SimulationData.categories;
    final visionProblems = ['myopia', 'presbyopia', 'multifocal', 'bifocal'];

    final problemCategories = allCategories
        .where((c) => visionProblems.contains(c.id))
        .toList();
    final treatmentCategories = allCategories
        .where((c) => !visionProblems.contains(c.id))
        .toList();

    return SliverList(
      delegate: SliverChildListDelegate([
        _buildSectionHeader('Refractive conditions'),
        _buildGridSection(context, problemCategories),
        const SizedBox(height: 24),
        _buildSectionHeader('Lens Treatments'),
        _buildGridSection(context, treatmentCategories),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildSectionHeader(String title) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final responsive = context.responsive(constraints, orientation);
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize(24),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGridSection(
    BuildContext context,
    List<SimulationCategory> categories,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isPhone ? 2 : 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: isPhone ? 12 : 16,
        mainAxisSpacing: isPhone ? 12 : 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(
          category: category,
          onTap: () {
            context.read<SimulationsCubit>().selectCategory(category);
          },
        );
      },
    );
  }

  Widget _buildScenarioGrid(BuildContext context, SimulationCategory category) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isPhone ? 1 : 2,
          childAspectRatio: isPhone ? 1.2 : 0.75,
          crossAxisSpacing: isPhone ? 12 : 16,
          mainAxisSpacing: isPhone ? 12 : 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final scenario = category.scenarios[index];
          return _ScenarioCard(
            scenario: scenario,
            category: category,
            onTap: () => _navigateToViewer(context, category, scenario),
          );
        }, childCount: category.scenarios.length),
      ),
    );
  }

  void _navigateToViewer(
    BuildContext context,
    SimulationCategory category,
    SimulationScenario scenario,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SimulationViewerScreen(category: category, scenario: scenario),
      ),
    );
  }
}

/// Card widget for displaying a category.
class _CategoryCard extends StatelessWidget {
  final SimulationCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  IconData get _icon {
    switch (category.id) {
      case 'myopia':
        return Icons.remove_red_eye_outlined;
      case 'presbyopia':
        return Icons.visibility_outlined;
      case 'multifocal':
        return Icons.view_stream_outlined;
      case 'bifocal':
        return Icons.center_focus_weak_outlined;
      case 'polarized':
        return Icons.filter_hdr_outlined;
      case 'anti_reflex':
        return Icons.shield_outlined;
      case 'drive':
        return Icons.directions_car_outlined;
      case 'photochromic':
        return Icons.brightness_5_outlined;
      case 'solar':
        return Icons.wb_sunny_outlined;
      case 'tint':
        return Icons.color_lens_outlined;
      default:
        return Icons.lens_outlined;
    }
  }

  Color get _iconColor {
    switch (category.id) {
      case 'myopia':
        return Colors.blue;
      case 'presbyopia':
        return Colors.purple;
      case 'multifocal':
        return Colors.teal;
      case 'bifocal':
        return Colors.indigo;
      case 'polarized':
        return Colors.cyan;
      case 'anti_reflex':
        return Colors.green;
      case 'drive':
        return Colors.orange;
      case 'photochromic':
        return Colors.amber;
      case 'solar':
        return Colors.amber.shade700;
      case 'tint':
        return Colors.indigoAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, _iconColor.withOpacity(0.1)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _iconColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icon,
                    size: isPhone ? 32 : 90,
                    color: _iconColor,
                  ),
                ),
                const SizedBox(height: 12),
                AutoSizeText(
                  category.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isPhone ? 16 : 40,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  minFontSize: 10,
                ),
                const SizedBox(height: 4),
                Text(
                  '${category.scenarios.length} scenes',
                  style: TextStyle(
                    fontSize: isPhone ? 11 : 22,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card widget for displaying a scenario with preview.
class _ScenarioCard extends StatelessWidget {
  final SimulationScenario scenario;
  final SimulationCategory category;
  final VoidCallback onTap;

  const _ScenarioCard({
    required this.scenario,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    scenario.problemImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Blur effect indicator
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Without lens',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      scenario.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isPhone ? 18 : 36,
                      ),
                      maxLines: 1,
                      minFontSize: 12,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${scenario.correctionLenses.length} lenses available',
                      style: TextStyle(
                        fontSize: isPhone ? 12 : 22,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: scenario.correctionLenses
                          .take(3)
                          .map(
                            (lens) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getLensColor(
                                  lens.quality,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AutoSizeText(
                                lens.displayName,
                                style: TextStyle(
                                  fontSize: isPhone ? 13 : 28,
                                  color: _getLensColor(lens.quality),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                minFontSize: 9,
                              ),
                            ),
                          )
                          .toList(),
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

  Color _getLensColor(LensQuality quality) {
    switch (quality) {
      case LensQuality.economy:
        return Colors.grey.shade600;
      case LensQuality.standard:
        return Colors.blue;
      case LensQuality.good:
        return Colors.green;
      case LensQuality.premium:
        return Colors.amber.shade700;
    }
  }
}
