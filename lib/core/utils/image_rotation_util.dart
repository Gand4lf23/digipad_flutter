import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

import 'package:exif/exif.dart';

Future<File> fixImageRotation(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final original = img.decodeImage(bytes);
  if (original == null) return imageFile;

  final exifData = await readExifFromBytes(bytes);
  final orientation = exifData['Image Orientation']?.printable;

  img.Image fixed = original;
  if ((orientation == null || orientation == 'Horizontal (normal)') &&
      original.width > original.height) {
    fixed = img.copyRotate(original, angle: 90);
  }

  switch (orientation) {
    case 'Rotate 90 CW':
      fixed = img.copyRotate(original, angle: 90);
      break;
    case 'Rotate 180':
      fixed = img.copyRotate(original, angle: 180);
      break;
    case 'Rotate 270 CW':
      fixed = img.copyRotate(original, angle: 270);
      break;
    case 'Horizontal (normal)':
    case null:
      debugPrint('EXIF orientation: $orientation');
      // No rotation needed
      break;
    default:
      debugPrint('Unknown orientation: $orientation');
      break;
  }

  final fixedFile = File(imageFile.path)
    ..writeAsBytesSync(img.encodeJpg(fixed));
  return fixedFile;
}
