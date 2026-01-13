import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders an asset image with one API for both SVG and raster formats.
///
/// Supported extensions:
/// - `.svg` via `flutter_svg`
/// - raster (`.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, ...) via `Image.asset`
class AppAsset extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Color? color;
  final BlendMode colorBlendMode;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppAsset(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.placeholder,
    this.errorWidget,
  });

  bool get _isSvg => assetPath.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      return SvgPicture.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        semanticsLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        colorFilter: color == null ? null : ColorFilter.mode(color!, colorBlendMode),
        placeholderBuilder: placeholder == null ? null : (_) => placeholder!,
      );
    }

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: errorWidget == null
          ? null
          : (context, error, stackTrace) {
              return errorWidget!;
            },
    );
  }
}
