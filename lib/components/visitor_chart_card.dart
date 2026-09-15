import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';

class VisitorChartCard extends StatelessComponent {
  const VisitorChartCard({super.key});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'bg-white dark:bg-[#131916] rounded-2xl p-5 border border-slate-200/80 dark:border-[#1F2D27] shadow-sm flex flex-col justify-between transition-colors',
      [
        // Header
        div(classes: 'flex items-center justify-between mb-4', [
          h3(classes: 'text-sm font-bold text-slate-900 dark:text-white', [Component.text('Visitor')]),
          button(classes: 'text-slate-400 dark:text-slate-500 hover:text-slate-600 dark:hover:text-slate-300 cursor-pointer', [
            const AppIcon(AppIcons.moreVertical),
          ]),
        ]),

        // Chart Visual Container
        div(classes: 'relative w-full h-36 my-2', [
          RawText('''<svg class="w-full h-full overflow-visible" viewBox="0 0 300 100">
            <!-- Background Grid Lines -->
            <line x1="0" y1="20" x2="300" y2="20" stroke="#1F2D27" stroke-width="1" stroke-dasharray="4 4" />
            <line x1="0" y1="50" x2="300" y2="50" stroke="#1F2D27" stroke-width="1" stroke-dasharray="4 4" />
            <line x1="0" y1="80" x2="300" y2="80" stroke="#1F2D27" stroke-width="1" stroke-dasharray="4 4" />

            <!-- Secondary Light Green Trend Line -->
            <path d="M 15 75 L 85 70 L 155 45 L 225 60 L 285 55" fill="none" stroke="#A7F3D0" stroke-width="2.5" />

            <!-- Primary Taska Green Trend Line -->
            <path d="M 15 55 L 85 35 L 155 40 L 225 25 L 285 40" fill="none" stroke="#00A870" stroke-width="2.5" />

            <!-- Data Dots on Primary Line -->
            <circle cx="15" cy="55" r="4" fill="#00A870" />
            <circle cx="85" cy="35" r="4" fill="#00A870" />
            <circle cx="155" cy="40" r="4" fill="#FFFFFF" stroke="#00A870" stroke-width="2.5" />
            <circle cx="225" cy="25" r="4" fill="#00A870" />
            <circle cx="285" cy="40" r="4" fill="#00A870" />

            <!-- Data Dots on Secondary Line -->
            <circle cx="155" cy="45" r="3.5" fill="#00F5A0" />
          </svg>'''),

          // Tooltip Badge at point 155, 40 ("17-21")
          div(classes: 'absolute left-[45%] top-[12%] -translate-x-1/2 bg-white dark:bg-[#18201D] rounded-full px-2.5 py-0.5 border border-emerald-200 dark:border-[#1F2D27] shadow-sm flex items-center space-x-1 text-[11px] font-bold text-[#00A870] dark:text-[#00F5A0]', [
            const AppIcon(AppIcons.chartGrowth),
            span([Component.text('+ 12%')]),
          ]),
        ]),

        // X-Axis Date Range Labels
        div(classes: 'flex items-center justify-between text-xs text-slate-400 dark:text-slate-500 pt-2 border-t border-slate-100 dark:border-[#1F2D27]', [
          span(classes: 'px-2 py-0.5', [Component.text('03-07')]),
          span(classes: 'px-2 py-0.5', [Component.text('10-14')]),
          span(classes: 'px-3 py-0.5 rounded-full border border-[#00A870] text-[#00A870] dark:text-[#00F5A0] font-bold text-[11px] bg-emerald-50/50 dark:bg-emerald-950/40', [Component.text('17-21')]),
          span(classes: 'px-2 py-0.5', [Component.text('24-28')]),
        ]),
      ],
    );
  }
}
