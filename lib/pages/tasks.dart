import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/task_detail_side_panel.dart';
import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/providers/admin_tasks_providers.dart';
import '../core/providers/ui_state_provider.dart';

@client
class TasksPage extends StatelessComponent {
  const TasksPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex-1 space-y-6 relative', [
      const _Header(),
      const _Dashboard(),
      const _TasksTable(),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Header Section Component
// ─────────────────────────────────────────────────────────────

class _Header extends StatelessComponent {
  const _Header();

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-4', [
      div([
        p(
          classes: 'text-xs sm:text-sm mt-1 font-medium transition-colors',
          styles: Styles(color: Color(colorScheme.textSecondary)),
          [
            Component.text(
              'Monitor, inspect, and analyze all platform tasks, dispatch statuses, pricing breakdowns, and provider assignments.',
            ),
          ],
        ),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Self-contained Component: _Dashboard
// ─────────────────────────────────────────────────────────────

class _Dashboard extends StatelessComponent {
  const _Dashboard();

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));
    final statsAsync = context.watch(adminTaskStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final total = stats?.total ?? 0;
        final completed = stats?.completed ?? 0;
        final open = stats?.open ?? 0;
        final cancelled = stats?.cancelled ?? 0;

        return div(classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4', [
          _MetricCard(
            title: 'Total Tasks',
            count: '$total',
            icon: AppIcons.tasks,
            colorScheme: colorScheme,
          ),
          _MetricCard(
            title: 'Completed Tasks',
            count: '$completed',
            icon: AppIcons.checkCircle,
            colorScheme: colorScheme,
          ),
          _MetricCard(
            title: 'Open Tasks',
            count: '$open',
            icon: AppIcons.calendar,
            colorScheme: colorScheme,
          ),
          _MetricCard(
            title: 'Cancelled Tasks',
            count: '$cancelled',
            icon: AppIcons.disputes,
            colorScheme: colorScheme,
          ),
        ]);
      },
      loading: () => div(classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 animate-pulse', [
        for (var i = 0; i < 4; i++)
          div(
            classes: 'h-24 rounded-2xl border p-5',
            styles: Styles(
              backgroundColor: colorScheme.isDark ? Color.rgba(31, 45, 39, 0.8) : Color.rgba(226, 232, 240, 0.8),
              raw: {'border-color': colorScheme.border},
            ),
            [],
          ),
      ]),
      error: (_, __) => div([]),
    );
  }
}

class _MetricCard extends StatelessComponent {
  final String title;
  final String count;
  final AppIcons icon;
  final ColorScheme colorScheme;

