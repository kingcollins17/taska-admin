import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/system_logs/system_log_metric_item.dart';
import '../core/models/clients/system_logs/system_log_stats.dart';
import '../core/providers/systems_log_providers.dart';
import '../core/providers/ui_state_provider.dart';

@client
class SystemLogsPage extends StatelessComponent {
  const SystemLogsPage({super.key});

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));
    final statsAsync = context.watch(getLogStatsProvider);
    final metricsAsync = context.watch(getMetricsSummaryProvider(const GetMetricsSummaryParams(page: 1, perPage: 12)));

    return div(classes: 'flex-1 space-y-6 animate-fade-in-scaled relative', [
      // Sub-Header
      div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-4', [
        div([
          p(
            classes: 'text-xs sm:text-sm font-medium transition-colors',
            styles: Styles(color: Color(colorScheme.textSecondary)),
            [
              Component.text(
                'Monitor system level statistics, service metric performance summaries, and log volume overview.',
              ),
            ],
          ),
        ]),
        div(classes: 'flex items-center space-x-3 shrink-0', [
          div(classes: 'flex items-center space-x-2', [
            div(
              classes: 'w-2 h-2 rounded-full animate-live-pulse',
              styles: Styles(backgroundColor: Color(colorScheme.primary)),
              [],
            ),
            span(
              classes: 'text-xs font-semibold',
              styles: Styles(color: Color(colorScheme.primary)),
              [Component.text('Live Monitoring')],
            ),
          ]),
          Link(
            to: '/system-logs/table',
            classes:
                'px-3.5 py-1.5 rounded-xl text-white text-xs font-bold shadow-sm transition-all cursor-pointer border-none flex items-center space-x-1.5 hover:opacity-95 active:scale-95',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            child: div(classes: 'flex items-center space-x-1.5', [
              const div(
                classes: 'w-3.5 h-3.5',
                [AppIcon(AppIcons.documents)],
              ),
              span([Component.text('View Log Stream')]),
            ]),
          ),
        ]),
      ]),

      // Primary KPI Summary Cards Grid
      statsAsync.when(
        data: (stats) => _LogStatsSummaryGrid(colorScheme: colorScheme, stats: stats),
        loading: () => _KpiGridShimmer(colorScheme: colorScheme),
        error: (_, __) => _LogStatsSummaryGrid(colorScheme: colorScheme, stats: null),
      ),

      // Navigation Banner Card for Log Table Explorer
      div(
        classes:
            'p-5 sm:p-6 rounded-2xl border shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4 relative overflow-hidden transition-all',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [
          div(classes: 'flex items-center space-x-4 min-w-0', [
            div(
              classes:
                  'w-12 h-12 rounded-2xl flex items-center justify-center text-white shrink-0 shadow-md shadow-emerald-500/10',
              styles: Styles(backgroundColor: Color(colorScheme.primary)),
              [const AppIcon(AppIcons.security)],
            ),
            div(classes: 'min-w-0', [
              h3(
                classes: 'text-base font-extrabold tracking-tight truncate',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('System Log Explorer & Live Stream Table')],
              ),
              p(
                classes: 'text-xs font-medium truncate mt-0.5',
                styles: Styles(color: Color(colorScheme.textSecondary)),
                [
                  Component.text(
                    'Search, filter by log levels (INFO, WARN, ERROR, DEBUG), inspect raw payload metadata, and paginate system entries.',
                  ),
                ],
              ),
            ]),
          ]),
          Link(
            to: '/system-logs/table',
            classes:
                'px-4 py-2.5 rounded-xl text-white text-xs font-bold shadow-md transition-all cursor-pointer border-none shrink-0 flex items-center justify-center space-x-2 hover:opacity-90 active:scale-95',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            child: div(classes: 'flex items-center space-x-2', [
              span([Component.text('Explore System Logs Table')]),
              span(classes: 'text-sm font-bold', [Component.text('→')]),
            ]),
          ),
        ],
      ),

      // Service Performance & Metrics Breakdown
      metricsAsync.when(
        data: (paginatedMetrics) {
          final items = paginatedMetrics?.items ?? [];
          if (items.isEmpty) return const div([]);
          return _MetricsSummaryCard(colorScheme: colorScheme, items: items);
        },
        loading: () => _CardShimmer(colorScheme: colorScheme),
        error: (err, _) => _ErrorCard(colorScheme: colorScheme, errorMsg: err.toString()),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Log Stats Summary Grid & KPI Summary Card
// ─────────────────────────────────────────────────────────────

class _LogStatsSummaryGrid extends StatelessComponent {
  final ColorScheme colorScheme;
  final SystemLogStats? stats;

  const _LogStatsSummaryGrid({
    required this.colorScheme,
    required this.stats,
  });

  @override
  Component build(BuildContext context) {
    final infoCount = stats?.info ?? 0;
    final warnCount = stats?.warn ?? 0;
    final errorCount = stats?.error ?? 0;
    final debugCount = stats?.debug ?? 0;
    final metricCount = stats?.metric ?? 0;
    final totalLogs = infoCount + warnCount + errorCount + debugCount + metricCount;

    return div(classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5', [
      _KpiSummaryCard(
        colorScheme: colorScheme,
        title: 'INFO Logs',
        value: '$infoCount',
        subtitle: 'Standard operational events',
        icon: AppIcons.checkCircle,
        badgeBgColor: Color.rgba(16, 185, 129, 0.12),
        badgeTextColor: Color(colorScheme.primary),
        accentGradientStart: 'rgba(16, 185, 129, 0.08)',
        accentGradientEnd: 'rgba(16, 185, 129, 0.0)',
        delayClass: 'animate-card-delay-1',
      ),
      _KpiSummaryCard(
        colorScheme: colorScheme,
        title: 'WARN Logs',
        value: '$warnCount',
        subtitle: 'Warnings & potential issues',
        icon: AppIcons.disputes,
        badgeBgColor: Color.rgba(245, 158, 11, 0.12),
        badgeTextColor: Color.rgba(245, 158, 11, 1.0),
        accentGradientStart: 'rgba(245, 158, 11, 0.08)',
        accentGradientEnd: 'rgba(245, 158, 11, 0.0)',
        delayClass: 'animate-card-delay-2',
      ),
      _KpiSummaryCard(
        colorScheme: colorScheme,
        title: 'ERROR Logs',
        value: '$errorCount',
        subtitle: 'System errors & failures',
        icon: AppIcons.close,
        badgeBgColor: Color.rgba(239, 68, 68, 0.12),
        badgeTextColor: Color.rgba(239, 68, 68, 1.0),
        accentGradientStart: 'rgba(239, 68, 68, 0.08)',
        accentGradientEnd: 'rgba(239, 68, 68, 0.0)',
        delayClass: 'animate-card-delay-3',
      ),
      _KpiSummaryCard(
        colorScheme: colorScheme,
        title: 'Total Log Volume',
        value: '$totalLogs',
        subtitle: '$debugCount debug · $metricCount metrics',
        icon: AppIcons.analytics,
        badgeBgColor: Color.rgba(99, 102, 241, 0.12),
        badgeTextColor: Color.rgba(99, 102, 241, 1.0),
        accentGradientStart: 'rgba(99, 102, 241, 0.08)',
        accentGradientEnd: 'rgba(99, 102, 241, 0.0)',
        delayClass: 'animate-card-delay-4',
      ),
    ]);
  }
}

