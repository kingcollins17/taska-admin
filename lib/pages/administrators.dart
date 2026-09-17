import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/admin_detail_side_panel.dart';
import '../components/invite_admin_dialog.dart';
import '../components/invite_detail_side_panel.dart';
import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/providers/admin_management_providers.dart';
import '../core/providers/ui_state_provider.dart';

@client
class AdministratorsPage extends StatelessComponent {
  const AdministratorsPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex-1 space-y-6 relative', [
      const _Header(),
      const _TabbedContent(),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────

class _Header extends StatelessComponent {
  const _Header();

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-4', [
      div([
        p(
          classes: 'text-xs sm:text-sm mt-1 font-medium transition-colors',
          styles: Styles(color: Color(colorScheme.textSecondary)),
          [
            Component.text(
              'Manage administrator accounts, roles, invitations, and access permissions.',
            ),
          ],
        ),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Tabbed Content
// ─────────────────────────────────────────────────────────────

class _TabbedContent extends StatefulComponent {
  const _TabbedContent();

  @override
  State<_TabbedContent> createState() => _TabbedContentState();
}

class _TabbedContentState extends State<_TabbedContent> {
  int activeTab = 0; // 0 = Admins, 1 = Invitations

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return div(
      classes: 'border rounded-2xl shadow-sm transition-all overflow-hidden',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        // Tab Bar
        div(
          classes: 'flex items-center border-b px-1.5 pt-1.5',
          styles: Styles(raw: {'border-color': colorScheme.border}),
          [
            _TabButton(
              label: 'Administrators',
              icon: AppIcons.administrators,
              isActive: activeTab == 0,
              colorScheme: colorScheme,
              onTap: () => setState(() => activeTab = 0),
            ),
            _TabButton(
              label: 'Invitations',
              icon: AppIcons.externalLink,
              isActive: activeTab == 1,
              colorScheme: colorScheme,
              onTap: () => setState(() => activeTab = 1),
            ),
          ],
        ),

        // Tab Content
        div(
          key: Key(activeTab == 0 ? 'admins-tab' : 'invitations-tab'),
          classes: 'p-5 sm:p-6 animate-fade-in-scaled',
          [
            if (activeTab == 0)
              const _AdminsTable()
            else
              const _InvitationsTable(),
          ],
        ),
      ],
    );
  }
}

class _TabButton extends StatelessComponent {
  final String label;
  final AppIcons icon;
  final bool isActive;
  final ColorScheme colorScheme;
  final void Function() onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Component build(BuildContext context) {
    return button(
      onClick: onTap,
      classes: isActive
          ? 'flex items-center space-x-2 px-4 py-2.5 text-xs font-bold cursor-pointer border-b-2 transition-all bg-transparent border-l-0 border-r-0 border-t-0'
          : 'flex items-center space-x-2 px-4 py-2.5 text-xs font-medium cursor-pointer border-b-2 border-transparent transition-all bg-transparent border-l-0 border-r-0 border-t-0 hover:opacity-80',
      styles: Styles(
        color: isActive ? Color(colorScheme.primary) : Color(colorScheme.textMuted),
        raw: {
          if (isActive) 'border-bottom-color': colorScheme.primary,
        },
      ),
      [
        AppIcon(icon),
        span([Component.text(label)]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Admins Table Tab
// ─────────────────────────────────────────────────────────────

class _AdminsTable extends StatefulComponent {
  const _AdminsTable();

  @override
  State<_AdminsTable> createState() => _AdminsTableState();
}

class _AdminsTableState extends State<_AdminsTable> {
  String searchQuery = '';
  String _searchInputValue = '';
  Timer? _searchDebounceTimer;
  int currentPage = 1;

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchInput(dynamic value) {
    _searchInputValue = value.toString();
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        searchQuery = _searchInputValue;
        currentPage = 1;
      });
    });
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));
    final adminsAsync = context.watch(
      listAdminsProvider(
        ListAdminsParams(
          email: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
          page: currentPage,
          perPage: 20,
        ),
      ),
    );

