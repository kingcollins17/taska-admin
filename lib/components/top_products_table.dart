import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';

class TopProductsTable extends StatelessComponent {
  const TopProductsTable({super.key});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'bg-white dark:bg-[#131916] rounded-2xl p-6 border border-slate-200/80 dark:border-[#1F2D27] shadow-sm overflow-hidden flex flex-col justify-between transition-colors',
      [
        // Table Card Header
        div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6', [
          div(classes: 'flex items-center space-x-3', [
            h3(classes: 'text-base font-bold text-slate-900 dark:text-white', [Component.text('Top Selling Product')]),
            span(classes: 'text-xs font-bold text-[#00A870] dark:text-[#00F5A0] bg-emerald-50 dark:bg-emerald-950/40 px-2.5 py-1 rounded-full border border-emerald-100 dark:border-emerald-800/60', [
              Component.text('15 Product'),
            ]),
          ]),

          div(classes: 'flex items-center space-x-3', [
            // Filters Button
            button(classes: 'bg-white dark:bg-[#18201D] border border-slate-200/90 dark:border-[#1F2D27] text-slate-700 dark:text-slate-200 text-xs font-semibold px-3 py-1.5 rounded-lg hover:bg-slate-50 dark:hover:bg-[#1F2D27] transition-colors shadow-sm flex items-center space-x-1.5 cursor-pointer', [
              const AppIcon(AppIcons.filter),
              span([Component.text('Filters')]),
            ]),

            // See More Primary Button
            button(classes: 'bg-[#00A870] hover:bg-[#008F5F] text-white text-xs font-semibold px-4 py-1.5 rounded-lg transition-all shadow-md shadow-emerald-900/10 cursor-pointer', [
              Component.text('See More'),
            ]),
          ]),
        ]),

        // Responsive Data Table
        div(classes: 'overflow-x-auto', [
          table(classes: 'w-full text-left border-collapse', [
            // Table Header
            thead(classes: 'border-b border-slate-100 dark:border-[#1F2D27] text-[11px] font-semibold text-slate-400 dark:text-slate-500 uppercase tracking-wider', [
              tr([
                th(classes: 'pb-3 font-semibold', [
                  div(classes: 'flex items-center space-x-1', [
                    span([Component.text('Product')]),
                    const AppIcon(AppIcons.tableSortArrow),
                  ]),
                ]),
                th(classes: 'pb-3 font-semibold text-center', [
                  div(classes: 'flex items-center justify-center space-x-1', [
                    span([Component.text('Sales')]),
                    const AppIcon(AppIcons.tableSortArrow),
                  ]),
                ]),
                th(classes: 'pb-3 font-semibold text-right', [
                  div(classes: 'flex items-center justify-end space-x-1', [
                    span([Component.text('Amount')]),
                    const AppIcon(AppIcons.tableSortArrow),
                  ]),
                ]),
                th(classes: 'pb-3 font-semibold text-right', [Component.text('Price')]),
                th(classes: 'pb-3 font-semibold text-right', [
                  div(classes: 'flex items-center justify-end space-x-1', [
                    span([Component.text('Status')]),
                    const AppIcon(AppIcons.tableSortArrow),
                  ]),
                ]),
              ]),
            ]),

            // Table Rows
            tbody(classes: 'divide-y divide-slate-100/80 dark:divide-slate-800/80 text-xs font-medium text-slate-700 dark:text-slate-300', [
              _buildRow(
                name: 'FlexCR Man...',
                sku: 'SKU: 302012',
                sales: '380',
                amount: '\$84,611',
                price: '\$121.00',
                status: 'Low Cost',
                isPublished: false,
                avatarBg: 'bg-indigo-100 dark:bg-indigo-950/60 text-indigo-600 dark:text-indigo-400',
              ),
              _buildRow(
                name: 'EasyTr Landing',
                sku: 'SKU: 30574',
                sales: '109',
                amount: '\$177,000',
                price: '\$590.00',
                status: 'Published',
                isPublished: true,
                avatarBg: 'bg-emerald-100 dark:bg-emerald-950/60 text-emerald-600 dark:text-emerald-400',
              ),
              _buildRow(
                name: 'Flicio App D...',
                sku: 'SKU: 302855',
                sales: '611',
                amount: '\$37,500',
                price: '\$125.00',
                status: 'Low Cost',
                isPublished: false,
                avatarBg: 'bg-blue-100 dark:bg-blue-950/60 text-blue-600 dark:text-blue-400',
              ),
              _buildRow(
                name: 'Headphone...',
                sku: 'SKU: 302910',
                sales: '490',
                amount: '\$103,704',
                price: '\$248.00',
                status: 'Published',
                isPublished: true,
                avatarBg: 'bg-amber-100 dark:bg-amber-950/60 text-amber-600 dark:text-amber-400',
              ),
            ]),
          ]),
        ]),
      ],
    );
  }

  Component _buildRow({
    required String name,
    required String sku,
    required String sales,
    required String amount,
    required String price,
    required String status,
    required bool isPublished,
    required String avatarBg,
  }) {
    return tr(classes: 'hover:bg-slate-50/70 dark:hover:bg-slate-800/50 transition-colors', [
      td(classes: 'py-3.5', [
        div(classes: 'flex items-center space-x-3', [
          div(classes: 'w-8 h-8 rounded-lg $avatarBg flex items-center justify-center font-bold text-xs shrink-0', [
            Component.text(name.substring(0, 1)),
          ]),
          div([
            div(classes: 'font-bold text-slate-900 dark:text-white text-xs', [Component.text(name)]),
            div(classes: 'text-[10px] text-slate-400 dark:text-slate-500 font-normal', [Component.text(sku)]),
          ]),
        ]),
      ]),
      td(classes: 'py-3.5 text-center font-bold text-slate-900 dark:text-white', [Component.text(sales)]),
      td(classes: 'py-3.5 text-right font-extrabold text-slate-900 dark:text-white', [Component.text(amount)]),
      td(classes: 'py-3.5 text-right font-medium text-slate-600 dark:text-slate-400', [Component.text(price)]),
      td(classes: 'py-3.5 text-right', [
        if (isPublished)
          span(classes: 'inline-block px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400 border border-emerald-100 dark:border-emerald-800/60', [
            Component.text(status),
          ])
        else
          span(classes: 'inline-block px-2.5 py-1 rounded-full text-[11px] font-medium text-slate-500 dark:text-slate-400 bg-slate-100 dark:bg-slate-800 border border-slate-200/60 dark:border-slate-700', [
            Component.text(status),
          ]),
      ]),
    ]);
  }
}
