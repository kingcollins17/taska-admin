import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../components/system_log_detail_side_panel.dart';
import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/providers/systems_log_providers.dart';
import '../core/providers/ui_state_provider.dart';

@client
class SystemLogsTablePage extends StatefulComponent {
  const SystemLogsTablePage({super.key});

  @override
  State<SystemLogsTablePage> createState() => _SystemLogsTablePageState();
}

class _SystemLogsTablePageState extends State<SystemLogsTablePage> {
  String selectedLevel = '';
  String selectedSource = '';
  String searchQuery = '';
  String _searchInputValue = '';
  Timer? _searchDebounceTimer;
  int currentPage = 1;
  int perPage = 25;

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

  String _formatMs(num? val) {
    if (val == null) return '0 ms';
    if (val >= 1000) {
      final sec = val / 1000;
      return '${sec.toStringAsFixed(sec >= 10 ? 1 : 2)}s';
    }
    if (val is int || val == val.roundToDouble()) {
      return '${val.toInt()} ms';
    }
    return '${val.toStringAsFixed(1)} ms';
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    final String? queryLevel = selectedLevel.isNotEmpty ? selectedLevel : null;
    final String? querySource = selectedSource.isNotEmpty
        ? selectedSource
        : (searchQuery.trim().isNotEmpty ? searchQuery.trim() : null);

    final logsAsync = context.watch(
      getSystemLogsProvider(
        GetSystemLogsParams(
          level: queryLevel,
          source: querySource,
          page: currentPage,
          perPage: perPage,
        ),
      ),
    );

    return div(classes: 'flex-1 space-y-6 animate-fade-in-scaled relative', [
      // Top Navigation / Header
      div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-4', [
        div(classes: 'flex items-center space-x-3', [
          Link(
            to: '/system-logs',
            classes:
                'p-2 rounded-xl border transition-all cursor-pointer hover:opacity-80 flex items-center justify-center shrink-0',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            child: div(classes: 'flex items-center space-x-1 text-xs font-bold', [
              span(classes: 'text-sm font-bold', [Component.text('←')]),
              span([Component.text('Stats Dashboard')]),
            ]),
          ),
          div([
            h2(
              classes: 'text-lg font-extrabold tracking-tight',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text('System Log Explorer')],
            ),
            p(
              classes: 'text-xs font-medium',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text('Filter, search, inspect, and paginate raw system logs.')],
            ),
          ]),
        ]),
        div(classes: 'flex items-center space-x-2 shrink-0', [
          div(
            classes: 'w-2 h-2 rounded-full animate-live-pulse',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [],
          ),
          span(
            classes: 'text-xs font-semibold',
            styles: Styles(color: Color(colorScheme.primary)),
            [Component.text('Live Log Stream')],
          ),
        ]),
      ]),

      // System Logs Main Data Table Container
      div(
        classes: 'border rounded-2xl shadow-sm transition-all overflow-hidden p-5 sm:p-6 space-y-5 min-w-0',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [
          // Toolbar Filters
          div(classes: 'flex flex-col lg:flex-row lg:items-center justify-between gap-4', [
            // Search Input
            div(classes: 'relative w-full lg:w-72 min-w-0', [
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
                attributes: {'placeholder': 'Filter by source or message...'},
                onInput: _onSearchInput,
              ),
            ]),

            // Log Level Filter Pills & Refresh
            div(classes: 'flex flex-wrap items-center gap-2', [
              span(
                classes: 'text-[11px] font-bold uppercase tracking-wider mr-1',
                styles: Styles(color: Color(colorScheme.textMuted)),
                [Component.text('Level:')],
              ),
              for (final level in ['', 'INFO', 'WARN', 'ERROR', 'DEBUG', 'METRIC'])
                button(
                  onClick: () => setState(() {
                    selectedLevel = level;
                    currentPage = 1;
                  }),
                  classes:
                      'px-3 py-1.5 rounded-lg transition-all cursor-pointer text-[11px] font-bold border',
                  styles: selectedLevel == level
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
                  [Component.text(level.isEmpty ? 'All' : level)],
                ),
              button(
                onClick: () => setState(() {}),
                classes:
                    'p-2 rounded-lg transition-all cursor-pointer border hover:opacity-80 ml-1',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  color: Color(colorScheme.textSecondary),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                [
                  const div(
                    classes: 'w-4 h-4',
                    [AppIcon(AppIcons.refresh)],
                  ),
                ],
              ),
            ]),
          ]),

          // System Logs Data Content
          logsAsync.when(
            data: (paginatedData) {
              final items = paginatedData?.items ?? [];
              final total = paginatedData?.total ?? items.length;
              final currentPerPage = paginatedData?.perPage ?? perPage;

              if (items.isEmpty) {
                return _EmptyState(
                  colorScheme: colorScheme,
                  message: 'No system logs found',
                  onReset: () => setState(() {
                    selectedLevel = '';
                    selectedSource = '';
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
                    table(classes: 'w-full min-w-[950px] text-left border-collapse text-xs', [
                      thead(
                        classes: 'uppercase tracking-wider text-[10.5px] border-b font-bold',
                        styles: Styles(
                          backgroundColor: Color(colorScheme.inputBg),
                          color: Color(colorScheme.textMuted),
                          raw: {'border-color': colorScheme.border},
                        ),
                        [
                          tr([
                            th(classes: 'p-3.5 pl-4 whitespace-nowrap', [Component.text('Level')]),
                            th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Source')]),
                            th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Log Message')]),
                            th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Duration')]),
                            th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Timestamp')]),
                            th(classes: 'p-3.5 pr-4 text-center whitespace-nowrap', [Component.text('Actions')]),
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
                              classes: 'hover:opacity-90 transition-colors cursor-pointer',
                              events: {
                                'click': (_) => SystemLogDetailSidePanel.show(context, log),
                              },
                              [
                                // Level Badge
                                td(
                                  classes: 'p-3.5 pl-4 whitespace-nowrap',
                                  [
                                    div(classes: 'flex items-center space-x-2.5', [
                                      _buildLevelPill(log.level ?? 'INFO', colorScheme),
                                    ]),
                                  ],
                                ),
                                // Source
                                td(classes: 'p-3.5 whitespace-nowrap', [
                                  span(
                                    classes: 'font-mono text-xs font-bold uppercase tracking-tight',
                                    styles: Styles(color: Color(colorScheme.textHeading)),
                                    [Component.text(log.source ?? 'system')],
                                  ),
                                ]),
                                // Log Message
                                td(
                                  classes: 'p-3.5 text-xs max-w-md truncate font-mono whitespace-nowrap',
                                  styles: Styles(color: Color(colorScheme.textSecondary)),
                                  [Component.text(log.message ?? '—')],
                                ),
                                // Duration
                                td(
                                  classes: 'p-3.5 text-xs font-mono font-medium whitespace-nowrap',
                                  styles: Styles(color: Color(colorScheme.textMuted)),
                                  [
                                    Component.text(
                                      log.durationMs != null ? _formatMs(log.durationMs) : '—',
                                    ),
                                  ],
                                ),
                                // Timestamp
                                td(
                                  classes: 'p-3.5 text-xs font-medium whitespace-nowrap shrink-0',
                                  styles: Styles(color: Color(colorScheme.textMuted)),
                                  [Component.text(_formatDateTime(log.createdAt))],
                                ),
                                // Action Button
                                td(classes: 'p-3.5 pr-4 text-center whitespace-nowrap', [
                                  button(
                                    onClick: () => SystemLogDetailSidePanel.show(context, log),
                                    classes:
                                        'text-white text-[11px] font-bold px-3 py-1.5 rounded-lg shadow-xs cursor-pointer transition-all border-none whitespace-nowrap shrink-0',
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
                  perPage: currentPerPage,
                  currentPage: currentPage,
                  onPreviousPage: () {
                    if (currentPage > 1) {
                      setState(() => currentPage--);
                    }
                  },
                  onNextPage: () {
                    final maxPage = (total / currentPerPage).ceil().clamp(1, 9999);
                    if (currentPage < maxPage) {
                      setState(() => currentPage++);
                    }
                  },
                ),
              ]);
            },
            loading: () => _ShimmerTableLoading(colorScheme: colorScheme),
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

  Component _buildLevelPill(String level, ColorScheme colorScheme) {
    final lvl = level.toUpperCase();
    final isDark = colorScheme.isDark;
    Color bg;
    Color fg;
    String border;

    if (lvl == 'INFO') {
      bg = isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1);
      fg = isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0);
      border = isDark ? 'rgba(16, 185, 129, 0.4)' : 'rgba(16, 185, 129, 0.25)';
    } else if (lvl == 'WARN' || lvl == 'WARNING') {
      bg = isDark ? Color.rgba(245, 158, 11, 0.18) : Color.rgba(245, 158, 11, 0.1);
      fg = isDark ? Color.rgba(252, 211, 77, 1.0) : Color.rgba(180, 83, 9, 1.0);
      border = isDark ? 'rgba(245, 158, 11, 0.4)' : 'rgba(245, 158, 11, 0.25)';
    } else if (lvl == 'ERROR' || lvl == 'CRITICAL') {
      bg = isDark ? Color.rgba(244, 63, 94, 0.18) : Color.rgba(244, 63, 94, 0.1);
      fg = isDark ? Color.rgba(253, 164, 175, 1.0) : Color.rgba(190, 18, 60, 1.0);
      border = isDark ? 'rgba(244, 63, 94, 0.4)' : 'rgba(244, 63, 94, 0.25)';
    } else if (lvl == 'DEBUG') {
      bg = isDark ? Color.rgba(99, 102, 241, 0.18) : Color.rgba(99, 102, 241, 0.1);
      fg = isDark ? Color.rgba(165, 180, 252, 1.0) : Color.rgba(67, 56, 202, 1.0);
      border = isDark ? 'rgba(99, 102, 241, 0.4)' : 'rgba(99, 102, 241, 0.25)';
    } else {
      bg = isDark ? Color.rgba(14, 165, 233, 0.18) : Color.rgba(14, 165, 233, 0.1);
      fg = isDark ? Color.rgba(125, 211, 252, 1.0) : Color.rgba(3, 105, 161, 1.0);
      border = isDark ? 'rgba(14, 165, 233, 0.4)' : 'rgba(14, 165, 233, 0.25)';
    }

    return span(
      classes:
          'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border font-mono whitespace-nowrap',
      styles: Styles(
        backgroundColor: bg,
        color: fg,
        raw: {'border-color': border},
      ),
      [Component.text(lvl)],
    );
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
    final start = total == 0 ? 0 : (currentPage - 1) * perPage + 1;
    final end = (currentPage * perPage).clamp(0, total);
    final maxPage = (total / perPage).ceil().clamp(1, 9999);

    return div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-2', [
      span(
        classes: 'text-xs font-medium',
        styles: Styles(color: Color(colorScheme.textMuted)),
        [
          Component.text('Showing $start to $end of $total log records'),
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

class _ShimmerTableLoading extends StatelessComponent {
  final ColorScheme colorScheme;

  const _ShimmerTableLoading({required this.colorScheme});

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
          [const AppIcon(AppIcons.security)],
        ),
        p(
          classes: 'text-sm font-bold',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text(message)],
        ),
        p(
          classes: 'text-xs font-medium max-w-sm mx-auto',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('No system logs matched your search or log level filter criteria.')],
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
          [Component.text('Failed to load system logs: $errorMsg')],
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
