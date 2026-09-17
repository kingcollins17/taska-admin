import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/audit_log_detail_side_panel.dart';
import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/providers/admin_management_providers.dart';
import '../core/providers/ui_state_provider.dart';

@client
class AuditLogsPage extends StatefulComponent {
  const AuditLogsPage({super.key});

  @override
  State<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends State<AuditLogsPage> {
  String selectedResourceType = '';
  String selectedAction = '';
  String searchQuery = '';
  String _searchInputValue = '';
  Timer? _searchDebounceTimer;
  int currentPage = 1;

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchInput(dynamic value) {
    _searchInputValue = value.toString();
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 600), () {
      setState(() {
        searchQuery = _searchInputValue;
        currentPage = 1;
      });
    });
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
    return '$month ${local.day}, ${local.year} $hour:$minute:$second';
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    final String? queryAction = selectedAction.isNotEmpty
        ? selectedAction
        : (searchQuery.trim().isNotEmpty ? searchQuery.trim().toUpperCase() : null);

    final logsAsync = context.watch(
      listAuditLogsProvider(
        ListAuditLogsParams(
          resourceType: selectedResourceType.isEmpty ? null : selectedResourceType,
          action: queryAction,
          page: currentPage,
          perPage: 20,
        ),
      ),
    );

    return div(classes: 'flex-1 space-y-6 relative', [
      // Page Sub-header
      div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-4', [
        div([
          p(
            classes: 'text-xs sm:text-sm mt-1 font-medium transition-colors',
            styles: Styles(color: Color(colorScheme.textSecondary)),
            [
              Component.text(
                'Query and inspect immutable admin audit logs, security events, resource mutations, and system action records.',
              ),
            ],
          ),
        ]),
      ]),

