import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../app_icons.dart';

class AppIcon extends StatelessComponent {
  final AppIcons icon;

  const AppIcon(this.icon, {super.key});

  @override
  Component build(BuildContext context) {
    return RawText(icon.value);
  }
}
