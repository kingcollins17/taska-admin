import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';

class KpiCard extends StatelessComponent {
  final String title;
  final String count;
  final String changePercentage;
  final bool isPositive;
  final AppIcons icon;

  const KpiCard({
    super.key,
    required this.title,
    required this.count,
    required this.changePercentage,
    required this.isPositive,
    required this.icon,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'bg-white dark:bg-[#131916] rounded-2xl p-4 border border-slate-200/80 dark:border-[#1F2D27] shadow-sm hover:shadow-md transition-all flex flex-col justify-between',
      [
        // Header Row: Category label with icon + right chevron
        div(classes: 'flex items-center justify-between mb-3', [
          div(classes: 'flex items-center space-x-2 text-slate-500 dark:text-slate-400', [
            AppIcon(icon),
            span(classes: 'text-xs font-semibold text-slate-600 dark:text-slate-300', [Component.text(title)]),
          ]),
          const AppIcon(AppIcons.chevronRight),
        ]),

        // Bottom Row: Main Big Count + Percentage Pill Badge
        div(classes: 'flex items-baseline justify-between', [
          span(classes: 'text-2xl font-bold text-slate-900 dark:text-white tracking-tight', [Component.text(count)]),

          if (isPositive)
            span(classes: 'inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-bold bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400 border border-emerald-100 dark:border-emerald-800/60', [
              const AppIcon(AppIcons.arrowUp),
              Component.text(changePercentage),
            ])
          else
            span(classes: 'inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-bold bg-rose-50 dark:bg-rose-950/40 text-rose-500 dark:text-rose-400 border border-rose-100 dark:border-rose-800/60', [
              const AppIcon(AppIcons.arrowDown),
              Component.text(changePercentage),
            ]),
        ]),
      ],
    );
  }
}
