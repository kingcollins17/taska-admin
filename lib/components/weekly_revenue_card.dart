import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';

class WeeklyRevenueCard extends StatelessComponent {
  const WeeklyRevenueCard({super.key});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'bg-white dark:bg-slate-900 rounded-2xl p-5 border border-slate-100 dark:border-slate-800 shadow-sm flex flex-col justify-between transition-colors',
      [
        // Header
        div(classes: 'flex items-center justify-between mb-4', [
          h3(classes: 'text-sm font-bold text-slate-900 dark:text-white', [Component.text('Weekly Revenue')]),
          button(classes: 'text-slate-400 dark:text-slate-500 hover:text-slate-600 dark:hover:text-slate-300 cursor-pointer', [
            const AppIcon(AppIcons.moreVertical),
          ]),
        ]),

        // Bar Chart Area
        div(classes: 'relative w-full h-44 my-1 flex items-end justify-between px-2', [
          // Y-axis Labels
          div(classes: 'absolute left-0 top-0 bottom-6 flex flex-col justify-between text-[10px] font-medium text-slate-400 dark:text-slate-500', [
            span([Component.text('100k')]),
            span([Component.text('90k')]),
            span([Component.text('60k')]),
            span([Component.text('30k')]),
            span([Component.text('10k')]),
          ]),

          // Floating Tooltip above Wednesday
          div(classes: 'absolute left-[45%] top-2 -translate-x-1/2 bg-white dark:bg-slate-800 rounded-lg px-2.5 py-1 border border-slate-200 dark:border-slate-700 shadow-md text-xs font-extrabold text-slate-900 dark:text-white z-10 animate-pulse', [
            Component.text('\$20,989'),
          ]),

          // Bars (Mon, Tue, Wed, Thu, Fri)
          div(classes: 'w-full pl-9 flex items-end justify-around h-full pt-6 pb-6', [
            _buildBar('Mon', 'h-24', isHighlighted: false),
            _buildBar('Tue', 'h-28', isHighlighted: false),
            _buildBar('Wed', 'h-36', isHighlighted: true),
            _buildBar('Thu', 'h-20', isHighlighted: false),
            _buildBar('Fri', 'h-32', isHighlighted: false),
          ]),
        ]),

        // X-Axis Day Labels
        div(classes: 'flex items-center justify-around text-xs text-slate-400 dark:text-slate-500 pt-2 border-t border-slate-100 dark:border-slate-800 pl-7', [
          span([Component.text('Mon')]),
          span([Component.text('Tue')]),
          span(classes: 'font-bold text-slate-700 dark:text-slate-200', [Component.text('Wed')]),
          span([Component.text('Thu')]),
          span([Component.text('Fri')]),
        ]),
      ],
    );
  }

  Component _buildBar(String day, String heightClass, {required bool isHighlighted}) {
    if (isHighlighted) {
      return div(classes: 'w-7 $heightClass bg-gradient-to-t from-lime-400 to-emerald-400 rounded-xl shadow-md shadow-lime-500/20 hover:scale-105 transition-transform', []);
    }
    return div(classes: 'w-7 $heightClass bg-slate-100/90 dark:bg-slate-800 rounded-xl hover:bg-slate-200 dark:hover:bg-slate-700 transition-colors', []);
  }
}