  const _MetricCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.colorScheme,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes:
          'border rounded-2xl p-5 shadow-sm flex items-start justify-between relative overflow-hidden transition-all',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'space-y-2', [
          span(
            classes: 'text-xs font-semibold uppercase tracking-wider',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text(title)],
          ),
          div(classes: 'flex items-baseline space-x-2', [
            span(
              classes: 'text-2xl sm:text-3xl font-extrabold tracking-tight',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text(count)],
            ),
          ]),
        ]),
        div(
          classes: 'w-10 h-10 rounded-full flex items-center justify-center shrink-0 shadow-sm',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.primary),
          ),
          [
            AppIcon(icon),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Self-contained Component: _TasksTable
// ─────────────────────────────────────────────────────────────

class _TasksTable extends StatefulComponent {
  const _TasksTable();

  @override
  State<_TasksTable> createState() => _TasksTableState();
}

class _TasksTableState extends State<_TasksTable> {
  String selectedStatus = '';
  String searchQuery = '';
  String _searchInputValue = '';
  Timer? _searchDebounceTimer;
  int currentPage = 1;
  String sortBy = 'created_at';
  bool sortDesc = true;

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchInput(dynamic value) {
    _searchInputValue = value.toString();
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
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
    return '$month ${local.day}, ${local.year} at $hour:$minute';
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '₦0.00';
    return '₦${amount.toStringAsFixed(2)}';
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    final tasksAsync = context.watch(
      listTasksProvider(
        ListTasksParams(
          search: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
          status: selectedStatus.isEmpty ? null : [selectedStatus],
          sortBy: sortBy,
          sortDesc: sortDesc,
          page: currentPage,
          perPage: 20,
        ),
      ),
    );

    return div(
      classes: 'border rounded-2xl shadow-sm transition-all overflow-hidden p-5 sm:p-6 space-y-5',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        // Aligned Toolbar Filters (Search Left, Status Pills Right with smooth horizontal scrolling support)
        div(classes: 'flex flex-col lg:flex-row lg:items-center justify-between gap-4 pb-1', [
          // Search Input
          div(classes: 'relative w-full lg:w-72 shrink-0', [
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
              attributes: {'placeholder': 'Search tasks by title or ID...'},
              onInput: _onSearchInput,
            ),
          ]),

          // Status Filter Pills (Horizontal scrollable inside available container space)
          div(
            classes:
                'flex items-center gap-1.5 overflow-x-auto max-w-full min-w-0 flex-1 lg:justify-end py-1 no-scrollbar',
            styles: Styles(raw: {
              '-webkit-overflow-scrolling': 'touch',
              'scrollbar-width': 'none',
              'ms-overflow-style': 'none',
            }),
            [
              span(
                classes: 'text-[11px] font-bold uppercase tracking-wider shrink-0 mr-1',
                styles: Styles(color: Color(colorScheme.textMuted)),
                [Component.text('Status:')],
              ),
              for (final status in [
                '',
                'DRAFT',
                'SEARCHING',
                'ASSIGNED',
                'IN_PROGRESS',
                'COMPLETED',
                'CANCELLED'
              ])
                button(
                  onClick: () => setState(() {
                    selectedStatus = status;
                    currentPage = 1;
                  }),
                  classes:
                      'px-3 py-1.5 rounded-lg transition-all cursor-pointer text-[11px] font-bold border shrink-0 whitespace-nowrap',
                  styles: selectedStatus == status
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
                  [Component.text(status.isEmpty ? 'All' : status.replaceAll('_', ' '))],
                ),
            ],
          ),
        ]),

        // Tasks Data Content
        tasksAsync.when(
          data: (paginatedData) {
            final items = paginatedData?.items ?? [];
            final total = paginatedData?.total ?? items.length;
            final perPage = paginatedData?.perPage ?? 20;

            if (items.isEmpty) {
              return _EmptyState(
                colorScheme: colorScheme,
                message: 'No tasks found',
                onReset: () {
                  _searchDebounceTimer?.cancel();
                  _searchInputValue = '';
                  setState(() {
                    searchQuery = '';
                    selectedStatus = '';
                    currentPage = 1;
                  });
                },
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
                          th(classes: 'p-3.5 pl-4', [Component.text('Task & Category')]),
                          th(classes: 'p-3.5', [Component.text('Total Price')]),
                          th(classes: 'p-3.5', [Component.text('Provider Payout')]),
                          th(classes: 'p-3.5 text-center', [Component.text('Status')]),
                          th(classes: 'p-3.5', [Component.text('Created At')]),
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
                        for (final task in items)
                          tr(
                            classes: 'hover:opacity-90 transition-colors cursor-pointer',
                            events: {
                              'click': (_) => TaskDetailSidePanel.show(context, task),
                            },
                            [
                              // Task Title & Category
                              td(
                                classes: 'p-3.5 pl-4',
                                [
                                  div(classes: 'flex items-center space-x-3', [
                                    div(
                                      classes:
                                          'w-8 h-8 rounded-full flex items-center justify-center shrink-0 shadow-xs',
                                      styles: Styles(
                                        backgroundColor: Color(colorScheme.inputBg),
                                        color: Color(colorScheme.primary),
                                      ),
                                      [const AppIcon(AppIcons.tasks)],
                                    ),
                                    div(classes: 'min-w-0', [
                                      div(
                                        classes: 'font-bold text-xs truncate max-w-xs sm:max-w-sm',
                                        styles: Styles(color: Color(colorScheme.textHeading)),
                                        [Component.text(task.title ?? 'Untitled Task')],
                                      ),
                                      div(
                                        classes: 'text-[11px] truncate',
                                        styles: Styles(color: Color(colorScheme.textMuted)),
                                        [Component.text(task.category?.name ?? task.categoryId ?? 'General')],
                                      ),
                                    ]),
                                  ]),
                                ],
                              ),
                              // Total Price
                              td(
                                classes: 'p-3.5 font-mono font-bold text-xs whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textHeading)),
                                [Component.text(_formatCurrency(task.customerTotalPrice))],
                              ),
                              // Provider Payout
                              td(
                                classes: 'p-3.5 font-mono text-xs text-emerald-500 font-bold whitespace-nowrap',
                                [Component.text(_formatCurrency(task.providerPayout))],
                              ),
                              // Status
                              td(
                                classes: 'p-3.5 text-center whitespace-nowrap',
                                [
                                  _StatusPill(
                                    status: task.status ?? 'DRAFT',
                                    colorScheme: colorScheme,
                                  ),
                                ],
                              ),
                              // Created At
                              td(
                                classes: 'p-3.5 text-xs font-medium whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textMuted)),
                                [Component.text(_formatDateTime(task.createdAt))],
                              ),
                              // Action Button
                              td(classes: 'p-3.5 pr-4 text-center whitespace-nowrap', [
                                button(
                                  onClick: () => TaskDetailSidePanel.show(context, task),
                                  classes:
                                      'text-white text-[11px] font-bold px-3 py-1.5 rounded-lg shadow-xs cursor-pointer transition-all border-none',
                                  styles: Styles(backgroundColor: Color(colorScheme.primary)),
                                  [Component.text('View')],
                                ),
                              ]),
                            ],
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
    );
  }
}

class _StatusPill extends StatelessComponent {
  final String status;
  final ColorScheme colorScheme;

  const _StatusPill({
    required this.status,
    required this.colorScheme,
  });

  @override
  Component build(BuildContext context) {
    final st = status.toUpperCase();
    final isDark = colorScheme.isDark;
    Color bg;
    Color fg;
    String border;

    switch (st) {
      case 'COMPLETED':
        bg = isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1);
        fg = isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0);
        border = isDark ? 'rgba(16, 185, 129, 0.4)' : 'rgba(16, 185, 129, 0.25)';
        break;
      case 'IN_PROGRESS':
      case 'ASSIGNED':
        bg = isDark ? Color.rgba(59, 130, 246, 0.18) : Color.rgba(59, 130, 246, 0.1);
        fg = isDark ? Color.rgba(147, 197, 253, 1.0) : Color.rgba(29, 78, 216, 1.0);
        border = isDark ? 'rgba(59, 130, 246, 0.4)' : 'rgba(59, 130, 246, 0.25)';
        break;
      case 'CANCELLED':
      case 'EXPIRED':
        bg = isDark ? Color.rgba(244, 63, 94, 0.18) : Color.rgba(244, 63, 94, 0.1);
        fg = isDark ? Color.rgba(253, 164, 175, 1.0) : Color.rgba(190, 18, 60, 1.0);
        border = isDark ? 'rgba(244, 63, 94, 0.4)' : 'rgba(244, 63, 94, 0.25)';
        break;
      case 'SEARCHING':
      case 'POSTED':
        bg = isDark ? Color.rgba(245, 158, 11, 0.18) : Color.rgba(245, 158, 11, 0.1);
        fg = isDark ? Color.rgba(252, 211, 77, 1.0) : Color.rgba(180, 83, 9, 1.0);
        border = isDark ? 'rgba(245, 158, 11, 0.4)' : 'rgba(245, 158, 11, 0.25)';
        break;
      case 'DRAFT':
      default:
        bg = isDark ? Color.rgba(148, 163, 184, 0.18) : Color.rgba(148, 163, 184, 0.1);
        fg = isDark ? Color.rgba(203, 213, 225, 1.0) : Color.rgba(71, 85, 105, 1.0);
        border = isDark ? 'rgba(148, 163, 184, 0.4)' : 'rgba(148, 163, 184, 0.25)';
        break;
    }

    return span(
      classes:
          'px-2.5 py-1 rounded-lg text-[10.5px] font-extrabold tracking-wider uppercase border font-mono inline-block whitespace-nowrap',
      styles: Styles(
        backgroundColor: bg,
        color: fg,
        raw: {'border-color': border},
      ),
      [Component.text(st.replaceAll('_', ' '))],
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
          Component.text('Showing $start to $end of $total tasks'),
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
          [const AppIcon(AppIcons.tasks)],
        ),
        p(
          classes: 'text-sm font-bold',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text(message)],
        ),
        p(
          classes: 'text-xs font-medium max-w-sm mx-auto',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('No task records matched your search query or status filter parameters.')],
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
          [Component.text('Failed to load tasks: $errorMsg')],
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
