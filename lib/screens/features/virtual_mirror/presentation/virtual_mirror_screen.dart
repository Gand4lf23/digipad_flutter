import 'package:digipad_flutter/screens/features/virtual_mirror/cubit/virtual_mirror_cubit.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/widgets/control_panel.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/widgets/gallery_section.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/widgets/image_dropzone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VirtualMirrorScreen extends StatefulWidget {
  const VirtualMirrorScreen({super.key});

  @override
  State<VirtualMirrorScreen> createState() => _VirtualMirrorScreenState();
}

class _VirtualMirrorScreenState extends State<VirtualMirrorScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VirtualMirrorCubit>().initGallery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const GallerySection(),
            Expanded(
              child: Row(
                children: const [
                  Expanded(
                    child: ImageDropZone(
                      side: DropSide.left,
                      showEmptyMessage: true,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    color: Colors.white24,
                    thickness: 1,
                  ),
                  Expanded(
                    child: ImageDropZone(
                      side: DropSide.right,
                      showEmptyMessage: true,
                    ),
                  ),
                ],
              ),
            ),
            const ControlPanel(),
          ],
        ),
      ),
    );
  }
}

enum DropSide { left, right }
