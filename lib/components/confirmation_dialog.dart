import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/providers/ui_state_provider.dart';

class ConfirmationDialog extends StatelessComponent {
  final String dialogTitle;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final AppIcons? icon;
  final Completer<bool?> _completer;

  const ConfirmationDialog({
    super.key,
    required this.dialogTitle,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.icon,
    required Completer<bool?> completer,
  }) : _completer = completer;

  /// Shows the confirmation dialog and returns a [Future<bool?>] which completes
  /// with `true` if the user confirms, and `false` or `null` if cancelled.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    AppIcons? icon,
  }) {
    final completer = Completer<bool?>();
    context.showDialog(
      ConfirmationDialog(
        dialogTitle: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        icon: icon,
        completer: completer,
      ),
      title: title,
    );
    return completer.future;
  }

  void _onConfirm(BuildContext context) {
    if (!_completer.isCompleted) {
      _completer.complete(true);
    }
    context.hideDialog();
  }

  void _onCancel(BuildContext context) {
    if (!_completer.isCompleted) {
      _completer.complete(false);
    }
    context.hideDialog();
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));
    final isDark = colorScheme.isDark;

    final displayIcon = icon ?? (isDestructive ? AppIcons.logout : AppIcons.infoCircle);

    return div(classes: 'space-y-6 animate-fade-in-scaled', [
      // Header Icon & Description Card
      div(classes: 'flex items-start space-x-4', [
        div(
          classes: 'w-12 h-12 rounded-2xl flex items-center justify-center shrink-0 shadow-sm border',
          styles: Styles(
            backgroundColor: isDestructive
                ? (isDark ? Color.rgba(244, 63, 94, 0.15) : Color.rgba(244, 63, 94, 0.1))
                : (isDark ? Color.rgba(16, 185, 129, 0.15) : Color.rgba(16, 185, 129, 0.1)),
            color: isDestructive
                ? const Color('#EF4444')
                : Color(colorScheme.primary),
            raw: {
              'border-color': isDestructive
                  ? (isDark ? 'rgba(244, 63, 94, 0.3)' : 'rgba(244, 63, 94, 0.2)')
                  : (isDark ? 'rgba(16, 185, 129, 0.3)' : 'rgba(16, 185, 129, 0.2)')
            },
          ),
          [
            AppIcon(displayIcon),
          ],
        ),
        div(classes: 'space-y-1.5 min-w-0 flex-1', [
          h4(
            classes: 'text-base font-extrabold tracking-tight leading-tight',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [Component.text(dialogTitle)],
          ),
          p(
            classes: 'text-xs font-medium leading-relaxed',
            styles: Styles(color: Color(colorScheme.textSecondary)),
            [Component.text(message)],
          ),
        ]),
      ]),

      // Action Buttons Footer
      div(classes: 'flex items-center justify-end space-x-3 pt-3 border-t', styles: Styles(raw: {'border-color': colorScheme.borderInput}), [
        button(
          type: ButtonType.button,
          onClick: () => _onCancel(context),
          classes:
              'px-4 py-2.5 rounded-xl border text-xs font-bold transition-all cursor-pointer hover:opacity-80 active:scale-95',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textSecondary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          [Component.text(cancelText)],
        ),
        button(
          type: ButtonType.button,
          onClick: () => _onConfirm(context),
          classes: isDestructive
              ? 'px-5 py-2.5 rounded-xl text-white text-xs font-bold shadow-sm transition-all cursor-pointer border-none bg-rose-600 hover:bg-rose-700 active:scale-95'
              : 'px-5 py-2.5 rounded-xl text-white text-xs font-bold shadow-sm transition-all cursor-pointer border-none hover:opacity-95 active:scale-95',
          styles: isDestructive ? null : Styles(backgroundColor: Color(colorScheme.primary)),
          [Component.text(confirmText)],
        ),
      ]),
    ]);
  }
}
