import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/web.dart' as web;

import '../designs/colors.dart';
import '../services/local_storage.dart';

enum ThemeMode {
  system,
  light,
  dark,
}

enum FlushbarType {
  info,
  success,
  warning,
  error,
}

class FlushbarConfig {
  final String message;
  final String? title;
  final FlushbarType type;
  final Duration duration;
  final DateTime createdAt;

  FlushbarConfig({
    required this.message,
    this.title,
    this.type = FlushbarType.info,
    this.duration = const Duration(seconds: 4),
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class UIState {
  final ThemeMode themeMode;
  final Component? sidePanel;
  final bool isSidePanelOpen;
  final FlushbarConfig? flushbar;

  const UIState({
    this.themeMode = ThemeMode.light,
    this.sidePanel,
    this.isSidePanelOpen = false,
    this.flushbar,
  });

  bool get isDarkMode {
    if (themeMode == ThemeMode.dark) return true;
    if (themeMode == ThemeMode.light) return false;
    try {
      return web.window.matchMedia('(prefers-color-scheme: dark)').matches;
    } catch (_) {
      return false;
    }
  }

  ColorScheme get colorScheme =>
      isDarkMode ?  ColorScheme.darkScheme:  ColorScheme.lightScheme;

  UIState copyWith({
    ThemeMode? themeMode,
    Component? sidePanel,
    bool? isSidePanelOpen,
    FlushbarConfig? flushbar,
    bool clearSidePanel = false,
    bool clearFlushbar = false,
  }) {
    return UIState(
      themeMode: themeMode ?? this.themeMode,
      sidePanel: clearSidePanel ? null : (sidePanel ?? this.sidePanel),
      isSidePanelOpen: isSidePanelOpen ?? (clearSidePanel ? false : this.isSidePanelOpen),
      flushbar: clearFlushbar ? null : (flushbar ?? this.flushbar),
    );
  }

  @override
  toString() => {'themeMode': themeMode.toString(), 'isSidePanelOpen': isSidePanelOpen}.toString();
}

final uiStateProvider = NotifierProvider<UIStateNotifier, UIState>(UIStateNotifier.new);

class UIStateNotifier extends Notifier<UIState> {
  static const _themeStorageKey = 'taska_is_dark';

  @override
  UIState build() {
    final savedIsDarkStr = localStorage.getItem(_themeStorageKey);
    ThemeMode initialMode = ThemeMode.light;

    if (savedIsDarkStr != null) {
      final isDark = savedIsDarkStr.toLowerCase() == 'true' || savedIsDarkStr.toLowerCase() == 'dark';
      initialMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }

    return UIState(themeMode: initialMode);
  }

  void setThemeMode(ThemeMode mode) {
    final isDark = mode == ThemeMode.dark;
    localStorage.setItem(_themeStorageKey, isDark.toString());
    state = state.copyWith(themeMode: mode);
  }

  void toggleTheme() {
    final newMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    final isDark = newMode == ThemeMode.dark;
    localStorage.setItem(_themeStorageKey, isDark.toString());
    state = state.copyWith(themeMode: newMode);
  }

  void showSidePanel(Component component) {
    state = state.copyWith(
      sidePanel: component,
      isSidePanelOpen: true,
    );
  }

  void hideSidePanel() {
    state = state.copyWith(
      clearSidePanel: true,
      isSidePanelOpen: false,
    );
  }

  void showFlushbar({
    required String message,
    String? title,
    FlushbarType type = FlushbarType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    state = state.copyWith(
      flushbar: FlushbarConfig(
        message: message,
        title: title,
        type: type,
        duration: duration,
      ),
    );
  }

  void hideFlushbar() {
    state = state.copyWith(clearFlushbar: true);
  }
}

extension BuildContextUIExtensions on BuildContext {
  UIState get uiState => read(uiStateProvider);
  ColorScheme get colorScheme => watch(uiStateProvider.select((state) => state.colorScheme));

  void showSidePanel(Component component) {
    read(uiStateProvider.notifier).showSidePanel(component);
  }

  void hideSidePanel() {
    read(uiStateProvider.notifier).hideSidePanel();
  }

  void showFlushbar({
    required String message,
    String? title,
    FlushbarType type = FlushbarType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    read(uiStateProvider.notifier).showFlushbar(
      message: message,
      title: title,
      type: type,
      duration: duration,
    );
  }

  void hideFlushbar() {
    read(uiStateProvider.notifier).hideFlushbar();
  }

  void setThemeMode(ThemeMode mode) {
    read(uiStateProvider.notifier).setThemeMode(mode);
  }

  void toggleTheme() {
    read(uiStateProvider.notifier).toggleTheme();
  }
}
