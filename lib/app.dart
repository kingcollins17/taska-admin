import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/sidebar.dart';
import 'components/top_bar.dart';
import 'core/providers/ui_state_provider.dart';
import 'core/services/local_storage.dart';
import 'pages/about.dart';
import 'pages/home.dart';
import 'pages/login.dart';
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

    return div(
      classes: appClasses,
      styles: Styles(backgroundColor: Color(colorScheme.background)),
      [
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
            ShellRoute(
              builder: (context, state, child) {
                var activePath = state.location;
                var title = 'Overview';
                if (activePath == '/about') {
                  title = 'About Taska';
                } else if (activePath == '/users' || activePath == '/customers') {
                  title = 'User Management';
                }

                return div(
                  classes:
                      'w-full min-h-screen flex flex-col md:flex-row transition-colors duration-200',
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
            routes: [
              Route(
                path: '/',
                title: 'Taska Admin - Overview',
                builder: (context, state) => const Home(),
              ),
              Route(
                path: '/users',
                title: 'Taska Admin - User Management',
                builder: (context, state) => const UsersPage(),
              ),
              Route(
                path: '/customers',
                title: 'Taska Admin - User Management',
                builder: (context, state) => const UsersPage(),
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
        buildSidePanelOverlay(context, uiState.sidePanel!),
      if (uiState.flushbar != null)
        buildFlushbar(context, uiState.flushbar!),
    ]);
  }

  Component buildSidePanelOverlay(BuildContext context, Component content) {
    return div(
      classes:
          'fixed inset-0 z-50 flex justify-end bg-black/40 backdrop-blur-sm transition-opacity animate-fade-in',
      events: {
        'click': (event) {
          context.hideSidePanel();
        },
      },
      [
        div(
          classes:
              'h-full w-full max-w-md ml-auto bg-white dark:bg-[#121816] shadow-2xl p-6 overflow-y-auto border-l border-slate-200 dark:border-slate-800 animate-slide-left',
          events: {
            'click': (event) {
              event.stopPropagation();
            },
          },
          [
            div(
              classes:
                  'flex items-center justify-between pb-4 border-b border-slate-100 dark:border-slate-800 mb-4',
              [
                h3(classes: 'text-lg font-bold text-slate-900 dark:text-white', [
                  Component.text('Panel'),
                ]),
                button(
                  type: ButtonType.button,
                  classes:
                      'p-1 rounded-lg text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 transition-colors cursor-pointer border-none bg-transparent',
                  events: {
                    'click': (e) {
                      context.hideSidePanel();
                    },
                  },
                  [Component.text('✕')],
                ),
              ],
            ),
            content,
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
        typeClasses =
            'bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900 shadow-slate-900/20';
        iconSymbol = 'ℹ';
        break;
    }

    return div(
      classes:
          'fixed top-5 right-5 z-50 flex items-center gap-3 px-4 py-3 rounded-xl shadow-xl transition-all duration-300 transform translate-y-0 $typeClasses',
      [
        span(
          classes:
              'flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-white/20 text-xs font-bold',
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
