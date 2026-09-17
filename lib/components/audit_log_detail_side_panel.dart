import 'dart:convert';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/admin_management/admin_audit_log_item.dart';
import '../core/providers/ui_state_provider.dart';

class AuditLogDetailSidePanel extends StatelessComponent {
  final AdminAuditLogItem log;

  const AuditLogDetailSidePanel({
    required this.log,
    super.key,
  });

  static void show(BuildContext context, AdminAuditLogItem log) {
    context.showSidePanel(
      AuditLogDetailSidePanel(log: log),
      title: 'Audit Log Details',
    );
  }

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
    final second = local.second.toString().padLeft(2, '0');
    return '$month ${local.day}, ${local.year} at $hour:$minute:$second';
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;
    final action = (log.action ?? 'UNKNOWN').toUpperCase();
    final metaDataJson = log.metaData != null && log.metaData!.isNotEmpty
        ? const JsonEncoder.withIndent('  ').convert(log.metaData)
        : null;

    return div(classes: 'space-y-6 text-xs pb-8 relative', [
      // ─────────────────────────────────────────────────────────────
      // Hero Audit Event Card
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
                'absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-500 via-indigo-400 to-emerald-500',
            [],
          ),
          div(classes: 'flex items-start justify-between gap-3 pt-1', [
            div(classes: 'flex items-center space-x-3.5 min-w-0 flex-1', [
              // Icon Avatar
              div(
                classes:
                    'w-14 h-14 rounded-2xl border-2 shadow-md shrink-0 flex items-center justify-center bg-gradient-to-br from-indigo-500/20 to-blue-500/10',
                styles: Styles(raw: {'border-color': 'rgba(99, 102, 241, 0.4)'}),
                [
                  div(
                    classes: 'w-7 h-7 text-indigo-500',
                    [const AppIcon(AppIcons.auditLogs)],
                  ),
                ],
              ),
              div(classes: 'space-y-1 min-w-0 flex-1', [
                h4(
                  classes: 'font-black text-base truncate tracking-tight',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text(action)],
                ),
                p(
                  classes: 'text-xs font-mono truncate font-medium',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  [Component.text('Event ID: ${log.id ?? 'N/A'}')],
                ),
              ]),
            ]),
          ]),

