import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/providers/theme_scope.dart';

class TopBar extends StatelessComponent {
  final String title;
  const TopBar({super.key, this.title = 'Sales Overview'});

  @override
  Component build(BuildContext context) {
    final themeScope = ThemeScope.of(context);
    final isDarkMode = themeScope?.isDarkMode ?? false;

    return header(classes: 'w-full flex flex-col md:flex-row md:items-center justify-between gap-4 mb-7', [
      // Left: Page Title
      h1(classes: 'text-2xl font-extrabold text-slate-900 dark:text-white tracking-tight', [
        Component.text(title),
      ]),

      // Right: Controls (Search + Theme Toggle + Calendar + Notification + Profile)
      div(classes: 'flex items-center space-x-3.5', [
        // Search Input Pill
        div(classes: 'relative w-60 md:w-72', [
          div(classes: 'absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400 dark:text-slate-500', [
            const AppIcon(AppIcons.search),
          ]),
          input(
            type: InputType.text,
            classes: 'w-full bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 rounded-full pl-10 pr-4 py-2 text-xs font-medium text-slate-700 dark:text-slate-200 placeholder-slate-400 dark:placeholder-slate-500 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all',
            attributes: {'placeholder': 'Search....'},
          ),
        ]),

        // Light/Dark Theme Toggle Button
        button(
          onClick: () {
            themeScope?.toggleTheme();
          },
          classes: 'w-9 h-9 rounded-full bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 flex items-center justify-center text-slate-600 dark:text-amber-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-all shadow-sm cursor-pointer active:scale-95',
          attributes: {'title': isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'},
          [
            AppIcon(isDarkMode ? AppIcons.sun : AppIcons.moon),
          ],
        ),

        // Calendar Icon Button
        button(
          classes: 'w-9 h-9 rounded-full bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 flex items-center justify-center text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors shadow-sm cursor-pointer',
          [
            const AppIcon(AppIcons.calendar),
          ],
        ),

        // Notification Bell Icon Button with Red Badge
        button(
          classes: 'w-9 h-9 rounded-full bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 flex items-center justify-center text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors shadow-sm relative cursor-pointer',
          [
            const AppIcon(AppIcons.bell),
            span(classes: 'absolute -top-0.5 -right-0.5 w-4 h-4 bg-rose-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center border-2 border-white dark:border-slate-900', [
              Component.text('1'),
            ]),
          ],
        ),

        // User Profile Card
        div(classes: 'flex items-center space-x-3 pl-1 cursor-pointer group', [
          img(
            src: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
            classes: 'w-9 h-9 rounded-full object-cover border border-slate-200 dark:border-slate-700 shadow-sm group-hover:scale-105 transition-transform',
            alt: 'Avatar',
          ),
          div(classes: 'hidden sm:block text-left', [
            div(classes: 'text-xs font-bold text-slate-900 dark:text-white leading-snug', [Component.text('James Herwitz')]),
            div(classes: 'text-[11px] font-normal text-slate-400 dark:text-slate-500 leading-tight', [Component.text('jamesh@gmail.com')]),
          ]),
          const AppIcon(AppIcons.chevronDown),
        ]),
      ]),
    ]);
  }
}
