import 'package:jaspr_riverpod/jaspr_riverpod.dart';

final isDarkModeProvider = NotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}
