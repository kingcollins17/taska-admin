import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/dashboard/admin_dashboard_overview.dart';
import '../core/providers/admin_providers.dart';
import '../core/providers/ui_state_provider.dart';
import '../core/utils/currency_formatter.dart';

@client
class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));
    final overviewAsync = context.watch(adminDashboardOverviewProvider);

    return div(
      classes: 'flex-1 space-y-6 animate-fade-in-scaled',
      [
        overviewAsync.when(
          data: (overview) {
            if (overview == null) {
              return _EmptyState(colorScheme: colorScheme);
            }
            return _DashboardContent(colorScheme: colorScheme, overview: overview);
          },
          loading: () => _ShimmerLoading(colorScheme: colorScheme),
          error: (err, stack) => _ErrorState(colorScheme: colorScheme, errorMsg: err.toString()),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dashboard Content Layout
// ─────────────────────────────────────────────────────────────

class _DashboardContent extends StatelessComponent {
  final ColorScheme colorScheme;
  final AdminDashboardOverview overview;

  const _DashboardContent({
    required this.colorScheme,
    required this.overview,
  });

  @override
  Component build(BuildContext context) {
    return div(classes: 'space-y-6', [
      // Top 4 Primary KPI Summary Cards Grid
      _SummaryCardsGrid(colorScheme: colorScheme, overview: overview),

      // Main 2-Column Section Grid
      div(classes: 'grid grid-cols-1 lg:grid-cols-12 gap-6', [
        // Left Column (7 cols): Task Operations Breakdown Card
        div(classes: 'lg:col-span-7 space-y-6', [
          _TaskOperationsBreakdownCard(colorScheme: colorScheme, overview: overview),
        ]),

        // Right Column (5 cols): User & Provider Distribution Card
        div(classes: 'lg:col-span-5 space-y-6', [
          _UserDistributionCard(colorScheme: colorScheme, overview: overview),
        ]),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Summary Cards Grid & KPI Card Component
// ─────────────────────────────────────────────────────────────

class _SummaryCardsGrid extends StatelessComponent {
  final ColorScheme colorScheme;
  final AdminDashboardOverview overview;

  const _SummaryCardsGrid({
    required this.colorScheme,
    required this.overview,
  });

  @override
  Component build(BuildContext context) {
    final revenue = (overview.totalRevenueAmount ?? 0).toNaira();
    final payouts = (overview.totalProcessedPayoutsAmount ?? 0).toNaira();
    final totalTasks = (overview.totalTasks ?? 0).toString();
    final totalUsers = (overview.totalUsers ?? 0).toString();

    return div(classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5', [
      _KpiSummaryCard(
        colorScheme: colorScheme,
        title: 'Total Revenue',
        value: revenue,
        subtitle: 'Platform revenue',
        icon: AppIcons.salesTag,
        badgeBgColor: Color.rgba(0, 168, 112, 0.12),
        badgeTextColor: Color(colorScheme.primary),
      ),
      _KpiSummaryCard(
        colorScheme: colorScheme,
        title: 'Total Payouts',
        value: payouts,
        subtitle: 'Completed payouts',
        icon: AppIcons.transaction,
        badgeBgColor: Color.rgba(59, 130, 246, 0.12),
        badgeTextColor: Color.rgba(59, 130, 246, 1.0),
      ),
      _KpiSummaryCard(
        colorScheme: colorScheme,
        title: 'Total Tasks',
        value: totalTasks,
        subtitle: 'Platform task volume',
        icon: AppIcons.ordersDoc,
        badgeBgColor: Color.rgba(99, 102, 241, 0.12),
        badgeTextColor: Color.rgba(99, 102, 241, 1.0),
      ),
      _KpiSummaryCard(
        colorScheme: colorScheme,
        title: 'Total Users',
        value: totalUsers,
        subtitle: 'Registered accounts',
        icon: AppIcons.customersGroup,
        badgeBgColor: Color.rgba(245, 158, 11, 0.12),
        badgeTextColor: Color.rgba(245, 158, 11, 1.0),
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

  const _KpiSummaryCard({
    required this.colorScheme,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.badgeBgColor,
    required this.badgeTextColor,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes:
          'rounded-2xl p-5 border shadow-sm hover:shadow-md transition-all flex flex-col justify-between group',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'flex items-center justify-between mb-3', [
          span(
            classes: 'text-xs font-semibold uppercase tracking-wider',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text(title)],
          ),
          div(
            classes:
                'w-9 h-9 rounded-xl flex items-center justify-center transition-transform group-hover:scale-105',
            styles: Styles(backgroundColor: badgeBgColor, color: badgeTextColor),
            [
              AppIcon(icon),
            ],
          ),
        ]),
        div(classes: 'space-y-1', [
          div(
            classes: 'text-2xl font-extrabold tracking-tight',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [Component.text(value)],
          ),
          div(
            classes: 'text-xs font-medium',
            styles: Styles(color: Color(colorScheme.placeholder)),
            [Component.text(subtitle)],
          ),
        ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Task Operations Breakdown Card Component
// ─────────────────────────────────────────────────────────────

class _TaskOperationsBreakdownCard extends StatelessComponent {
  final ColorScheme colorScheme;
  final AdminDashboardOverview overview;

  const _TaskOperationsBreakdownCard({
    required this.colorScheme,
    required this.overview,
  });

  @override
  Component build(BuildContext context) {
    final total = (overview.totalTasks ?? 0) > 0 ? overview.totalTasks! : 1;
    final completed = overview.totalCompletedTasks ?? 0;
    final inProgress = overview.totalInProgressTasks ?? 0;
    final open = overview.totalOpenTasks ?? 0;
    final cancelled = overview.totalCancelledTasks ?? 0;

    return div(
      classes: 'rounded-2xl p-6 border shadow-sm space-y-6',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(
          classes: 'flex items-center justify-between pb-4 border-b',
          styles: Styles(raw: {'border-color': colorScheme.border}),
          [
            div(classes: 'flex items-center space-x-2.5', [
              div(
                classes: 'w-8 h-8 rounded-xl flex items-center justify-center',
                styles: Styles(
                  backgroundColor: Color.rgba(0, 168, 112, 0.15),
                  color: Color(colorScheme.primary),
                ),
                [
                  const AppIcon(AppIcons.ordersDoc),
                ],
              ),
              h3(
                classes: 'text-base font-bold',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('Task Operations Breakdown')],
              ),
            ]),
            span(
              classes: 'text-xs font-bold px-3 py-1 rounded-full border',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.textSecondary),
                raw: {'border-color': colorScheme.border},
              ),
              [Component.text('${overview.totalTasks ?? 0} Total')],
            ),
          ],
        ),

        // Status Metrics List
        div(classes: 'space-y-4', [
          _StatusProgressRow(
            colorScheme: colorScheme,
            label: 'Completed Tasks',
            count: completed,
            total: total,
            barColor: Color(colorScheme.primary),
          ),
          _StatusProgressRow(
            colorScheme: colorScheme,
            label: 'In-Progress Tasks',
            count: inProgress,
            total: total,
            barColor: Color.rgba(245, 158, 11, 1.0),
          ),
          _StatusProgressRow(
            colorScheme: colorScheme,
            label: 'Open Tasks',
            count: open,
            total: total,
            barColor: Color.rgba(99, 102, 241, 1.0),
          ),
          _StatusProgressRow(
            colorScheme: colorScheme,
            label: 'Cancelled Tasks',
            count: cancelled,
            total: total,
            barColor: Color.rgba(239, 68, 68, 1.0),
          ),
        ]),
      ],
    );
  }
}

class _StatusProgressRow extends StatelessComponent {
  final ColorScheme colorScheme;
  final String label;
  final int count;
  final int total;
  final Color barColor;

  const _StatusProgressRow({
    required this.colorScheme,
    required this.label,
    required this.count,
    required this.total,
    required this.barColor,
  });

  @override
  Component build(BuildContext context) {
    final percentage = ((count / total) * 100).clamp(0, 100).toInt();

    return div(classes: 'space-y-1.5', [
      div(classes: 'flex items-center justify-between text-xs font-semibold', [
        span(styles: Styles(color: Color(colorScheme.textPrimary)), [Component.text(label)]),
        span(styles: Styles(color: Color(colorScheme.textMuted)), [Component.text('$count ($percentage%)')]),
      ]),
      div(
        classes: 'w-full h-2 rounded-full overflow-hidden',
        styles: Styles(backgroundColor: Color(colorScheme.border)),
        [
          div(
            classes: 'h-full rounded-full transition-all duration-500',
            styles: Styles(
              width: Unit.percent(percentage.toDouble()),
              backgroundColor: barColor,
            ),
            [],
          ),
        ],
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// User & Provider Distribution Card Component
// ─────────────────────────────────────────────────────────────

class _UserDistributionCard extends StatelessComponent {
  final ColorScheme colorScheme;
  final AdminDashboardOverview overview;

  const _UserDistributionCard({
    required this.colorScheme,
    required this.overview,
  });

  @override
  Component build(BuildContext context) {
    final customers = overview.totalCustomers ?? 0;
    final providers = overview.totalProviders ?? 0;
    final totalUsers = overview.totalUsers ?? (customers + providers);

    return div(
      classes: 'rounded-2xl p-6 border shadow-sm space-y-6',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(
          classes: 'flex items-center justify-between pb-4 border-b',
          styles: Styles(raw: {'border-color': colorScheme.border}),
          [
            div(classes: 'flex items-center space-x-2.5', [
              div(
                classes: 'w-8 h-8 rounded-xl flex items-center justify-center',
                styles: Styles(
                  backgroundColor: Color.rgba(59, 130, 246, 0.15),
                  color: Color.rgba(59, 130, 246, 1.0),
                ),
                [
                  const AppIcon(AppIcons.customersGroup),
                ],
              ),
              h3(
                classes: 'text-base font-bold',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('User & Provider Breakdown')],
              ),
            ]),
          ],
        ),

        div(classes: 'grid grid-cols-2 gap-4', [
          div(
            classes: 'p-4 rounded-xl border flex flex-col space-y-1',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              raw: {'border-color': colorScheme.border},
            ),
            [
              span(
                classes: 'text-xs font-semibold',
                styles: Styles(color: Color(colorScheme.textMuted)),
                [Component.text('Customers')],
              ),
              span(
                classes: 'text-2xl font-bold',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('$customers')],
              ),
            ],
          ),
          div(
            classes: 'p-4 rounded-xl border flex flex-col space-y-1',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              raw: {'border-color': colorScheme.border},
            ),
            [
              span(
                classes: 'text-xs font-semibold',
                styles: Styles(color: Color(colorScheme.textMuted)),
                [Component.text('Providers')],
              ),
              span(
                classes: 'text-2xl font-bold',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('$providers')],
              ),
            ],
          ),
        ]),

        div(
          classes: 'p-4 rounded-xl border flex items-center justify-between',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            raw: {'border-color': colorScheme.border},
          ),
          [
            div(classes: 'flex items-center space-x-3', [
              const AppIcon(AppIcons.customer),
              span(
                classes: 'text-xs font-semibold',
                styles: Styles(color: Color(colorScheme.textSecondary)),
                [Component.text('Total Users')],
              ),
            ]),
            span(
              classes: 'text-sm font-bold',
              styles: Styles(color: Color(colorScheme.primary)),
              [Component.text('$totalUsers')],
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Loading Shimmer, Empty State & Error Components
// ─────────────────────────────────────────────────────────────

class _ShimmerLoading extends StatelessComponent {
  final ColorScheme colorScheme;

  const _ShimmerLoading({required this.colorScheme});

  @override
  Component build(BuildContext context) {
    final blockColor = colorScheme.isDark ? Color.rgba(31, 45, 39, 0.8) : Color.rgba(226, 232, 240, 0.8);

    return div(classes: 'space-y-6 animate-pulse', [
      // 4 KPI Shimmer Cards Grid
      div(classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5', [
        for (var i = 0; i < 4; i++)
          div(
            classes: 'rounded-2xl p-5 border space-y-4 shadow-sm',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              raw: {'border-color': colorScheme.border},
            ),
            [
              div(classes: 'flex justify-between items-center', [
                div(
                  classes: 'h-3 w-20 rounded-md',
                  styles: Styles(backgroundColor: blockColor),
                  [],
                ),
                div(
                  classes: 'w-8 h-8 rounded-xl',
                  styles: Styles(backgroundColor: blockColor),
                  [],
                ),
              ]),
              div(
                classes: 'h-7 w-28 rounded-lg',
                styles: Styles(backgroundColor: blockColor),
                [],
              ),
              div(
                classes: 'h-3 w-24 rounded-md',
                styles: Styles(backgroundColor: blockColor),
                [],
              ),
            ],
          ),
      ]),

      // 2 Main Column Shimmers
      div(classes: 'grid grid-cols-1 lg:grid-cols-12 gap-6', [
        div(
          classes: 'lg:col-span-7 rounded-2xl p-6 border space-y-5 shadow-sm',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            div(
              classes: 'flex items-center justify-between pb-4 border-b',
              styles: Styles(raw: {'border-color': colorScheme.border}),
              [
                div(
                  classes: 'h-5 w-44 rounded-md',
                  styles: Styles(backgroundColor: blockColor),
                  [],
                ),
                div(
                  classes: 'h-6 w-20 rounded-full',
                  styles: Styles(backgroundColor: blockColor),
                  [],
                ),
              ],
            ),
            for (var j = 0; j < 4; j++)
              div(classes: 'space-y-2', [
                div(classes: 'flex justify-between', [
                  div(
                    classes: 'h-3 w-28 rounded-md',
                    styles: Styles(backgroundColor: blockColor),
                    [],
                  ),
                  div(
                    classes: 'h-3 w-16 rounded-md',
                    styles: Styles(backgroundColor: blockColor),
                    [],
                  ),
                ]),
                div(
                  classes: 'h-2 w-full rounded-full',
                  styles: Styles(backgroundColor: blockColor),
                  [],
                ),
              ]),
          ],
        ),
        div(
          classes: 'lg:col-span-5 rounded-2xl p-6 border space-y-5 shadow-sm',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            div(
              classes: 'flex items-center justify-between pb-4 border-b',
              styles: Styles(raw: {'border-color': colorScheme.border}),
              [
                div(
                  classes: 'h-5 w-40 rounded-md',
                  styles: Styles(backgroundColor: blockColor),
                  [],
                ),
              ],
            ),
            div(classes: 'grid grid-cols-2 gap-4', [
              div(
                classes: 'h-20 rounded-xl',
                styles: Styles(backgroundColor: blockColor),
                [],
              ),
              div(
                classes: 'h-20 rounded-xl',
                styles: Styles(backgroundColor: blockColor),
                [],
              ),
            ]),
            div(
              classes: 'h-14 rounded-xl',
              styles: Styles(backgroundColor: blockColor),
              [],
            ),
          ],
        ),
      ]),
    ]);
  }
}

class _EmptyState extends StatelessComponent {
  final ColorScheme colorScheme;

  const _EmptyState({required this.colorScheme});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'rounded-2xl p-12 text-center border space-y-3',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        h3(
          classes: 'text-lg font-bold',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text('No Dashboard Metrics Available')],
        ),
        p(
          classes: 'text-sm max-w-md mx-auto',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Dashboard overview data is empty or not initialized yet.')],
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessComponent {
  final ColorScheme colorScheme;
  final String errorMsg;

  const _ErrorState({
    required this.colorScheme,
    required this.errorMsg,
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
        div(
          classes: 'text-rose-500 font-bold text-lg',
          [Component.text('Failed to Load Overview Metrics')],
        ),
        p(
          classes: 'text-xs text-slate-400 max-w-md mx-auto',
          [Component.text(errorMsg)],
        ),
      ],
    );
  }
}
