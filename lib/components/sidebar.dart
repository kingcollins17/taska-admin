import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/providers/network_providers.dart';
import '../core/providers/ui_state_provider.dart';
import '../core/services/local_storage.dart';

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
          div(
            classes: 'flex items-center space-x-3 mb-10 pb-4 border-b px-2 shrink-0 transition-colors',
            styles: Styles(raw: {'border-color': colorScheme.border}),
            [
              div(
                classes:
                    'w-8 h-8 md:w-9 md:h-9 rounded-xl flex items-center justify-center text-white shadow-md shadow-emerald-500/20',
                styles: Styles(backgroundColor: Color(colorScheme.primary)),
                [
                  const AppIcon(AppIcons.logo),
                ],
              ),
              div(classes: 'flex flex-col', [
                span(
                  classes: 'text-lg md:text-xl font-extrabold tracking-tight leading-tight',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [
                    Component.text('Taska'),
                  ],
                ),
                span(
                  classes: 'text-[10px] font-medium tracking-wide uppercase opacity-60',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  [
                    Component.text('Admin Portal'),
                  ],
                ),
              ]),
            ],
          ),

          // Scrollable Navigation Menu
          div(
            classes: 'flex-1 overflow-y-auto space-y-6 pt-2 pr-1 custom-scrollbar',
            [
              // Standalone Top Item: Dashboard
              nav(classes: 'space-y-0.5', [
                _buildNavItem(
                  context,
                  colorScheme,
                  'Dashboard',
                  '/',
                  AppIcons.overview,
                  isActive: activePath == '/' || activePath == '/overview' || activePath == '/dashboard',
                ),
              ]),

              // Operations Section
              _buildSection(
                context,
                colorScheme,
                title: 'OPERATIONS',
                items: [
                  _NavItemData('Users', '/users', AppIcons.customersGroup,
                      isActive: activePath == '/users' || activePath == '/customers'),
                  _NavItemData('KYC', '/kyc', AppIcons.kyc,
                      isActive: activePath == '/kyc' || activePath == '/operations/kyc'),
                  _NavItemData('Guarantors', '/guarantors', AppIcons.guarantors,
                      isActive: activePath == '/guarantors' || activePath == '/operations/guarantors'),
                  _NavItemData('Interviews', '/interviews', AppIcons.calendar,
                      isActive: activePath == '/interviews' || activePath == '/operations/interviews'),
                  _NavItemData('Tasks', '/tasks', AppIcons.tasks,
                      isActive: activePath == '/tasks' || activePath == '/operations/tasks'),
                  _NavItemData('Support', '/support', AppIcons.help,
                      isActive: activePath == '/support' || activePath == '/help'),
                ],
              ),

              // Finance Section
              _buildSection(
                context,
                colorScheme,
                title: 'FINANCE',
                items: [
                  _NavItemData('Payments', '/payments', AppIcons.transaction,
                      isActive: activePath == '/payments' || activePath == '/transactions' || activePath == '/finance/payments'),
                ],
              ),

              // Administration Section
              _buildSection(
                context,
                colorScheme,
                title: 'ADMINISTRATION',
                items: [
                  _NavItemData('Administrators', '/administrators', AppIcons.administrators,
                      isActive: activePath == '/administrators' || activePath == '/admin/administrators'),
                  _NavItemData('Audit Logs', '/audit-logs', AppIcons.auditLogs,
                      isActive: activePath == '/audit-logs' || activePath == '/admin/audit-logs'),
                ],
              ),

              // Logout Button
              div(classes: 'shrink-0', [
                div(
                  classes: 'text-[10px] font-bold tracking-wider uppercase mb-1.5 px-3',
                  styles: Styles(color: Color(colorScheme.placeholder)),
                  [
                    Component.text('ACCOUNT'),
                  ],
                ),
                nav(
                  classes: 'space-y-0.5',
                  [
                    button(
                      type: ButtonType.button,
                      onClick: () {
                        localStorage.removeItem('accessToken');
                        localStorage.removeItem('refreshToken');
                        context.invalidate(isAuthenticatedProvider);
                        Router.of(context).push('/login');
                      },
                      classes:
                          'w-full rounded-xl px-3 py-2 flex items-center space-x-3 transition-colors text-xs md:text-sm hover:opacity-80 cursor-pointer border-none bg-transparent',
                      styles: Styles(color: Color(colorScheme.textSecondary)),
                      [
                        div(classes: 'flex items-center space-x-3', [
                          const AppIcon(AppIcons.logout),
                          span(classes: 'font-medium', [Component.text('Logout')]),
                        ]),
                      ],
                    ),
                  ],
                ),
              ]),
            ],
          ),
        ]),
      ],
    );
  }

  Component _buildSection(
    BuildContext context,
    ColorScheme colorScheme, {
    required String title,
    required List<_NavItemData> items,
  }) {
    return div(classes: 'shrink-0', [
      div(
        classes: 'text-[10px] font-bold tracking-wider uppercase mb-1.5 px-3',
        styles: Styles(color: Color(colorScheme.placeholder)),
        [
          Component.text(title),
        ],
      ),
      nav(
        classes: 'space-y-0.5',
        items.map((item) => _buildNavItem(
              context,
              colorScheme,
              item.label,
              item.path,
              item.icon,
              isActive: item.isActive,
            )).toList(),
      ),
    ]);
  }

  Component _buildNavItem(
    BuildContext context,
    ColorScheme colorScheme,
    String label,
    String path,
    AppIcons icon, {
    bool isActive = false,
  }) {
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

class _NavItemData {
  final String label;
  final String path;
  final AppIcons icon;
  final bool isActive;

  const _NavItemData(this.label, this.path, this.icon, {this.isActive = false});
}
