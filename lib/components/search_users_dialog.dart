import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/users/admin_platform_user_item.dart';
import '../core/providers/admin_user_providers.dart';
import '../core/providers/ui_state_provider.dart';

/// A modal dialog for searching and selecting platform users by email, name (`name:<name>`), or ID (`id:<userid>`).
class SearchUsersDialog extends StatefulComponent {
  final Completer<AdminPlatformUserItem?>? _completer;
  final String? initialSearch;

  const SearchUsersDialog({
    super.key,
    Completer<AdminPlatformUserItem?>? completer,
    this.initialSearch,
  }) : _completer = completer;

  /// Shows the user search dialog and returns a [Future<AdminPlatformUserItem?>]
  /// which completes with the selected user, or `null` if cancelled.
  static Future<AdminPlatformUserItem?> search(
    BuildContext context, {
    String title = 'Search Users',
    String? initialSearch,
  }) {
    final completer = Completer<AdminPlatformUserItem?>();
    context.showDialog(
      SearchUsersDialog(
        completer: completer,
        initialSearch: initialSearch,
      ),
      title: title,
    );
    return completer.future;
  }

  /// Alias for [search] for API consistency with other dialogs.
  static Future<AdminPlatformUserItem?> show(
    BuildContext context, {
    String title = 'Search Users',
    String? initialSearch,
  }) =>
      search(context, title: title, initialSearch: initialSearch);

  @override
  State<SearchUsersDialog> createState() => _SearchUsersDialogState();
}

class _SearchUsersDialogState extends State<SearchUsersDialog> {
  String _searchQuery = '';
  String _searchInputValue = '';
  Timer? _searchDebounceTimer;
  int _currentPage = 1;
  String _selectedRole = 'ALL';

