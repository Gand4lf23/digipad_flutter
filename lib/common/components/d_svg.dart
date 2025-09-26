import 'dart:typed_data';

import 'package:digipad_flutter/common/components/d_loader.dart';
import 'package:digipad_flutter/common/managers/svg_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DSvg extends StatelessWidget {
  const DSvg({
    super.key,
    this.svgUrl,
    this.svgPath,
    this.svgName, // New parameter for using SvgManager
    this.svgBytes,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.colorFilter,
    this.errorWidget,
    this.loadingWidget,
  }) : assert(
         svgUrl == null || svgUrl is String || svgUrl is Uint8List,
         'svgUrl must be either String, Uint8List or null',
       );

  final dynamic svgUrl;
  final String? svgPath;
  final String? svgName; // Name to lookup in SvgManager
  final Uint8List? svgBytes;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ColorFilter? colorFilter;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    return _buildSvgWidget();
  }

  Widget _buildSvgWidget() {
    // Handle SVG by name using SvgManager
    if (svgName != null) {
      try {
        final svgManager = SvgManager();
        final resolvedPath = svgManager.getSvgPath(svgName!);
        return SvgPicture.asset(
          resolvedPath,
          width: width,
          height: height,
          fit: fit,
          colorFilter: colorFilter,
        );
      } catch (e) {
        return errorWidget ?? const SizedBox.shrink();
      }
    }

    // Handle network SVG
    if (svgUrl is String) {
      return SvgPicture.network(
        svgUrl as String,
        width: width,
        height: height,
        fit: fit,
        colorFilter: colorFilter,
        placeholderBuilder: (_) => loadingWidget ?? const DLoader(),
      );
    }

    // Handle SVG from bytes
    if (svgUrl is Uint8List || svgBytes != null) {
      final bytes = (svgUrl is Uint8List) ? svgUrl as Uint8List : svgBytes!;
      return SvgPicture.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        colorFilter: colorFilter,
      );
    }

    // Handle asset SVG
    final safeSvgPath = (svgPath?.isNotEmpty ?? false) ? svgPath : null;
    if (safeSvgPath != null) {
      return SvgPicture.asset(
        safeSvgPath,
        width: width,
        height: height,
        fit: fit,
        colorFilter: colorFilter,
      );
    }

    // Return error widget if no valid source provided
    return errorWidget ?? const SizedBox.shrink();
  }
}
