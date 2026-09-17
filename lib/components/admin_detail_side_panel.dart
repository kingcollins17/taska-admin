import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/admin_management/admin_role.dart';
import '../core/models/clients/admin_management/change_admin_role_request.dart';
import '../core/models/clients/auth/admin_user.dart';
import '../core/providers/admin_management_providers.dart';
import '../core/providers/ui_state_provider.dart';

class AdminDetailSidePanel extends StatefulComponent {
  final AdminUser admin;

  const AdminDetailSidePanel({
    required this.admin,
    super.key,
  });

  static void show(BuildContext context, AdminUser admin) {
    context.showSidePanel(
      AdminDetailSidePanel(admin: admin),
      title: 'Administrator Details',
    );
  }

  @override
  State<AdminDetailSidePanel> createState() => _AdminDetailSidePanelState();
}

class _AdminDetailSidePanelState extends State<AdminDetailSidePanel> {
  String? selectedRole;
  bool isUpdatingRole = false;
  bool isTogglingStatus = false;

  @override
  void initState() {
    super.initState();
    selectedRole = component.admin.role;
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    if (text.isEmpty) return;
    try {
      web.window.navigator.clipboard.writeText(text);
      context.showFlushbar(
        message: '$label copied to clipboard',
        type: FlushbarType.success,
      );
    } catch (_) {
      context.showFlushbar(
        message: 'Failed to copy $label',
        type: FlushbarType.error,
      );
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'N/A';
    final local = dt.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[local.month - 1];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month ${local.day}, ${local.year} at $hour:$minute';
  }

  void _handleChangeRole(BuildContext context, String adminId, String currentRole) {
    final newRole = selectedRole;
    if (newRole == null || newRole == currentRole) {
      context.showFlushbar(
        message: 'Please select a different role to update',
        type: FlushbarType.warning,
      );
      return;
    }

    setState(() => isUpdatingRole = true);

    context.read(adminManagementProvider.notifier).changeAdminRole(
      adminId,
      ChangeAdminRoleRequest(newRole: newRole),
      onSuccess: (message) {
        if (!mounted) return;
        setState(() => isUpdatingRole = false);
        context.showFlushbar(
          title: 'Role Updated',
          message: message,
          type: FlushbarType.success,
        );
        context.invalidate(adminManagementDetailProvider(adminId));
        context.invalidate(listAdminsProvider(const ListAdminsParams()));
      },
      onError: (message) {
        if (!mounted) return;
        setState(() => isUpdatingRole = false);
        context.showFlushbar(
          title: 'Failed to Update Role',
          message: message,
          type: FlushbarType.error,
        );
      },
    );
  }

  void _handleToggleStatus(BuildContext context, String adminId, bool isActive) {
    if (isTogglingStatus) return;
    setState(() => isTogglingStatus = true);

    final notifier = context.read(adminManagementProvider.notifier);
    if (isActive) {
      notifier.deactivateAdmin(
        adminId,
        onSuccess: (message) {
          if (!mounted) return;
          setState(() => isTogglingStatus = false);
          context.showFlushbar(
            title: 'Admin Deactivated',
            message: message,
            type: FlushbarType.success,
          );
          context.invalidate(adminManagementDetailProvider(adminId));
          context.invalidate(listAdminsProvider(const ListAdminsParams()));
        },
        onError: (message) {
          if (!mounted) return;
          setState(() => isTogglingStatus = false);
          context.showFlushbar(
            title: 'Deactivation Failed',
            message: message,
            type: FlushbarType.error,
          );
        },
      );
    } else {
      notifier.reactivateAdmin(
        adminId,
        onSuccess: (message) {
          if (!mounted) return;
          setState(() => isTogglingStatus = false);
          context.showFlushbar(
            title: 'Admin Reactivated',
            message: message,
            type: FlushbarType.success,
          );
          context.invalidate(adminManagementDetailProvider(adminId));
          context.invalidate(listAdminsProvider(const ListAdminsParams()));
        },
        onError: (message) {
          if (!mounted) return;
          setState(() => isTogglingStatus = false);
          context.showFlushbar(
            title: 'Reactivation Failed',
            message: message,
            type: FlushbarType.error,
          );
        },
      );
    }
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;
    final adminId = component.admin.id;

    final detailAsync = (adminId != null && adminId.isNotEmpty)
        ? context.watch(adminManagementDetailProvider(adminId))
        : null;
    final admin = detailAsync?.asData?.value ?? component.admin;

    final currentRole = admin.role ?? AdminRoles.support;
    final activeRole = selectedRole ?? currentRole;
    final isActive = admin.isActive ?? true;

    return div(classes: 'space-y-6 text-xs pb-8 relative', [
      // ─────────────────────────────────────────────────────────────
      // Hero Profile Card
      // ─────────────────────────────────────────────────────────────
      div(
        classes:
            'p-5 rounded-2xl border flex flex-col space-y-4 relative overflow-hidden shadow-xl transition-all',
        styles: Styles(
          backgroundColor: Color(colorScheme.inputBg),
          raw: {'border-color': colorScheme.borderInput},
        ),
        [
          // Decorative top accent gradient bar
          div(
            classes:
                'absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-emerald-500 via-teal-400 to-cyan-500',
            [],
          ),
          div(classes: 'flex items-start justify-between gap-3 pt-1', [
            div(classes: 'flex items-center space-x-3.5 min-w-0 flex-1', [
              // Avatar
              div(classes: 'relative shrink-0', [
                img(
                  src:
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(admin.fullname ?? admin.email ?? 'Admin')}&background=0D9488&color=fff&bold=true',
                  classes:
                      'w-14 h-14 rounded-2xl object-cover border-2 shadow-md shrink-0',
                  styles: Styles(raw: {'border-color': 'rgba(16, 185, 129, 0.4)'}),
                  alt: admin.fullname ?? 'Admin',
                ),
                div(
                  classes:
                      'w-3.5 h-3.5 rounded-full ring-4 absolute -bottom-1 -right-1 shadow-sm',
                  styles: isActive
                      ? Styles(
                          backgroundColor: Color.rgba(52, 211, 153, 1.0),
                          raw: {'ring-color': colorScheme.surface},
                        )
                      : Styles(
                          backgroundColor: Color.rgba(244, 63, 94, 1.0),
                          raw: {'ring-color': colorScheme.surface},
                        ),
                  [],
                ),
              ]),
              div(classes: 'space-y-1 min-w-0 flex-1', [
                h4(
                  classes: 'font-black text-base truncate tracking-tight',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text(admin.fullname ?? 'N/A')],
                ),
                div(
                  classes:
                      'flex items-center space-x-2 text-xs font-mono cursor-pointer hover:text-emerald-500 transition-colors group',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  events: {
                    'click': (_) =>
                        _copyToClipboard(context, admin.email ?? '', 'Email address'),
                  },
                  [
                    span(classes: 'truncate font-medium', [
                      Component.text(admin.email ?? 'No email address'),
                    ]),
                    div(
                      classes:
                          'w-3.5 h-3.5 group-hover:text-emerald-500 transition-colors shrink-0',
                      styles: Styles(color: Color(colorScheme.textMuted)),
                      [const AppIcon(AppIcons.copy)],
                    ),
                  ],
                ),
              ]),
            ]),
          ]),

          // Badges & Copy ID Action Row
          div(
            classes:
                'flex flex-wrap items-center justify-between gap-2.5 pt-3.5 border-t',
            styles: Styles(raw: {'border-color': colorScheme.border}),
            [
              div(classes: 'flex items-center space-x-2', [
                // Role Badge
                _buildRoleBadge(currentRole, isDark),
                // Account Active Badge
                span(
                  classes:
                      'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border',
                  styles: isActive
                      ? Styles(
                          backgroundColor: isDark
                              ? Color.rgba(16, 185, 129, 0.18)
                              : Color.rgba(16, 185, 129, 0.1),
                          color: isDark
                              ? Color.rgba(110, 231, 183, 1.0)
                              : Color.rgba(4, 120, 87, 1.0),
                          raw: {
                            'border-color': isDark
                                ? 'rgba(16, 185, 129, 0.4)'
                                : 'rgba(16, 185, 129, 0.25)'
                          },
                        )
                      : Styles(
                          backgroundColor: isDark
                              ? Color.rgba(244, 63, 94, 0.18)
                              : Color.rgba(244, 63, 94, 0.1),
                          color: isDark
                              ? Color.rgba(253, 164, 175, 1.0)
                              : Color.rgba(190, 18, 60, 1.0),
                          raw: {
                            'border-color': isDark
                                ? 'rgba(244, 63, 94, 0.4)'
                                : 'rgba(244, 63, 94, 0.25)'
                          },
                        ),
                  [
                    Component.text(isActive ? '● Active' : '○ Inactive'),
                  ],
                ),
              ]),

              div(classes: 'flex items-center space-x-2', [
                // Quick Copy ID Button Chip
                button(
                  type: ButtonType.button,
                  classes:
                      'px-3 py-1.5 rounded-xl text-[11px] font-bold transition-all cursor-pointer flex items-center space-x-1.5 active:scale-95 shadow-sm border',
                  styles: Styles(
                    backgroundColor: isDark
                        ? Color.rgba(16, 185, 129, 0.15)
                        : Color.rgba(16, 185, 129, 0.08),
                    color: isDark
                        ? Color.rgba(110, 231, 183, 1.0)
                        : Color.rgba(4, 120, 87, 1.0),
                    raw: {
                      'border-color': isDark
                          ? 'rgba(16, 185, 129, 0.35)'
                          : 'rgba(16, 185, 129, 0.25)'
                    },
                  ),
                  events: {
                    'click': (_) =>
                        _copyToClipboard(context, admin.id ?? '', 'Admin ID'),
                  },
                  [
                    div(
                      classes: 'w-3.5 h-3.5 shrink-0',
                      styles: Styles(color: Color(colorScheme.primary)),
                      [const AppIcon(AppIcons.copy)],
                    ),
                    span([Component.text('Copy ID')]),
                  ],
                ),
              ]),
            ],
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // Administrator Information
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3', [
        _buildSectionHeader('Administrator Details', AppIcons.administrators, context),
        div(
          classes: 'divide-y border rounded-2xl overflow-hidden shadow-sm',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {
              'border-color': colorScheme.border,
              'divide-color': colorScheme.borderInput,
            },
          ),
          [
            _buildDetailRow('Account ID', admin.id ?? 'N/A', context, isCopyable: true),
            _buildDetailRow('Email Address', admin.email ?? 'N/A', context, isCopyable: true),
            _buildDetailRow('Full Name', admin.fullname ?? 'N/A', context),
            _buildDetailRow('Role Tier', AdminRoles.labelOf(currentRole), context),
            _buildDetailRow('Region', admin.region?.state ?? admin.region?.addressLine ?? admin.regionId ?? 'Global', context),
            _buildDetailRow('Parent Admin ID', admin.parentAdminId ?? 'None (Top Level)', context, isCopyable: admin.parentAdminId != null),
            _buildDetailRow('Created By ID', admin.createdById ?? 'System', context, isCopyable: admin.createdById != null),
            _buildDetailRow('Last Login', _formatDateTime(admin.lastLoginAt), context),
            _buildDetailRow('Created At', _formatDateTime(admin.createdAt), context),
            _buildDetailRow('Updated At', _formatDateTime(admin.updatedAt), context),
          ],
        ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Role Management Card
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3', [
        _buildSectionHeader('Role & Authority Level', AppIcons.security, context),
        div(
          classes: 'p-4 rounded-2xl border space-y-4 shadow-sm',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            p(
              classes: 'text-xs text-muted font-medium',
              styles: Styles(color: Color(colorScheme.textSecondary)),
              [
                Component.text(
                  'Select a new role to adjust operational authority and feature permissions for this administrator account.',
                ),
              ],
            ),
            // Role Pills
            div(classes: 'flex flex-wrap gap-2', [
              for (final r in AdminRoles.assignableRoles)
                button(
                  type: ButtonType.button,
                  onClick: () => setState(() => selectedRole = r),
                  classes:
                      'px-3 py-1.5 rounded-xl text-[11px] font-bold transition-all cursor-pointer border flex items-center space-x-1.5',
                  styles: activeRole == r
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
                  [
                    if (r == currentRole)
                      span(
                        classes:
                            'w-1.5 h-1.5 rounded-full bg-emerald-400 inline-block mr-1',
                        [],
                      ),
                    Component.text(AdminRoles.labelOf(r)),
                  ],
                ),
            ]),
            // Submit Role Change
            if (activeRole != currentRole)
              div(classes: 'pt-2 flex justify-end', [
                button(
                  type: ButtonType.button,
                  onClick: isUpdatingRole
                      ? null
                      : () => _handleChangeRole(context, admin.id!, currentRole),
                  classes:
                      'px-4 py-2 rounded-xl text-xs font-bold text-white transition-all cursor-pointer shadow-sm flex items-center space-x-2 border-none',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.primary),
                    raw: {
                      if (isUpdatingRole) 'opacity': '0.7',
                    },
                  ),
                  [
                    if (isUpdatingRole)
                      span(classes: 'animate-spin text-sm', [Component.text('◌')])
                    else
                      AppIcon(AppIcons.checkCircle),
                    span([
                      Component.text(isUpdatingRole ? 'Updating...' : 'Save Role Change'),
                    ]),
                  ],
                ),
              ]),
          ],
        ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Account Status & Deactivation Management
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3', [
        _buildSectionHeader('Account Access Status', AppIcons.setting, context),
        div(
          classes: 'p-4 rounded-2xl border space-y-4 shadow-sm',
          styles: isActive
              ? Styles(
                  backgroundColor: isDark
                      ? Color.rgba(244, 63, 94, 0.05)
                      : Color.rgba(244, 63, 94, 0.03),
                  raw: {
                    'border-color': isDark
                        ? 'rgba(244, 63, 94, 0.3)'
                        : 'rgba(244, 63, 94, 0.2)'
                  },
                )
              : Styles(
                  backgroundColor: isDark
                      ? Color.rgba(16, 185, 129, 0.05)
                      : Color.rgba(16, 185, 129, 0.03),
                  raw: {
                    'border-color': isDark
                        ? 'rgba(16, 185, 129, 0.3)'
                        : 'rgba(16, 185, 129, 0.2)'
                  },
                ),
          [
            div(classes: 'flex items-start space-x-3', [
              div(
                classes: 'w-8 h-8 rounded-xl shrink-0 flex items-center justify-center border',
                styles: isActive
                    ? Styles(
                        backgroundColor: isDark
                            ? Color.rgba(244, 63, 94, 0.15)
                            : Color.rgba(244, 63, 94, 0.1),
                        color: isDark
                            ? Color.rgba(253, 164, 175, 1.0)
                            : Color.rgba(190, 18, 60, 1.0),
                        raw: {'border-color': 'rgba(244, 63, 94, 0.3)'},
                      )
                    : Styles(
                        backgroundColor: isDark
                            ? Color.rgba(16, 185, 129, 0.15)
                            : Color.rgba(16, 185, 129, 0.1),
                        color: isDark
                            ? Color.rgba(110, 231, 183, 1.0)
                            : Color.rgba(4, 120, 87, 1.0),
                        raw: {'border-color': 'rgba(16, 185, 129, 0.3)'},
                      ),
                [
                  AppIcon(isActive ? AppIcons.close : AppIcons.checkCircle),
                ],
              ),
              div(classes: 'space-y-1 min-w-0 flex-1', [
                h5(
                  classes: 'font-bold text-xs',
                  styles: Styles(
                    color: isActive
                        ? (isDark
                            ? Color.rgba(253, 164, 175, 1.0)
                            : Color.rgba(190, 18, 60, 1.0))
                        : (isDark
                            ? Color.rgba(110, 231, 183, 1.0)
                            : Color.rgba(4, 120, 87, 1.0)),
                  ),
                  [
                    Component.text(
                      isActive ? 'Deactivate Administrator' : 'Reactivate Administrator',
                    ),
                  ],
                ),
                p(
                  classes: 'text-xs font-medium leading-relaxed',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  [
                    Component.text(
                      isActive
                          ? 'Deactivating this administrator will revoke login privileges and invalidate active sessions immediately.'
                          : 'Reactivating this administrator will restore login privileges and allow system access according to assigned role.',
                    ),
                  ],
                ),
              ]),
            ]),
            // Action Button
            div(classes: 'flex justify-end pt-1', [
              button(
                type: ButtonType.button,
                onClick: (isTogglingStatus || admin.id == null)
                    ? null
                    : () => _handleToggleStatus(context, admin.id!, isActive),
                classes:
                    'px-4 py-2 rounded-xl text-xs font-bold text-white transition-all cursor-pointer shadow-sm flex items-center space-x-2 border-none',
                styles: isActive
                    ? Styles(
                        backgroundColor: Color.rgba(225, 29, 72, 1.0),
                        raw: {
                          if (isTogglingStatus) 'opacity': '0.7',
                        },
                      )
                    : Styles(
                        backgroundColor: Color.rgba(16, 185, 129, 1.0),
                        raw: {
                          if (isTogglingStatus) 'opacity': '0.7',
                        },
                      ),
                [
                  if (isTogglingStatus)
                    span(classes: 'animate-spin text-sm', [Component.text('◌')])
                  else
                    AppIcon(isActive ? AppIcons.close : AppIcons.checkCircle),
                  span([
                    Component.text(
                      isTogglingStatus
                          ? 'Processing...'
                          : (isActive ? 'Deactivate Account' : 'Reactivate Account'),
                    ),
                  ]),
                ],
              ),
            ]),
          ],
        ),
      ]),
    ]);
  }

  Component _buildRoleBadge(String role, bool isDark) {
    return span(
      classes:
          'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border flex items-center gap-1.5',
      styles: Styles(
        backgroundColor: isDark
            ? Color.rgba(16, 185, 129, 0.18)
            : Color.rgba(16, 185, 129, 0.1),
        color: isDark
            ? Color.rgba(110, 231, 183, 1.0)
            : Color.rgba(4, 120, 87, 1.0),
        raw: {
          'border-color': isDark
              ? 'rgba(16, 185, 129, 0.4)'
              : 'rgba(16, 185, 129, 0.25)'
        },
      ),
      [
        span(
          classes: 'w-1.5 h-1.5 rounded-full bg-emerald-400',
          [],
        ),
        Component.text(AdminRoles.labelOf(role)),
      ],
    );
  }

  Component _buildSectionHeader(
      String title, AppIcons icon, BuildContext context) {
    final colorScheme = context.colorScheme;
    return div(classes: 'flex items-center space-x-2 pt-2', [
      div(
        classes: 'w-4 h-4 shrink-0',
        styles: Styles(color: Color(colorScheme.primary)),
        [AppIcon(icon)],
      ),
      h4(
        classes: 'font-bold text-xs uppercase tracking-wider',
        styles: Styles(color: Color(colorScheme.textHeading)),
        [Component.text(title)],
      ),
    ]);
  }

  Component _buildDetailRow(
    String label,
    String value,
    BuildContext context, {
    bool isCopyable = false,
  }) {
    final colorScheme = context.colorScheme;
    return div(
      classes:
          'p-3.5 flex flex-col sm:flex-row sm:items-center justify-between gap-2 hover:bg-black/5 transition-colors',
      [
        span(
          classes: 'text-xs font-semibold shrink-0',
          styles: Styles(color: Color(colorScheme.textSecondary)),
          [Component.text(label)],
        ),
        div(
          classes: 'flex items-center space-x-2 min-w-0',
          [
            span(
              classes:
                  'text-xs font-mono font-medium truncate select-all',
              styles: Styles(color: Color(colorScheme.textPrimary)),
              [Component.text(value)],
            ),
            if (isCopyable && value != 'N/A' && value.isNotEmpty)
              button(
                type: ButtonType.button,
                onClick: () => _copyToClipboard(context, value, label),
                classes:
                    'p-1 rounded-md hover:bg-emerald-500/10 hover:text-emerald-500 transition-colors cursor-pointer border-none bg-transparent',
                styles: Styles(color: Color(colorScheme.textMuted)),
                [
                  const div(
                    classes: 'w-3.5 h-3.5',
                    [AppIcon(AppIcons.copy)],
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
