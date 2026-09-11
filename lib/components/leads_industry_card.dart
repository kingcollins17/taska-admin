import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';

class LeadsIndustryCard extends StatelessComponent {
  const LeadsIndustryCard({super.key});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'bg-white dark:bg-slate-900 rounded-2xl p-5 border border-slate-100 dark:border-slate-800 shadow-sm flex flex-col justify-between transition-colors',
      [
        // Header
        div(classes: 'flex items-center justify-between mb-2', [
          h3(classes: 'text-sm font-bold text-slate-900 dark:text-white', [Component.text('Leads by Industry')]),
          button(classes: 'text-slate-400 dark:text-slate-500 hover:text-slate-600 dark:hover:text-slate-300 cursor-pointer', [
            const AppIcon(AppIcons.moreHorizontal),
          ]),
        ]),

        // Main Stat Row
        div(classes: 'flex items-center justify-between mb-4', [
          span(classes: 'text-2xl font-extrabold text-slate-900 dark:text-white tracking-tight', [Component.text('39.3%')]),
          div(classes: 'flex items-center space-x-1 text-xs font-bold text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-950/40 px-2 py-0.5 rounded-full border border-blue-100 dark:border-blue-800/60', [
            const AppIcon(AppIcons.externalLink),
            span([Component.text('+12.9%')]),
          ]),
        ]),

        // List Breakdown
        div(classes: 'space-y-3 pt-2 border-t border-slate-100 dark:border-slate-800', [
          _buildIndustryItem(
            name: 'Software Management',
            sessions: '34 Sessions',
            percentage: '13.08%',
            progressColor: 'bg-blue-500',
          ),
          _buildIndustryItem(
            name: 'Real Estate',
            sessions: '23 Sessions',
            percentage: '45.08%',
            progressColor: 'bg-emerald-400',
          ),
          _buildIndustryItem(
            name: 'Finance Management',
            sessions: '45 Sessions',
            percentage: '12.08%',
            progressColor: 'bg-indigo-500',
          ),
        ]),
      ],
    );
  }

  Component _buildIndustryItem({
    required String name,
    required String sessions,
    required String percentage,
    required String progressColor,
  }) {
    return div(classes: 'flex flex-col space-y-1', [
      div(classes: 'flex items-center justify-between text-xs', [
        div([
          div(classes: 'font-bold text-slate-900 dark:text-white', [Component.text(name)]),
          div(classes: 'text-[10px] text-slate-400 dark:text-slate-500 font-normal', [Component.text(sessions)]),
        ]),
        span(classes: 'text-[11px] font-bold text-slate-600 dark:text-slate-300 bg-slate-50 dark:bg-slate-800 px-2 py-0.5 rounded-md border border-slate-100 dark:border-slate-700', [
          Component.text(percentage),
        ]),
      ]),
    ]);
  }
}