    return div(classes: 'space-y-5', [
      // Toolbar
      div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4', [
        div(classes: 'flex items-center space-x-2', [
          h3(
            classes: 'text-base font-bold tracking-tight',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [Component.text('Admin Accounts')],
          ),
        ]),
        div(classes: 'flex flex-wrap items-center gap-3', [
          // Search
          div(classes: 'relative w-full sm:w-64', [
            div(
              classes: 'absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none',
              styles: Styles(color: Color(colorScheme.placeholder)),
              [const AppIcon(AppIcons.search)],
            ),
            input(
              type: InputType.text,
              value: _searchInputValue,
              classes:
                  'w-full border rounded-xl pl-9 pr-4 py-2 text-xs font-medium focus:outline-none focus:ring-2 transition-all',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.textPrimary),
                raw: {'border-color': colorScheme.borderInput},
              ),
              attributes: {'placeholder': 'Search admins by email...'},
              onInput: _onSearchInput,
            ),
          ]),
          // Invite Admin Dialog Button
          button(
            type: ButtonType.button,
            onClick: () => InviteAdminDialog.show(context),
            classes:
                'px-3.5 py-2 rounded-xl text-xs font-bold text-white cursor-pointer transition-all flex items-center space-x-1.5 border-none shadow-sm hover:opacity-90 active:scale-95',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [
              span(classes: 'text-sm leading-none', [Component.text('+')]),
              span([Component.text('Invite Admin')]),
            ],
          ),
        ]),
      ]),