      // Main Audit Container Card
      div(
        classes: 'border rounded-2xl shadow-sm transition-all overflow-hidden p-5 sm:p-6 space-y-5',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [
          // Toolbar Filters
          div(classes: 'flex flex-col lg:flex-row lg:items-center justify-between gap-4', [
            // Search Input
            div(classes: 'relative w-full lg:w-72', [
              div(
                classes: 'absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none',
                styles: Styles(color: Color(colorScheme.placeholder)),
                [const AppIcon(AppIcons.search)],
              ),
              input(
                type: InputType.text,
                value: _searchInputValue,
                classes:
                    'w-full border rounded-xl pl-9 pr-4 py-2 text-xs font-medium focus:outline-none focus:ring-2 transition-all',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  color: Color(colorScheme.textPrimary),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                attributes: {'placeholder': 'Search action or resource type...'},
                onInput: _onSearchInput,
              ),
            ]),

            // Resource Type Filter Pills
            div(classes: 'flex flex-wrap items-center gap-2', [
              span(
                classes: 'text-[11px] font-bold uppercase tracking-wider mr-1',
                styles: Styles(color: Color(colorScheme.textMuted)),
                [Component.text('Resource:')],
              ),
              for (final type in ['', 'ADMIN', 'USER', 'DISPUTE', 'TASK', 'GUARANTOR'])
                button(
                  onClick: () => setState(() {
                    selectedResourceType = type;
                    currentPage = 1;
                  }),
                  classes:
                      'px-3 py-1.5 rounded-lg transition-all cursor-pointer text-[11px] font-bold border',
                  styles: selectedResourceType == type
                      ? Styles(
                          backgroundColor: Color(colorScheme.primary),
                          color: Color('#FFFFFF'),
                          raw: {'border-color': colorScheme.primary},
                        )
                      : Styles(
                          backgroundColor: Color(colorScheme.inputBg),
                          color: Color(colorScheme.textSecondary),
                          raw: {'border-color': colorScheme.borderInput},
                        ),
                  [Component.text(type.isEmpty ? 'All' : type)],
                ),
            ]),
          ]),

          // Audit Logs Data Content
          logsAsync.when(
            data: (paginatedData) {
              final items = paginatedData?.items ?? [];
              final total = paginatedData?.total ?? items.length;
              final perPage = paginatedData?.perPage ?? 20;

              if (items.isEmpty) {
                return _EmptyState(
                  colorScheme: colorScheme,
                  message: 'No audit logs found',
                  onReset: () => setState(() {
                    selectedResourceType = '';
                    selectedAction = '';
                    searchQuery = '';
                    _searchInputValue = '';
                    currentPage = 1;
                  }),
                );
              }

              return div(classes: 'space-y-5', [
                div(
                  classes: 'overflow-x-auto rounded-xl border transition-colors',
                  styles: Styles(raw: {'border-color': colorScheme.border}),
                  [
                    table(classes: 'w-full text-left border-collapse text-xs', [
                      thead(
                        classes: 'uppercase tracking-wider text-[10.5px] border-b font-bold',
                        styles: Styles(
                          backgroundColor: Color(colorScheme.inputBg),
                          color: Color(colorScheme.textMuted),
                          raw: {'border-color': colorScheme.border},
                        ),
                        [
                          tr([
                            th(classes: 'p-3.5 pl-4', [Component.text('Action')]),
                            th(classes: 'p-3.5', [Component.text('Resource')]),
                            th(classes: 'p-3.5', [Component.text('Admin Actor')]),
                            th(classes: 'p-3.5', [Component.text('Reason / Notes')]),
                            th(classes: 'p-3.5', [Component.text('Timestamp')]),
                            th(classes: 'p-3.5 pr-4 text-center', [Component.text('Actions')]),
                          ]),
                        ],
                      ),
                      tbody(
                        classes: 'divide-y font-medium',
                        styles: Styles(
                          color: Color(colorScheme.textPrimary),
                          raw: {'border-color': colorScheme.border},
                        ),
                        [
                          for (final log in items)
                            tr(
                              [
                                // Action Badge
                                td(
                                  classes: 'p-3.5 pl-4',
                                  [
                                    div(classes: 'flex items-center space-x-2.5', [
                                      div(
                                        classes:
                                            'w-7 h-7 rounded-lg flex items-center justify-center shrink-0 shadow-xs',
                                        styles: Styles(
                                          backgroundColor: Color(colorScheme.inputBg),
                                          color: Color(colorScheme.primary),
                                        ),
                                        [const AppIcon(AppIcons.auditLogs)],
                                      ),
                                      _buildActionPill(log.action ?? 'UNKNOWN', colorScheme),
                                    ]),
                                  ],
                                ),
                                // Resource Type & ID
                                td(classes: 'p-3.5', [
                                  div(classes: 'flex flex-col space-y-0.5', [
                                    span(
                                      classes: 'font-bold text-xs uppercase tracking-tight',
                                      styles: Styles(color: Color(colorScheme.textHeading)),
                                      [Component.text(log.resourceType ?? 'N/A')],
                                    ),
                                    if (log.resourceId != null && log.resourceId!.isNotEmpty)
                                      span(
                                        classes: 'text-[10.5px] font-mono font-medium truncate max-w-xs',
                                        styles: Styles(color: Color(colorScheme.textMuted)),
                                        [Component.text('#${log.resourceId}')],
                                      ),
                                  ]),
                                ]),
                                // Admin Actor ID
                                td(
                                  classes: 'p-3.5 font-mono text-[11px]',
                                  styles: Styles(color: Color(colorScheme.textSecondary)),
                                  [Component.text(log.adminId ?? 'System')],
                                ),
                                // Reason
                                td(
                                  classes: 'p-3.5 text-xs max-w-xs truncate',
                                  styles: Styles(color: Color(colorScheme.textSecondary)),
                                  [Component.text(log.reason ?? '—')],
                                ),
                                // Timestamp
                                td(
                                  classes: 'p-3.5 text-xs font-medium shrink-0',
                                  styles: Styles(color: Color(colorScheme.textMuted)),
                                  [Component.text(_formatDateTime(log.createdAt))],
                                ),
                                // Action Button
                                td(classes: 'p-3.5 pr-4 text-center', [
                                  button(
                                    onClick: () => AuditLogDetailSidePanel.show(context, log),
                                    classes:
                                        'text-white text-[11px] font-bold px-3 py-1.5 rounded-lg shadow-xs cursor-pointer transition-all border-none',
                                    styles: Styles(backgroundColor: Color(colorScheme.primary)),
                                    [Component.text('View')],
                                  ),
                                ]),
                              ],
                              classes: 'hover:opacity-90 transition-colors cursor-pointer',
                              events: {
                                'click': (_) => AuditLogDetailSidePanel.show(context, log),
                              },
                            ),
                        ],
                      ),
                    ]),
                  ],
                ),
                // Pagination Footer
                _PaginationFooter(
                  colorScheme: colorScheme,
                  total: total,
                  perPage: perPage,
                  currentPage: currentPage,
                  onPreviousPage: () {
                    if (currentPage > 1) {
                      setState(() => currentPage--);
                    }
                  },
                  onNextPage: () {
                    final maxPage = (total / perPage).ceil().clamp(1, 9999);
                    if (currentPage < maxPage) {
                      setState(() => currentPage++);
                    }
                  },
                ),
              ]);
            },
            loading: () => _ShimmerLoading(colorScheme: colorScheme),
            error: (err, _) => _ErrorState(
              colorScheme: colorScheme,
              errorMsg: err.toString(),
              onRetry: () => setState(() {}),
            ),
          ),
        ],
      ),
    ]);
  }

  Component _buildActionPill(String action, ColorScheme colorScheme) {
    final act = action.toUpperCase();
    final isDark = colorScheme.isDark;
    Color bg;
    Color fg;
    String border;

    if (act.contains('CREATE') || act.contains('INVITE') || act.contains('REACTIVATE')) {
      bg = isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1);
      fg = isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0);
      border = isDark ? 'rgba(16, 185, 129, 0.4)' : 'rgba(16, 185, 129, 0.25)';
    } else if (act.contains('DELETE') || act.contains('DEACTIVATE') || act.contains('REVOKE')) {
      bg = isDark ? Color.rgba(244, 63, 94, 0.18) : Color.rgba(244, 63, 94, 0.1);
      fg = isDark ? Color.rgba(253, 164, 175, 1.0) : Color.rgba(190, 18, 60, 1.0);
      border = isDark ? 'rgba(244, 63, 94, 0.4)' : 'rgba(244, 63, 94, 0.25)';
    } else if (act.contains('UPDATE') || act.contains('ROLE') || act.contains('CHANGE')) {
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
          'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border font-mono',
      styles: Styles(
        backgroundColor: bg,
        color: fg,
        raw: {'border-color': border},
      ),
      [Component.text(act)],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Pagination Footer
// ─────────────────────────────────────────────────────────────

class _PaginationFooter extends StatelessComponent {
  final ColorScheme colorScheme;
  final int total;
  final int perPage;
  final int currentPage;
  final void Function() onPreviousPage;
  final void Function() onNextPage;

  const _PaginationFooter({
    required this.colorScheme,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Component build(BuildContext context) {
    final start = total == 0 ? 0 : (currentPage - 1) * perPage + 1;
    final end = (currentPage * perPage).clamp(0, total);
    final maxPage = (total / perPage).ceil().clamp(1, 9999);

    return div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-2', [
      span(
        classes: 'text-xs font-medium',
        styles: Styles(color: Color(colorScheme.textMuted)),
        [
          Component.text('Showing $start to $end of $total audit events'),
        ],
      ),
      div(classes: 'flex items-center space-x-2', [
        button(
          onClick: onPreviousPage,
          disabled: currentPage <= 1,
          classes: currentPage <= 1
              ? 'px-3 py-1.5 rounded-lg text-xs font-bold transition-all cursor-not-allowed border opacity-40'
              : 'px-3 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer border hover:opacity-80 active:scale-95',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textPrimary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          [Component.text('Previous')],
        ),
        span(
          classes: 'text-xs font-bold px-2 font-mono',
          styles: Styles(color: Color(colorScheme.textSecondary)),
          [Component.text('$currentPage / $maxPage')],
        ),
        button(
          onClick: onNextPage,
          disabled: currentPage >= maxPage,
          classes: currentPage >= maxPage
              ? 'px-3 py-1.5 rounded-lg text-xs font-bold transition-all cursor-not-allowed border opacity-40'
              : 'px-3 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer border hover:opacity-80 active:scale-95',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textPrimary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          [Component.text('Next')],
        ),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// States: Shimmer Loading, Empty, Error
// ─────────────────────────────────────────────────────────────

class _ShimmerLoading extends StatelessComponent {
  final ColorScheme colorScheme;

  const _ShimmerLoading({required this.colorScheme});

  @override
  Component build(BuildContext context) {
    return div(classes: 'space-y-3 animate-pulse py-4', [
      for (var i = 0; i < 5; i++)
        div(
          classes: 'h-14 rounded-xl border',
          styles: Styles(
            backgroundColor:
                colorScheme.isDark ? Color.rgba(31, 45, 39, 0.8) : Color.rgba(226, 232, 240, 0.8),
            raw: {'border-color': colorScheme.border},
          ),
          [],
        ),
    ]);
  }
}

class _EmptyState extends StatelessComponent {
  final ColorScheme colorScheme;
  final String message;
  final void Function() onReset;

  const _EmptyState({
    required this.colorScheme,
    required this.message,
    required this.onReset,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'py-14 text-center space-y-3 border rounded-2xl p-6',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.borderInput},
      ),
      [
        div(
          classes: 'w-12 h-12 rounded-full mx-auto flex items-center justify-center opacity-60',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            color: Color(colorScheme.textMuted),
          ),
          [const AppIcon(AppIcons.auditLogs)],
        ),
        p(
          classes: 'text-sm font-bold',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text(message)],
        ),
        p(
          classes: 'text-xs font-medium max-w-sm mx-auto',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('No audit events matched your search query or resource filter parameters.')],
        ),
        div(classes: 'pt-2', [
          button(
            onClick: onReset,
            classes: 'px-4 py-2 rounded-xl text-xs font-bold text-white transition-all cursor-pointer border-none shadow-sm',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [Component.text('Clear Filters')],
          ),
        ]),
      ],
    );
  }
}

class _ErrorState extends StatelessComponent {
  final ColorScheme colorScheme;
  final String errorMsg;
  final void Function() onRetry;

  const _ErrorState({
    required this.colorScheme,
    required this.errorMsg,
    required this.onRetry,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'py-10 text-center space-y-3 border rounded-2xl p-6 border-rose-500/30 bg-rose-500/5',
      [
        p(
          classes: 'text-xs font-bold text-rose-500',
          [Component.text('Failed to load audit logs: $errorMsg')],
        ),
        button(
          onClick: onRetry,
          classes: 'px-4 py-2 rounded-xl text-xs font-bold text-white transition-all cursor-pointer border-none shadow-sm bg-rose-500 hover:bg-rose-600',
          [Component.text('Retry Request')],
        ),
      ],
    );
  }
}
