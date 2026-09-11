import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/sidebar.dart';
import 'components/top_bar.dart';
import 'core/providers/theme_scope.dart';
import 'pages/about.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/users.dart';

@client
class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Component build(BuildContext context) {
    var appClasses = 'w-full min-h-screen bg-[#F3F5F8] dark:bg-slate-950 text-slate-900 dark:text-slate-100 font-sans antialiased selection:bg-blue-500 selection:text-white transition-colors duration-200';
    if (isDarkMode) {
      appClasses += ' dark';
    }

    return ThemeScope(
      isDarkMode: isDarkMode,
      toggleTheme: toggleTheme,
      child: div(classes: appClasses, [
        Router(routes: [
          Route(path: '/login', title: 'Taska Admin - Authentication', builder: (context, state) => const LoginPage()),
          ShellRoute(
            builder: (context, state, child) {
              var activePath = state.location;
              var title = 'Sales Overview';
              if (activePath == '/about') {
                title = 'About ProSale';
              } else if (activePath == '/users' || activePath == '/customers') {
                title = 'User Management';
              }

              return div(classes: 'w-full min-h-screen flex flex-col md:flex-row bg-[#F3F5F8] dark:bg-slate-950 transition-colors duration-200', [
                Sidebar(activePath: activePath),
                section(classes: 'flex-1 bg-[#F3F5F8] dark:bg-slate-950 p-4 sm:p-6 lg:p-8 max-w-7xl mx-auto w-full overflow-x-hidden transition-colors duration-200', [
                  TopBar(title: title),
                  child,
                ]),
              ]);
            },
            routes: [
              Route(path: '/', title: 'ProSale - Sales Overview', builder: (context, state) => const Home()),
              Route(path: '/users', title: 'ProSale - User Management', builder: (context, state) => const UsersPage()),
              Route(path: '/customers', title: 'ProSale - User Management', builder: (context, state) => const UsersPage()),
              Route(path: '/about', title: 'About ProSale', builder: (context, state) => const About()),
            ],
          ),
        ]),
      ]),
    );
  }
}