      // Data
      adminsAsync.when(
        data: (paginatedData) {
          final items = paginatedData?.items ?? [];
          final total = paginatedData?.total ?? items.length;
          final perPage = paginatedData?.perPage ?? 20;

          if (items.isEmpty) {
            return _EmptyState(
              colorScheme: colorScheme,
              message: 'No administrators found',
              onReset: () {
                _searchDebounceTimer?.cancel();
                _searchInputValue = '';
                setState(() {
                  searchQuery = '';
                  currentPage = 1;
                });
              },
            );
          }

          return div(classes: 'space-y-5', [
            div(
              classes: 'overflow-x-auto rounded-xl border transition-colors',
              styles: Styles(raw: {'border-color': colorScheme.border}),
              [
                table(classes: 'w-full text-left border-collapse text-xs', [
                  thead(
                    classes: 'uppercase tracking-wider text-[10.5px] border-b font-bold',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      color: Color(colorScheme.textMuted),
                      raw: {'border-color': colorScheme.border},
                    ),
                    [
                      tr([
                        th(classes: 'p-3.5 pl-4', [Component.text('Admin')]),
                        th(classes: 'p-3.5', [Component.text('Role')]),
                        th(classes: 'p-3.5', [Component.text('Region')]),
                        th(classes: 'p-3.5 text-center', [Component.text('Status')]),
                        th(classes: 'p-3.5', [Component.text('Last Login')]),
                        th(classes: 'p-3.5', [Component.text('Created')]),
                        th(classes: 'p-3.5 pr-4 text-center', [Component.text('Actions')]),
                      ]),
                    ],
                  ),
                  tbody(
                    classes: 'divide-y font-medium',
                    styles: Styles(
                      color: Color(colorScheme.textPrimary),
                      raw: {'border-color': colorScheme.border},
                    ),
                    [
                      for (final admin in items)
                        tr(
                          [
                            // Admin name + email
                            td(classes: 'p-3.5 pl-4', [
                              div(classes: 'flex items-center space-x-3', [
                                div(
                                  classes:
                                      'w-8 h-8 rounded-full flex items-center justify-center text-[11px] font-bold text-white shrink-0 shadow-sm',
                                  styles: Styles(backgroundColor: Color(colorScheme.primary)),
                                  [
                                    Component.text(
                                      _initials(admin.fullname),
                                    ),
                                  ],
                                ),
                                div([
                                  div(
                                    classes: 'font-bold text-xs',
                                    styles: Styles(color: Color(colorScheme.textHeading)),
                                    [Component.text(admin.fullname ?? 'N/A')],
                                  ),
                                  div(
                                    classes: 'text-[11px]',
                                    styles: Styles(color: Color(colorScheme.textMuted)),
                                    [Component.text(admin.email ?? 'No email')],
                                  ),
                                ]),
                              ]),
                            ]),
                            // Role badge
                            td(classes: 'p-3.5', [
                              _RoleBadge(
                                role: admin.role ?? 'UNKNOWN',
                                colorScheme: colorScheme,
                              ),
                            ]),
                            // Region
                            td(
                              classes: 'p-3.5 text-xs font-medium',
                              styles: Styles(color: Color(colorScheme.textSecondary)),
                              [Component.text(admin.region?.state ?? admin.region?.addressLine ?? '—')],
                            ),
                            // Status
                            td(
                              classes: 'p-3.5 text-center',
                              [
                                _StatusBadge(
                                  status: admin.isActive == true ? 'Active' : 'Inactive',
                                  colorScheme: colorScheme,
                                ),
                              ],
                            ),
                            // Last login
                            td(
                              classes: 'p-3.5 text-xs font-medium',
                              styles: Styles(color: Color(colorScheme.textMuted)),
                              [Component.text(_formatDateTime(admin.lastLoginAt))],
                            ),
                            // Created
                            td(
                              classes: 'p-3.5 text-xs font-medium',
                              styles: Styles(color: Color(colorScheme.textMuted)),
                              [Component.text(_formatDateTime(admin.createdAt))],
                            ),
                            // Actions
                            td(classes: 'p-3.5 pr-4 text-center', [
                              button(
                                onClick: () => AdminDetailSidePanel.show(context, admin),
                                classes:
                                    'text-white text-[11px] font-bold px-3 py-1.5 rounded-lg shadow-xs cursor-pointer transition-all',
                                styles: Styles(backgroundColor: Color(colorScheme.primary)),
                                [Component.text('View')],
                              ),
                            ]),
                          ],
                          classes: 'hover:opacity-90 transition-colors cursor-pointer',
                          events: {
                            'click': (_) => AdminDetailSidePanel.show(context, admin),
                          },
                        ),
                    ],
                  ),
                ]),
              ],
            ),
            // Pagination
            _PaginationFooter(
              colorScheme: colorScheme,
              total: total,
              perPage: perPage,
              currentPage: currentPage,
              onPreviousPage: () {
                if (currentPage > 1) {
                  setState(() => currentPage--);
                }
              },
              onNextPage: () {
                final maxPage = (total / perPage).ceil().clamp(1, 9999);
                if (currentPage < maxPage) {
                  setState(() => currentPage++);
                }
              },
            ),
          ]);
        },
        loading: () => _ShimmerLoading(colorScheme: colorScheme),
        error: (err, _) => _ErrorState(
          colorScheme: colorScheme,
          errorMsg: err.toString(),
          onRetry: () => setState(() {}),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Invitations Table Tab
// ─────────────────────────────────────────────────────────────

class _InvitationsTable extends StatefulComponent {
  const _InvitationsTable();

  @override
  State<_InvitationsTable> createState() => _InvitationsTableState();
}

class _InvitationsTableState extends State<_InvitationsTable> {
  String selectedStatus = '';
  String searchQuery = '';
  String _searchInputValue = '';
  Timer? _searchDebounceTimer;
  int currentPage = 1;

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchInput(dynamic value) {
    _searchInputValue = value.toString();
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = _searchInputValue;
        currentPage = 1;
      });
    });
  }

  void _handleResend(BuildContext context, String invitationId) {
    context.read(adminManagementProvider.notifier).resendInvitation(
      invitationId,
      onSuccess: (message) {
        context.showFlushbar(message: message, type: FlushbarType.success);
        context.invalidate(listInvitationsProvider(
          ListInvitationsParams(
            email: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
            status: selectedStatus.isEmpty ? null : selectedStatus,
            page: currentPage,
          ),
        ));
      },
      onError: (message) {
        context.showFlushbar(message: message, type: FlushbarType.error);
      },
    );
  }

  void _handleRevoke(BuildContext context, String invitationId) {
    context.read(adminManagementProvider.notifier).revokeInvitation(
      invitationId,
      onSuccess: (message) {
        context.showFlushbar(message: message, type: FlushbarType.success);
        context.invalidate(listInvitationsProvider(
          ListInvitationsParams(
            email: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
            status: selectedStatus.isEmpty ? null : selectedStatus,
            page: currentPage,
          ),
        ));
      },
      onError: (message) {
        context.showFlushbar(message: message, type: FlushbarType.error);
      },
    );
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));
    final invitationsAsync = context.watch(
      listInvitationsProvider(
        ListInvitationsParams(
          email: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
          status: selectedStatus.isEmpty ? null : selectedStatus,
          page: currentPage,
          perPage: 20,
        ),
      ),
    );

    return div(classes: 'space-y-5', [
      // Toolbar
      div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4', [
        div(classes: 'flex items-center space-x-2', [
          h3(
            classes: 'text-base font-bold tracking-tight',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [Component.text('Admin Invitations')],
          ),
        ]),
        div(classes: 'flex flex-wrap items-center gap-3', [
          // Search input
          div(classes: 'relative w-full sm:w-60', [
            div(
              classes: 'absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none',
              styles: Styles(color: Color(colorScheme.placeholder)),
              [const AppIcon(AppIcons.search)],
            ),
            input(
              type: InputType.text,
              value: _searchInputValue,
              classes:
                  'w-full border rounded-xl pl-9 pr-4 py-1.5 text-xs font-medium focus:outline-none focus:ring-2 transition-all',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.textPrimary),
                raw: {'border-color': colorScheme.borderInput},
              ),
              attributes: {'placeholder': 'Search by email...'},
              onInput: _onSearchInput,
            ),
          ]),

          // Status filter pills
          for (final status in ['', 'PENDING', 'ACCEPTED', 'REVOKED', 'EXPIRED'])
            button(
              onClick: () => setState(() {
                selectedStatus = status;
                currentPage = 1;
              }),
              classes: 'px-3 py-1.5 rounded-lg transition-all cursor-pointer text-[11px] font-bold border',
              styles: selectedStatus == status
                  ? Styles(
                      backgroundColor: Color(colorScheme.primary),
                      color: Color('#FFFFFF'),
                      raw: {'border-color': colorScheme.primary},
                    )
                  : Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      color: Color(colorScheme.textSecondary),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
              [Component.text(status.isEmpty ? 'All' : _formatStatusLabel(status))],
            ),

          // Invite button
          button(
            type: ButtonType.button,
            onClick: () => InviteAdminDialog.show(context),
            classes:
                'px-3.5 py-1.5 rounded-lg text-[11px] font-bold text-white cursor-pointer transition-all flex items-center space-x-1.5 border-none shadow-sm hover:opacity-90 active:scale-95',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [
              span(classes: 'text-sm leading-none', [Component.text('+')]),
              span([Component.text('Invite Admin')]),
            ],
          ),
        ]),
      ]),

      // Data
      invitationsAsync.when(
        data: (paginatedData) {
          final items = paginatedData?.items ?? [];
          final total = paginatedData?.total ?? items.length;
          final perPage = paginatedData?.perPage ?? 20;

          if (items.isEmpty) {
            return _EmptyState(
              colorScheme: colorScheme,
              message: 'No invitations found',
              onReset: () {
                _searchDebounceTimer?.cancel();
                _searchInputValue = '';
                setState(() {
                  searchQuery = '';
                  selectedStatus = '';
                  currentPage = 1;
                });
              },
            );
          }

          return div(classes: 'space-y-5', [
            div(
              classes: 'overflow-x-auto rounded-xl border transition-colors',
              styles: Styles(raw: {'border-color': colorScheme.border}),
              [
                table(classes: 'w-full text-left border-collapse text-xs', [
                  thead(
                    classes: 'uppercase tracking-wider text-[10.5px] border-b font-bold',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      color: Color(colorScheme.textMuted),
                      raw: {'border-color': colorScheme.border},
                    ),
                    [
                      tr([
                        th(classes: 'p-3.5 pl-4', [Component.text('Email')]),
                        th(classes: 'p-3.5', [Component.text('Role')]),
                        th(classes: 'p-3.5 text-center', [Component.text('Status')]),
                        th(classes: 'p-3.5', [Component.text('Expires')]),
                        th(classes: 'p-3.5', [Component.text('Sent')]),
                        th(classes: 'p-3.5 pr-4 text-center', [Component.text('Actions')]),
                      ]),
                    ],
                  ),
                  tbody(
                    classes: 'divide-y font-medium',
                    styles: Styles(
                      color: Color(colorScheme.textPrimary),
                      raw: {'border-color': colorScheme.border},
                    ),
                    [
                      for (final invite in items)
                        tr(
                          [
                            // Email
                            td(
                              classes: 'p-3.5 pl-4',
                              [
                                div(classes: 'flex items-center space-x-3', [
                                  div(
                                    classes:
                                        'w-8 h-8 rounded-full flex items-center justify-center shrink-0 shadow-sm',
                                    styles: Styles(
                                      backgroundColor: Color(colorScheme.inputBg),
                                      color: Color(colorScheme.primary),
                                    ),
                                    [const AppIcon(AppIcons.externalLink)],
                                  ),
                                  span(
                                    classes: 'font-bold text-xs',
                                    styles: Styles(color: Color(colorScheme.textHeading)),
                                    [Component.text(invite.email ?? 'N/A')],
                                  ),
                                ]),
                              ],
                            ),
                            // Role
                            td(classes: 'p-3.5', [
                              _RoleBadge(
                                role: invite.role ?? 'UNKNOWN',
                                colorScheme: colorScheme,
                              ),
                            ]),
                            // Status
                            td(
                              classes: 'p-3.5 text-center',
                              [
                                _InvitationStatusBadge(
                                  status: invite.status ?? 'UNKNOWN',
                                  colorScheme: colorScheme,
                                ),
                              ],
                            ),
                            // Expires
                            td(
                              classes: 'p-3.5 text-xs font-medium',
                              styles: Styles(color: Color(colorScheme.textMuted)),
                              [Component.text(_formatDateTime(invite.expiresAt))],
                            ),
                            // Sent
                            td(
                              classes: 'p-3.5 text-xs font-medium',
                              styles: Styles(color: Color(colorScheme.textMuted)),
                              [Component.text(_formatDateTime(invite.createdAt))],
                            ),
                            // Actions
                            td(classes: 'p-3.5 pr-4 text-center', [
                              div(classes: 'flex items-center justify-center space-x-1.5', [
                                button(
                                  onClick: () => InviteDetailSidePanel.show(context, invite),
                                  classes:
                                      'text-white text-[11px] font-bold px-2.5 py-1 rounded-lg shadow-xs cursor-pointer transition-all border-none',
                                  styles: Styles(backgroundColor: Color(colorScheme.primary)),
                                  [Component.text('View')],
                                ),
                                if (invite.status == 'PENDING' && invite.id != null) ...[
                                  button(
                                    onClick: () => _handleResend(context, invite.id!),
                                    classes:
                                        'text-[11px] font-bold px-2.5 py-1 rounded-lg cursor-pointer transition-all border',
                                    styles: Styles(
                                      backgroundColor: Color(colorScheme.inputBg),
                                      color: Color(colorScheme.primary),
                                      raw: {'border-color': colorScheme.borderInput},
                                    ),
                                    [Component.text('Resend')],
                                  ),
                                  button(
                                    onClick: () => _handleRevoke(context, invite.id!),
                                    classes:
                                        'text-[11px] font-bold px-2.5 py-1 rounded-lg cursor-pointer transition-all border',
                                    styles: Styles(
                                      backgroundColor: Color(colorScheme.inputBg),
                                      color: Color('#ef4444'),
                                      raw: {'border-color': colorScheme.borderInput},
                                    ),
                                    [Component.text('Revoke')],
                                  ),
                                ],
                              ]),
                            ]),
                          ],
                          classes: 'hover:opacity-90 transition-colors cursor-pointer',
                          events: {
                            'click': (_) => InviteDetailSidePanel.show(context, invite),
                          },
                        ),
                    ],
                  ),
                ]),
              ],
            ),
            // Pagination
            _PaginationFooter(
              colorScheme: colorScheme,
              total: total,
              perPage: perPage,
              currentPage: currentPage,
              onPreviousPage: () {
                if (currentPage > 1) {
                  setState(() => currentPage--);
                }
              },
              onNextPage: () {
                final maxPage = (total / perPage).ceil().clamp(1, 9999);
                if (currentPage < maxPage) {
                  setState(() => currentPage++);
                }
              },
            ),
          ]);
        },
        loading: () => _ShimmerLoading(colorScheme: colorScheme),
        error: (err, _) => _ErrorState(
          colorScheme: colorScheme,
          errorMsg: err.toString(),
          onRetry: () => setState(() {}),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Shared Sub-components
// ─────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessComponent {
  final String role;
  final ColorScheme colorScheme;

  const _RoleBadge({required this.role, required this.colorScheme});

  @override
  Component build(BuildContext context) {
    String bgClass;
    String textClass;
    String borderClass;

    switch (role) {
      case 'ROOT_ADMIN':
        bgClass = 'bg-violet-50 dark:bg-violet-950/60';
        textClass = 'text-violet-600 dark:text-violet-400';
        borderClass = 'border-violet-200/50 dark:border-violet-800/50';
        break;
      case 'SUPER_ADMIN':
        bgClass = 'bg-blue-50 dark:bg-blue-950/60';
        textClass = 'text-blue-600 dark:text-blue-400';
        borderClass = 'border-blue-200/50 dark:border-blue-800/50';
        break;
      case 'OPERATIONS':
        bgClass = 'bg-amber-50 dark:bg-amber-950/60';
        textClass = 'text-amber-600 dark:text-amber-400';
        borderClass = 'border-amber-200/50 dark:border-amber-800/50';
        break;
      case 'FINANCE':
        bgClass = 'bg-emerald-50 dark:bg-emerald-950/60';
        textClass = 'text-emerald-600 dark:text-emerald-400';
        borderClass = 'border-emerald-200/50 dark:border-emerald-800/50';
        break;
      case 'SUPPORT':
        bgClass = 'bg-sky-50 dark:bg-sky-950/60';
        textClass = 'text-sky-600 dark:text-sky-400';
        borderClass = 'border-sky-200/50 dark:border-sky-800/50';
        break;
      default:
        bgClass = 'bg-slate-50 dark:bg-slate-800';
        textClass = 'text-slate-600 dark:text-slate-400';
        borderClass = 'border-slate-200 dark:border-slate-700';
    }

    return span(
      classes:
          'px-2.5 py-0.5 rounded-full text-[10px] font-bold tracking-wide inline-block leading-snug border $bgClass $textClass $borderClass',
      [Component.text(_formatRoleLabel(role))],
    );
  }
}

