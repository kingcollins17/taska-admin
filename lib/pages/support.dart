import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../components/support_case_detail_side_panel.dart';
import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/providers/admin_support_providers.dart';
import '../core/providers/ui_state_provider.dart';

@client
class SupportPage extends StatelessComponent {
  const SupportPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex-1 space-y-6 relative', [
      const _Header(),
      const _SupportTable(),
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
              'Manage customer and provider support tickets, inquiries, SLA timelines, and issue resolution.',
            ),
          ],
        ),
      ]),
      button(
        type: ButtonType.button,
        onClick: () {
          Router.of(context).push('/support/workspace');
        },
        classes: 'px-4 py-2 rounded-xl text-white font-bold text-xs shadow-md transition-all cursor-pointer flex items-center space-x-2 active:scale-95 border-none shrink-0 self-start sm:self-auto',
        styles: Styles(backgroundColor: Color(colorScheme.primary)),
        [
          div(classes: 'w-4 h-4', [const AppIcon(AppIcons.externalLink)]),
          span([Component.text('Workspace View')]),
        ],
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Support Cases Table Component
// ─────────────────────────────────────────────────────────────

class _SupportTable extends StatefulComponent {
  const _SupportTable();

  @override
  State<_SupportTable> createState() => _SupportTableState();
}

class _SupportTableState extends State<_SupportTable> {
  String searchQuery = '';
  String _searchInputValue = '';
  Timer? _searchDebounceTimer;

  // Multi-select status filter state
  Set<String> selectedStatuses = {};
  String selectedPriority = 'All';
  bool isFilterOpen = false;
  int currentPage = 1;

  final List<String> allStatusOptions = [
    'OPEN',
    'IN_PROGRESS',
    'WAITING_FOR_USER',
    'WAITING_FOR_PROVIDER',
    'WAITING_FOR_INTERNAL',
    'RESOLVED',
    'CLOSED',
    'AUTO_CLOSED',
  ];

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

  void _toggleStatusFilter(String status) {
    setState(() {
      if (selectedStatuses.contains(status)) {
        selectedStatuses.remove(status);
      } else {
        selectedStatuses.add(status);
      }
      currentPage = 1;
    });
  }

  void _resetFilters() {
    _searchDebounceTimer?.cancel();
    _searchInputValue = '';
    setState(() {
      searchQuery = '';
      selectedStatuses.clear();
      selectedPriority = 'All';
      currentPage = 1;
    });
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));
    final casesAsync = context.watch(
      adminSupportCasesProvider(
        GetAdminSupportCasesParams(
          search: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
          status: selectedStatuses.isEmpty ? null : selectedStatuses.toList(),
          priority: selectedPriority == 'All' ? null : selectedPriority,
          page: currentPage,
          perPage: 20,
        ),
      ),
    );

    return casesAsync.when(
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
                  [Component.text('Support Cases & Tickets')],
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
                // Search Input Pill
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
                    attributes: {'placeholder': 'Search by subject, case #, user...'},
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
                  styles: isFilterOpen || selectedStatuses.isNotEmpty || selectedPriority != 'All'
                      ? Styles(
                          backgroundColor: Color(colorScheme.primary),
                          color: Color('#FFFFFF'),
                          raw: {'border-color': colorScheme.primary},
                        )
                      : Styles(
                          backgroundColor: Color(colorScheme.inputBg),
                          color: Color(colorScheme.textPrimary),
                          raw: {'border-color': colorScheme.borderInput},
                        ),
                  [
                    const AppIcon(AppIcons.filter),
                    span([Component.text(selectedStatuses.isNotEmpty ? 'Filters (${selectedStatuses.length})' : 'Filter')]),
                  ],
                ),

                if (selectedStatuses.isNotEmpty || selectedPriority != 'All' || searchQuery.isNotEmpty)
                  button(
                    onClick: _resetFilters,
                    classes: 'text-xs font-bold text-rose-500 hover:underline cursor-pointer border-none bg-transparent',
                    [Component.text('Reset')],
                  ),
              ]),
            ]),

            // Expandable Multi-Select Status & Priority Filter Bar
            if (isFilterOpen)
              _MultiSelectFilterBar(
                colorScheme: colorScheme,
                allStatuses: allStatusOptions,
                selectedStatuses: selectedStatuses,
                selectedPriority: selectedPriority,
                onToggleStatus: _toggleStatusFilter,
                onSelectPriority: (pri) => setState(() {
                  selectedPriority = pri;
                  currentPage = 1;
                }),
                onClearAll: _resetFilters,
              ),

            // Support Cases Data Table
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
                          th(classes: 'p-3.5 pl-4', [Component.text('Case #')]),
                          th(classes: 'p-3.5', [Component.text('Subject & Summary')]),
                          th(classes: 'p-3.5', [Component.text('Initiator')]),
                          th(classes: 'p-3.5 text-center', [Component.text('Type')]),
                          th(classes: 'p-3.5 text-center', [Component.text('Priority')]),
                          th(classes: 'p-3.5 text-center', [Component.text('Status')]),
                          th(classes: 'p-3.5', [Component.text('Created At')]),
                          th(classes: 'p-3.5 pr-4 text-center', [Component.text('Action')]),
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
                              [Component.text(item.caseNumber ?? _formatId(item.id))],
                            ),
                            td(
                              classes: 'p-3.5 max-w-xs',
                              [
                                div(
                                  classes: 'font-bold text-xs truncate',
                                  styles: Styles(color: Color(colorScheme.textHeading)),
                                  [Component.text(item.subject ?? 'No Subject')],
                                ),
                                if (item.description != null && item.description!.isNotEmpty)
                                  div(
                                    classes: 'text-[11px] truncate',
                                    styles: Styles(color: Color(colorScheme.textMuted)),
                                    [Component.text(item.description!)],
                                  ),
                              ],
                            ),
                            td(
                              classes: 'p-3.5',
                              [
                                if (item.initiator != null) ...[
                                  div(
                                    classes: 'font-semibold text-xs truncate',
                                    styles: Styles(color: Color(colorScheme.textPrimary)),
                                    [Component.text('${item.initiator?.firstName ?? ''} ${item.initiator?.lastName ?? ''}'.trim().isEmpty ? 'Initiator' : '${item.initiator?.firstName ?? ''} ${item.initiator?.lastName ?? ''}')],
                                  ),
                                  if (item.initiator?.email != null)
                                    div(
                                      classes: 'text-[10.5px] font-mono truncate',
                                      styles: Styles(color: Color(colorScheme.textMuted)),
                                      [Component.text(item.initiator!.email!)],
                                    ),
                                ] else
                                  span(
                                    classes: 'text-slate-400 font-mono text-[11px]',
                                    [Component.text(_formatId(item.customerId ?? item.initiatedBy))],
                                  ),
                              ],
                            ),
                            td(classes: 'p-3.5 text-center', [
                              span(
                                classes: 'px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider border',
                                styles: Styles(
                                  backgroundColor: Color(colorScheme.inputBg),
                                  color: Color(colorScheme.textSecondary),
                                  raw: {'border-color': colorScheme.borderInput},
                                ),
                                [Component.text(item.type ?? 'GENERAL')],
                              ),
                            ]),
                            td(classes: 'p-3.5 text-center', [
                              _PriorityPill(priority: item.priority ?? 'NORMAL', colorScheme: colorScheme),
                            ]),
                            td(classes: 'p-3.5 text-center', [
                              _StatusPill(status: item.status ?? 'OPEN', colorScheme: colorScheme),
                            ]),
                            td(
                              classes: 'p-3.5 text-xs font-medium',
                              styles: Styles(color: Color(colorScheme.textMuted)),
                              [Component.text(_formatDate(item.createdAt))],
                            ),
                            td(classes: 'p-3.5 pr-4 text-center', [
                              button(
                                onClick: () {
                                  if (item.id != null) {
                                    SupportCaseDetailSidePanel.show(context, item.id!, caseItem: item);
                                  }
                                },
                                classes:
                                    'text-white text-[11px] font-bold px-3 py-1.5 rounded-lg shadow-xs transition-all cursor-pointer border-none',
                                styles: Styles(backgroundColor: Color(colorScheme.primary)),
                                [Component.text('View Details')],
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
// Multi-Select Status & Priority Filter Bar
// ─────────────────────────────────────────────────────────────

class _MultiSelectFilterBar extends StatelessComponent {
  final ColorScheme colorScheme;
  final List<String> allStatuses;
  final Set<String> selectedStatuses;
  final String selectedPriority;
  final void Function(String status) onToggleStatus;
  final void Function(String priority) onSelectPriority;
  final void Function() onClearAll;

  const _MultiSelectFilterBar({
    required this.colorScheme,
    required this.allStatuses,
    required this.selectedStatuses,
    required this.selectedPriority,
    required this.onToggleStatus,
    required this.onSelectPriority,
    required this.onClearAll,
  });

  @override
  Component build(BuildContext context) {
    final priorityOptions = ['All', 'LOW', 'NORMAL', 'HIGH', 'URGENT'];

    return div(
      classes: 'p-4 rounded-xl border space-y-3.5 transition-all shadow-2xs',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.borderInput},
      ),
      [
        // Status Multi-select Chips
        div(classes: 'space-y-1.5', [
          div(classes: 'flex items-center justify-between', [
            span(
              classes: 'text-[11px] font-black uppercase tracking-wider block',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text('Filter Statuses (Multi-Select):')],
            ),
            if (selectedStatuses.isNotEmpty)
              button(
                type: ButtonType.button,
                onClick: onClearAll,
                classes: 'text-[10.5px] font-bold text-rose-500 hover:underline cursor-pointer border-none bg-transparent',
                [Component.text('Clear Statuses')],
              ),
          ]),

          div(classes: 'flex flex-wrap items-center gap-1.5', [
            for (final st in allStatuses)
              _MultiSelectChip(
                label: st,
                isSelected: selectedStatuses.contains(st),
                colorScheme: colorScheme,
                onToggle: () => onToggleStatus(st),
              ),
          ]),
        ]),

        // Priority Filter Chips
        div(classes: 'space-y-1.5 pt-2 border-t', styles: Styles(raw: {'border-color': colorScheme.borderInput}), [
          span(
            classes: 'text-[11px] font-black uppercase tracking-wider block',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text('Filter Priority:')],
          ),
          div(classes: 'flex flex-wrap items-center gap-1.5', [
            for (final pri in priorityOptions)
              button(
                type: ButtonType.button,
                onClick: () => onSelectPriority(pri),
                classes: 'px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer border',
                styles: selectedPriority == pri
                    ? Styles(
                        backgroundColor: Color(colorScheme.primary),
                        color: Color('#FFFFFF'),
                        raw: {'border-color': colorScheme.primary},
                      )
                    : Styles(
                        backgroundColor: Color(colorScheme.surface),
                        color: Color(colorScheme.textSecondary),
                        raw: {'border-color': colorScheme.borderInput},
                      ),
                [Component.text(pri)],
              ),
          ]),
        ]),
      ],
    );
  }
}

