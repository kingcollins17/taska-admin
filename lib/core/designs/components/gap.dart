import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A utility component for creating horizontal and vertical whitespace gap.
class Gap extends StatelessComponent {
  /// Horizontal spacing width (in pixels).
  final num? x;

  /// Vertical spacing height (in pixels).
  final num? y;

  const Gap({
    super.key,
    this.x,
    this.y,
  });

  /// Shortcut for horizontal spacing.
  const Gap.horizontal(num width, {Key? key}) : this(key: key, x: width);

  /// Shortcut for vertical spacing.
  const Gap.vertical(num height, {Key? key}) : this(key: key, y: height);

  @override
  Component build(BuildContext context) {
    final widthVal = x != null ? '${x}px' : null;
    final heightVal = y != null ? '${y}px' : null;

    final stylesMap = <String, String>{
      if (widthVal != null) 'width': widthVal,
      if (heightVal != null) 'height': heightVal,
      if (widthVal != null) 'min-width': widthVal,
      if (heightVal != null) 'min-height': heightVal,
      'flex-shrink': '0',
    };

    return div(
      styles: Styles(raw: stylesMap),
      [],
    );
  }
}

typedef Space=Gap;
