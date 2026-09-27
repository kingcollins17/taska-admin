import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/dashboard/admin_dashboard_overview.dart';
import '../core/providers/admin_providers.dart';
import '../core/providers/stats_providers.dart';
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
      // ── Welcome Header ──
      _WelcomeHeader(colorScheme: colorScheme),

      // ── Top 4 Primary KPI Summary Cards Grid ──
      _SummaryCardsGrid(colorScheme: colorScheme, overview: overview),

      // ── Row 2: Task Donut Chart + Financial Summary ──
      div(classes: 'grid grid-cols-1 lg:grid-cols-12 gap-6 animate-section-in animate-section-delay-1', [
        div(classes: 'lg:col-span-7', [
          _TaskDonutCard(colorScheme: colorScheme, overview: overview),
        ]),
        div(classes: 'lg:col-span-5', [
          _FinancialSummaryCard(colorScheme: colorScheme, overview: overview),
        ]),
      ]),

      // ── Row 3: KYC Pipeline + Guarantor + Interview ──
      div(classes: 'grid grid-cols-1 lg:grid-cols-3 gap-6 animate-section-in animate-section-delay-2', [
        _KycPipelineCard(colorScheme: colorScheme),
        _GuarantorCard(colorScheme: colorScheme),
        _InterviewPipelineCard(colorScheme: colorScheme),
      ]),

      // ── Row 4: User Activity + Task Operations ──
      div(classes: 'grid grid-cols-1 lg:grid-cols-12 gap-6 animate-section-in animate-section-delay-3', [
        div(classes: 'lg:col-span-5', [
          _UserActivityCard(colorScheme: colorScheme, overview: overview),
        ]),
        div(classes: 'lg:col-span-7', [
          _TaskOperationsBreakdownCard(colorScheme: colorScheme, overview: overview),
        ]),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Welcome Header
// ─────────────────────────────────────────────────────────────

class _WelcomeHeader extends StatelessComponent {
  final ColorScheme colorScheme;

  const _WelcomeHeader({required this.colorScheme});

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex items-center justify-between', [
      div(classes: 'space-y-1', [
       
        p(
          classes: 'text-xs font-medium',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Monitor your platform performance and operations at a glance.')],
        ),
      ]),
      div(classes: 'flex items-center space-x-2', [
        div(
          classes: 'w-2 h-2 rounded-full animate-live-pulse',
          styles: Styles(backgroundColor: Color(colorScheme.primary)),
          [],
        ),
        span(
          classes: 'text-xs font-semibold',
          styles: Styles(color: Color(colorScheme.primary)),
          [Component.text('Live')],
        ),
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
    final completedTasks = overview.totalCompletedTasks ?? 0;
    final totalTasksNum = overview.totalTasks ?? 0;
    final completionRate = totalTasksNum > 0
        ? '${((completedTasks / totalTasksNum) * 100).toStringAsFixed(1)}%'
        : '0%';

    return div(classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5', [
      _KpiSummaryCard(
        colorScheme: colorScheme,
        title: 'Total Revenue',
        value: revenue,
        subtitle: 'Platform revenue',
        icon: AppIcons.salesTag,
        badgeBgColor: Color.rgba(0, 168, 112, 0.12),
        badgeTextColor: Color(colorScheme.primary),
        accentGradientStart: 'rgba(0, 168, 112, 0.08)',
        accentGradientEnd: 'rgba(0, 168, 112, 0.0)',
        delayClass: 'animate-card-delay-1',
      ),
      _KpiSummaryCard(
        colorScheme: colorScheme,
        title: 'Total Payouts',
        value: payouts,
        subtitle: 'Processed payouts',
        icon: AppIcons.transaction,
        badgeBgColor: Color.rgba(59, 130, 246, 0.12),
        badgeTextColor: Color.rgba(59, 130, 246, 1.0),
        accentGradientStart: 'rgba(59, 130, 246, 0.08)',
        accentGradientEnd: 'rgba(59, 130, 246, 0.0)',
        delayClass: 'animate-card-delay-2',
      ),
      _KpiSummaryCard(
        colorScheme: colorScheme,
        title: 'Total Tasks',
        value: totalTasks,
        subtitle: '$completionRate completion rate',
        icon: AppIcons.ordersDoc,
        badgeBgColor: Color.rgba(99, 102, 241, 0.12),
        badgeTextColor: Color.rgba(99, 102, 241, 1.0),
        accentGradientStart: 'rgba(99, 102, 241, 0.08)',
        accentGradientEnd: 'rgba(99, 102, 241, 0.0)',
        delayClass: 'animate-card-delay-3',
      ),
      _KpiSummaryCard(
        colorScheme: colorScheme,
        title: 'Total Users',
        value: totalUsers,
        subtitle: '${overview.totalProviders ?? 0} providers · ${overview.totalCustomers ?? 0} customers',
        icon: AppIcons.customersGroup,
        badgeBgColor: Color.rgba(245, 158, 11, 0.12),
        badgeTextColor: Color.rgba(245, 158, 11, 1.0),
        accentGradientStart: 'rgba(245, 158, 11, 0.08)',
        accentGradientEnd: 'rgba(245, 158, 11, 0.0)',
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
          'rounded-2xl p-5 border shadow-sm hover:shadow-md transition-all flex flex-col justify-between group animate-card-in $delayClass relative overflow-hidden',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        // Subtle accent gradient overlay
        div(
          classes: 'absolute inset-0 pointer-events-none',
          styles: Styles(
            raw: {
              'background': 'linear-gradient(135deg, $accentGradientStart 0%, $accentGradientEnd 60%)',
            },
          ),
          [],
        ),
        div(classes: 'relative', [
          div(classes: 'flex items-center justify-between mb-3', [
            span(
              classes: 'text-xs font-semibold uppercase tracking-wider',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text(title)],
            ),
            div(
              classes:
                  'w-9 h-9 rounded-xl flex items-center justify-center transition-transform group-hover:scale-110',
              styles: Styles(backgroundColor: badgeBgColor, color: badgeTextColor),
              [
                AppIcon(icon),
              ],
            ),
          ]),
          div(classes: 'space-y-1', [
            div(
              classes: 'text-2xl font-extrabold tracking-tight animate-number-in',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text(value)],
            ),
            div(
              classes: 'text-xs font-medium',
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
// Task Donut Chart Card (CSS conic-gradient based)
// ─────────────────────────────────────────────────────────────

class _TaskDonutCard extends StatelessComponent {
  final ColorScheme colorScheme;
  final AdminDashboardOverview overview;

  const _TaskDonutCard({
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

    final completedPct = (completed / total * 100).toInt();
    final inProgressPct = (inProgress / total * 100).toInt();
    final openPct = (open / total * 100).toInt();
    final cancelledPct = 100 - completedPct - inProgressPct - openPct;

    // Conic gradient segments
    final seg1End = completedPct;
    final seg2End = seg1End + inProgressPct;
    final seg3End = seg2End + openPct;

    final primaryColor = colorScheme.primary;
    const amberColor = '#F59E0B';
    const indigoColor = '#6366F1';
    const redColor = '#EF4444';

    final conicGradient =
        'conic-gradient(from 0deg, $primaryColor 0% $seg1End%, $amberColor $seg1End% $seg2End%, $indigoColor $seg2End% $seg3End%, $redColor $seg3End% 100%)';

    final centerBg = colorScheme.surface;

    return div(
      classes: 'rounded-2xl p-6 border shadow-sm',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        // Header
        _CardHeader(
          colorScheme: colorScheme,
          title: 'Task Distribution',
          icon: AppIcons.analytics,
          iconBgColor: Color.rgba(99, 102, 241, 0.15),
          iconColor: Color.rgba(99, 102, 241, 1.0),
          trailing: span(
            classes: 'text-xs font-bold px-3 py-1 rounded-full border',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.border},
            ),
            [Component.text('${overview.totalTasks ?? 0} Total')],
          ),
        ),

        // Chart + Legend Layout
        div(classes: 'flex items-center gap-8 mt-6', [
          // Donut Chart
          div(classes: 'flex-shrink-0 animate-donut-in', [
            div(
              classes: 'relative flex items-center justify-center',
              styles: Styles(
                width: Unit.pixels(140),
                height: Unit.pixels(140),
              ),
              [
                // Outer donut ring
                div(
                  classes: 'absolute inset-0 rounded-full',
                  styles: Styles(
                    raw: {
                      'background': conicGradient,
                      'mask': 'radial-gradient(farthest-side, transparent 62%, black 63%)',
                      '-webkit-mask': 'radial-gradient(farthest-side, transparent 62%, black 63%)',
                    },
                  ),
                  [],
                ),
                // Center label
                div(
                  classes: 'relative flex flex-col items-center justify-center',
                  styles: Styles(
                    width: Unit.pixels(86),
                    height: Unit.pixels(86),
                    backgroundColor: Color(centerBg),
                    raw: {'border-radius': '50%'},
                  ),
                  [
                    span(
                      classes: 'text-2xl font-extrabold',
                      styles: Styles(color: Color(colorScheme.textHeading)),
                      [Component.text('${overview.totalTasks ?? 0}')],
                    ),
                    span(
                      classes: 'text-xs font-medium -mt-0.5',
                      styles: Styles(color: Color(colorScheme.textMuted)),
                      [Component.text('tasks')],
                    ),
                  ],
                ),
              ],
            ),
          ]),

          // Legend
          div(classes: 'flex-1 grid grid-cols-2 gap-3', [
            _DonutLegendItem(
              colorScheme: colorScheme,
              label: 'Completed',
              count: completed,
              percentage: completedPct,
              color: Color(colorScheme.primary),
            ),
            _DonutLegendItem(
              colorScheme: colorScheme,
              label: 'In Progress',
              count: inProgress,
              percentage: inProgressPct,
              color: const Color('#F59E0B'),
            ),
            _DonutLegendItem(
              colorScheme: colorScheme,
              label: 'Open',
              count: open,
              percentage: openPct,
              color: const Color('#6366F1'),
            ),
            _DonutLegendItem(
              colorScheme: colorScheme,
              label: 'Cancelled',
              count: cancelled,
              percentage: cancelledPct.clamp(0, 100),
              color: const Color('#EF4444'),
            ),
          ]),
        ]),
      ],
    );
  }
}

class _DonutLegendItem extends StatelessComponent {
  final ColorScheme colorScheme;
  final String label;
  final int count;
  final int percentage;
  final Color color;

  const _DonutLegendItem({
    required this.colorScheme,
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'p-3 rounded-xl border space-y-1.5',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'flex items-center space-x-2', [
          div(
            classes: 'w-2.5 h-2.5 rounded-full flex-shrink-0',
            styles: Styles(backgroundColor: color),
            [],
          ),
          span(
            classes: 'text-xs font-semibold',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text(label)],
          ),
        ]),
        div(classes: 'flex items-baseline space-x-1.5', [
          span(
            classes: 'text-lg font-bold',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [Component.text('$count')],
          ),
          span(
            classes: 'text-xs font-medium',
            styles: Styles(color: Color(colorScheme.placeholder)),
            [Component.text('($percentage%)')],
          ),
        ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Financial Summary Card
// ─────────────────────────────────────────────────────────────

class _FinancialSummaryCard extends StatelessComponent {
  final ColorScheme colorScheme;
  final AdminDashboardOverview overview;

  const _FinancialSummaryCard({
    required this.colorScheme,
    required this.overview,
  });

  @override
  Component build(BuildContext context) {
    final revenue = overview.totalRevenueAmount ?? 0;
    final payouts = overview.totalProcessedPayoutsAmount ?? 0;
    final maxVal = revenue > payouts ? revenue : (payouts > 0 ? payouts : 1);
    final revenuePct = (revenue / maxVal * 100).clamp(0, 100).toInt();
    final payoutsPct = (payouts / maxVal * 100).clamp(0, 100).toInt();
    final netBalance = revenue - payouts;

    return div(
      classes: 'rounded-2xl p-6 border shadow-sm h-full flex flex-col',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        _CardHeader(
          colorScheme: colorScheme,
          title: 'Financial Summary',
          icon: AppIcons.salesTag,
          iconBgColor: Color.rgba(0, 168, 112, 0.15),
          iconColor: Color(colorScheme.primary),
        ),

        div(classes: 'flex-1 mt-6 space-y-5', [
          // Revenue Bar
          _FinancialBarRow(
            colorScheme: colorScheme,
            label: 'Revenue',
            amount: revenue.toNaira(),
            percentage: revenuePct,
            barColor: Color(colorScheme.primary),
          ),
          // Payouts Bar
          _FinancialBarRow(
            colorScheme: colorScheme,
            label: 'Payouts',
            amount: payouts.toNaira(),
            percentage: payoutsPct,
            barColor: const Color('#3B82F6'),
          ),
        ]),

        // Net Balance Footer
        div(
          classes: 'mt-5 pt-4 border-t flex items-center justify-between',
          styles: Styles(raw: {'border-color': colorScheme.border}),
          [
            span(
              classes: 'text-xs font-semibold uppercase tracking-wider',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text('Net Balance')],
            ),
            span(
              classes: 'text-lg font-extrabold',
              styles: Styles(
                color: netBalance >= 0 ? Color(colorScheme.primary) : const Color('#EF4444'),
              ),
              [Component.text(netBalance.toNaira())],
            ),
          ],
        ),
      ],
    );
  }
}

class _FinancialBarRow extends StatelessComponent {
  final ColorScheme colorScheme;
  final String label;
  final String amount;
  final int percentage;
  final Color barColor;

  const _FinancialBarRow({
    required this.colorScheme,
    required this.label,
    required this.amount,
    required this.percentage,
    required this.barColor,
  });

  @override
  Component build(BuildContext context) {
    return div(classes: 'space-y-2', [
      div(classes: 'flex items-center justify-between', [
        span(
          classes: 'text-xs font-semibold',
          styles: Styles(color: Color(colorScheme.textPrimary)),
          [Component.text(label)],
        ),
        span(
          classes: 'text-sm font-bold',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text(amount)],
        ),
      ]),
      div(
        classes: 'w-full h-2.5 rounded-full overflow-hidden',
        styles: Styles(backgroundColor: Color(colorScheme.border)),
        [
          div(
            classes: 'h-full rounded-full transition-all duration-700 animate-progress-fill',
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
// KYC Verification Pipeline Card
// ─────────────────────────────────────────────────────────────

class _KycPipelineCard extends StatelessComponent {
  final ColorScheme colorScheme;

  const _KycPipelineCard({required this.colorScheme});

  @override
  Component build(BuildContext context) {
    final kycAsync = context.watch(adminKycStatsProvider);

    return kycAsync.when(
      data: (kycStats) {
        final totalDocs = kycStats?.totalDocuments ?? 0;
        final verified = kycStats?.totalVerified ?? 0;
        final pending = kycStats?.totalPending ?? 0;
        final underReview = kycStats?.totalUnderReview ?? 0;
        final submitted = kycStats?.totalSubmitted ?? 0;
        final rejected = kycStats?.totalRejected ?? 0;
        final safeDivisor = totalDocs > 0 ? totalDocs : 1;

        return div(
          classes: 'rounded-2xl p-6 border shadow-sm h-full flex flex-col',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            _CardHeader(
              colorScheme: colorScheme,
              title: 'KYC Verification',
              icon: AppIcons.kyc,
              iconBgColor: Color.rgba(16, 185, 129, 0.15),
              iconColor: const Color('#10B981'),
              trailing: span(
                classes: 'text-lg font-extrabold',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('$totalDocs')],
              ),
            ),

            // Stacked progress bar
            div(classes: 'mt-4 mb-1', [
              div(
                classes: 'h-2 rounded-full overflow-hidden flex',
                styles: Styles(backgroundColor: Color(colorScheme.inputBg)),
                [
                  if (verified > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(verified / safeDivisor * 100), backgroundColor: Color(colorScheme.primary)), []),
                  if (underReview > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(underReview / safeDivisor * 100), backgroundColor: const Color('#F59E0B')), []),
                  if (submitted > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(submitted / safeDivisor * 100), backgroundColor: const Color('#3B82F6')), []),
                  if (pending > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(pending / safeDivisor * 100), backgroundColor: const Color('#8B5CF6')), []),
                  if (rejected > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(rejected / safeDivisor * 100), backgroundColor: const Color('#EF4444')), []),
                ],
              ),
            ]),

            // Stats grid
            div(classes: 'flex-1 mt-3 grid grid-cols-2 gap-2.5', [
              _StatTile(colorScheme: colorScheme, label: 'Verified', count: verified, accentColor: colorScheme.primary, accentBg: Color.rgba(0, 168, 112, 0.1)),
              _StatTile(colorScheme: colorScheme, label: 'Under Review', count: underReview, accentColor: '#F59E0B', accentBg: Color.rgba(245, 158, 11, 0.1)),
              _StatTile(colorScheme: colorScheme, label: 'Submitted', count: submitted, accentColor: '#3B82F6', accentBg: Color.rgba(59, 130, 246, 0.1)),
              _StatTile(colorScheme: colorScheme, label: 'Pending', count: pending, accentColor: '#8B5CF6', accentBg: Color.rgba(139, 92, 246, 0.1)),
              _StatTile(colorScheme: colorScheme, label: 'Rejected', count: rejected, accentColor: '#EF4444', accentBg: Color.rgba(239, 68, 68, 0.1)),
            ]),
          ],
        );
      },
      loading: () => _StatsCardShimmer(colorScheme: colorScheme, title: 'KYC Verification'),
      error: (_, __) => _StatsCardShimmer(colorScheme: colorScheme, title: 'KYC Verification'),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Guarantor Checks Card
// ─────────────────────────────────────────────────────────────

class _GuarantorCard extends StatelessComponent {
  final ColorScheme colorScheme;

  const _GuarantorCard({required this.colorScheme});

  @override
  Component build(BuildContext context) {
    final guarantorAsync = context.watch(adminGuarantorStatsProvider);

    return guarantorAsync.when(
      data: (guarantorStats) {
        final total = guarantorStats?.totalGuarantors ?? 0;
        final passed = guarantorStats?.totalPassed ?? 0;
        final failed = guarantorStats?.totalFailed ?? 0;
        final pending = guarantorStats?.totalPending ?? 0;
        final underReview = guarantorStats?.totalUnderReview ?? 0;
        final safeDivisor = total > 0 ? total : 1;

        return div(
          classes: 'rounded-2xl p-6 border shadow-sm h-full flex flex-col',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            _CardHeader(
              colorScheme: colorScheme,
              title: 'Guarantor Checks',
              icon: AppIcons.guarantors,
              iconBgColor: Color.rgba(139, 92, 246, 0.15),
              iconColor: const Color('#8B5CF6'),
              trailing: span(
                classes: 'text-lg font-extrabold',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('$total')],
              ),
            ),

            // Stacked progress bar
            div(classes: 'mt-4 mb-1', [
              div(
                classes: 'h-2 rounded-full overflow-hidden flex',
                styles: Styles(backgroundColor: Color(colorScheme.inputBg)),
                [
                  if (passed > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(passed / safeDivisor * 100), backgroundColor: Color(colorScheme.primary)), []),
                  if (underReview > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(underReview / safeDivisor * 100), backgroundColor: const Color('#F59E0B')), []),
                  if (pending > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(pending / safeDivisor * 100), backgroundColor: const Color('#8B5CF6')), []),
                  if (failed > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(failed / safeDivisor * 100), backgroundColor: const Color('#EF4444')), []),
                ],
              ),
            ]),

            // Stats grid
            div(classes: 'flex-1 mt-3 grid grid-cols-2 gap-2.5', [
              _StatTile(colorScheme: colorScheme, label: 'Passed', count: passed, accentColor: colorScheme.primary, accentBg: Color.rgba(0, 168, 112, 0.1)),
              _StatTile(colorScheme: colorScheme, label: 'Under Review', count: underReview, accentColor: '#F59E0B', accentBg: Color.rgba(245, 158, 11, 0.1)),
              _StatTile(colorScheme: colorScheme, label: 'Pending', count: pending, accentColor: '#8B5CF6', accentBg: Color.rgba(139, 92, 246, 0.1)),
              _StatTile(colorScheme: colorScheme, label: 'Failed', count: failed, accentColor: '#EF4444', accentBg: Color.rgba(239, 68, 68, 0.1)),
            ]),
          ],
        );
      },
      loading: () => _StatsCardShimmer(colorScheme: colorScheme, title: 'Guarantor Checks'),
      error: (_, __) => _StatsCardShimmer(colorScheme: colorScheme, title: 'Guarantor Checks'),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Interview Pipeline Card
// ─────────────────────────────────────────────────────────────

class _InterviewPipelineCard extends StatelessComponent {
  final ColorScheme colorScheme;

  const _InterviewPipelineCard({required this.colorScheme});

  @override
  Component build(BuildContext context) {
    final interviewAsync = context.watch(adminInterviewStatsProvider);

    return interviewAsync.when(
      data: (interviewStats) {
        final total = interviewStats?.totalInterviews ?? 0;
        final scheduled = interviewStats?.totalScheduled ?? 0;
        final passed = interviewStats?.totalPassed ?? 0;
        final failed = interviewStats?.totalFailed ?? 0;
        final cancelled = interviewStats?.totalCancelled ?? 0;
        final rescheduled = interviewStats?.totalRescheduled ?? 0;
        final safeDivisor = total > 0 ? total : 1;

        return div(
          classes: 'rounded-2xl p-6 border shadow-sm h-full flex flex-col',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            _CardHeader(
              colorScheme: colorScheme,
              title: 'Interview Pipeline',
              icon: AppIcons.calendar,
              iconBgColor: Color.rgba(59, 130, 246, 0.15),
              iconColor: const Color('#3B82F6'),
              trailing: span(
                classes: 'text-lg font-extrabold',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('$total')],
              ),
            ),

            // Stacked progress bar
            div(classes: 'mt-4 mb-1', [
              div(
                classes: 'h-2 rounded-full overflow-hidden flex',
                styles: Styles(backgroundColor: Color(colorScheme.inputBg)),
                [
                  if (scheduled > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(scheduled / safeDivisor * 100), backgroundColor: const Color('#3B82F6')), []),
                  if (passed > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(passed / safeDivisor * 100), backgroundColor: Color(colorScheme.primary)), []),
                  if (rescheduled > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(rescheduled / safeDivisor * 100), backgroundColor: const Color('#F59E0B')), []),
                  if (failed > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(failed / safeDivisor * 100), backgroundColor: const Color('#EF4444')), []),
                  if (cancelled > 0)
                    div(classes: 'h-full', styles: Styles(width: Unit.percent(cancelled / safeDivisor * 100), backgroundColor: const Color('#6B7280')), []),
                ],
              ),
            ]),

            // Stats grid
            div(classes: 'flex-1 mt-3 grid grid-cols-2 gap-2.5', [
              _StatTile(colorScheme: colorScheme, label: 'Scheduled', count: scheduled, accentColor: '#3B82F6', accentBg: Color.rgba(59, 130, 246, 0.1)),
              _StatTile(colorScheme: colorScheme, label: 'Passed', count: passed, accentColor: colorScheme.primary, accentBg: Color.rgba(0, 168, 112, 0.1)),
              _StatTile(colorScheme: colorScheme, label: 'Rescheduled', count: rescheduled, accentColor: '#F59E0B', accentBg: Color.rgba(245, 158, 11, 0.1)),
              _StatTile(colorScheme: colorScheme, label: 'Failed', count: failed, accentColor: '#EF4444', accentBg: Color.rgba(239, 68, 68, 0.1)),
              _StatTile(colorScheme: colorScheme, label: 'Cancelled', count: cancelled, accentColor: '#6B7280', accentBg: Color.rgba(107, 114, 128, 0.1)),
            ]),
          ],
        );
      },
      loading: () => _StatsCardShimmer(colorScheme: colorScheme, title: 'Interview Pipeline'),
      error: (_, __) => _StatsCardShimmer(colorScheme: colorScheme, title: 'Interview Pipeline'),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stat Tile (compact colored tile for pipeline grids)
// ─────────────────────────────────────────────────────────────

class _StatTile extends StatelessComponent {
  final ColorScheme colorScheme;
  final String label;
  final int count;
  final String accentColor;
  final Color accentBg;

  const _StatTile({
    required this.colorScheme,
    required this.label,
    required this.count,
    required this.accentColor,
    required this.accentBg,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'p-3 rounded-xl flex flex-col space-y-1',
      styles: Styles(backgroundColor: accentBg),
      [
        div(classes: 'flex items-center space-x-1.5', [
          div(
            classes: 'w-1.5 h-1.5 rounded-full flex-shrink-0',
            styles: Styles(backgroundColor: Color(accentColor)),
            [],
          ),
          span(
            classes: 'text-xs font-medium truncate',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text(label)],
          ),
        ]),
        span(
          classes: 'text-lg font-bold',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text('$count')],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// User Activity Card
// ─────────────────────────────────────────────────────────────

class _UserActivityCard extends StatelessComponent {
  final ColorScheme colorScheme;
  final AdminDashboardOverview overview;

  const _UserActivityCard({
    required this.colorScheme,
    required this.overview,
  });

  @override
  Component build(BuildContext context) {
    final userAsync = context.watch(adminUserStatsProvider);

    return userAsync.when(
      data: (userStats) {
        final totalUsers = userStats?.totalUsers ?? overview.totalUsers ?? 0;
        final activeUsers = userStats?.totalActive ?? 0;
        final inactiveUsers = userStats?.totalInactive ?? 0;
        final customers = userStats?.totalCustomers ?? overview.totalCustomers ?? 0;
        final providers = userStats?.totalProviders ?? overview.totalProviders ?? 0;
        final hasActivityData = activeUsers > 0 || inactiveUsers > 0;
        final activePct = hasActivityData && totalUsers > 0 ? (activeUsers / totalUsers * 100).toInt() : 0;
        final inactivePct = hasActivityData && totalUsers > 0 ? 100 - activePct : 0;

        return div(
          classes: 'rounded-2xl p-6 border shadow-sm h-full flex flex-col',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            _CardHeader(
              colorScheme: colorScheme,
              title: 'User Activity',
              icon: AppIcons.customersGroup,
              iconBgColor: Color.rgba(245, 158, 11, 0.15),
              iconColor: const Color('#F59E0B'),
            ),

            // Active / Inactive split bar
            div(classes: 'mt-5 space-y-2', [
              div(
                classes: 'flex items-center h-3 rounded-full overflow-hidden',
                styles: Styles(backgroundColor: Color(colorScheme.inputBg)),
                [
                  if (hasActivityData && activePct > 0)
                    div(
                      classes: 'h-full rounded-l-full transition-all',
                      styles: Styles(
                        width: Unit.percent(activePct.toDouble()),
                        backgroundColor: Color(colorScheme.primary),
                      ),
                      [],
                    ),
                  if (hasActivityData && inactivePct > 0)
                    div(
                      classes: 'h-full rounded-r-full transition-all',
                      styles: Styles(
                        width: Unit.percent(inactivePct.toDouble()),
                        backgroundColor: Color.rgba(239, 68, 68, 0.6),
                      ),
                      [],
                    ),
                ],
              ),
              if (hasActivityData)
                div(classes: 'flex items-center justify-between text-xs', [
                  div(classes: 'flex items-center space-x-1.5', [
                    div(
                      classes: 'w-2 h-2 rounded-full',
                      styles: Styles(backgroundColor: Color(colorScheme.primary)),
                      [],
                    ),
                    span(
                      classes: 'font-semibold',
                      styles: Styles(color: Color(colorScheme.textPrimary)),
                      [Component.text('Active $activeUsers ($activePct%)')],
                    ),
                  ]),
                  div(classes: 'flex items-center space-x-1.5', [
                    div(
                      classes: 'w-2 h-2 rounded-full',
                      styles: Styles(backgroundColor: Color.rgba(239, 68, 68, 0.6)),
                      [],
                    ),
                    span(
                      classes: 'font-semibold',
                      styles: Styles(color: Color(colorScheme.textPrimary)),
                      [Component.text('Inactive $inactiveUsers ($inactivePct%)')],
                    ),
                  ]),
                ]),
              if (!hasActivityData)
                span(
                  classes: 'text-xs font-medium text-center',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  [Component.text('No activity data yet')],
                ),
            ]),

            // User type mini cards
            div(classes: 'mt-5 grid grid-cols-2 gap-3', [
              _MiniStatCard(
                colorScheme: colorScheme,
                label: 'Customers',
                value: '$customers',
                icon: AppIcons.customer,
                accentColor: const Color('#3B82F6'),
                accentBgColor: Color.rgba(59, 130, 246, 0.12),
              ),
              _MiniStatCard(
                colorScheme: colorScheme,
                label: 'Providers',
                value: '$providers',
                icon: AppIcons.administrators,
                accentColor: const Color('#8B5CF6'),
                accentBgColor: Color.rgba(139, 92, 246, 0.12),
              ),
            ]),

            // Total footer
            div(
              classes: 'mt-4 pt-3 border-t flex items-center justify-between',
              styles: Styles(raw: {'border-color': colorScheme.border}),
              [
                span(
                  classes: 'text-xs font-semibold',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  [Component.text('Total Registered')],
                ),
                span(
                  classes: 'text-sm font-extrabold',
                  styles: Styles(color: Color(colorScheme.primary)),
                  [Component.text('$totalUsers')],
                ),
              ],
            ),
          ],
        );
      },
      loading: () => _StatsCardShimmer(colorScheme: colorScheme, title: 'User Activity'),
      error: (_, __) => _StatsCardShimmer(colorScheme: colorScheme, title: 'User Activity'),
    );
  }
}

class _MiniStatCard extends StatelessComponent {
  final ColorScheme colorScheme;
  final String label;
  final String value;
  final AppIcons icon;
  final Color accentColor;
  final Color accentBgColor;

  const _MiniStatCard({
    required this.colorScheme,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.accentBgColor,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'p-3.5 rounded-xl border flex items-center space-x-3',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(
          classes: 'w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0',
          styles: Styles(
            backgroundColor: accentBgColor,
            color: accentColor,
          ),
          [AppIcon(icon)],
        ),
        div(classes: 'flex flex-col', [
          span(
            classes: 'text-xs font-medium',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text(label)],
          ),
          span(
            classes: 'text-base font-bold',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [Component.text(value)],
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
      classes: 'rounded-2xl p-6 border shadow-sm space-y-6 h-full',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        _CardHeader(
          colorScheme: colorScheme,
          title: 'Task Operations',
          icon: AppIcons.tasks,
          iconBgColor: Color.rgba(0, 168, 112, 0.15),
          iconColor: Color(colorScheme.primary),
          trailing: span(
            classes: 'text-xs font-bold px-3 py-1 rounded-full border',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.border},
            ),
            [Component.text('${overview.totalTasks ?? 0} Total')],
          ),
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
            barColor: const Color('#F59E0B'),
          ),
          _StatusProgressRow(
            colorScheme: colorScheme,
            label: 'Open Tasks',
            count: open,
            total: total,
            barColor: const Color('#6366F1'),
          ),
          _StatusProgressRow(
            colorScheme: colorScheme,
            label: 'Cancelled Tasks',
            count: cancelled,
            total: total,
            barColor: const Color('#EF4444'),
          ),
        ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared Components
// ─────────────────────────────────────────────────────────────

class _CardHeader extends StatelessComponent {
  final ColorScheme colorScheme;
  final String title;
  final AppIcons icon;
  final Color iconBgColor;
  final Color iconColor;
  final Component? trailing;

  const _CardHeader({
    required this.colorScheme,
    required this.title,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.trailing,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'flex items-center justify-between pb-4 border-b',
      styles: Styles(raw: {'border-color': colorScheme.border}),
      [
        div(classes: 'flex items-center space-x-2.5', [
          div(
            classes: 'w-8 h-8 rounded-xl flex items-center justify-center',
            styles: Styles(
              backgroundColor: iconBgColor,
              color: iconColor,
            ),
            [
              AppIcon(icon),
            ],
          ),
          h3(
            classes: 'text-sm font-bold',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [Component.text(title)],
          ),
        ]),
        if (trailing != null) trailing!,
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
            classes: 'h-full rounded-full transition-all duration-500 animate-progress-fill',
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
// Loading Shimmer, Empty State & Error Components
// ─────────────────────────────────────────────────────────────

class _StatsCardShimmer extends StatelessComponent {
  final ColorScheme colorScheme;
  final String title;

  const _StatsCardShimmer({required this.colorScheme, required this.title});

  @override
  Component build(BuildContext context) {
    final blockColor = colorScheme.isDark ? Color.rgba(31, 45, 39, 0.8) : Color.rgba(226, 232, 240, 0.8);

    return div(
      classes: 'relative rounded-2xl p-5 border flex flex-col justify-between overflow-hidden shadow-sm animate-pulse',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'flex items-center justify-between', [
          span(classes: 'text-sm font-semibold tracking-tight', styles: Styles(color: Color(colorScheme.textSecondary)), [Component.text(title)]),
          div(
            classes: 'w-7 h-7 rounded-lg',
            styles: Styles(backgroundColor: blockColor),
            [],
          ),
        ]),
        div(classes: 'mt-4 space-y-3 flex-1 flex flex-col justify-end', [
          div(
            classes: 'h-7 w-20 rounded-lg',
            styles: Styles(backgroundColor: blockColor),
            [],
          ),
          div(classes: 'grid grid-cols-2 gap-2.5', [
            for (var i = 0; i < 4; i++)
              div(
                classes: 'h-12 rounded-xl',
                styles: Styles(backgroundColor: blockColor),
                [],
              ),
          ]),
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

    return div(classes: 'space-y-6 animate-pulse', [
      // Header shimmer
      div(classes: 'flex items-center justify-between', [
        div(classes: 'space-y-2', [
          div(
            classes: 'h-6 w-48 rounded-lg',
            styles: Styles(backgroundColor: blockColor),
            [],
          ),
          div(
            classes: 'h-3 w-72 rounded-md',
            styles: Styles(backgroundColor: blockColor),
            [],
          ),
        ]),
        div(
          classes: 'h-5 w-12 rounded-full',
          styles: Styles(backgroundColor: blockColor),
          [],
        ),
      ]),

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
            div(classes: 'flex items-center space-x-4', [
              div(
                classes: 'w-32 h-32 rounded-full',
                styles: Styles(backgroundColor: blockColor),
                [],
              ),
              div(classes: 'flex-1 space-y-3', [
                for (var j = 0; j < 4; j++)
                  div(
                    classes: 'h-12 rounded-xl',
                    styles: Styles(backgroundColor: blockColor),
                    [],
                  ),
              ]),
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
              classes: 'h-5 w-40 rounded-md',
              styles: Styles(backgroundColor: blockColor),
              [],
            ),
            for (var k = 0; k < 3; k++)
              div(classes: 'space-y-2', [
                div(
                  classes: 'h-3 w-full rounded-md',
                  styles: Styles(backgroundColor: blockColor),
                  [],
                ),
                div(
                  classes: 'h-3 w-full rounded-full',
                  styles: Styles(backgroundColor: blockColor),
                  [],
                ),
              ]),
          ],
        ),
      ]),

      // 3 Column Shimmers
      div(classes: 'grid grid-cols-1 lg:grid-cols-3 gap-6', [
        for (var m = 0; m < 3; m++)
          div(
            classes: 'rounded-2xl p-6 border space-y-4 shadow-sm',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              raw: {'border-color': colorScheme.border},
            ),
            [
              div(
                classes: 'h-5 w-32 rounded-md',
                styles: Styles(backgroundColor: blockColor),
                [],
              ),
              for (var n = 0; n < 4; n++)
                div(
                  classes: 'h-8 rounded-lg',
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
