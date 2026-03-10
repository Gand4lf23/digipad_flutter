import 'package:flutter/material.dart';

/// Responsive utility class for adaptive sizing across different devices
class ResponsiveUtils {
  final BuildContext context;
  final BoxConstraints constraints;
  final Orientation orientation;

  ResponsiveUtils({
    required this.context,
    required this.constraints,
    required this.orientation,
  });

  /// Get screen width
  double get width => constraints.maxWidth;

  /// Get screen height
  double get height => constraints.maxHeight;

  /// Check if device is a phone (width < 600)
  bool get isPhone => width < 600;

  /// Check if device is a tablet (width >= 600)
  bool get isTablet => width >= 600;

  /// Check if device is a desktop (width >= 1024)
  bool get isDesktop => width >= 1024;

  /// Check if in landscape mode
  bool get isLandscape => orientation == Orientation.landscape;

  /// Check if in portrait mode
  bool get isPortrait => orientation == Orientation.portrait;

  /// Get responsive font size
  /// Base size is for tablets in portrait
  double fontSize(double baseSize) {
    if (isTablet) {
      return baseSize;
    }
    // For phones, reduce font size by 20-30%
    return baseSize * 0.75;
  }

  /// Get responsive spacing
  double spacing(double baseSpacing) {
    if (isTablet) {
      return baseSpacing;
    }
    // For phones, reduce spacing by 25%
    return baseSpacing * 0.75;
  }

  /// Return a value depending on breakpoint
  /// Provide explicit values for mobile, tablet, and desktop.
  /// Example:
  ///   responsive.value(mobile: 18, tablet: 22, desktop: 24)
  double value({
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    return mobile;
  }

  /// Get responsive icon size
  double iconSize(double baseSize) {
    if (isTablet) {
      return baseSize;
    }
    // For phones, reduce icon size by 15%
    return baseSize * 0.85;
  }

  /// Get responsive control panel icon size
  /// Control panel icons are larger, so reduce more on phones
  double controlPanelIconSize(double baseSize) {
    if (isTablet) {
      return baseSize;
    }
    // For phones, reduce control panel icons by 50%
    return baseSize * 0.5;
  }

  /// Get responsive control panel container size
  double controlPanelContainerSize(double baseSize) {
    if (isTablet) {
      return baseSize;
    }
    // For phones, reduce container size by 50%
    return baseSize * 0.5;
  }

  /// Get responsive padding
  EdgeInsets padding(EdgeInsets basePadding) {
    if (isTablet) {
      return basePadding;
    }
    // For phones, reduce padding by 30%
    return basePadding * 0.7;
  }

  /// Determine if split-screen should be horizontal (side-by-side)
  /// or vertical (stacked)
  bool get shouldUseSideBySideLayout {
    // Use side-by-side layout for:
    // - Tablets in any orientation
    // - Phones in landscape mode
    return isTablet || isLandscape;
  }

  /// Get flex values for split screen layouts
  /// Returns [topFlex, bottomFlex] for vertical or [leftFlex, rightFlex] for horizontal
  List<int> getSplitFlexValues({
    required int defaultTop,
    required int defaultBottom,
  }) {
    if (shouldUseSideBySideLayout) {
      // In landscape or tablet, use side-by-side with equal or custom flex
      return [defaultTop, defaultBottom];
    } else {
      // In portrait phone, might want different ratios
      return [defaultTop, defaultBottom];
    }
  }

  /// Get responsive button size
  Size buttonSize({required double width, required double height}) {
    if (isTablet) {
      return Size(width, height);
    }
    return Size(width * 0.85, height * 0.85);
  }

  /// Get responsive border radius
  double borderRadius(double baseRadius) {
    if (isTablet) {
      return baseRadius;
    }
    return baseRadius * 0.8;
  }
}

/// Extension on BuildContext for easy access to responsive utils
extension ResponsiveContext on BuildContext {
  /// Create ResponsiveUtils from current context
  /// Requires LayoutBuilder and OrientationBuilder ancestors
  ResponsiveUtils responsive(
    BoxConstraints constraints,
    Orientation orientation,
  ) {
    return ResponsiveUtils(
      context: this,
      constraints: constraints,
      orientation: orientation,
    );
  }
}