class _MultiSelectChip extends StatelessComponent {
  final String label;
  final bool isSelected;
  final ColorScheme colorScheme;
  final void Function() onToggle;

  const _MultiSelectChip({
    required this.label,
    required this.isSelected,
    required this.colorScheme,
    required this.onToggle,
  });

  @override
  Component build(BuildContext context) {
    return button(
      type: ButtonType.button,
      onClick: onToggle,
      classes:
          'px-2.5 py-1 rounded-lg text-[11px] font-bold transition-all cursor-pointer flex items-center space-x-1.5 border active:scale-95',
      styles: isSelected
          ? Styles(
              backgroundColor: Color(colorScheme.primary),
              color: Color('#FFFFFF'),
              raw: {'border-color': colorScheme.primary},
            )
          : Styles(
              backgroundColor: Color(colorScheme.surface),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
      [
        span(classes: 'text-[10px]', [Component.text(isSelected ? '✓' : '+')]),
        span([Component.text(label)]),
      ],
    );
  }
}

class _StatusPill extends StatelessComponent {
  final String status;
  final ColorScheme colorScheme;

  const _StatusPill({required this.status, required this.colorScheme});

  @override
  Component build(BuildContext context) {
    String bg = 'bg-slate-100 dark:bg-slate-800';
    String text = 'text-slate-700 dark:text-slate-300';
    String border = 'border-slate-200 dark:border-slate-700';

    switch (status.toUpperCase()) {
      case 'OPEN':
      case 'IN_PROGRESS':
        bg = 'bg-amber-50 dark:bg-amber-950/60';
        text = 'text-amber-600 dark:text-amber-400';
        border = 'border-amber-200/50 dark:border-amber-800/50';
        break;
      case 'RESOLVED':
      case 'CLOSED':
      case 'AUTO_CLOSED':
        bg = 'bg-emerald-50 dark:bg-emerald-950/60';
        text = 'text-emerald-600 dark:text-emerald-400';
        border = 'border-emerald-200/50 dark:border-emerald-800/50';
        break;
      case 'WAITING_FOR_USER':
      case 'WAITING_FOR_PROVIDER':
      case 'WAITING_FOR_INTERNAL':
        bg = 'bg-sky-50 dark:bg-sky-950/60';
        text = 'text-sky-600 dark:text-sky-400';
        border = 'border-sky-200/50 dark:border-sky-800/50';
        break;
    }

    return span(
      classes: 'px-2.5 py-1 rounded-full text-[10.5px] font-bold inline-block leading-none tracking-tight border $bg $text $border',
      [Component.text(status)],
    );
  }
}

class _PriorityPill extends StatelessComponent {
  final String priority;
  final ColorScheme colorScheme;

