import 'dart:io';

class VirtualMirrorState {
  final File? leftImage;
  final File? rightImage;
  final List<File> galleryImages;

  VirtualMirrorState({
    this.leftImage,
    this.rightImage,
    this.galleryImages = const [],
  });

  VirtualMirrorState copyWith({
    File? leftImage,
    File? rightImage,
    List<File>? galleryImages,
  }) {
    return VirtualMirrorState(
      leftImage: leftImage ?? this.leftImage,
      rightImage: rightImage ?? this.rightImage,
      galleryImages: galleryImages ?? this.galleryImages,
    );
  }
}
