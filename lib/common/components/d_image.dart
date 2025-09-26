import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:digipad_flutter/common/components/d_loader.dart';
import 'package:digipad_flutter/common/managers/image_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class DImage extends StatelessWidget {
  const DImage({
    super.key,
    this.imageUrl,
    this.imagePath,
    this.imageName, // New parameter for using ImageManager
    this.imageBytes,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.loadingWidget,
  }) : assert(
         imageUrl == null || imageUrl is String || imageUrl is Uint8List,
         'imageUrl must be either String, Uint8List or null',
       );

  final dynamic imageUrl;
  final String? imagePath;
  final String? imageName; // Name to lookup in ImageManager
  final Uint8List? imageBytes;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  static final CacheManager _defaultCacheManager = CacheManager(
    Config(
      'bupa_image_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: 'bupa_image_cache'),
      fileService: HttpFileService(),
    ),
  );

  ImageProvider get provider {
    // Handle image by name using ImageManager
    if (imageName != null) {
      try {
        final imageManager = ImageManager();
        final resolvedPath = imageManager.getImagePath(imageName!);
        return AssetImage(resolvedPath);
      } catch (e) {
        return const AssetImage('');
      }
    }

    if (imageUrl is String) {
      return CachedNetworkImageProvider(
        imageUrl as String,
        cacheManager: _defaultCacheManager,
      );
    }

    if (imageUrl is Uint8List) {
      return MemoryImage(imageUrl as Uint8List);
    }

    if (imagePath?.isNotEmpty ?? false) {
      return AssetImage(imagePath ?? '');
    }

    return const AssetImage('');
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: _buildImageWidget(),
    );
  }

  Widget _buildImageWidget() {
    // Handle image by name using ImageManager
    if (imageName != null) {
      try {
        final imageManager = ImageManager();
        final resolvedPath = imageManager.getImagePath(imageName!);
        return Image.asset(
          resolvedPath,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? Text('error'),
        );
      } catch (e) {
        return errorWidget ?? Text('error');
      }
    }

    if (imageUrl is String) {
      return CachedNetworkImage(
        imageUrl: imageUrl as String,
        fit: fit,
        cacheManager: _defaultCacheManager,
        placeholder: (_, _) => loadingWidget ?? const DLoader(),
        errorListener: (value) {
          // https://github.com/Baseflow/flutter_cached_network_image/issues/1007
        },
        errorWidget: (_, _, _) => errorWidget ?? Text('error'),
      );
    }
    if (imageUrl is Uint8List) {
      return Image.memory(imageUrl as Uint8List, fit: fit);
    }

    final safeImagePath = (imagePath?.isNotEmpty ?? false) ? imagePath : null;
    if (safeImagePath != null) {
      return Image.asset(
        safeImagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? Text('error'),
      );
    }
    return errorWidget ?? Text('error');
  }
}
