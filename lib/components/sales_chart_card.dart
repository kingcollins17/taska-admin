import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';

class SalesChartCard extends StatelessComponent {
  const SalesChartCard({super.key});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'bg-white dark:bg-[#131916] rounded-2xl p-6 border border-slate-200/80 dark:border-[#1F2D27] shadow-sm flex flex-col justify-between overflow-hidden transition-colors',
      [
        // Top Header
        div(classes: 'flex items-center justify-between mb-4', [
          div(classes: 'flex items-center space-x-2.5', [
            div(classes: 'w-7 h-7 rounded-lg bg-emerald-50 dark:bg-emerald-950/50 flex items-center justify-center text-[#00A870] dark:text-[#00F5A0]', [
              const AppIcon(AppIcons.salesTag),
            ]),
            h2(classes: 'text-base font-bold text-slate-900 dark:text-white', [Component.text('Sales')]),
            const AppIcon(AppIcons.infoCircle),
          ]),

          // Action Toolbar Icons
          div(classes: 'flex items-center space-x-2 text-slate-400 dark:text-slate-500', [
            button(classes: 'p-1.5 hover:bg-slate-100 dark:hover:bg-[#18201D] rounded-lg transition-colors cursor-pointer', [
              const AppIcon(AppIcons.expand),
            ]),
            button(classes: 'p-1.5 hover:bg-slate-100 dark:hover:bg-[#18201D] rounded-lg transition-colors cursor-pointer', [
              const AppIcon(AppIcons.editPen),
            ]),
            button(classes: 'p-1.5 hover:bg-slate-100 dark:hover:bg-[#18201D] rounded-lg transition-colors cursor-pointer', [
              const AppIcon(AppIcons.moreHorizontal),
            ]),
          ]),
        ]),

        // Main Stat & Comparison Subtitle
        div(classes: 'mb-6', [
          div(classes: 'text-3xl font-extrabold text-slate-900 dark:text-white tracking-tight mb-2', [
            Component.text('\$94,127'),
          ]),
          div(classes: 'flex items-center space-x-2', [
            span(classes: 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400 border border-emerald-100 dark:border-emerald-800/60', [
              const AppIcon(AppIcons.arrowUp),
              Component.text('12%'),
            ]),
            span(classes: 'text-xs font-medium text-slate-400 dark:text-slate-500', [Component.text('vs last years')]),
          ]),
        ]),

        // 4 Columns Metrics Breakdown
        div(classes: 'grid grid-cols-2 sm:grid-cols-4 gap-4 mb-6 pt-4 border-t border-slate-100 dark:border-[#1F2D27]', [
          _buildStageMetric('Lead', '\$20,010', '80 Deals', '#34D399'),
          _buildStageMetric('Proposal', '\$17,210', '23 Deals', '#00A870'),
          _buildStageMetric('Sales', '\$9,210', '12 Deals', '#00F5A0'),
          _buildStageMetric('Contract sent', '\$8,210', '21 Deals', '#A7F3D0'),
        ]),

        // Wavy Multi-section Area Chart SVG
        div(classes: 'w-full h-32 mt-2 relative', [
          RawText('''<svg class="w-full h-full overflow-visible" viewBox="0 0 600 120" preserveAspectRatio="none">
            <defs>
              <linearGradient id="gradLead" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stop-color="#34D399" stop-opacity="0.8"/>
                <stop offset="100%" stop-color="#6EE7B7" stop-opacity="0.4"/>
              </linearGradient>
              <linearGradient id="gradProposal" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stop-color="#00A870" stop-opacity="0.95"/>
                <stop offset="100%" stop-color="#00734C" stop-opacity="0.9"/>
              </linearGradient>
              <linearGradient id="gradSales" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stop-color="#00F5A0" stop-opacity="0.85"/>
                <stop offset="100%" stop-color="#6EE7B7" stop-opacity="0.5"/>
              </linearGradient>
              <linearGradient id="gradContract" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stop-color="#A7F3D0" stop-opacity="0.9"/>
                <stop offset="100%" stop-color="#D1FAE5" stop-opacity="0.5"/>
              </linearGradient>
            </defs>

            <!-- Segment 1: Lead (Soft Light Blue wave) -->
            <path d="M 0 120 L 0 60 C 50 60, 100 65, 150 70 L 150 120 Z" fill="url(#gradLead)" />

            <!-- Segment 2: Proposal (Deep Blue wave) -->
            <path d="M 150 120 L 150 70 C 200 75, 250 90, 300 80 L 300 120 Z" fill="url(#gradProposal)" />

            <!-- Segment 3: Sales (Mint Green wave) -->
            <path d="M 300 120 L 300 80 C 350 70, 400 85, 450 85 L 450 120 Z" fill="url(#gradSales)" />

            <!-- Segment 4: Contract Sent (Lime Green wave) -->
            <path d="M 450 120 L 450 85 C 500 85, 550 95, 600 90 L 600 120 Z" fill="url(#gradContract)" />

            <!-- Top Continuous Smooth Curved Outline -->
            <path d="M 0 60 C 50 60, 100 65, 150 70 C 200 75, 250 90, 300 80 C 350 70, 400 85, 450 85 C 500 85, 550 95, 600 90" fill="none" stroke="#FFFFFF" stroke-width="2.5" />
          </svg>'''),
        ]),
      ],
    );
  }

  Component _buildStageMetric(String label, String amount, String deals, String colorHex) {
    return div(classes: 'flex flex-col', [
      div(classes: 'text-xs font-semibold text-slate-400 dark:text-slate-500 mb-1', [Component.text(label)]),
      div(classes: 'text-base font-extrabold text-slate-900 dark:text-white tracking-tight', [Component.text(amount)]),
      div(classes: 'text-[11px] font-normal text-slate-400 dark:text-slate-500 mt-0.5', [Component.text(deals)]),
    ]);
  }
}
