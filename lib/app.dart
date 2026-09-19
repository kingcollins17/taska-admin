import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/sidebar.dart';
import 'components/top_bar.dart';
import 'core/designs/app_icons.dart';
import 'core/designs/components/app_icon.dart';
import 'core/providers/ui_state_provider.dart';
import 'core/services/local_storage.dart';
import 'pages/about.dart';
import 'pages/administrators.dart';
import 'pages/audit_logs.dart';
import 'pages/guarantors.dart';
import 'pages/home.dart';
import 'pages/interviews.dart';
import 'pages/kyc.dart';
import 'pages/login.dart';
import 'pages/support.dart';
import 'pages/support_ticket_workspace_manager.dart';
import 'pages/tasks.dart';
import 'pages/users.dart';

@client
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    final uiState = context.watch(uiStateProvider);
    final colorScheme = uiState.colorScheme;
    final isDarkMode = uiState.isDarkMode;

    var appClasses =
        'relative w-full min-h-screen font-sans antialiased selection:bg-[#00A870] selection:text-white transition-colors duration-200';
    if (isDarkMode) {
      appClasses += ' dark';
    }

    return div(classes: appClasses, styles: Styles(backgroundColor: Color(colorScheme.background)), [
      Router(
        redirect: (context, state) {
          final token = localStorage.getItem('accessToken');
          final isAuthenticated = token != null && token.isNotEmpty;
          final isLoggingIn = state.location == '/login';

          if (!isAuthenticated && !isLoggingIn) {
            return '/login';
          }
          if (isAuthenticated && isLoggingIn) {
            return '/';
          }
          return null;
        },
        routes: [
          Route(
            path: '/login',
            title: 'Taska Admin - Authentication',
            builder: (context, state) => const LoginPage(),
          ),
          Route(
            path: '/support/workspace',
            title: 'Taska Admin - Support Workspace',
            builder: (context, state) => const SupportTicketWorkspaceManagerPage(),
          ),
          Route(
            path: '/support-workspace',
            title: 'Taska Admin - Support Workspace',
            builder: (context, state) => const SupportTicketWorkspaceManagerPage(),
          ),
          ShellRoute(
            builder: (context, state, child) {
              var activePath = state.location;
              var title = 'Dashboard';
              if (activePath == '/about') {
                title = 'About Taska';
              } else if (activePath == '/users' || activePath == '/customers') {
                title = 'Users Management';
              } else if (activePath == '/kyc') {
                title = 'KYC Verification';
              } else if (activePath == '/guarantors') {
                title = 'Guarantors Management';
              } else if (activePath == '/interviews') {
                title = 'Provider Interviews';
              } else if (activePath == '/tasks') {
                title = 'Tasks Management';
              } else if (activePath == '/disputes') {
                title = 'Disputes & Claims';
              } else if (activePath == '/support' || activePath == '/help') {
                title = 'Support & Help Desk';
              } else if (activePath == '/payments' || activePath == '/transactions') {
                title = 'Payments & Finance';
              } else if (activePath == '/administrators') {
                title = 'Administrators & Roles';
              } else if (activePath == '/audit-logs') {
                title = 'Audit Logs';
              } else if (activePath == '/settings') {
                title = 'System Settings';
              }

              return div(
                classes: 'w-full min-h-screen flex flex-col md:flex-row transition-colors duration-200',
                styles: Styles(backgroundColor: Color(colorScheme.background)),
                [
                  Sidebar(activePath: activePath),
                  section(
                    classes:
                        'flex-1 p-4 sm:p-6 lg:p-8 max-w-7xl mx-auto w-full overflow-x-hidden transition-colors duration-200',
                    styles: Styles(backgroundColor: Color(colorScheme.background)),
                    [
                      TopBar(title: title),
                      child,
                    ],
                  ),
                ],
              );
            },
            // ShellRoute children
            routes: [
              Route(
                path: '/',
                title: 'Taska Admin - Dashboard',
                builder: (context, state) => const Home(),
              ),
              Route(
                path: '/users',
                title: 'Taska Admin - Users',
                builder: (context, state) => const UsersPage(),
              ),
              Route(
                path: '/customers',
                title: 'Taska Admin - Users',
                builder: (context, state) => const UsersPage(),
              ),
              Route(
                path: '/kyc',
                title: 'Taska Admin - KYC Verification',
                builder: (context, state) => const KycPage(),
              ),
              Route(
                path: '/guarantors',
                title: 'Taska Admin - Guarantors',
                builder: (context, state) => const GuarantorsPage(),
              ),
              Route(
                path: '/interviews',
                title: 'Taska Admin - Interviews',
                builder: (context, state) => const InterviewsPage(),
              ),
              Route(
                path: '/tasks',
                title: 'Taska Admin - Tasks',
                builder: (context, state) => const TasksPage(),
              ),
              Route(
                path: '/disputes',
                title: 'Taska Admin - Disputes',
                builder: (context, state) => const _PlaceholderPage(
                  title: 'Disputes & Resolution',
                  description: 'Track open customer disputes, arbitration tickets, and resolution history.',
                ),
              ),
              Route(
                path: '/support',
                title: 'Taska Admin - Support',
                builder: (context, state) => const SupportPage(),
              ),
              Route(
                path: '/payments',
                title: 'Taska Admin - Payments',
                builder: (context, state) => const _PlaceholderPage(
                  title: 'Payments & Transactions',
                  description: 'View payout history, transaction ledgers, escrow holds, and gateway logs.',
                ),
              ),
              Route(
                path: '/administrators',
                title: 'Taska Admin - Administrators',
                builder: (context, state) => const AdministratorsPage(),
              ),
              Route(
                path: '/audit-logs',
                title: 'Taska Admin - Audit Logs',
                builder: (context, state) => const AuditLogsPage(),
              ),
              Route(
                path: '/settings',
                title: 'Taska Admin - Settings',
                builder: (context, state) => const _PlaceholderPage(
                  title: 'System Settings',
                  description: 'Configure application parameters, notification services, integrations, and branding.',
                ),
              ),
              Route(
                path: '/about',
                title: 'About Taska',
                builder: (context, state) => const About(),
              ),
            ],
          ),
        ],
      ),
      if (uiState.isSidePanelOpen && uiState.sidePanel != null)
        buildSidePanelOverlay(context, uiState.sidePanel!, uiState.sidePanelTitle),
      if (uiState.isDialogOpen && uiState.dialog != null)
        buildDialogOverlay(context, uiState.dialog!, uiState.dialogTitle),
      if (uiState.flushbar != null) buildFlushbar(context, uiState.flushbar!),
    ]);
  }

  Component buildDialogOverlay(BuildContext context, Component content, String? title) {
    final colorScheme = context.colorScheme;

    return div(
      classes:
          'fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-md animate-backdrop-in',
      events: {
        'click': (event) {
          context.hideDialog();
        },
      },
      [
        div(
          classes:
              'w-full max-w-lg rounded-2xl shadow-2xl border flex flex-col relative transition-colors duration-200 overflow-hidden animate-fade-in-scaled',
          styles: Styles(
            backgroundColor: Color(colorScheme.background),
            raw: {'border-color': colorScheme.border},
          ),
          events: {
            'click': (event) {
              event.stopPropagation();
            },
          },
          [
            if (title != null && title.isNotEmpty)
              div(
                classes:
                    'sticky top-0 z-20 px-6 py-4 border-b flex items-center justify-between shrink-0 transition-colors duration-200',
                styles: Styles(
                  backgroundColor: Color(colorScheme.surface),
                  raw: {'border-color': colorScheme.border},
                ),
                [
                  h3(
                    classes: 'text-base font-extrabold leading-tight',
                    styles: Styles(color: Color(colorScheme.textHeading)),
                    [
                      Component.text(title),
                    ],
                  ),
                  button(
                    type: ButtonType.button,
                    classes:
                        'w-8 h-8 rounded-full flex items-center justify-center transition-all cursor-pointer border-none bg-transparent hover:bg-slate-100 dark:hover:bg-slate-800',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    events: {
                      'click': (e) {
                        context.hideDialog();
                      },
                    },
                    [
                      span(classes: 'text-sm font-bold', [Component.text('✕')]),
                    ],
                  ),
                ],
              ),
            div(classes: 'p-6 space-y-6 flex-1 overflow-y-auto max-h-[85vh]', [
              content,
            ]),
          ],
        ),
      ],
    );
  }

  Component buildSidePanelOverlay(BuildContext context, Component content, String? title) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;

    return div(
      classes: 'fixed inset-0 z-50 flex justify-end bg-black/30 backdrop-blur-sm animate-backdrop-in',
      events: {
        'click': (event) {
          context.hideSidePanel();
        },
      },
      [
        div(
          classes:
              'h-full w-full max-w-md sm:max-w-lg ml-auto shadow-2xl border-l animate-side-panel-in flex flex-col relative transition-colors duration-200',
          styles: Styles(
            backgroundColor: Color(colorScheme.background),
            raw: {'border-color': colorScheme.border},
          ),
          events: {
            'click': (event) {
              event.stopPropagation();
            },
          },
          [
            div(
              classes:
                  'sticky top-0 z-20 px-6 py-4 border-b flex items-center justify-between shrink-0 transition-colors duration-200',
              styles: Styles(
                backgroundColor: Color(colorScheme.surface),
                raw: {'border-color': colorScheme.border},
              ),
              [
                div(classes: 'flex items-center space-x-3', [
                  div(
                    classes: 'w-9 h-9 rounded-xl flex items-center justify-center border shadow-sm shrink-0',
                    styles: Styles(
                      backgroundColor: isDark ? Color.rgba(16, 185, 129, 0.15) : Color.rgba(16, 185, 129, 0.1),
                      color: Color(colorScheme.primary),
                      raw: {'border-color': isDark ? 'rgba(16, 185, 129, 0.3)' : 'rgba(16, 185, 129, 0.2)'},
                    ),
                    [
                      const AppIcon(AppIcons.customer),
                    ],
                  ),
                  div([
                    h3(
                      classes: 'text-base font-extrabold leading-tight',
                      styles: Styles(color: Color(colorScheme.textHeading)),
                      [
                        Component.text(title ?? 'User Details'),
                      ],
                    ),
                    span(
                      classes: 'text-[11px] font-medium block',
                      styles: Styles(color: Color(colorScheme.textMuted)),
                      [
                        Component.text('Platform Management'),
                      ],
                    ),
                  ]),
                ]),
                button(
                  type: ButtonType.button,
                  classes:
                      'w-8 h-8 rounded-full flex items-center justify-center transition-all cursor-pointer border-none bg-transparent hover:bg-slate-100 dark:hover:bg-slate-800',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  events: {
                    'click': (e) {
                      context.hideSidePanel();
                    },
                  },
                  [
                    span(classes: 'text-sm font-bold', [Component.text('✕')]),
                  ],
                ),
              ],
            ),
            div(classes: 'p-6 space-y-6 flex-1 overflow-y-auto animate-panel-content-in', [
              content,
            ]),
          ],
        ),
      ],
    );
  }

  Component buildFlushbar(BuildContext context, FlushbarConfig config) {
    String typeClasses;
    String iconSymbol;

    switch (config.type) {
      case FlushbarType.success:
        typeClasses = 'bg-emerald-600 text-white shadow-emerald-500/20';
        iconSymbol = '✓';
        break;
      case FlushbarType.error:
        typeClasses = 'bg-rose-600 text-white shadow-rose-500/20';
        iconSymbol = '✕';
        break;
      case FlushbarType.warning:
        typeClasses = 'bg-amber-500 text-white shadow-amber-500/20';
        iconSymbol = '⚠';
        break;
      case FlushbarType.info:
        typeClasses = 'bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900 shadow-slate-900/20';
        iconSymbol = 'ℹ';
        break;
    }

    return div(
      classes:
          'fixed top-5 right-5 z-50 flex items-center gap-3 px-4 py-3 rounded-xl shadow-xl transition-all duration-300 transform translate-y-0 $typeClasses',
      [
        span(
          classes: 'flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-white/20 text-xs font-bold',
          [
            Component.text(iconSymbol),
          ],
        ),
        div(classes: 'flex flex-col text-sm', [
          if (config.title != null && config.title!.isNotEmpty)
            span(classes: 'font-bold leading-tight', [Component.text(config.title!)]),
          span(classes: 'leading-tight opacity-90', [Component.text(config.message)]),
        ]),
        button(
          type: ButtonType.button,
          classes:
              'ml-2 p-1 text-xs opacity-70 hover:opacity-100 transition-opacity cursor-pointer border-none bg-transparent text-inherit',
          events: {
            'click': (e) {
              context.hideFlushbar();
            },
          },
          [Component.text('✕')],
        ),
      ],
    );
  }
}

class _PlaceholderPage extends StatelessComponent {
  final String title;
  final String description;

  const _PlaceholderPage({required this.title, required this.description});

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return div(
      classes: 'p-6 md:p-10 rounded-2xl border shadow-sm mt-6 transition-colors',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'flex flex-col items-center justify-center text-center py-12 space-y-4', [
          div(
            classes:
                'w-14 h-14 rounded-2xl flex items-center justify-center text-emerald-600 bg-emerald-50 dark:bg-emerald-950/40 border border-emerald-100 dark:border-emerald-800/40 shadow-sm mb-2',
            [
              const AppIcon(AppIcons.logo),
            ],
          ),
          h2(
            classes: 'text-2xl font-bold tracking-tight',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [
              Component.text(title),
            ],
          ),
          p(
            classes: 'text-sm max-w-md leading-relaxed',
            styles: Styles(color: Color(colorScheme.textSecondary)),
            [
              Component.text(description),
            ],
          ),
          div(
            classes: 'pt-2',
            [
              span(
                classes:
                    'inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 dark:bg-emerald-950/60 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800',
                [
                  Component.text('Module Active'),
                ],
              ),
            ],
          ),
        ]),
      ],
    );
  }
}
