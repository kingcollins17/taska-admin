import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/kpi_card.dart';
import '../components/leads_industry_card.dart';
import '../components/sales_chart_card.dart';
import '../components/top_products_table.dart';
import '../components/visitor_chart_card.dart';
import '../components/weekly_revenue_card.dart';
import '../core/designs/app_icons.dart';

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex-1 space-y-6', [
      // Top Row: 3 KPI Cards Grid
      div(classes: 'grid grid-cols-1 sm:grid-cols-3 gap-5', [
        const KpiCard(
          title: 'Products',
          count: '6201',
          changePercentage: '10%',
          isPositive: true,
          icon: AppIcons.productsBag,
        ),
        const KpiCard(
          title: 'Customers',
          count: '1351',
          changePercentage: '5%',
          isPositive: false,
          icon: AppIcons.customersGroup,
        ),
        const KpiCard(
          title: 'Orders',
          count: '1190',
          changePercentage: '8%',
          isPositive: true,
          icon: AppIcons.ordersDoc,
        ),
      ]),

      // Main Dashboard Layout Grid (Left Column 8/12, Right Column 4/12)
      div(classes: 'grid grid-cols-1 lg:grid-cols-12 gap-6', [
        // Left Column (8 cols): Sales Chart + Top Products Table
        div(classes: 'lg:col-span-7 xl:col-span-8 space-y-6', [
          const SalesChartCard(),
          const TopProductsTable(),
        ]),

        // Right Column (4 cols): Visitor + Weekly Revenue + Leads by Industry
        div(classes: 'lg:col-span-5 xl:col-span-4 space-y-6', [
          const VisitorChartCard(),
          const WeeklyRevenueCard(),
          const LeadsIndustryCard(),
        ]),
      ]),
    ]);
  }
}
