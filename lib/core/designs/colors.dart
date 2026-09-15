enum AppBrightness { light, dark }

/// Represents a dynamic theme color scheme with support for light and dark modes.
class ColorScheme {
  final AppBrightness brightness;
  final String primary;
  final String primaryHover;
  final String primaryDark;
  final String primaryDarkest;
  final String mint;

  final String background;
  final String surface;
  final String inputBg;
  final String textHeading;
  final String textPrimary;
  final String textSecondary;
  final String textMuted;
  final String placeholder;
  final String border;
  final String borderInput;
  final String bgHover;

  const ColorScheme({
    required this.brightness,
    required this.primary,
    required this.primaryHover,
    required this.primaryDark,
    required this.primaryDarkest,
    required this.mint,
    required this.background,
    required this.surface,
    required this.inputBg,
    required this.textHeading,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.placeholder,
    required this.border,
    required this.borderInput,
    required this.bgHover,
  });

  const ColorScheme.light({
    this.primary = '#00A870',
    this.primaryHover = '#00734C',
    this.primaryDark = '#004D33',
    this.primaryDarkest = '#00281B',
    this.mint = '#00F5A0',
    this.background = '#FFFFFF',
    this.surface = '#FFFFFF',
    this.inputBg = '#FFFFFF',
    this.textHeading = '#0B0F0E',
    this.textPrimary = '#0F172A',
    this.textSecondary = '#475569',
    this.textMuted = '#64748B',
    this.placeholder = '#94A3B8',
    this.border = '#E2E8F0',
    this.borderInput = '#CBD5E1',
    this.bgHover = '#F8FAFC',
  }) : brightness = AppBrightness.light;

  const ColorScheme.dark({
    this.primary = '#00A870',
    this.primaryHover = '#00F5A0',
    this.primaryDark = '#004D33',
    this.primaryDarkest = '#001A12',
    this.mint = '#00F5A0',
    this.background = '#121816',
    this.surface = '#121816',
    this.inputBg = '#19221E',
    this.textHeading = '#FFFFFF',
    this.textPrimary = '#F8FAFC',
    this.textSecondary = '#94A3B8',
    this.textMuted = '#94A3B8',
    this.placeholder = '#64748B',
    this.border = '#1F2D27',
    this.borderInput = '#26352E',
    this.bgHover = '#18201D',
  }) : brightness = AppBrightness.dark;

  bool get isDark => brightness == AppBrightness.dark;
  bool get isLight => brightness == AppBrightness.light;

  static const  darkScheme =ColorScheme.dark();
  static const lightScheme =ColorScheme.light();
}

typedef AppColorScheme = ColorScheme;

enum AppColors {
  // Brand Primary & Accents
  primary('#00A870', darkHex: '#00A870'),
  primaryHover('#00734C', darkHex: '#00F5A0'),
  primaryDark('#004D33', darkHex: '#004D33'),
  primaryDarkest('#00281B', darkHex: '#001A12'),
  mint('#00F5A0', darkHex: '#00F5A0'),

  // Text & Slate Neutrals
  textHeading('#0B0F0E', darkHex: '#FFFFFF'),
  textPrimary('#0F172A', darkHex: '#F8FAFC'),
  textSecondary('#475569', darkHex: '#94A3B8'),
  textMuted('#64748B', darkHex: '#94A3B8'),
  placeholder('#94A3B8', darkHex: '#64748B'),
  border('#E2E8F0', darkHex: '#1F2D27'),
  borderInput('#CBD5E1', darkHex: '#26352E'),
  bgHover('#F8FAFC', darkHex: '#18201D');

  const AppColors(this.hex, {String? darkHex}) : darkHex = darkHex ?? hex;

  /// The light mode string hex value (e.g. `'#00A870'`).
  final String hex;

  /// The dark mode string hex value.
  final String darkHex;

  /// Returns the hex string value corresponding to the given [ColorScheme].
  String of(ColorScheme scheme) => scheme.isDark ? darkHex : hex;

  @override
  String toString() => hex;
}
