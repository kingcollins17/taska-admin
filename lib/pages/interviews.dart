import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/providers/admin_user_providers.dart';
import '../core/providers/ui_state_provider.dart';

@client
class InterviewsPage extends StatelessComponent {
  const InterviewsPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex-1 space-y-6 relative', [
      const _Header(),
      const _Dashboard(),
      const _InterviewsTable(),
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
              'Schedule provider interviews, review meeting details, and manage vetting results.',
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
    final interviewsAsync = context.watch(adminInterviewsProvider(const GetInterviewsParams(page: 1)));

    return interviewsAsync.when(
      data: (paginatedData) {
        final items = paginatedData?.items ?? [];
        final total = paginatedData?.total ?? items.length;
        final passedCount = items.where((interview) => interview.status == 'PASSED').length;
        final scheduledCount = items.where((interview) => interview.status == 'SCHEDULED' || interview.status == 'RESCHEDULED').length;
        final failedCount = items.where((interview) => interview.status == 'FAILED' || interview.status == 'CANCELLED').length;

        return div(classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4', [
          _MetricCard(
            title: 'Total Interviews',
            count: '$total',
            icon: AppIcons.calendar,
            colorScheme: colorScheme,
          ),
          _MetricCard(
            title: 'Passed Interviews',
            count: '$passedCount',
            icon: AppIcons.checkCircle,
            colorScheme: colorScheme,
          ),
          _MetricCard(
            title: 'Scheduled',
            count: '$scheduledCount',
            icon: AppIcons.documents,
            colorScheme: colorScheme,
          ),
          _MetricCard(
            title: 'Failed / Cancelled',
            count: '$failedCount',
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
// Self-contained Component: _InterviewsTable
// ─────────────────────────────────────────────────────────────

class _InterviewsTable extends StatefulComponent {
  const _InterviewsTable();

  @override
  State<_InterviewsTable> createState() => _InterviewsTableState();
}

class _InterviewsTableState extends State<_InterviewsTable> {
  String searchQuery = '';
  String _searchInputValue = '';
  Timer? _searchDebounceTimer;

  String selectedStatus = 'All';
  bool isFilterOpen = false;
  int currentPage = 1;

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchInput(dynamic value) {
    _searchInputValue = value.toString();
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        searchQuery = _searchInputValue;
        currentPage = 1;
      });
    });
  }

  void _resetFilters() {
    _searchDebounceTimer?.cancel();
    _searchInputValue = '';
    setState(() {
      searchQuery = '';
      selectedStatus = 'All';
      currentPage = 1;
    });
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));
    final interviewsAsync = context.watch(
      adminInterviewsProvider(
        GetInterviewsParams(
          search: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
          status: selectedStatus == 'All' ? null : selectedStatus,
          page: currentPage,
        ),
      ),
    );

    return interviewsAsync.when(
      data: (paginatedData) {
        final items = paginatedData?.items ?? [];
        final total = paginatedData?.total ?? items.length;
        final perPage = paginatedData?.perPage ?? 20;

        return div(
          classes: 'border rounded-2xl p-5 sm:p-6 shadow-sm space-y-5 transition-all',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            // Toolbar Header
            div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4', [
              div(classes: 'flex items-center space-x-2', [
                h3(
                  classes: 'text-base font-bold tracking-tight',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text('Provider Interviews')],
                ),
                span(
                  classes: 'text-xs font-semibold px-2.5 py-0.5 rounded-full',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.primary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  [
                    Component.text('${items.length} of $total'),
                  ],
                ),
              ]),

              div(classes: 'flex flex-wrap items-center gap-3', [
                // Search Input Pill with 2s Timer Debounce
                div(classes: 'relative w-full sm:w-64', [
                  div(
                    classes: 'absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none',
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
                    attributes: {'placeholder': 'Search by notes, meeting link, user...'},
                    onInput: _onSearchInput,
                  ),
                ]),

                // Filter Toggle Button
                button(
                  onClick: () {
                    setState(() {
                      isFilterOpen = !isFilterOpen;
                    });
                  },
                  classes:
                      'text-xs font-semibold px-3.5 py-2 rounded-xl flex items-center space-x-1.5 transition-colors cursor-pointer border',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.textPrimary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  [
                    const AppIcon(AppIcons.filter),
                    span([Component.text('Filter')]),
                  ],
                ),

                // Schedule Interview Primary Button
                button(
                  onClick: () {
                    context.showFlushbar(
                      title: 'Schedule Interview',
                      message: 'Opening interview scheduling workspace...',
                      type: FlushbarType.info,
                    );
                  },
                  classes:
                      'active:scale-[0.98] text-white text-xs font-bold px-4 py-2 rounded-xl flex items-center space-x-1.5 shadow-sm transition-all cursor-pointer border-none',
                  styles: Styles(backgroundColor: Color(colorScheme.primary)),
                  [
                    const AppIcon(AppIcons.calendar),
                    span([Component.text('Schedule Interview')]),
                  ],
                ),
              ]),
            ]),

