import 'package:jaspr/jaspr.dart';

class ThemeScope extends InheritedComponent {
  final bool isDarkMode;
  final void Function() toggleTheme;

  const ThemeScope({
    required this.isDarkMode,
    required this.toggleTheme,
    required super.child,
    super.key,
  });

  static ThemeScope? of(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<ThemeScope>();
  }

  @override
  bool updateShouldNotify(ThemeScope oldComponent) {
    return isDarkMode != oldComponent.isDarkMode;
  }
}
