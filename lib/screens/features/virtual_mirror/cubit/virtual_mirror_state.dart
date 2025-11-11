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
    Object? leftImage = _sentinel,
    Object? rightImage = _sentinel,
    List<File>? galleryImages,
  }) {
    return VirtualMirrorState(
      leftImage: leftImage == _sentinel ? this.leftImage : leftImage as File?,
      rightImage: rightImage == _sentinel
          ? this.rightImage
          : rightImage as File?,
      galleryImages: galleryImages ?? this.galleryImages,
    );
  }

  static const _sentinel = Object();
}
