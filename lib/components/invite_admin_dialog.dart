import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/admin_management/admin_role.dart';
import '../core/models/clients/admin_management/invite_admin_request.dart';
import '../core/providers/admin_management_providers.dart';
import '../core/providers/ui_state_provider.dart';

class InviteAdminDialog extends StatefulComponent {
  const InviteAdminDialog({super.key});

  static void show(BuildContext context) {
    context.showDialog(
      const InviteAdminDialog(),
      title: 'Invite Administrator',
    );
  }

  @override
  State<InviteAdminDialog> createState() => _InviteAdminDialogState();
}

class _InviteAdminDialogState extends State<InviteAdminDialog> {
  String _email = '';
  String _role = AdminRoles.support;
  bool _isSubmitting = false;
  String? _errorMessage;

  void _handleSubmit(BuildContext context) {
    if (_isSubmitting) return;

    final trimmedEmail = _email.trim();
    if (trimmedEmail.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address (e.g., admin@example.com)';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    context.read(adminManagementProvider.notifier).inviteAdmin(
      InviteAdminRequest(email: trimmedEmail, role: _role),
      onSuccess: (message) {
        context.showFlushbar(
          title: 'Invitation Sent',
          message: message,
          type: FlushbarType.success,
        );
        context.hideDialog();
        context.invalidate(listInvitationsProvider(const ListInvitationsParams()));
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _errorMessage = message;
        });
      },
    );
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return div(classes: 'space-y-5', [
      // Info Description Header
      div(classes: 'space-y-1', [
        p(
          classes: 'text-xs font-medium leading-relaxed',
          styles: Styles(color: Color(colorScheme.textSecondary)),
          [
            Component.text(
              'Send an email invitation for a new administrator account. The user will receive an email with instructions to complete setup.',
            ),
          ],
        ),
      ]),

      // Error Banner
      if (_errorMessage != null)
        div(
          classes: 'p-3 rounded-xl border border-rose-500/30 bg-rose-500/10 text-rose-500 text-xs font-semibold animate-fade-in-scaled',
          [Component.text(_errorMessage!)],
        ),

      // Email Address Field
      div(classes: 'space-y-1.5', [
        label(
          classes: 'block text-xs font-bold uppercase tracking-wider',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [
            Component.text('Email Address *'),
          ],
        ),
        div(classes: 'relative w-full', [
          div(
            classes: 'absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none',
            styles: Styles(color: Color(colorScheme.placeholder)),
            [const AppIcon(AppIcons.externalLink)],
          ),
          input(
            type: InputType.email,
            value: _email,
            classes:
                'w-full border rounded-xl pl-9 pr-4 py-2.5 text-xs font-medium focus:outline-none focus:ring-2 transition-all',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textPrimary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            attributes: {'placeholder': 'new.admin@taska.com'},
            onInput: (val) {
              setState(() {
                _email = val.toString();
                _errorMessage = null;
              });
            },
          ),
        ]),
      ]),

      // Role Selection Group
      div(classes: 'space-y-2', [
        label(
          classes: 'block text-xs font-bold uppercase tracking-wider',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [
            Component.text('Administrator Role *'),
          ],
        ),
        div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-2.5', [
          for (final role in AdminRoles.invitableRoles)
            div(
              classes: _role == role
                  ? 'p-3 rounded-xl border-2 cursor-pointer transition-all flex items-start space-x-2.5 shadow-xs'
                  : 'p-3 rounded-xl border cursor-pointer transition-all flex items-start space-x-2.5 hover:opacity-80',
              styles: _role == role
                  ? Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      raw: {'border-color': colorScheme.primary},
                    )
                  : Styles(
                      backgroundColor: Color(colorScheme.surface),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
              events: {
                'click': (_) => setState(() => _role = role),
              },
              [
                div(
                  classes: _role == role
                      ? 'w-4 h-4 rounded-full border-4 mt-0.5 shrink-0 transition-colors'
                      : 'w-4 h-4 rounded-full border-2 mt-0.5 shrink-0 transition-colors',
                  styles: _role == role
                      ? Styles(
                          backgroundColor: Color(colorScheme.surface),
                          raw: {'border-color': colorScheme.primary},
                        )
                      : Styles(
                          backgroundColor: Color(colorScheme.surface),
                          raw: {'border-color': colorScheme.borderInput},
                        ),
                  [],
                ),
                div(classes: 'space-y-0.5 min-w-0 flex-1', [
                  h5(
                    classes: 'font-bold text-xs truncate',
                    styles: Styles(
                      color: _role == role
                          ? Color(colorScheme.primary)
                          : Color(colorScheme.textHeading),
                    ),
                    [Component.text(AdminRoles.labelOf(role))],
                  ),
                  p(
                    classes: 'text-[11px] font-medium leading-tight',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text(_getRoleDescription(role))],
                  ),
                ]),
              ],
            ),
        ]),
      ]),

      // Dialog Actions (Cancel / Send Invitation)
      div(classes: 'flex items-center justify-end space-x-3 pt-3 border-t',
        styles: Styles(raw: {'border-color': colorScheme.border}),
        [
          button(
            type: ButtonType.button,
            onClick: () => context.hideDialog(),
            classes: 'px-4 py-2.5 rounded-xl border text-xs font-bold transition-all cursor-pointer',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [Component.text('Cancel')],
          ),
          button(
            type: ButtonType.button,
            onClick: () => _handleSubmit(context),
            disabled: _isSubmitting,
            classes:
                'px-5 py-2.5 rounded-xl text-white text-xs font-bold shadow-sm transition-all cursor-pointer border-none flex items-center space-x-1.5 ${_isSubmitting ? 'opacity-60 cursor-not-allowed' : 'hover:opacity-95 active:scale-95'}',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [
              if (_isSubmitting)
                span(classes: 'animate-spin border-2 border-white border-t-transparent rounded-full w-3.5 h-3.5 mr-1', [])
              else
                const AppIcon(AppIcons.externalLink),
              Component.text(_isSubmitting ? 'Sending...' : 'Send Invitation'),
            ],
          ),
        ],
      ),
    ]);
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case AdminRoles.rootAdmin:
        return 'Full system access and root privileges across all domains.';
      case AdminRoles.superAdmin:
        return 'Elevated access for platform administration and configuration.';
      case AdminRoles.operations:
        return 'Operational management for tasks, providers, and users.';
      case AdminRoles.support:
        return 'Customer support and user dispute resolution capabilities.';
      case AdminRoles.finance:
        return 'Financial transactions, payouts, and revenue audit access.';
      default:
        return 'Standard administrative permissions.';
    }
  }
}
