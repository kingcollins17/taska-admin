import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/admin_management/admin_invitation_item.dart';
import '../core/models/clients/admin_management/admin_role.dart';
import '../core/providers/admin_management_providers.dart';
import '../core/providers/ui_state_provider.dart';

class InviteDetailSidePanel extends StatefulComponent {
  final AdminInvitationItem invitation;

  const InviteDetailSidePanel({
    required this.invitation,
    super.key,
  });

  static void show(BuildContext context, AdminInvitationItem invitation) {
    context.showSidePanel(
      InviteDetailSidePanel(invitation: invitation),
      title: 'Invitation Details',
    );
  }

  @override
  State<InviteDetailSidePanel> createState() => _InviteDetailSidePanelState();
}

class _InviteDetailSidePanelState extends State<InviteDetailSidePanel> {
  bool isResending = false;
  bool isRevoking = false;

  void _copyToClipboard(BuildContext context, String text, String label) {
    if (text.isEmpty) return;
    try {
      web.window.navigator.clipboard.writeText(text);
      context.showFlushbar(
        message: '$label copied to clipboard',
        type: FlushbarType.success,
      );
    } catch (_) {
      context.showFlushbar(
        message: 'Failed to copy $label',
        type: FlushbarType.error,
      );
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'N/A';
    final local = dt.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[local.month - 1];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month ${local.day}, ${local.year} at $hour:$minute';
  }

  void _handleResend(BuildContext context, String invitationId) {
    if (isResending) return;
    setState(() => isResending = true);

    context.read(adminManagementProvider.notifier).resendInvitation(
      invitationId,
      onSuccess: (message) {
        if (!mounted) return;
        setState(() => isResending = false);
        context.showFlushbar(
          title: 'Invitation Resent',
          message: message,
          type: FlushbarType.success,
        );
        context.invalidate(listInvitationsProvider(const ListInvitationsParams()));
      },
      onError: (message) {
        if (!mounted) return;
        setState(() => isResending = false);
        context.showFlushbar(
          title: 'Resend Failed',
          message: message,
          type: FlushbarType.error,
        );
      },
    );
  }

  void _handleRevoke(BuildContext context, String invitationId) {
    if (isRevoking) return;
    setState(() => isRevoking = true);

    context.read(adminManagementProvider.notifier).revokeInvitation(
      invitationId,
      onSuccess: (message) {
        if (!mounted) return;
        setState(() => isRevoking = false);
        context.showFlushbar(
          title: 'Invitation Revoked',
          message: message,
          type: FlushbarType.success,
        );
        context.invalidate(listInvitationsProvider(const ListInvitationsParams()));
      },
      onError: (message) {
        if (!mounted) return;
        setState(() => isRevoking = false);
        context.showFlushbar(
          title: 'Revoke Failed',
          message: message,
          type: FlushbarType.error,
        );
      },
    );
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;
    final invitation = component.invitation;
    final status = (invitation.status ?? 'PENDING').toUpperCase();
    final role = invitation.role ?? AdminRoles.support;
    final invitationId = invitation.id;

    final canResend = status == 'PENDING' || status == 'EXPIRED';
    final canRevoke = status == 'PENDING';

    return div(classes: 'space-y-6 text-xs pb-8 relative', [
      // ─────────────────────────────────────────────────────────────
      // Hero Invitation Card
      // ─────────────────────────────────────────────────────────────
      div(
        classes:
            'p-5 rounded-2xl border flex flex-col space-y-4 relative overflow-hidden shadow-xl transition-all',
        styles: Styles(
          backgroundColor: Color(colorScheme.inputBg),
          raw: {'border-color': colorScheme.borderInput},
        ),
        [
          // Top accent gradient bar
          div(
            classes:
                'absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-amber-500 via-orange-400 to-emerald-500',
            [],
          ),
          div(classes: 'flex items-start justify-between gap-3 pt-1', [
            div(classes: 'flex items-center space-x-3.5 min-w-0 flex-1', [
              // Mail Icon Avatar
              div(
                classes:
                    'w-14 h-14 rounded-2xl border-2 shadow-md shrink-0 flex items-center justify-center bg-gradient-to-br from-amber-500/20 to-orange-500/10',
                styles: Styles(raw: {'border-color': 'rgba(245, 158, 11, 0.4)'}),
                [
                  div(
                    classes: 'w-7 h-7 text-amber-500',
                    [const AppIcon(AppIcons.externalLink)],
                  ),
                ],
              ),
              div(classes: 'space-y-1 min-w-0 flex-1', [
                h4(
                  classes: 'font-black text-base truncate tracking-tight',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text(invitation.email ?? 'No email')],
                ),
                div(
                  classes:
                      'flex items-center space-x-2 text-xs font-mono cursor-pointer hover:text-amber-500 transition-colors group',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  events: {
                    'click': (_) => _copyToClipboard(
                        context, invitation.email ?? '', 'Invitation Email'),
                  },
                  [
                    span(classes: 'truncate font-medium', [
                      Component.text('Tap to copy email address'),
                    ]),
                    div(
                      classes:
                          'w-3.5 h-3.5 group-hover:text-amber-500 transition-colors shrink-0',
                      styles: Styles(color: Color(colorScheme.textMuted)),
                      [const AppIcon(AppIcons.copy)],
                    ),
                  ],
                ),
              ]),
            ]),
          ]),

          // Badges & Actions Row
          div(
            classes:
                'flex flex-wrap items-center justify-between gap-2.5 pt-3.5 border-t',
            styles: Styles(raw: {'border-color': colorScheme.border}),
            [
              div(classes: 'flex items-center space-x-2', [
                // Status Badge
                _buildStatusBadge(status, isDark),
                // Role Badge
                _buildRoleBadge(role, isDark),
              ]),

              div(classes: 'flex items-center space-x-2', [
                // Copy Invitation ID
                button(
                  type: ButtonType.button,
                  classes:
                      'px-3 py-1.5 rounded-xl text-[11px] font-bold transition-all cursor-pointer flex items-center space-x-1.5 active:scale-95 shadow-sm border',
                  styles: Styles(
                    backgroundColor: isDark
                        ? Color.rgba(245, 158, 11, 0.15)
                        : Color.rgba(245, 158, 11, 0.08),
                    color: isDark
                        ? Color.rgba(252, 211, 77, 1.0)
                        : Color.rgba(180, 83, 9, 1.0),
                    raw: {
                      'border-color': isDark
                          ? 'rgba(245, 158, 11, 0.35)'
                          : 'rgba(245, 158, 11, 0.25)'
                    },
                  ),
                  events: {
                    'click': (_) => _copyToClipboard(
                        context, invitation.id ?? '', 'Invitation ID'),
                  },
                  [
                    div(
                      classes: 'w-3.5 h-3.5 shrink-0',
                      styles: Styles(color: Color(colorScheme.primary)),
                      [const AppIcon(AppIcons.copy)],
                    ),
                    span([Component.text('Copy ID')]),
                  ],
                ),
              ]),
            ],
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // Invitation Details Grid
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3', [
        _buildSectionHeader('Invitation Overview', AppIcons.documents, context),
        div(
          classes: 'divide-y border rounded-2xl overflow-hidden shadow-sm',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {
              'border-color': colorScheme.border,
              'divide-color': colorScheme.borderInput,
            },
          ),
          [
            _buildDetailRow('Invitation ID', invitation.id ?? 'N/A', context, isCopyable: true),
            _buildDetailRow('Recipient Email', invitation.email ?? 'N/A', context, isCopyable: true),
            _buildDetailRow('Assigned Role', AdminRoles.labelOf(role), context),
            _buildDetailRow('Status', _formatStatusLabel(status), context),
            _buildDetailRow('Invited By ID', invitation.invitedById ?? 'N/A', context, isCopyable: invitation.invitedById != null),
            _buildDetailRow('Expires At', _formatDateTime(invitation.expiresAt), context),
            _buildDetailRow('Created At', _formatDateTime(invitation.createdAt), context),
          ],
        ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Management Actions Card
      // ─────────────────────────────────────────────────────────────
      if (invitationId != null && invitationId.isNotEmpty)
        div(classes: 'space-y-3', [
          _buildSectionHeader('Management Actions', AppIcons.setting, context),
          div(
            classes: 'p-4 rounded-2xl border space-y-4 shadow-sm',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              raw: {'border-color': colorScheme.border},
            ),
            [
              // Resend Action Box
              if (canResend)
                div(
                  classes: 'p-3.5 rounded-xl border flex flex-col sm:flex-row sm:items-center justify-between gap-3',
                  styles: Styles(
                    backgroundColor: isDark
                        ? Color.rgba(16, 185, 129, 0.05)
                        : Color.rgba(16, 185, 129, 0.03),
                    raw: {
                      'border-color': isDark
                          ? 'rgba(16, 185, 129, 0.25)'
                          : 'rgba(16, 185, 129, 0.15)'
                    },
                  ),
                  [
                    div(classes: 'space-y-0.5', [
                      h5(
                        classes: 'font-bold text-xs',
                        styles: Styles(
                          color: isDark
                              ? Color.rgba(110, 231, 183, 1.0)
                              : Color.rgba(4, 120, 87, 1.0),
                        ),
                        [Component.text('Resend Invitation')],
                      ),
                      p(
                        classes: 'text-[11px] font-medium',
                        styles: Styles(color: Color(colorScheme.textSecondary)),
                        [
                          Component.text('Send a fresh invitation email to ${invitation.email ?? 'recipient'}.'),
                        ],
                      ),
                    ]),
                    button(
                      type: ButtonType.button,
                      onClick: isResending ? null : () => _handleResend(context, invitationId),
                      classes:
                          'px-3.5 py-1.5 rounded-xl text-xs font-bold text-white transition-all cursor-pointer shadow-sm flex items-center space-x-1.5 border-none shrink-0',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.primary),
                        raw: {
                          if (isResending) 'opacity': '0.7',
                        },
                      ),
                      [
                        if (isResending)
                          span(classes: 'animate-spin text-sm', [Component.text('◌')])
                        else
                          const AppIcon(AppIcons.externalLink),
                        span([Component.text(isResending ? 'Sending...' : 'Resend Email')]),
                      ],
                    ),
                  ],
                ),

              // Revoke Action Box
              if (canRevoke)
                div(
                  classes: 'p-3.5 rounded-xl border flex flex-col sm:flex-row sm:items-center justify-between gap-3',
                  styles: Styles(
                    backgroundColor: isDark
                        ? Color.rgba(244, 63, 94, 0.05)
                        : Color.rgba(244, 63, 94, 0.03),
                    raw: {
                      'border-color': isDark
                          ? 'rgba(244, 63, 94, 0.25)'
                          : 'rgba(244, 63, 94, 0.15)'
                    },
                  ),
                  [
                    div(classes: 'space-y-0.5', [
                      h5(
                        classes: 'font-bold text-xs',
                        styles: Styles(
                          color: isDark
                              ? Color.rgba(253, 164, 175, 1.0)
                              : Color.rgba(190, 18, 60, 1.0),
                        ),
                        [Component.text('Revoke Invitation')],
                      ),
                      p(
                        classes: 'text-[11px] font-medium',
                        styles: Styles(color: Color(colorScheme.textSecondary)),
                        [
                          Component.text('Cancel this pending invitation and prevent the link from being used.'),
                        ],
                      ),
                    ]),
                    button(
                      type: ButtonType.button,
                      onClick: isRevoking ? null : () => _handleRevoke(context, invitationId),
                      classes:
                          'px-3.5 py-1.5 rounded-xl text-xs font-bold text-white transition-all cursor-pointer shadow-sm flex items-center space-x-1.5 border-none shrink-0',
                      styles: Styles(
                        backgroundColor: Color.rgba(225, 29, 72, 1.0),
                        raw: {
                          if (isRevoking) 'opacity': '0.7',
                        },
                      ),
                      [
                        if (isRevoking)
                          span(classes: 'animate-spin text-sm', [Component.text('◌')])
                        else
                          const AppIcon(AppIcons.close),
                        span([Component.text(isRevoking ? 'Revoking...' : 'Revoke Invitation')]),
                      ],
                    ),
                  ],
                ),

              if (!canResend && !canRevoke)
                p(
                  classes: 'text-xs font-medium text-center py-2',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  [
                    Component.text(
                      'No further actions available for this ${status.toLowerCase()} invitation.',
                    ),
                  ],
                ),
            ],
          ),
        ]),
    ]);
  }