  const _PriorityPill({required this.priority, required this.colorScheme});

  @override
  Component build(BuildContext context) {
    String bg = 'bg-slate-100 dark:bg-slate-800';
    String text = 'text-slate-700 dark:text-slate-300';
    String border = 'border-slate-200 dark:border-slate-700';

    switch (priority.toUpperCase()) {
      case 'HIGH':
      case 'URGENT':
        bg = 'bg-rose-50 dark:bg-rose-950/60';
        text = 'text-rose-600 dark:text-rose-400';
        border = 'border-rose-200/50 dark:border-rose-800/50';
        break;
      case 'NORMAL':
        bg = 'bg-sky-50 dark:bg-sky-950/60';
        text = 'text-sky-600 dark:text-sky-400';
        border = 'border-sky-200/50 dark:border-sky-800/50';
        break;
    }

    return span(
      classes: 'px-2 py-1 rounded-full text-[10.5px] font-bold inline-block leading-none tracking-tight border $bg $text $border',
      [Component.text(priority)],
    );
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
        [Component.text('No matching support cases found')],
      ),
      button(
        onClick: onResetFilters,
        classes: 'text-xs font-bold hover:underline cursor-pointer border-none bg-transparent',
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
        div(classes: 'text-rose-500 font-bold text-lg', [Component.text('Failed to Load Support Cases')]),
        p(classes: 'text-xs text-slate-400 max-w-md mx-auto', [Component.text(errorMsg)]),
        button(
          onClick: onRetry,
          classes: 'px-4 py-2 text-xs font-bold text-white rounded-xl shadow-xs cursor-pointer border-none',
          styles: Styles(backgroundColor: Color(colorScheme.primary)),
          [Component.text('Retry')],
        ),
      ],
    );
  }
}

String _formatId(String? id) {
  if (id == null || id.isEmpty) return '#SUP-000';
  if (id.length <= 8) return '#$id';
  return '#${id.substring(0, 8)}...';
}

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return 'N/A';
  try {
    final dt = DateTime.parse(raw).toLocal();
    return '${dt.day}/${dt.month}/${dt.year}';
  } catch (_) {
    return raw;
  }
}
