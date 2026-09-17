import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/auth/admin_user.dart';
import '../core/providers/admin_providers.dart';
import '../core/providers/ui_state_provider.dart';

class TopBar extends StatelessComponent {
  final String title;
  const TopBar({super.key, this.title = 'Sales Overview'});

  @override
  Component build(BuildContext context) {
    final uiState = context.watch(uiStateProvider);
    final colorScheme = uiState.colorScheme;
    final isDarkMode = uiState.isDarkMode;
    final adminUserAsync = context.watch(adminUserProvider);

    return header(
      classes: 'w-full flex flex-col md:flex-row md:items-center justify-between gap-4 mb-7',
      [
        // Left: Page Title
        h1(
          classes: 'text-2xl font-extrabold tracking-tight',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [
            Component.text(title),
          ],
        ),

        // Right: Controls (Search + Theme Toggle + Calendar + Notification + Profile)
        div(classes: 'flex items-center space-x-3.5', [
          // Search Input Pill
          

          // Light/Dark Theme Toggle Button
          button(
            type: ButtonType.button,
            onClick: () {
              context.toggleTheme();
            },
            classes:
                'w-9 h-9 rounded-full border flex items-center justify-center transition-all shadow-sm cursor-pointer active:scale-95',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              color: Color(isDarkMode ? colorScheme.mint : colorScheme.textSecondary),
              raw: {'border-color': colorScheme.border},
            ),
            attributes: {'title': isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'},
            [
              AppIcon(isDarkMode ? AppIcons.sun : AppIcons.moon),
            ],
          ),

          // Calendar Icon Button
          button(
            type: ButtonType.button,
            classes:
                'w-9 h-9 rounded-full border flex items-center justify-center transition-colors shadow-sm cursor-pointer',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              color: Color(colorScheme.textMuted),
              raw: {'border-color': colorScheme.border},
            ),
            [
              const AppIcon(AppIcons.calendar),
            ],
          ),

          // Notification Bell Icon Button with Red Badge
          button(
            type: ButtonType.button,
            classes:
                'w-9 h-9 rounded-full border flex items-center justify-center transition-colors shadow-sm relative cursor-pointer',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              color: Color(colorScheme.textMuted),
              raw: {'border-color': colorScheme.border},
            ),
            [
              const AppIcon(AppIcons.bell),
              span(
                classes:
                    'absolute -top-0.5 -right-0.5 w-4 h-4 text-white text-[10px] font-bold rounded-full flex items-center justify-center border-2',
                styles: Styles(
                  backgroundColor: Color(colorScheme.primary),
                  raw: {'border-color': colorScheme.surface},
                ),
                [
                  Component.text('1'),
                ],
              ),
            ],
          ),

          // User Profile Card / Shimmer Loading
          _buildUserProfile(context, colorScheme, adminUserAsync),
        ]),
      ],
    );
  }

  Component _buildUserProfile(
      BuildContext context, ColorScheme colorScheme, AsyncValue<AdminUser> adminUserAsync) {
    return adminUserAsync.when(
      data: (user) {
        final fullname = user.fullname?.isNotEmpty == true ? user.fullname! : 'Admin User';
        final email = user.email?.isNotEmpty == true ? user.email! : 'admin@taska.com';

        final initials = fullname.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

        return div(classes: 'flex items-center space-x-3 pl-1 cursor-pointer group', [
          div(
            classes:
                'w-9 h-9 rounded-full flex items-center justify-center text-xs font-bold text-white shadow-sm group-hover:scale-105 transition-transform',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [
              Component.text(initials.isNotEmpty ? initials : 'AU'),
            ],
          ),
          div(classes: 'hidden sm:block text-left', [
            div(
              classes: 'text-xs font-bold leading-snug',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text(fullname)],
            ),
            div(
              classes: 'text-[11px] font-normal leading-tight',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text(email)],
            ),
          ]),
          const AppIcon(AppIcons.chevronDown),
        ]);
      },
      loading: () {
        // Shimmer loading effect
        return div(classes: 'flex items-center space-x-3 pl-1 animate-pulse', [
          div(
            classes: 'w-9 h-9 rounded-full border shadow-sm',
            styles: Styles(
              backgroundColor: Color(colorScheme.border),
              raw: {'border-color': colorScheme.border},
            ),
            [],
          ),
          div(classes: 'hidden sm:block text-left space-y-1.5', [
            div(
              classes: 'h-3 w-24 rounded',
              styles: Styles(backgroundColor: Color(colorScheme.border)),
              [],
            ),
            div(
              classes: 'h-2.5 w-32 rounded',
              styles: Styles(backgroundColor: Color(colorScheme.border)),
              [],
            ),
          ]),
        ]);
      },
      error: (err, stack) {
        return div(classes: 'flex items-center space-x-3 pl-1 cursor-pointer group', [
          div(
            classes:
                'w-9 h-9 rounded-full flex items-center justify-center text-xs font-bold text-white shadow-sm',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [
              Component.text('AD'),
            ],
          ),
          div(classes: 'hidden sm:block text-left', [
            div(
              classes: 'text-xs font-bold leading-snug',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text('Admin')],
            ),
          ]),
        ]);
      },
    );
  }
}