  Component _buildStatusBadge(String status, bool isDark) {
    Color bg;
    Color fg;
    String border;

    switch (status) {
      case 'ACCEPTED':
        bg = isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1);
        fg = isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0);
        border = isDark ? 'rgba(16, 185, 129, 0.4)' : 'rgba(16, 185, 129, 0.25)';
        break;
      case 'REVOKED':
      case 'EXPIRED':
        bg = isDark ? Color.rgba(244, 63, 94, 0.18) : Color.rgba(244, 63, 94, 0.1);
        fg = isDark ? Color.rgba(253, 164, 175, 1.0) : Color.rgba(190, 18, 60, 1.0);
        border = isDark ? 'rgba(244, 63, 94, 0.4)' : 'rgba(244, 63, 94, 0.25)';
        break;
      case 'PENDING':
      default:
        bg = isDark ? Color.rgba(245, 158, 11, 0.18) : Color.rgba(245, 158, 11, 0.1);
        fg = isDark ? Color.rgba(252, 211, 77, 1.0) : Color.rgba(180, 83, 9, 1.0);
        border = isDark ? 'rgba(245, 158, 11, 0.4)' : 'rgba(245, 158, 11, 0.25)';
        break;
    }

    return span(
      classes:
          'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border',
      styles: Styles(
        backgroundColor: bg,
        color: fg,
        raw: {'border-color': border},
      ),
      [Component.text(_formatStatusLabel(status))],
    );
  }

  Component _buildRoleBadge(String role, bool isDark) {
    return span(
      classes:
          'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border',
      styles: Styles(
        backgroundColor: isDark
            ? Color.rgba(14, 165, 233, 0.18)
            : Color.rgba(14, 165, 233, 0.1),
        color: isDark
            ? Color.rgba(125, 211, 252, 1.0)
            : Color.rgba(3, 105, 161, 1.0),
        raw: {
          'border-color': isDark
              ? 'rgba(14, 165, 233, 0.4)'
              : 'rgba(14, 165, 233, 0.25)'
        },
      ),
      [Component.text(AdminRoles.labelOf(role))],
    );
  }

  String _formatStatusLabel(String status) {
    if (status.isEmpty) return 'Pending';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  Component _buildSectionHeader(
      String title, AppIcons icon, BuildContext context) {
    final colorScheme = context.colorScheme;
    return div(classes: 'flex items-center space-x-2 pt-2', [
      div(
        classes: 'w-4 h-4 shrink-0',
        styles: Styles(color: Color(colorScheme.primary)),
        [AppIcon(icon)],
      ),
      h4(
        classes: 'font-bold text-xs uppercase tracking-wider',
        styles: Styles(color: Color(colorScheme.textHeading)),
        [Component.text(title)],
      ),
    ]);
  }

  Component _buildDetailRow(
    String label,
    String value,
    BuildContext context, {
    bool isCopyable = false,
  }) {
    final colorScheme = context.colorScheme;
    return div(
      classes:
          'p-3.5 flex flex-col sm:flex-row sm:items-center justify-between gap-2 hover:bg-black/5 transition-colors',
      [
        span(
          classes: 'text-xs font-semibold shrink-0',
          styles: Styles(color: Color(colorScheme.textSecondary)),
          [Component.text(label)],
        ),
        div(
          classes: 'flex items-center space-x-2 min-w-0',
          [
            span(
              classes:
                  'text-xs font-mono font-medium truncate select-all',
              styles: Styles(color: Color(colorScheme.textPrimary)),
              [Component.text(value)],
            ),
            if (isCopyable && value != 'N/A' && value.isNotEmpty)
              button(
                type: ButtonType.button,
                onClick: () => _copyToClipboard(context, value, label),
                classes:
                    'p-1 rounded-md hover:bg-amber-500/10 hover:text-amber-500 transition-colors cursor-pointer border-none bg-transparent',
                styles: Styles(color: Color(colorScheme.textMuted)),
                [
                  const div(
                    classes: 'w-3.5 h-3.5',
                    [AppIcon(AppIcons.copy)],
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