class _KpiSummaryCard extends StatelessComponent {
  final ColorScheme colorScheme;
  final String title;
  final String value;
  final String subtitle;
  final AppIcons icon;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final String accentGradientStart;
  final String accentGradientEnd;
  final String delayClass;

  const _KpiSummaryCard({
    required this.colorScheme,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.accentGradientStart,
    required this.accentGradientEnd,
    required this.delayClass,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes:
          'rounded-2xl p-5 border shadow-sm hover:shadow-md transition-all flex flex-col justify-between group animate-card-in $delayClass relative overflow-hidden min-w-0',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(
          classes: 'absolute inset-0 pointer-events-none',
          styles: Styles(
            raw: {
              'background': 'linear-gradient(135deg, $accentGradientStart 0%, $accentGradientEnd 60%)',
            },
          ),
          [],
        ),
        div(classes: 'relative min-w-0', [
          div(classes: 'flex items-center justify-between gap-2 mb-3 min-w-0', [
            span(
              classes: 'text-xs font-semibold uppercase tracking-wider truncate min-w-0 flex-1',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text(title)],
            ),
            div(
              classes:
                  'w-9 h-9 rounded-xl flex items-center justify-center shrink-0 transition-transform group-hover:scale-110',
              styles: Styles(backgroundColor: badgeBgColor, color: badgeTextColor),
              [
                AppIcon(icon),
              ],
            ),
          ]),
          div(classes: 'space-y-1 min-w-0', [
            div(
              classes: 'text-2xl font-extrabold tracking-tight truncate animate-number-in',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text(value)],
            ),
            div(
              classes: 'text-xs font-medium truncate',
              styles: Styles(color: Color(colorScheme.placeholder)),
              [Component.text(subtitle)],
            ),
          ]),
        ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Metrics Summary Card
// ─────────────────────────────────────────────────────────────

class _MetricsSummaryCard extends StatelessComponent {
  final ColorScheme colorScheme;
  final List<SystemLogMetricItem> items;

  const _MetricsSummaryCard({
    required this.colorScheme,
    required this.items,
  });

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
    return div(
      classes: 'rounded-2xl p-6 border shadow-sm space-y-4 transition-all min-w-0 overflow-hidden',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'flex items-center justify-between', [
          div(classes: 'flex items-center space-x-3 min-w-0', [
            div(
              classes: 'w-8 h-8 rounded-xl flex items-center justify-center shrink-0',
              styles: Styles(
                backgroundColor: Color.rgba(99, 102, 241, 0.12),
                color: const Color('#6366F1'),
              ),
              [const AppIcon(AppIcons.analytics)],
            ),
            div(classes: 'min-w-0', [
              h3(
                classes: 'text-sm font-extrabold tracking-tight truncate',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('Service Performance & Metrics Breakdown')],
              ),
              p(
                classes: 'text-[11px] font-medium truncate',
                styles: Styles(color: Color(colorScheme.textMuted)),
                [Component.text('Execution metrics grouped by service source.')],
              ),
            ]),
          ]),
        ]),

        div(classes: 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 pt-1', [
          for (final metric in items)
            div(
              classes: 'p-4 rounded-xl border flex flex-col justify-between space-y-3 min-w-0 overflow-hidden',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                raw: {'border-color': colorScheme.borderInput},
              ),
              [
                div(classes: 'flex items-center justify-between gap-2 min-w-0', [
                  div(classes: 'min-w-0 flex-1 overflow-hidden', [
                    span(
                      classes:
                          'px-2.5 py-1 rounded-lg text-[11px] font-mono font-bold uppercase tracking-wider border truncate block max-w-full',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.surface),
                        color: Color(colorScheme.textHeading),
                        raw: {'border-color': colorScheme.border},
                      ),
                      attributes: {'title': metric.source ?? ''},
                      [Component.text(metric.source ?? 'Unknown Source')],
                    ),
                  ]),
                  span(
                    classes: 'text-xs font-extrabold font-mono shrink-0 ml-1 whitespace-nowrap',
                    styles: Styles(color: Color(colorScheme.primary)),
                    [Component.text('${metric.count ?? 0} requests')],
                  ),
                ]),
                div(
                  classes: 'grid grid-cols-3 gap-1.5 pt-2 text-center border-t min-w-0',
                  styles: Styles(raw: {'border-color': colorScheme.borderInput}),
                  [
                    div(classes: 'min-w-0 overflow-hidden', [
                      span(
                        classes: 'text-[10px] uppercase font-bold block truncate',
                        styles: Styles(color: Color(colorScheme.textMuted)),
                        [Component.text('Avg Duration')],
                      ),
                      span(
                        classes: 'text-xs font-mono font-bold block truncate',
                        styles: Styles(color: Color(colorScheme.textPrimary)),
                        [Component.text(_formatMs(metric.avgDuration))],
                      ),
                    ]),
                    div(classes: 'min-w-0 overflow-hidden', [
                      span(
                        classes: 'text-[10px] uppercase font-bold block truncate',
                        styles: Styles(color: Color(colorScheme.textMuted)),
                        [Component.text('Max Duration')],
                      ),
                      span(
                        classes: 'text-xs font-mono font-bold text-amber-500 block truncate',
                        [Component.text(_formatMs(metric.maxDuration))],
                      ),
                    ]),
                    div(classes: 'min-w-0 overflow-hidden', [
                      span(
                        classes: 'text-[10px] uppercase font-bold block truncate',
                        styles: Styles(color: Color(colorScheme.textMuted)),
                        [Component.text('Min Duration')],
                      ),
                      span(
                        classes: 'text-xs font-mono font-bold text-emerald-500 block truncate',
                        [Component.text(_formatMs(metric.minDuration))],
                      ),
                    ]),
                  ],
                ),
              ],
            ),
        ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shimmer & Error States
// ─────────────────────────────────────────────────────────────

class _KpiGridShimmer extends StatelessComponent {
  final ColorScheme colorScheme;