class _StatusBadge extends StatelessComponent {
  final String status;
  final ColorScheme colorScheme;

  const _StatusBadge({required this.status, required this.colorScheme});

  @override
  Component build(BuildContext context) {
    String bgClass;
    String textClass;
    String borderClass;

    if (status == 'Active') {
      bgClass = 'bg-emerald-50 dark:bg-emerald-950/60';
      textClass = 'text-emerald-600 dark:text-emerald-400';
      borderClass = 'border-emerald-200/50 dark:border-emerald-800/50';
    } else {
      bgClass = 'bg-rose-50 dark:bg-rose-950/60';
      textClass = 'text-rose-600 dark:text-rose-400';
      borderClass = 'border-rose-200/50 dark:border-rose-800/50';
    }

    return span(
      classes: 'px-3 py-1 rounded-full text-[11px] font-bold inline-block leading-none border $bgClass $textClass $borderClass',
      [Component.text(status)],
    );
  }
}

class _InvitationStatusBadge extends StatelessComponent {
  final String status;
  final ColorScheme colorScheme;

  const _InvitationStatusBadge({required this.status, required this.colorScheme});

  @override
  Component build(BuildContext context) {
    String bgClass;
    String textClass;
    String borderClass;

    switch (status) {
      case 'PENDING':
        bgClass = 'bg-amber-50 dark:bg-amber-950/60';
        textClass = 'text-amber-600 dark:text-amber-400';
        borderClass = 'border-amber-200/50 dark:border-amber-800/50';
        break;
      case 'ACCEPTED':
        bgClass = 'bg-emerald-50 dark:bg-emerald-950/60';
        textClass = 'text-emerald-600 dark:text-emerald-400';
        borderClass = 'border-emerald-200/50 dark:border-emerald-800/50';
        break;
      case 'REVOKED':
        bgClass = 'bg-rose-50 dark:bg-rose-950/60';
        textClass = 'text-rose-600 dark:text-rose-400';
        borderClass = 'border-rose-200/50 dark:border-rose-800/50';
        break;
      case 'EXPIRED':
        bgClass = 'bg-slate-100 dark:bg-slate-800';
        textClass = 'text-slate-500 dark:text-slate-400';
        borderClass = 'border-slate-200 dark:border-slate-700';
        break;
      default:
        bgClass = 'bg-slate-100 dark:bg-slate-800';
        textClass = 'text-slate-600 dark:text-slate-400';
        borderClass = 'border-slate-200 dark:border-slate-700';
    }

    return span(
      classes: 'px-3 py-1 rounded-full text-[11px] font-bold inline-block leading-none border $bgClass $textClass $borderClass',
      [Component.text(_formatStatusLabel(status))],
    );
  }
}

