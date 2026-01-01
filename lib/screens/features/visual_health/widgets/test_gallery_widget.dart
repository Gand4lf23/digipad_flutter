import 'package:digipad_flutter/screens/features/visual_health/cubit/visual_health_cubit.dart';
import 'package:digipad_flutter/screens/features/visual_health/cubit/visual_health_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digipad_flutter/l10n/l10n.dart';

class TestGalleryWidget extends StatefulWidget {
  const TestGalleryWidget({super.key});

  @override
  State<TestGalleryWidget> createState() => _TestGalleryWidgetState();
}

class _TestGalleryWidgetState extends State<TestGalleryWidget> {
  final _controller = ScrollController();

  void scrollLeft() {
    _controller.animateTo(
      _controller.offset - 220,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void scrollRight() {
    _controller.animateTo(
      _controller.offset + 220,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisualHealthCubit, VisualHealthState>(
      builder: (context, state) {
        if (!state.isInitialized || state.testImages.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Card(
              color: Colors.grey.shade900,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade600, width: 1),
              ),
              child: SizedBox(
                height: 250,
                child: Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    context.l10n.vhNoTests,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          );
        }

        return Card(
          color: Colors.black,
          elevation: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade600, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 250,
              child: Stack(
                children: [
                  // Scrollable gallery
                  NotificationListener<UserScrollNotification>(
                    onNotification: (_) => true,
                    child: ListView.separated(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      itemCount: state.testImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final testImage = state.testImages[index];
                        final isSelected = index == state.currentTestIndex;
                        return _TestThumbnail(
                          imagePath: testImage,
                          isSelected: isSelected,
                          onTap: () => context
                              .read<VisualHealthCubit>()
                              .selectTest(index),
                        );
                      },
                    ),
                  ),
                  // Scroll arrows
                  Positioned(
                    left: 0,
                    top: 100,
                    child: _ArrowButton(
                      icon: Icons.arrow_back_ios,
                      onTap: scrollLeft,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 100,
                    child: _ArrowButton(
                      icon: Icons.arrow_forward_ios,
                      onTap: scrollRight,
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

class _TestThumbnail extends StatelessWidget {
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _TestThumbnail({
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 200,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.yellow.shade600 : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.yellow.shade600.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey.shade800,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
