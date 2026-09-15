import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/providers/ui_state_provider.dart';

class Sidebar extends StatelessComponent {
  final String activePath;
  const Sidebar({super.key, this.activePath = '/'});

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return aside(
      classes:
          'w-64 border-r h-screen sticky top-0 p-4 md:p-5 flex flex-col justify-between shrink-0 overflow-hidden select-none transition-colors',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {
          'border-color': colorScheme.border,
        },
      ),
      [
        div(classes: 'flex flex-col flex-1 overflow-hidden', [
          // Logo Section
          div(classes: 'flex items-center space-x-3 mb-5 px-2 shrink-0', [
            div(
              classes:
                  'w-8 h-8 md:w-9 md:h-9 rounded-xl flex items-center justify-center text-white shadow-md shadow-emerald-500/20',
              styles: Styles(backgroundColor: Color(colorScheme.primary)),
              [
                const AppIcon(AppIcons.logo),
              ],
            ),
            span(
              classes: 'text-lg md:text-xl font-extrabold tracking-tight',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [
                Component.text('Taska'),
              ],
            ),
          ]),

          // MENU Section
          div(classes: 'mb-4 shrink-0', [
            div(
              classes: 'text-[10px] font-bold tracking-wider uppercase mb-1.5 px-3',
              styles: Styles(color: Color(colorScheme.placeholder)),
              [
                Component.text('MENU'),
              ],
            ),
            nav(classes: 'space-y-0.5', [
              _buildNavItem(context, colorScheme, 'Overview', '/', AppIcons.overview,
                  isActive: activePath == '/' || activePath == '/overview'),
              _buildNavItem(context, colorScheme, 'Users', '/users', AppIcons.customersGroup,
                  isActive: activePath == '/users'),
              _buildNavItem(
                  context, colorScheme, 'Transaction', '/transactions', AppIcons.transaction,
                  isActive: activePath == '/transactions'),
              _buildNavItem(context, colorScheme, 'Customer', '/customers', AppIcons.customer,
                  isActive: activePath == '/customers'),
              _buildNavItem(context, colorScheme, 'Marketing', '/marketing', AppIcons.marketing,
                  isActive: activePath == '/marketing'),
              _buildNavItem(context, colorScheme, 'Analytics', '/analytics', AppIcons.analytics,
                  isActive: activePath == '/analytics'),
              _buildNavItem(context, colorScheme, 'Documents', '/documents', AppIcons.documents,
                  isActive: activePath == '/documents'),
            ]),
          ]),

          // ORDER Section
          div(classes: 'mb-4 shrink-0', [
            div(
              classes: 'text-[10px] font-bold tracking-wider uppercase mb-1.5 px-3',
              styles: Styles(color: Color(colorScheme.placeholder)),
              [
                Component.text('ORDER'),
              ],
            ),
            nav(classes: 'space-y-0.5', [
              _buildNavItem(context, colorScheme, 'Get help', '/help', AppIcons.help,
                  isActive: activePath == '/help'),
              _buildNavItem(context, colorScheme, 'Setting', '/settings', AppIcons.setting,
                  isActive: activePath == '/settings'),
              _buildNavItem(
                  context, colorScheme, 'Integration', '/integration', AppIcons.integration,
                  isActive: activePath == '/integration'),
              _buildNavItem(context, colorScheme, 'Auth Page', '/login', AppIcons.customer,
                  isActive: activePath == '/login'),
            ]),
          ]),
        ]),
      ],
    );
  }

  Component _buildNavItem(
      BuildContext context, ColorScheme colorScheme, String label, String path, AppIcons icon,
      {bool isActive = false}) {
    if (isActive) {
      return Link(
        to: path,
        classes:
            'text-white font-medium rounded-xl px-3 py-2 flex items-center space-x-3 shadow-md transition-all text-xs md:text-sm',
        styles: Styles(backgroundColor: Color(colorScheme.primary)),
        child: div(classes: 'flex items-center space-x-3', [
          AppIcon(icon),
          span(classes: 'font-medium', [Component.text(label)]),
        ]),
      );
    }
    return Link(
      to: path,
      classes:
          'rounded-xl px-3 py-2 flex items-center space-x-3 transition-colors text-xs md:text-sm hover:opacity-80',
      styles: Styles(color: Color(colorScheme.textSecondary)),
      child: div(classes: 'flex items-center space-x-3', [
        AppIcon(icon),
        span(classes: 'font-medium', [Component.text(label)]),
      ]),
    );
  }
}
