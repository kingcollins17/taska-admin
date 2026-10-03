import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../app_icons.dart';

class AppIcon extends StatelessComponent {
  final AppIcons icon;
  final num? size;
  final num? width;
  final num? height;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.width,
    this.height,
  });

  @override
  Component build(BuildContext context) {
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;

    String svgString = icon.value;

    if (effectiveWidth != null || effectiveHeight != null) {
      final widthCss = effectiveWidth != null ? 'width: ${effectiveWidth}px; min-width: ${effectiveWidth}px;' : '';
      final heightCss = effectiveHeight != null ? 'height: ${effectiveHeight}px; min-height: ${effectiveHeight}px;' : '';
      final styleAttr = 'style="$widthCss $heightCss"';

      if (svgString.startsWith('<svg')) {
        svgString = svgString.replaceFirst('<svg', '<svg $styleAttr');
      }
    }

    return RawText(svgString);
  }
}

