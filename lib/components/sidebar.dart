import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';

class Sidebar extends StatelessComponent {
  final String activePath;
  const Sidebar({super.key, this.activePath = '/'});

  @override
  Component build(BuildContext context) {
    return aside(classes: 'w-64 bg-white dark:bg-[#131916] border-r border-slate-200/80 dark:border-[#1F2D27] h-screen sticky top-0 p-4 md:p-5 flex flex-col justify-between shrink-0 overflow-hidden select-none transition-colors', [
      div(classes: 'flex flex-col flex-1 overflow-hidden', [
        // Logo Section
        div(classes: 'flex items-center space-x-3 mb-5 px-2 shrink-0', [
          div(classes: 'w-8 h-8 md:w-9 md:h-9 bg-[#00A870] rounded-xl flex items-center justify-center text-white shadow-md shadow-emerald-500/20', [
            const AppIcon(AppIcons.logo),
          ]),
          span(classes: 'text-lg md:text-xl font-extrabold text-slate-900 dark:text-white tracking-tight', [
            Component.text('Taska'),
          ]),
        ]),

        // MENU Section
        div(classes: 'mb-4 shrink-0', [
          div(classes: 'text-[10px] font-bold text-slate-400 dark:text-slate-500 tracking-wider uppercase mb-1.5 px-3', [
            Component.text('MENU'),
          ]),
          nav(classes: 'space-y-0.5', [
            _buildNavItem('Overview', '/', AppIcons.overview, isActive: activePath == '/' || activePath == '/overview'),
            _buildNavItem('Users', '/users', AppIcons.customersGroup, isActive: activePath == '/users'),
            _buildNavItem('Transaction', '/transactions', AppIcons.transaction, isActive: activePath == '/transactions'),
            _buildNavItem('Customer', '/customers', AppIcons.customer, isActive: activePath == '/customers'),
            _buildNavItem('Marketing', '/marketing', AppIcons.marketing, isActive: activePath == '/marketing'),
            _buildNavItem('Analytics', '/analytics', AppIcons.analytics, isActive: activePath == '/analytics'),
            _buildNavItem('Documents', '/documents', AppIcons.documents, isActive: activePath == '/documents'),
          ]),
        ]),

        // ORDER Section
        div(classes: 'mb-4 shrink-0', [
          div(classes: 'text-[10px] font-bold text-slate-400 dark:text-slate-500 tracking-wider uppercase mb-1.5 px-3', [
            Component.text('ORDER'),
          ]),
          nav(classes: 'space-y-0.5', [
            _buildNavItem('Get help', '/help', AppIcons.help, isActive: activePath == '/help'),
            _buildNavItem('Setting', '/settings', AppIcons.setting, isActive: activePath == '/settings'),
            _buildNavItem('Integration', '/integration', AppIcons.integration, isActive: activePath == '/integration'),
            _buildNavItem('Auth Page', '/login', AppIcons.customer, isActive: activePath == '/login'),
          ]),
        ]),
      ]),

      // Bottom Upgrade Card
      div(classes: 'bg-gradient-to-br from-emerald-50/50 via-slate-50 to-emerald-50/30 dark:from-[#18201D] dark:via-[#131916] dark:to-[#0F261F] border border-slate-200/70 dark:border-[#1F2D27] rounded-2xl p-3.5 shadow-sm shrink-0 mt-auto', [
        div(classes: 'flex items-center space-x-2 mb-1.5', [
          div(classes: 'w-6 h-6 rounded-lg bg-emerald-100 dark:bg-emerald-950/60 flex items-center justify-center text-[#00A870] dark:text-[#00F5A0] shrink-0', [
            const AppIcon(AppIcons.lightbulb),
          ]),
          span(classes: 'text-xs font-bold text-slate-900 dark:text-white', [
            Component.text('Upgrade plans'),
          ]),
        ]),
        p(classes: 'text-[10.5px] text-slate-500 dark:text-slate-400 leading-snug mb-2.5', [
          Component.text('Unlock Your Full Service Potential with Taska Premium 🚀'),
        ]),
        button(
          classes: 'w-full bg-[#00A870] hover:bg-[#008F5F] active:scale-[0.98] text-white text-xs font-semibold py-2 px-3 rounded-xl transition-all shadow-md shadow-emerald-900/15 cursor-pointer text-center block',
          [Component.text('Upgrade now')],
        ),
      ]),
    ]);
  }

  Component _buildNavItem(String label, String path, AppIcons icon, {bool isActive = false}) {
    if (isActive) {
      return a(
        href: path,
        classes: 'bg-[#00A870] text-white font-medium rounded-xl px-3 py-2 flex items-center space-x-3 shadow-md shadow-emerald-600/20 transition-all text-xs md:text-sm',
        [
          AppIcon(icon),
          span(classes: 'font-medium', [Component.text(label)]),
        ],
      );
    }
    return a(
      href: path,
      classes: 'text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white hover:bg-slate-100/80 dark:hover:bg-[#18201D] rounded-xl px-3 py-2 flex items-center space-x-3 transition-colors text-xs md:text-sm',
      [
        AppIcon(icon),
        span(classes: 'font-medium', [Component.text(label)]),
      ],
    );
  }
}