  @override
  void initState() {
    super.initState();
    if (component.initialSearch != null) {
      _searchQuery = component.initialSearch!;
      _searchInputValue = component.initialSearch!;
    }
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchInput(dynamic value) {
    _searchInputValue = value.toString();
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _searchQuery = _searchInputValue;
        _currentPage = 1;
      });
    });
  }

  void _clearSearch() {
    _searchDebounceTimer?.cancel();
    setState(() {
      _searchInputValue = '';
      _searchQuery = '';
      _currentPage = 1;
    });
  }

  void _selectUser(BuildContext context, AdminPlatformUserItem user) {
    if (component._completer != null && !component._completer!.isCompleted) {
      component._completer!.complete(user);
    }
    context.hideDialog();
  }

  void _onCancel(BuildContext context) {
    if (component._completer != null && !component._completer!.isCompleted) {
      component._completer!.complete(null);
    }
    context.hideDialog();
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    final usersAsync = context.watch(
      adminUsersProvider(
        GetUsersParams(
          search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
          page: _currentPage,
        ),
      ),
    );

    return div(classes: 'space-y-4 animate-fade-in-scaled', [
      // Description & Tips
      div(classes: 'space-y-1', [
        p(
          classes: 'text-xs font-medium leading-relaxed',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [
            Component.text(
              'Search for platform users. Tip: Use email directly, ',
            ),
            code(
              classes: 'px-1.5 py-0.5 rounded text-[11px] font-mono font-bold bg-emerald-500/10 text-emerald-500',
              [Component.text('name:<user name>')],
            ),
            Component.text(' or '),
            code(
              classes: 'px-1.5 py-0.5 rounded text-[11px] font-mono font-bold bg-emerald-500/10 text-emerald-500',
              [Component.text('id:<user id>')],
            ),
            Component.text('.'),
          ],
        ),
      ]),

      // Search Bar & Filter Row
      div(classes: 'space-y-2.5', [
        div(classes: 'relative w-full flex items-center', [
          div(
            classes: 'absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none',
            styles: Styles(color: Color(colorScheme.placeholder)),
            [const AppIcon(AppIcons.search)],
          ),
          input(
            type: InputType.text,
            value: _searchInputValue,
            classes:
                'w-full border rounded-xl pl-10 pr-9 py-2.5 text-xs font-medium focus:outline-none focus:ring-2 transition-all shadow-xs',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textPrimary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            attributes: {
              'placeholder': 'Search by email, name:John, or id:usr_123...',
            },
            onInput: _onSearchInput,
          ),
          if (_searchInputValue.isNotEmpty)
            button(
              type: ButtonType.button,
              onClick: _clearSearch,
              classes:
                  'absolute right-3 p-1 rounded-full text-xs cursor-pointer border-none bg-transparent hover:opacity-80 transition-opacity',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text('✕')],
            ),
        ]),

        // Quick Role Filter Buttons
        div(classes: 'flex items-center space-x-2', [
          for (final role in ['ALL', 'CUSTOMER', 'PROVIDER'])
            button(
              type: ButtonType.button,
              onClick: () {
                setState(() {
                  _selectedRole = role;
                });
              },
              classes:
                  'px-3 py-1 rounded-lg text-[11px] font-bold transition-all cursor-pointer border shadow-2xs ${_selectedRole == role ? 'bg-emerald-600 text-white border-emerald-600' : 'hover:opacity-90'}',
              styles: _selectedRole == role
                  ? null
                  : Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      color: Color(colorScheme.textSecondary),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
              [Component.text(role == 'ALL' ? 'All Roles' : role)],
            ),
        ]),
      ]),

      // Users List View
      usersAsync.when(
        data: (paginatedData) {
          final rawItems = paginatedData?.items ?? [];
          final items = rawItems.where((userItem) {
            if (_selectedRole == 'ALL') return true;
            return userItem.type?.toUpperCase() == _selectedRole;
          }).toList();

          final total = paginatedData?.total ?? items.length;
          final perPage = paginatedData?.perPage ?? 20;
          final totalPages = (total / perPage).ceil();

          if (items.isEmpty) {
            return div(
              classes: 'py-12 text-center space-y-2 border rounded-xl p-6 shadow-2xs',
              styles: Styles(
                backgroundColor: Color(colorScheme.surface),
                raw: {'border-color': colorScheme.border},
              ),
              [
                div(
                  classes: 'w-10 h-10 rounded-full mx-auto flex items-center justify-center bg-slate-500/10 text-slate-400 mb-2',
                  [const AppIcon(AppIcons.customer)],
                ),
                p(
                  classes: 'text-xs font-semibold',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [
                    Component.text(_searchQuery.isEmpty ? 'No platform users found' : 'No users matching "$_searchQuery"'),
                  ],
                ),
                p(
                  classes: 'text-[11px]',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  [
                    Component.text('Try searching with a different name, email, or user ID prefix.'),
                  ],
                ),
              ],
            );
          }

          return div(classes: 'space-y-3', [
            div(
              classes: 'space-y-2 max-h-80 overflow-y-auto pr-1',
              [
                for (final user in items)
                  div(
                    classes:
                        'p-3 border rounded-xl flex items-center justify-between hover:border-emerald-500/50 transition-all cursor-pointer shadow-2xs group',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.surface),
                      raw: {'border-color': colorScheme.border},
                    ),
                    events: {
                      'click': (_) => _selectUser(context, user),
                    },
                    [
                      div(classes: 'flex items-center space-x-3 overflow-hidden min-w-0 flex-1 pr-2', [
                        img(
                          src:
                              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.fullname ?? user.email ?? 'User')}&background=00A870&color=fff',
                          classes: 'w-9 h-9 rounded-full object-cover border shrink-0',
                          styles: Styles(raw: {'border-color': colorScheme.border}),
                          alt: user.fullname ?? 'User',
                        ),
                        div(classes: 'min-w-0 flex-1', [
                          div(classes: 'flex items-center space-x-2', [
                            span(
                              classes: 'font-bold text-xs truncate',
                              styles: Styles(color: Color(colorScheme.textHeading)),
                              [Component.text(user.fullname ?? 'Unnamed User')],
                            ),
                            if (user.isActive != null)
                              span(
                                classes:
                                    'inline-block w-2 h-2 rounded-full ${user.isActive == true ? 'bg-emerald-500' : 'bg-slate-400'}',
                                attributes: {'title': user.isActive == true ? 'Active Account' : 'Inactive Account'},
                                [],
                              ),
                          ]),
                          div(classes: 'flex items-center space-x-2 text-[11px] truncate mt-0.5', [
                            span(
                              styles: Styles(color: Color(colorScheme.textMuted)),
                              [Component.text(user.email ?? user.phoneNumber ?? 'No email')],
                            ),
                            if (user.id != null) ...[
                              span(styles: Styles(color: Color(colorScheme.placeholder)), [Component.text('•')]),
                              span(
                                classes: 'font-mono text-[10px] opacity-75 truncate',
                                styles: Styles(color: Color(colorScheme.textMuted)),
                                [Component.text('ID: ${user.id}')],
                              ),
                            ],
                          ]),
                        ]),
                      ]),

                      div(classes: 'flex items-center space-x-2 shrink-0', [
                        if (user.type != null)
                          span(
                            classes:
                                'text-[10px] font-extrabold px-2 py-0.5 rounded-md border uppercase tracking-wider',
                            styles: Styles(
                              backgroundColor: Color(colorScheme.inputBg),
                              color: user.type == 'PROVIDER'
                                  ? const Color('#059669')
                                  : Color(colorScheme.primary),
                              raw: {'border-color': colorScheme.borderInput},
                            ),
                            [Component.text(user.type!)],
                          ),
                        button(
                          type: ButtonType.button,
                          onClick: () => _selectUser(context, user),
                          classes:
                              'text-white text-xs font-bold px-3 py-1.5 rounded-lg shadow-xs cursor-pointer border-none transition-transform group-hover:scale-105 active:scale-95',
                          styles: Styles(backgroundColor: Color(colorScheme.primary)),
                          [Component.text('Select')],
                        ),
                      ]),
                    ],
                  ),
              ],
            ),

            // Pagination Controls (if multiple pages)
            if (totalPages > 1)
              div(
                classes: 'flex items-center justify-between pt-2 border-t text-xs font-medium',
                styles: Styles(raw: {'border-color': colorScheme.borderInput}),
                [
                  span(
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text('Page $_currentPage of $totalPages ($total users)')],
                  ),
                  div(classes: 'flex items-center space-x-2', [
                    button(
                      type: ButtonType.button,
                      onClick: _currentPage > 1
                          ? () => setState(() => _currentPage--)
                          : null,
                      disabled: _currentPage <= 1,
                      classes:
                          'px-2.5 py-1 rounded-lg border text-xs font-bold transition-all cursor-pointer ${_currentPage <= 1 ? 'opacity-40 cursor-not-allowed' : 'hover:opacity-80'}',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        color: Color(colorScheme.textSecondary),
                        raw: {'border-color': colorScheme.borderInput},
                      ),
                      [Component.text('Previous')],
                    ),
                    button(
                      type: ButtonType.button,
                      onClick: _currentPage < totalPages
                          ? () => setState(() => _currentPage++)
                          : null,
                      disabled: _currentPage >= totalPages,
                      classes:
                          'px-2.5 py-1 rounded-lg border text-xs font-bold transition-all cursor-pointer ${_currentPage >= totalPages ? 'opacity-40 cursor-not-allowed' : 'hover:opacity-80'}',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        color: Color(colorScheme.textSecondary),
                        raw: {'border-color': colorScheme.borderInput},
                      ),
                      [Component.text('Next')],
                    ),
                  ]),
                ],
              ),
          ]);
        },
        loading: () => div(classes: 'space-y-2 animate-pulse py-2', [
          for (var i = 0; i < 4; i++)
            div(
              classes: 'h-14 rounded-xl border',
              styles: Styles(
                backgroundColor: colorScheme.isDark ? Color.rgba(31, 45, 39, 0.8) : Color.rgba(226, 232, 240, 0.8),
                raw: {'border-color': colorScheme.border},
              ),
              [],
            ),
        ]),
        error: (err, _) => div(
          classes: 'p-4 rounded-xl border border-rose-500/30 bg-rose-500/10 text-xs text-rose-500 font-semibold text-center',
          [Component.text('Error searching users: $err')],
        ),
      ),

      // Dialog Actions Footer
      div(
        classes: 'flex items-center justify-end space-x-3 pt-3 border-t',
        styles: Styles(raw: {'border-color': colorScheme.borderInput}),
        [
          button(
            type: ButtonType.button,
            onClick: () => _onCancel(context),
            classes:
                'px-4 py-2.5 rounded-xl border text-xs font-bold transition-all cursor-pointer hover:opacity-80 active:scale-95',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [Component.text('Cancel')],
          ),
        ],
      ),
    ]);
  }
}