  const _KpiGridShimmer({required this.colorScheme});

  @override
  Component build(BuildContext context) {
    return div(classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 animate-pulse', [
      for (var i = 0; i < 4; i++)
        div(
          classes: 'h-28 rounded-2xl border',
          styles: Styles(
            backgroundColor: colorScheme.isDark ? Color.rgba(31, 45, 39, 0.8) : Color.rgba(226, 232, 240, 0.8),
            raw: {'border-color': colorScheme.border},
          ),
          [],
        ),
    ]);
  }
}

class _CardShimmer extends StatelessComponent {
  final ColorScheme colorScheme;

  const _CardShimmer({required this.colorScheme});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'h-36 rounded-2xl border animate-pulse',
      styles: Styles(
        backgroundColor: colorScheme.isDark ? Color.rgba(31, 45, 39, 0.8) : Color.rgba(226, 232, 240, 0.8),
        raw: {'border-color': colorScheme.border},
      ),
      [],
    );
  }
}

class _ErrorCard extends StatelessComponent {
  final ColorScheme colorScheme;
  final String errorMsg;

  const _ErrorCard({required this.colorScheme, required this.errorMsg});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'p-6 rounded-2xl border text-center space-y-2 border-rose-500/30 bg-rose-500/5',
      [
        p(
          classes: 'text-xs font-bold text-rose-500',
          [Component.text('Failed to load metrics breakdown: $errorMsg')],
        ),
      ],
    );
  }
}