class _EmptyState extends StatelessComponent {
  final ColorScheme colorScheme;
  final String message;
  final void Function() onReset;

  const _EmptyState({
    required this.colorScheme,
    required this.message,
    required this.onReset,
  });

  @override
  Component build(BuildContext context) {
    return div(classes: 'py-14 text-center space-y-2', [
      p(
        classes: 'text-sm font-semibold',
        styles: Styles(color: Color(colorScheme.textSecondary)),
        [Component.text(message)],
      ),
      button(
        onClick: onReset,
        classes: 'text-xs font-bold hover:underline cursor-pointer border-none bg-transparent',
        styles: Styles(color: Color(colorScheme.primary)),
        [Component.text('Reset filters')],
      ),
    ]);
  }
}

class _PaginationFooter extends StatelessComponent {
  final ColorScheme colorScheme;
  final int total;
  final int perPage;
  final int currentPage;
  final void Function() onPreviousPage;
  final void Function() onNextPage;

  const _PaginationFooter({
    required this.colorScheme,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Component build(BuildContext context) {
    final maxPage = (total / perPage).ceil().clamp(1, 9999);

    return div(
      classes:
          'flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-2 text-xs transition-colors',
      styles: Styles(color: Color(colorScheme.textMuted)),
      [
        div(classes: 'font-medium', [
          Component.text('Showing page $currentPage of $maxPage (Total: $total entries)'),
        ]),
        div(classes: 'flex items-center space-x-1.5 font-semibold self-end sm:self-auto', [
          button(
            onClick: onPreviousPage,
            classes: 'px-2.5 py-1 rounded-lg border transition-colors cursor-pointer text-xs font-semibold',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [Component.text('Previous')],
          ),
          span(
            classes: 'px-3 py-1 rounded-lg font-bold text-white shadow-xs text-xs',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [Component.text('$currentPage')],
          ),
          button(
            onClick: onNextPage,
            classes: 'px-2.5 py-1 rounded-lg border transition-colors cursor-pointer text-xs font-semibold',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [Component.text('Next')],
          ),
        ]),
      ],
    );
  }
}

class _ShimmerLoading extends StatelessComponent {
  final ColorScheme colorScheme;

  const _ShimmerLoading({required this.colorScheme});

  @override
  Component build(BuildContext context) {
    final blockColor = colorScheme.isDark ? Color.rgba(31, 45, 39, 0.8) : Color.rgba(226, 232, 240, 0.8);

    return div(
      classes: 'space-y-6 animate-pulse',
      [
        div(classes: 'h-10 w-full rounded-xl', styles: Styles(backgroundColor: blockColor), []),
        div(classes: 'h-72 w-full rounded-xl', styles: Styles(backgroundColor: blockColor), []),
      ],
    );
  }
}

class _ErrorState extends StatelessComponent {
  final ColorScheme colorScheme;
  final String errorMsg;
  final void Function() onRetry;

  const _ErrorState({
    required this.colorScheme,
    required this.errorMsg,
    required this.onRetry,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'rounded-2xl p-12 text-center border space-y-4',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'text-rose-500 font-bold text-lg', [Component.text('Failed to Load Data')]),
        p(classes: 'text-xs text-slate-400 max-w-md mx-auto', [Component.text(errorMsg)]),
        button(
          onClick: onRetry,
          classes: 'px-4 py-2 text-xs font-bold text-white rounded-xl shadow-xs cursor-pointer border-none',
          styles: Styles(backgroundColor: Color(colorScheme.primary)),
          [Component.text('Retry')],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

String _initials(String? fullname) {
  if (fullname == null || fullname.isEmpty) return '??';
  return fullname.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
}

String _formatDateTime(DateTime? dt) {
  if (dt == null) return '—';
  return '${dt.day}/${dt.month}/${dt.year}';
}

String _formatRoleLabel(String role) {
  switch (role) {
    case 'ROOT_ADMIN':
      return 'Root Admin';
    case 'SUPER_ADMIN':
      return 'Super Admin';
    case 'OPERATIONS':
      return 'Operations';
    case 'SUPPORT':
      return 'Support';
    case 'FINANCE':
      return 'Finance';
    default:
      return role;
  }
}

String _formatStatusLabel(String status) {
  switch (status) {
    case 'PENDING':
      return 'Pending';
    case 'ACCEPTED':
      return 'Accepted';
    case 'REVOKED':
      return 'Revoked';
    case 'EXPIRED':
      return 'Expired';
    default:
      return status;
  }
}