          // Badges & Copy ID Action Row
          div(
            classes:
                'flex flex-wrap items-center justify-between gap-2.5 pt-3.5 border-t',
            styles: Styles(raw: {'border-color': colorScheme.border}),
            [
              div(classes: 'flex items-center space-x-2', [
                _buildActionBadge(action, isDark),
                if (log.resourceType != null && log.resourceType!.isNotEmpty)
                  span(
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
                    [Component.text(log.resourceType!)],
                  ),
              ]),

              div(classes: 'flex items-center space-x-2', [
                button(
                  type: ButtonType.button,
                  classes:
                      'px-3 py-1.5 rounded-xl text-[11px] font-bold transition-all cursor-pointer flex items-center space-x-1.5 active:scale-95 shadow-sm border',
                  styles: Styles(
                    backgroundColor: isDark
                        ? Color.rgba(99, 102, 241, 0.15)
                        : Color.rgba(99, 102, 241, 0.08),
                    color: isDark
                        ? Color.rgba(165, 180, 252, 1.0)
                        : Color.rgba(67, 56, 202, 1.0),
                    raw: {
                      'border-color': isDark
                          ? 'rgba(99, 102, 241, 0.35)'
                          : 'rgba(99, 102, 241, 0.25)'
                    },
                  ),
                  events: {
                    'click': (_) =>
                        _copyToClipboard(context, log.id ?? '', 'Log Event ID'),
                  },
                  [
                    div(
                      classes: 'w-3.5 h-3.5 shrink-0',
                      styles: Styles(color: Color(colorScheme.primary)),
                      [const AppIcon(AppIcons.copy)],
                    ),
                    span([Component.text('Copy Log ID')]),
                  ],
                ),
              ]),
            ],
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // Audit Event Overview
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3', [
        _buildSectionHeader('Audit Event Info', AppIcons.documents, context),
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
            _buildDetailRow('Event ID', log.id ?? 'N/A', context, isCopyable: true),
            _buildDetailRow('Actor Admin ID', log.adminId ?? 'N/A', context, isCopyable: true),
            _buildDetailRow('Action Type', action, context),
            _buildDetailRow('Target Resource Type', log.resourceType ?? 'N/A', context),
            _buildDetailRow('Target Resource ID', log.resourceId ?? 'N/A', context, isCopyable: log.resourceId != null),
            _buildDetailRow('Reason / Notes', log.reason ?? 'None provided', context),
            _buildDetailRow('Origin IP Address', log.ipAddress ?? 'N/A', context, isCopyable: log.ipAddress != null),
            _buildDetailRow('Client User Agent', log.userAgent ?? 'N/A', context),
            _buildDetailRow('Timestamp', _formatDateTime(log.createdAt), context),
          ],
        ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Context Metadata Viewer
      // ─────────────────────────────────────────────────────────────
      if (metaDataJson != null)
        div(classes: 'space-y-3', [
          _buildSectionHeader('Payload Metadata', AppIcons.security, context),
          div(
            classes: 'p-4 rounded-2xl border space-y-3 shadow-sm',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              raw: {'border-color': colorScheme.border},
            ),
            [
              div(classes: 'flex items-center justify-between', [
                span(
                  classes: 'text-xs font-bold uppercase tracking-wider',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  [Component.text('Raw Event Metadata')],
                ),
                button(
                  type: ButtonType.button,
                  onClick: () => _copyToClipboard(context, metaDataJson, 'Event Metadata'),
                  classes:
                      'px-2.5 py-1 rounded-lg text-[11px] font-bold border cursor-pointer transition-all flex items-center space-x-1',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.primary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  [
                    const div(
                      classes: 'w-3 h-3',
                      [AppIcon(AppIcons.copy)],
                    ),
                    span([Component.text('Copy JSON')]),
                  ],
                ),
              ]),
              pre(
                classes:
                    'p-3.5 rounded-xl border text-[11.5px] font-mono overflow-x-auto leading-relaxed max-h-80 overflow-y-auto select-all',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  color: Color(colorScheme.textPrimary),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                [Component.text(metaDataJson)],
              ),
            ],
          ),
        ]),
    ]);
  }

  Component _buildActionBadge(String action, bool isDark) {
    Color bg;
    Color fg;
    String border;

    if (action.contains('CREATE') || action.contains('INVITE') || action.contains('REACTIVATE')) {
      bg = isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1);
      fg = isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0);
      border = isDark ? 'rgba(16, 185, 129, 0.4)' : 'rgba(16, 185, 129, 0.25)';
    } else if (action.contains('DELETE') || action.contains('DEACTIVATE') || action.contains('REVOKE')) {
      bg = isDark ? Color.rgba(244, 63, 94, 0.18) : Color.rgba(244, 63, 94, 0.1);
      fg = isDark ? Color.rgba(253, 164, 175, 1.0) : Color.rgba(190, 18, 60, 1.0);
      border = isDark ? 'rgba(244, 63, 94, 0.4)' : 'rgba(244, 63, 94, 0.25)';
    } else if (action.contains('UPDATE') || action.contains('ROLE') || action.contains('CHANGE')) {
      bg = isDark ? Color.rgba(245, 158, 11, 0.18) : Color.rgba(245, 158, 11, 0.1);
      fg = isDark ? Color.rgba(252, 211, 77, 1.0) : Color.rgba(180, 83, 9, 1.0);
      border = isDark ? 'rgba(245, 158, 11, 0.4)' : 'rgba(245, 158, 11, 0.25)';
    } else {
      bg = isDark ? Color.rgba(99, 102, 241, 0.18) : Color.rgba(99, 102, 241, 0.1);
      fg = isDark ? Color.rgba(165, 180, 252, 1.0) : Color.rgba(67, 56, 202, 1.0);
      border = isDark ? 'rgba(99, 102, 241, 0.4)' : 'rgba(99, 102, 241, 0.25)';
    }

    return span(
      classes:
          'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border',
      styles: Styles(
        backgroundColor: bg,
        color: fg,
        raw: {'border-color': border},
      ),
      [Component.text(action)],
    );
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
                    'p-1 rounded-md hover:bg-indigo-500/10 hover:text-indigo-500 transition-colors cursor-pointer border-none bg-transparent',
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