            // Expandable Status Filter Bar
            if (isFilterOpen)
              _FilterBar(
                colorScheme: colorScheme,
                selectedStatus: selectedStatus,
                onSelectStatus: (status) => setState(() {
                  selectedStatus = status;
                  currentPage = 1;
                }),
              ),

            // Interviews Data Table Content
            if (items.isEmpty)
              _EmptyState(colorScheme: colorScheme, onResetFilters: _resetFilters)
            else
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
                          th(classes: 'p-3.5 pl-4', [Component.text('Interview ID')]),
                          th(classes: 'p-3.5', [Component.text('User ID')]),
                          th(classes: 'p-3.5', [Component.text('Admin ID')]),
                          th(classes: 'p-3.5', [Component.text('Scheduled At')]),
                          th(classes: 'p-3.5 text-center', [Component.text('Status')]),
                          th(classes: 'p-3.5', [Component.text('Notes')]),
                          th(classes: 'p-3.5 pr-4 text-center', [Component.text('Meeting Link')]),
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
                        for (final item in items)
                          tr(classes: 'hover:opacity-90 transition-colors', [
                            td(
                              classes: 'p-3.5 pl-4 font-mono font-bold text-[11px]',
                              styles: Styles(color: Color(colorScheme.textMuted)),
                              [Component.text(_formatId(item.id))],
                            ),
                            td(
                              classes: 'p-3.5 font-mono text-xs font-semibold',
                              styles: Styles(color: Color(colorScheme.textPrimary)),
                              [Component.text(_formatId(item.userId))],
                            ),
                            td(
                              classes: 'p-3.5 font-mono text-xs font-semibold',
                              styles: Styles(color: Color(colorScheme.textSecondary)),
                              [Component.text(_formatId(item.adminId))],
                            ),
                            td(
                              classes: 'p-3.5 text-xs font-medium',
                              styles: Styles(color: Color(colorScheme.textMuted)),
                              [Component.text(_formatDate(item.scheduledAt))],
                            ),
                            td(
                              classes: 'p-3.5 text-center',
                              [_InterviewBadgePill(status: item.status ?? 'UNKNOWN', colorScheme: colorScheme)],
                            ),
                            td(
                              classes: 'p-3.5 text-xs max-w-xs truncate font-medium',
                              styles: Styles(color: Color(colorScheme.textSecondary)),
                              [Component.text(item.notes ?? 'N/A')],
                            ),
                            td(classes: 'p-3.5 pr-4 text-center', [
                              if (item.meetingLink != null && item.meetingLink!.isNotEmpty)
                                a(
                                  href: item.meetingLink!,
                                  target: Target.blank,
                                  classes:
                                      'text-white text-[11px] font-bold px-3 py-1.5 rounded-lg shadow-xs transition-all inline-block',
                                  styles: Styles(backgroundColor: Color(colorScheme.primary)),
                                  [Component.text('Join Meeting')],
                                )
                              else
                                span(
                                  classes: 'text-[11px] font-medium text-slate-400',
                                  [Component.text('No Link')],
                                ),
                            ]),
                          ]),
                      ],
                    ),
                  ]),
                ],
              ),

            // Pagination Footer Bar
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
          ],
        );
      },
      loading: () => _ShimmerLoading(colorScheme: colorScheme),
      error: (err, stack) => _ErrorState(
        colorScheme: colorScheme,
        errorMsg: err.toString(),
        onRetry: () => setState(() {}),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Supporting Sub-components (Classes)
// ─────────────────────────────────────────────────────────────

class _FilterBar extends StatelessComponent {
  final ColorScheme colorScheme;
  final String selectedStatus;
  final void Function(String status) onSelectStatus;

  const _FilterBar({
    required this.colorScheme,
    required this.selectedStatus,
    required this.onSelectStatus,
  });

  @override
  Component build(BuildContext context) {
    final options = ['All', 'SCHEDULED', 'COMPLETED', 'PASSED', 'FAILED', 'CANCELLED', 'RESCHEDULED'];

    return div(
      classes: 'p-3.5 rounded-xl border flex flex-wrap items-center gap-2 text-xs font-semibold',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.borderInput},
      ),
      [
        span(
          classes: 'mr-1 text-[11px] uppercase tracking-wider font-bold',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Filter Status:')],
        ),
        for (final opt in options)
          _StatusChip(
            statusLabel: opt,
            isSelected: selectedStatus == opt,
            colorScheme: colorScheme,
            onSelect: () => onSelectStatus(opt),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessComponent {
  final String statusLabel;
  final bool isSelected;
  final ColorScheme colorScheme;
  final void Function() onSelect;

  const _StatusChip({
    required this.statusLabel,
    required this.isSelected,
    required this.colorScheme,
    required this.onSelect,
  });

  @override
  Component build(BuildContext context) {
    return button(
      onClick: onSelect,
      classes: 'px-3 py-1 rounded-lg transition-all cursor-pointer text-xs font-bold',
      styles: isSelected
          ? Styles(
              backgroundColor: Color(colorScheme.primary),
              color: Color('#FFFFFF'),
            )
          : Styles(
              backgroundColor: Color(colorScheme.surface),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
      [Component.text(statusLabel)],
    );
  }
}

class _InterviewBadgePill extends StatelessComponent {
  final String status;
  final ColorScheme colorScheme;

  const _InterviewBadgePill({
    required this.status,
    required this.colorScheme,
  });

  @override
  Component build(BuildContext context) {
    String badgeClasses =
        'px-3 py-1 rounded-full text-[11px] font-bold inline-block leading-none tracking-tight border';
    String bg = 'bg-slate-100 dark:bg-slate-800';
    String text = 'text-slate-700 dark:text-slate-300';
    String border = 'border-slate-200 dark:border-slate-700';

    if (status == 'PASSED' || status == 'COMPLETED') {
      bg = 'bg-emerald-50 dark:bg-emerald-950/60';
      text = 'text-emerald-600 dark:text-emerald-400';
      border = 'border-emerald-200/50 dark:border-emerald-800/50';
    } else if (status == 'SCHEDULED' || status == 'RESCHEDULED') {
      bg = 'bg-amber-50 dark:bg-amber-950/60';
      text = 'text-amber-600 dark:text-amber-400';
      border = 'border-amber-200/50 dark:border-amber-800/50';
    } else if (status == 'FAILED' || status == 'CANCELLED') {
      bg = 'bg-rose-50 dark:bg-rose-950/60';
      text = 'text-rose-600 dark:text-rose-400';
      border = 'border-rose-200/50 dark:border-rose-800/50';
    }

    return span(classes: '$badgeClasses $bg $text $border', [
      Component.text(status),
    ]);
  }
}

class _EmptyState extends StatelessComponent {
  final ColorScheme colorScheme;
  final void Function() onResetFilters;

  const _EmptyState({
    required this.colorScheme,
    required this.onResetFilters,
  });

  @override
  Component build(BuildContext context) {
    return div(classes: 'py-14 text-center space-y-2', [
      p(
        classes: 'text-sm font-semibold',
        styles: Styles(color: Color(colorScheme.textSecondary)),
        [Component.text('No matching interviews found')],
      ),
      button(
        onClick: onResetFilters,
        classes: 'text-xs font-bold hover:underline cursor-pointer',
        styles: Styles(color: Color(colorScheme.primary)),
        [Component.text('Reset filters')],
      ),
    ]);
  }
}

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
    final maxPage = (total / perPage).ceil().clamp(1, 9999);

    return div(
      classes:
          'flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-2 text-xs transition-colors',
      styles: Styles(color: Color(colorScheme.textMuted)),
      [
        div(classes: 'font-medium', [
          Component.text('Showing page $currentPage of $maxPage (Total: $total entries)'),
        ]),
        div(classes: 'flex items-center space-x-1.5 font-semibold self-end sm:self-auto', [
          button(
            onClick: onPreviousPage,
            classes: 'px-2.5 py-1 rounded-lg border transition-colors cursor-pointer text-xs font-semibold',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [Component.text('Previous')],
          ),
          span(
            classes: 'px-3 py-1 rounded-lg font-bold text-white shadow-xs text-xs',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [Component.text('$currentPage')],
          ),
          button(
            onClick: onNextPage,
            classes: 'px-2.5 py-1 rounded-lg border transition-colors cursor-pointer text-xs font-semibold',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [Component.text('Next')],
          ),
        ]),
      ],
    );
  }
}

class _ShimmerLoading extends StatelessComponent {
  final ColorScheme colorScheme;

  const _ShimmerLoading({required this.colorScheme});

  @override
  Component build(BuildContext context) {
    final blockColor = colorScheme.isDark ? Color.rgba(31, 45, 39, 0.8) : Color.rgba(226, 232, 240, 0.8);

    return div(
      classes: 'border rounded-2xl p-6 space-y-6 animate-pulse',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'h-10 w-full rounded-xl', styles: Styles(backgroundColor: blockColor), []),
        div(classes: 'h-72 w-full rounded-xl', styles: Styles(backgroundColor: blockColor), []),
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
      classes: 'rounded-2xl p-12 text-center border space-y-4',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'text-rose-500 font-bold text-lg', [Component.text('Failed to Load Interviews')]),
        p(classes: 'text-xs text-slate-400 max-w-md mx-auto', [Component.text(errorMsg)]),
        button(
          onClick: onRetry,
          classes: 'px-4 py-2 text-xs font-bold text-white rounded-xl shadow-xs cursor-pointer',
          styles: Styles(backgroundColor: Color(colorScheme.primary)),
          [Component.text('Retry')],
        ),
      ],
    );
  }
}

String _formatId(String? id) {
  if (id == null || id.isEmpty) return '#INT-000';
  if (id.length <= 8) return '#$id';
  return '#${id.substring(0, 8)}...';
}

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return 'N/A';
  try {
    final dt = DateTime.parse(raw);
    return '${dt.day}/${dt.month}/${dt.year}';
  } catch (_) {
    return raw;
  }
}
