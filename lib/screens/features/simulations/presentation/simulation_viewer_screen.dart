import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:digipad_flutter/l10n/l10n.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/simulations_cubit.dart';
import '../cubit/simulations_state.dart';
import '../models/simulation_scenario.dart';
import 'widgets/simulation_canvas.dart';
import 'widgets/simulation_control_panel.dart';
import 'widgets/simulation_top_bar.dart';

/// Screen that displays the simulation with draggable lens effect.
class SimulationViewerScreen extends StatefulWidget {
  final SimulationCategory category;
  final SimulationScenario scenario;

  const SimulationViewerScreen({
    super.key,
    required this.category,
    required this.scenario,
  });

  @override
  State<SimulationViewerScreen> createState() => _SimulationViewerScreenState();
}

class _SimulationViewerScreenState extends State<SimulationViewerScreen>
    with SingleTickerProviderStateMixin {
  ui.Image? _problemImage;
  ui.Image? _correctedImage;
  String? _errorMessage;
  bool _isLoading = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  CorrectionLens? _currentLens;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Set initial lens
    if (widget.scenario.correctionLenses.isNotEmpty) {
      _currentLens = widget.scenario.correctionLenses.first;
    }

    _loadImages();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);

    try {
      // Load problem image
      _problemImage = await _loadImage(widget.scenario.problemImagePath);

      // Load corrected image if lens is selected
      if (_currentLens != null) {
        _correctedImage = await _loadImage(_currentLens!.correctedImagePath);
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading images: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<ui.Image> _loadImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<void> _onLensChanged(CorrectionLens lens) async {
    if (_currentLens?.id == lens.id) return;

    setState(() {
      _currentLens = lens;
      _isLoading = true;
    });

    try {
      _correctedImage = await _loadImage(lens.correctedImagePath);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading lens image: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = SimulationsCubit();
        cubit.selectCategory(widget.category);
        cubit.selectScenario(widget.scenario);
        if (_currentLens != null) {
          cubit.selectLens(_currentLens!);
        }
        return cubit;
      },
      child: Scaffold(backgroundColor: Colors.black, body: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_isLoading || _problemImage == null) {
      return _buildLoadingView();
    }

    return BlocBuilder<SimulationsCubit, SimulationsState>(
      builder: (context, state) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Main simulation canvas
            SimulationCanvas(
              state: state,
              category: widget.category,
              problemImage: _problemImage!,
              correctedImage: _correctedImage,
              currentLens: _currentLens,
            ),

            // Top gradient and back button
            SimulationTopBar(
              scenario: widget.scenario,
              category: widget.category,
              categoryColor: _getCategoryColor(widget.category.id),
              onBack: () => Navigator.pop(context),
            ),

            // Bottom control panel
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SimulationControlPanel(
                state: state,
                category: widget.category,
                scenario: widget.scenario,
                selectedLens: _currentLens,
                onLensSelected: _onLensChanged,
              ),
            ),

            // Lens instruction overlay (shown initially)
            if (!state.isDragging &&
                _correctedImage != null &&
                widget.category.id != 'multifocal')
              _buildInstructionOverlay(state),
          ],
        );
      },
    );
  }

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
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

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.goBack),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 24),
          Text(
            context.l10n.loadingSimulation,
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionOverlay(SimulationsState state) {
    final size = MediaQuery.of(context).size;
    final position = state.isVerticalDivider
        ? Offset(size.width * state.dividerPosition, size.height / 2)
        : Offset(size.width / 2, size.height * state.dividerPosition);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Positioned(
          left: state.isVerticalDivider
              ? position.dx - 100
              : size.width / 2 - 100,
          top: state.isVerticalDivider ? position.dy - 100 : position.dy - 80,
          child: Opacity(
            opacity: _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.isVerticalDivider
                        ? Icons.swap_horiz_outlined
                        : Icons.swap_vert_outlined,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.dragDivider,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
