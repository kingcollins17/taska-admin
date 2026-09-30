import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/users/admin_platform_user_item.dart';
import '../core/models/clients/users/admin_user_status_update_body.dart';
import '../core/providers/admin_user_providers.dart';
import '../core/providers/stats_providers.dart';
import '../core/providers/ui_state_provider.dart';
import 'schedule_interview_dialog.dart';

class PlatformUserDetailSidePanel extends StatefulComponent {
  final AdminPlatformUserItem user;

  const PlatformUserDetailSidePanel({
    required this.user,
    super.key,
  });

  static void show(BuildContext context, AdminPlatformUserItem user) {
    context.showSidePanel(
      PlatformUserDetailSidePanel(user: user),
      title: 'User Profile',
    );
  }

  @override
  State<PlatformUserDetailSidePanel> createState() => _PlatformUserDetailSidePanelState();
}

class _PlatformUserDetailSidePanelState extends State<PlatformUserDetailSidePanel> {
  bool isViewingFullPicture = false;

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

  @override
  Component build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;
    final user = component.user;
    final userId = user.id;

    final detailAsync = (userId != null && userId.isNotEmpty)
        ? context.watch(adminUserDetailProvider(userId))
        : null;
    final detail = detailAsync?.asData?.value;
    final providerProfile = detail?.providerProfile;
    final selfieUrl = providerProfile?.selfieUrl;
    final isProvider = user.type == 'PROVIDER' || detail?.type == 'PROVIDER';
    final hasSelfie = isProvider && selfieUrl != null && selfieUrl.trim().isNotEmpty;
    final activeSelfieUrl = hasSelfie ? selfieUrl.trim() : null;
    final isCurrentlyActive = detail?.isActive ?? user.isActive ?? true;

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
              // Avatar with Status Dot Indicator
              div(classes: 'relative shrink-0 group', [
                img(
                  src: activeSelfieUrl ??
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.fullname ?? user.email ?? 'User')}&background=0D9488&color=fff&bold=true',
                  classes: activeSelfieUrl != null
                      ? 'w-14 h-14 rounded-2xl object-cover border-2 shadow-md shrink-0 cursor-pointer hover:opacity-90 transition-all'
                      : 'w-14 h-14 rounded-2xl object-cover border-2 shadow-md shrink-0',
                  styles: Styles(raw: {'border-color': 'rgba(16, 185, 129, 0.4)'}),
                  alt: user.fullname ?? 'User',
                  events: activeSelfieUrl != null
                      ? {
                          'click': (_) => setState(() => isViewingFullPicture = true),
                        }
                      : {},
                ),
                div(
                  classes: isCurrentlyActive
                      ? 'w-3.5 h-3.5 rounded-full ring-4 absolute -bottom-1 -right-1 shadow-sm'
                      : 'w-3.5 h-3.5 rounded-full ring-4 absolute -bottom-1 -right-1 shadow-sm',
                  styles: isCurrentlyActive
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
                  [Component.text(user.fullname ?? 'N/A')],
                ),
                div(
                  classes:
                      'flex items-center space-x-2 text-xs font-mono cursor-pointer hover:text-emerald-500 transition-colors group',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  events: {
                    'click': (_) =>
                        _copyToClipboard(context, user.email ?? '', 'Email address'),
                  },
                  [
                    span(classes: 'truncate font-medium', [
                      Component.text(user.email ?? 'No email address'),
                    ]),
                    div(
                      classes:
                          'w-3.5 h-3.5 group-hover:text-emerald-500 transition-colors shrink-0',
                      styles: Styles(color: Color(colorScheme.textMuted)),
                      [const AppIcon(AppIcons.copy)],
                    ),
                  ],
                ),
                if (activeSelfieUrl != null) ...[
                  button(
                    type: ButtonType.button,
                    classes:
                        'mt-1 px-2.5 py-1 rounded-lg text-[10.5px] font-bold transition-all cursor-pointer inline-flex items-center space-x-1.5 border active:scale-95 shadow-2xs',
                    styles: Styles(
                      backgroundColor: isDark ? Color.rgba(16, 185, 129, 0.15) : Color.rgba(16, 185, 129, 0.08),
                      color: isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0),
                      raw: {'border-color': isDark ? 'rgba(16, 185, 129, 0.35)' : 'rgba(16, 185, 129, 0.25)'},
                    ),
                    events: {
                      'click': (_) => setState(() => isViewingFullPicture = true),
                    },
                    [
                      div(
                        classes: 'w-3 h-3 shrink-0',
                        styles: Styles(color: Color(colorScheme.primary)),
                        [
                          const AppIcon(AppIcons.documents),
                        ],
                      ),
                      span([Component.text('View Full Photo')]),
                    ],
                  ),
                ],
              ]),
            ]),
          ]),

          // Badges & Actions Row
          div(
            classes:
                'flex flex-wrap items-center justify-between gap-2.5 pt-3.5 border-t',
            styles: Styles(raw: {'border-color': colorScheme.border}),
            [
              div(classes: 'flex flex-wrap items-center gap-2', [
                // Role Badge
                span(
                  classes:
                      'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border flex items-center gap-1.5',
                  styles: user.type == 'PROVIDER'
                      ? Styles(
                          backgroundColor: isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1),
                          color: isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0),
                          raw: {'border-color': isDark ? 'rgba(16, 185, 129, 0.4)' : 'rgba(16, 185, 129, 0.25)'},
                        )
                      : Styles(
                          backgroundColor: isDark ? Color.rgba(14, 165, 233, 0.18) : Color.rgba(14, 165, 233, 0.1),
                          color: isDark ? Color.rgba(125, 211, 252, 1.0) : Color.rgba(3, 105, 161, 1.0),
                          raw: {'border-color': isDark ? 'rgba(14, 165, 233, 0.4)' : 'rgba(14, 165, 233, 0.25)'},
                        ),
                  [
                    span(
                      classes: 'w-1.5 h-1.5 rounded-full',
                      styles: user.type == 'PROVIDER'
                          ? Styles(backgroundColor: Color.rgba(52, 211, 153, 1.0))
                          : Styles(backgroundColor: Color.rgba(56, 189, 248, 1.0)),
                      [],
                    ),
                    Component.text(user.type ?? 'CUSTOMER'),
                  ],
                ),
                // Account Active Badge
                span(
                  classes:
                      'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border',
                  styles: isCurrentlyActive
                      ? Styles(
                          backgroundColor: isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1),
                          color: isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0),
                          raw: {'border-color': isDark ? 'rgba(16, 185, 129, 0.4)' : 'rgba(16, 185, 129, 0.25)'},
                        )
                      : Styles(
                          backgroundColor: isDark ? Color.rgba(244, 63, 94, 0.18) : Color.rgba(244, 63, 94, 0.1),
                          color: isDark ? Color.rgba(253, 164, 175, 1.0) : Color.rgba(190, 18, 60, 1.0),
                          raw: {'border-color': isDark ? 'rgba(244, 63, 94, 0.4)' : 'rgba(244, 63, 94, 0.25)'},
                        ),
                  [
                    Component.text(isCurrentlyActive ? '● Active' : '○ Inactive'),
                  ],
                ),
              ]),

              div(classes: 'flex flex-wrap items-center gap-2', [
                // Quick Copy ID Button Chip
                button(
                  type: ButtonType.button,
                  classes:
                      'px-3 py-1.5 rounded-xl text-[11px] font-bold transition-all cursor-pointer flex items-center space-x-1.5 active:scale-95 shadow-sm border',
                  styles: Styles(
                    backgroundColor: isDark ? Color.rgba(16, 185, 129, 0.15) : Color.rgba(16, 185, 129, 0.08),
                    color: isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0),
                    raw: {'border-color': isDark ? 'rgba(16, 185, 129, 0.35)' : 'rgba(16, 185, 129, 0.25)'},
                  ),
                  events: {
                    'click': (_) => _copyToClipboard(context, user.id ?? '', 'User ID'),
                  },
                  [
                    div(
                      classes: 'w-3.5 h-3.5 shrink-0',
                      styles: Styles(color: Color(colorScheme.primary)),
                      [
                        const AppIcon(AppIcons.copy),
                      ],
                    ),
                    span([Component.text('Copy ID')]),
                  ],
                ),

                // Status Update (Activate / Deactivate) Button Chip
                button(
                  type: ButtonType.button,
                  classes: isCurrentlyActive
                      ? 'px-3 py-1.5 rounded-xl text-[11px] font-bold transition-all cursor-pointer flex items-center space-x-1.5 active:scale-95 shadow-sm border text-rose-600 dark:text-rose-400 border-rose-500/30 bg-rose-500/10 hover:bg-rose-500/20'
                      : 'px-3 py-1.5 rounded-xl text-[11px] font-bold transition-all cursor-pointer flex items-center space-x-1.5 active:scale-95 shadow-sm border text-emerald-600 dark:text-emerald-400 border-emerald-500/30 bg-emerald-500/10 hover:bg-emerald-500/20',
                  events: {
                    'click': (_) {
                      _UpdateUserStatusDialog.show(
                        context,
                        userId: user.id ?? '',
                        userName: user.fullname ?? user.email ?? 'User',
                        isCurrentlyActive: isCurrentlyActive,
                      );
                    },
                  },
                  [
                    div(
                      classes: 'w-3.5 h-3.5 shrink-0',
                      [
                        AppIcon(isCurrentlyActive ? AppIcons.disputes : AppIcons.checkCircle),
                      ],
                    ),
                    span([Component.text(isCurrentlyActive ? 'Deactivate' : 'Activate')]),
                  ],
                ),

                // Schedule Interview Button Chip
                button(
                  type: ButtonType.button,
                  classes:
                      'px-3 py-1.5 rounded-xl text-[11px] font-bold transition-all cursor-pointer flex items-center space-x-1.5 active:scale-95 shadow-sm border text-white border-none',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.primary),
                  ),
                  events: {
                    'click': (_) {
                      context.hideSidePanel();
                      ScheduleInterviewDialog.show(context, userId: user.id, user: user);
                    },
                  },
                  [
                    div(
                      classes: 'w-3.5 h-3.5 shrink-0',
                      [
                        const AppIcon(AppIcons.calendar),
                      ],
                    ),
                    span([Component.text('Schedule Interview')]),
                  ],
                ),
              ]),
            ],
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // Account Overview Section
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3', [
        _buildSectionHeader('Account Overview', AppIcons.documents, context),
        div(
          classes:
              'divide-y border rounded-2xl overflow-hidden shadow-sm',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {
              'border-color': colorScheme.border,
              'divide-color': colorScheme.borderInput,
            },
          ),
          [
            _buildCopyableRow(context, 'User ID', user.id ?? 'N/A'),
            _buildInfoRow(context, 'Phone Number', user.phoneNumber ?? 'N/A'),
            _buildCopyableRow(context, 'Region ID', user.regionId ?? 'N/A'),
            _buildInfoRow(context, 'Created At', _formatDate(user.createdAt)),
          ],
        ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Detailed Section (Riverpod Async Data)
      // ─────────────────────────────────────────────────────────────
      if (userId != null && userId.isNotEmpty)
        _buildDetailedSection(context, userId),

      // ─────────────────────────────────────────────────────────────
      // Bottom Sticky Action Footer
      // ─────────────────────────────────────────────────────────────
      div(
        classes:
            'pt-4 border-t flex items-center justify-between gap-3 sticky bottom-0 z-10 p-2.5 rounded-2xl shadow-lg backdrop-blur-md',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [
          div(classes: 'space-y-0.5 px-2', [
            span(
              classes: 'block text-xs font-bold',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text('Account Status Governance')],
            ),
            span(
              classes: 'block text-[11px]',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text(isCurrentlyActive ? 'Account is active and unrestricted' : 'Account is currently deactivated')],
            ),
          ]),

          button(
            type: ButtonType.button,
            onClick: () {
              _UpdateUserStatusDialog.show(
                context,
                userId: user.id ?? '',
                userName: user.fullname ?? user.email ?? 'User',
                isCurrentlyActive: isCurrentlyActive,
              );
            },
            classes: isCurrentlyActive
                ? 'px-4 py-2.5 rounded-xl text-xs font-bold text-white transition-all cursor-pointer shadow-md hover:opacity-90 active:scale-95 flex items-center space-x-2 bg-rose-600'
                : 'px-4 py-2.5 rounded-xl text-xs font-bold text-white transition-all cursor-pointer shadow-md hover:opacity-90 active:scale-95 flex items-center space-x-2 bg-emerald-600',
            [
              AppIcon(isCurrentlyActive ? AppIcons.disputes : AppIcons.checkCircle),
              span([Component.text(isCurrentlyActive ? 'Deactivate User' : 'Activate User')]),
            ],
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // Full Selfie Picture Modal Overlay
      // ─────────────────────────────────────────────────────────────
      if (isViewingFullPicture && activeSelfieUrl != null)
        div(
          classes:
              'fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-backdrop-in',
          events: {
            'click': (_) => setState(() => isViewingFullPicture = false),
          },
          [
            div(
              classes:
                  'relative max-w-lg w-full bg-slate-900 rounded-2xl p-5 border border-slate-800 shadow-2xl flex flex-col items-center space-y-4 animate-fade-in-scaled',
              events: {
                'click': (e) => e.stopPropagation(),
              },
              [
                div(
                  classes:
                      'w-full flex items-center justify-between text-white pb-3 border-b border-slate-800',
                  [
                    div(classes: 'flex items-center space-x-2.5 min-w-0', [
                      div(
                        classes:
                            'w-8 h-8 rounded-xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center border border-emerald-500/30 shrink-0',
                        [const AppIcon(AppIcons.customer)],
                      ),
                      div(classes: 'min-w-0 flex-1', [
                        h4(classes: 'font-extrabold text-sm leading-tight text-white truncate', [
                          Component.text(user.fullname ?? 'Provider Profile Photo'),
                        ]),
                        span(classes: 'text-[11px] text-slate-400 block font-medium', [
                          Component.text('Provider Selfie Verification'),
                        ]),
                      ]),
                    ]),
                    div(classes: 'flex items-center space-x-2 shrink-0', [
                      a(
                        href: activeSelfieUrl,
                        target: Target.blank,
                        classes:
                            'text-xs font-bold text-emerald-400 hover:text-emerald-300 px-3 py-1.5 rounded-xl bg-emerald-950/60 border border-emerald-800/60 transition-colors flex items-center gap-1 cursor-pointer',
                        [Component.text('Open original ↗')],
                      ),
                      button(
                        type: ButtonType.button,
                        events: {
                          'click': (_) => setState(() => isViewingFullPicture = false),
                        },
                        classes:
                            'w-8 h-8 rounded-full bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white flex items-center justify-center text-xs font-bold border-none cursor-pointer transition-colors',
                        [Component.text('✕')],
                      ),
                    ]),
                  ],
                ),
                div(classes: 'w-full flex items-center justify-center p-1 overflow-hidden', [
                  img(
                    src: activeSelfieUrl,
                    alt: user.fullname ?? 'Provider Selfie',
                    classes:
                        'max-h-[70vh] w-auto max-w-full rounded-xl object-contain shadow-2xl border border-slate-800',
                  ),
                ]),
              ],
            ),
          ],
        ),
    ]);
  }

  Component _buildDetailedSection(BuildContext context, String userId) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;
    final detailAsync = context.watch(adminUserDetailProvider(userId));

    return detailAsync.when(
      data: (detail) {
        if (detail == null) {
          return div(
            classes:
                'p-5 rounded-2xl border text-center font-semibold space-y-1',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              color: Color(colorScheme.textMuted),
              raw: {'border-color': colorScheme.border},
            ),
            [
              div(
                classes: 'text-lg',
                styles: Styles(color: Color(colorScheme.primary)),
                [Component.text('ℹ')],
              ),
              p([Component.text('No detailed metadata records returned for this user.')]),
            ],
          );
        }

        final stats = detail.stats;
        final customer = detail.customerProfile;
        final provider = detail.providerProfile;
        final location = detail.location;
        final payment = detail.paymentAccount;

        return div(classes: 'space-y-6', [
          // ─────────────────────────────────────────────────────────
          // Verification & Security Section
          // ─────────────────────────────────────────────────────────
          div(classes: 'space-y-3', [
            _buildSectionHeader('Verification & Security', AppIcons.kyc, context),
            div(
              classes: 'grid grid-cols-1 sm:grid-cols-2 gap-3',
              [
                _buildVerificationBadge(context, 'Email Verification', detail.emailVerified == true),
                _buildVerificationBadge(context, 'Phone Verification', detail.phoneVerified == true),
              ],
            ),
          ]),

          // ─────────────────────────────────────────────────────────
          // Performance Statistics Section
          // ─────────────────────────────────────────────────────────
          if (stats != null) ...[
            div(classes: 'space-y-3', [
              _buildSectionHeader('Performance Statistics', AppIcons.analytics, context),
              div(classes: 'grid grid-cols-2 sm:grid-cols-3 gap-3', [
                _buildPerformanceKpiCard(
                  context,
                  title: 'Credibility',
                  value: '${stats.credibilityScore ?? 0}',
                  subtitle: 'Trust Score',
                  icon: AppIcons.guarantors,
                  gradient: 'from-emerald-500/15 via-teal-500/5 to-transparent',
                  badgeBg: isDark ? Color.rgba(16, 185, 129, 0.2) : Color.rgba(16, 185, 129, 0.12),
                  badgeTextColor: isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0),
                  borderColor: 'rgba(16, 185, 129, 0.3)',
                ),
                _buildPerformanceKpiCard(
                  context,
                  title: 'Rating',
                  value: '★ ${(stats.averageRatings ?? 0.0).toStringAsFixed(1)}',
                  subtitle: 'User Reviews',
                  icon: AppIcons.salesTag,
                  gradient: 'from-amber-500/15 via-orange-500/5 to-transparent',
                  badgeBg: isDark ? Color.rgba(245, 158, 11, 0.2) : Color.rgba(245, 158, 11, 0.12),
                  badgeTextColor: isDark ? Color.rgba(252, 211, 77, 1.0) : Color.rgba(180, 83, 9, 1.0),
                  borderColor: 'rgba(245, 158, 11, 0.3)',
                ),
                _buildPerformanceKpiCard(
                  context,
                  title: 'Completed',
                  value: '${stats.totalTasksCompleted ?? 0}',
                  subtitle: 'Jobs Done',
                  icon: AppIcons.tasks,
                  gradient: 'from-blue-500/15 via-indigo-500/5 to-transparent',
                  badgeBg: isDark ? Color.rgba(59, 130, 246, 0.2) : Color.rgba(59, 130, 246, 0.12),
                  badgeTextColor: isDark ? Color.rgba(147, 197, 253, 1.0) : Color.rgba(29, 78, 216, 1.0),
                  borderColor: 'rgba(59, 130, 246, 0.3)',
                ),
                _buildPerformanceKpiCard(
                  context,
                  title: 'Posted',
                  value: '${stats.totalTasksPosted ?? 0}',
                  subtitle: 'Tasks Created',
                  icon: AppIcons.ordersDoc,
                  gradient: 'from-purple-500/15 via-violet-500/5 to-transparent',
                  badgeBg: isDark ? Color.rgba(168, 85, 247, 0.2) : Color.rgba(168, 85, 247, 0.12),
                  badgeTextColor: isDark ? Color.rgba(216, 180, 254, 1.0) : Color.rgba(126, 34, 206, 1.0),
                  borderColor: 'rgba(168, 85, 247, 0.3)',
                ),
                _buildPerformanceKpiCard(
                  context,
                  title: '30d Rate',
                  value: '${stats.completionRate30d ?? 0}%',
                  subtitle: 'Recent Activity',
                  icon: AppIcons.chartGrowth,
                  gradient: 'from-cyan-500/15 via-sky-500/5 to-transparent',
                  badgeBg: isDark ? Color.rgba(6, 182, 212, 0.2) : Color.rgba(6, 182, 212, 0.12),
                  badgeTextColor: isDark ? Color.rgba(103, 232, 249, 1.0) : Color.rgba(14, 116, 144, 1.0),
                  borderColor: 'rgba(6, 182, 212, 0.3)',
                ),
                _buildPerformanceKpiCard(
                  context,
                  title: 'Current Tier',
                  value: 'Tier ${stats.currentTier ?? 1}',
                  subtitle: 'Account Status',
                  icon: AppIcons.overview,
                  gradient: 'from-rose-500/15 via-pink-500/5 to-transparent',
                  badgeBg: isDark ? Color.rgba(244, 63, 94, 0.2) : Color.rgba(244, 63, 94, 0.12),
                  badgeTextColor: isDark ? Color.rgba(253, 164, 175, 1.0) : Color.rgba(190, 18, 60, 1.0),
                  borderColor: 'rgba(244, 63, 94, 0.3)',
                ),
              ]),
            ]),
          ],

          // ─────────────────────────────────────────────────────────
          // Profile Details Card
          // ─────────────────────────────────────────────────────────
          if (customer != null || provider != null) ...[
            div(classes: 'space-y-3', [
              _buildSectionHeader('Profile Information', AppIcons.customer, context),
              div(
                classes:
                    'p-4 border rounded-2xl space-y-3 shadow-sm',
                styles: Styles(
                  backgroundColor: Color(colorScheme.surface),
                  raw: {'border-color': colorScheme.border},
                ),
                [
                  if (customer != null) ...[
                    _buildProfileRow(context, 'First Name', customer.firstName ?? 'N/A'),
                    _buildProfileRow(context, 'Last Name', customer.lastName ?? 'N/A'),
                    if (customer.addressLine != null && customer.addressLine!.isNotEmpty)
                      _buildProfileRow(context, 'Address', customer.addressLine!),
                  ],
                  if (provider != null) ...[
                    _buildProfileRow(context, 'Gender', provider.gender ?? 'N/A'),
                    _buildBadgeRow(context, 'KYC Status', provider.kycStatus ?? 'NOT_SUBMITTED'),
                    _buildBadgeRow(context, 'Duty Status', provider.dutyStatus ?? 'OFFLINE'),
                    _buildBadgeRow(context, 'Is Online', provider.isOnline == true ? 'ONLINE' : 'OFFLINE'),
                  ],
                ],
              ),
            ]),
          ],

          // ─────────────────────────────────────────────────────────
          // Location Data Section
          // ─────────────────────────────────────────────────────────
          if (location != null) ...[
            div(classes: 'space-y-3', [
              _buildSectionHeader('Location Data', AppIcons.overview, context),
              div(
                classes:
                    'p-4 border rounded-2xl space-y-2.5 shadow-sm',
                styles: Styles(
                  backgroundColor: Color(colorScheme.surface),
                  raw: {'border-color': colorScheme.border},
                ),
                [
                  _buildProfileRow(context, 'Address', location.addressLine ?? 'N/A'),
                  _buildProfileRow(
                    context,
                    'Coordinates',
                    '${location.latitude ?? 0}, ${location.longitude ?? 0}',
                  ),
                ],
              ),
            ]),
          ],

          // ─────────────────────────────────────────────────────────
          // Payment Account Section
          // ─────────────────────────────────────────────────────────
          if (payment != null) ...[
            div(classes: 'space-y-3', [
              _buildSectionHeader('Payment Account', AppIcons.transaction, context),
              div(
                classes:
                    'p-4 border rounded-2xl space-y-2.5 shadow-sm',
                styles: Styles(
                  backgroundColor: Color(colorScheme.surface),
                  raw: {'border-color': colorScheme.border},
                ),
                [
                  _buildProfileRow(context, 'Provider', payment.provider ?? 'N/A'),
                  _buildProfileRow(context, 'Account Name', payment.accountName ?? 'N/A'),
                  _buildCopyableRow(context, 'External ID', payment.externalAccountId ?? 'N/A'),
                ],
              ),
            ]),
          ],
        ]);
      },
      loading: () => div(classes: 'space-y-4 py-2 animate-pulse', [
        for (var i = 0; i < 3; i++)
          div(
            classes:
                'h-24 rounded-2xl border p-4 space-y-2',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              raw: {'border-color': colorScheme.border},
            ),
            [
              div(
                classes: 'w-1/3 h-4 rounded',
                styles: Styles(backgroundColor: Color(colorScheme.inputBg)),
                [],
              ),
              div(
                classes: 'w-full h-8 rounded-xl',
                styles: Styles(backgroundColor: Color(colorScheme.inputBg)),
                [],
              ),
            ],
          ),
      ]),
      error: (err, stack) => div(
        classes:
            'p-4 rounded-2xl border text-center text-xs font-bold',
        styles: Styles(
          backgroundColor: isDark ? Color.rgba(244, 63, 94, 0.15) : Color.rgba(244, 63, 94, 0.08),
          color: isDark ? Color.rgba(253, 164, 175, 1.0) : Color.rgba(190, 18, 60, 1.0),
          raw: {'border-color': isDark ? 'rgba(244, 63, 94, 0.35)' : 'rgba(244, 63, 94, 0.25)'},
        ),
        [
          Component.text('Failed to fetch detailed user records: $err'),
        ],
      ),
    );
  }

  Component _buildSectionHeader(String title, AppIcons icon, BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;

    return div(classes: 'flex items-center space-x-2.5 pt-1', [
      div(
        classes:
            'w-7 h-7 rounded-lg flex items-center justify-center shrink-0 border shadow-sm',
        styles: Styles(
          backgroundColor: isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1),
          color: Color(colorScheme.primary),
          raw: {'border-color': isDark ? 'rgba(16, 185, 129, 0.35)' : 'rgba(16, 185, 129, 0.2)'},
        ),
        [
          div(
            classes: 'w-4 h-4',
            styles: Styles(color: Color(colorScheme.primary)),
            [AppIcon(icon)],
          ),
        ],
      ),
      h5(
        classes:
            'font-black uppercase text-[11px] tracking-wider',
        styles: Styles(color: Color(colorScheme.textHeading)),
        [Component.text(title)],
      ),
    ]);
  }

  Component _buildInfoRow(BuildContext context, String label, String value) {
    final colorScheme = context.colorScheme;

    return div(classes: 'px-4 py-3.5 flex items-center justify-between text-xs', [
      span(
        classes: 'font-semibold',
        styles: Styles(color: Color(colorScheme.textMuted)),
        [Component.text(label)],
      ),
      span(
        classes: 'font-bold font-mono text-xs tracking-tight shrink-0',
        styles: Styles(color: Color(colorScheme.textHeading)),
        [Component.text(value)],
      ),
    ]);
  }

  Component _buildCopyableRow(
      BuildContext context, String label, String value) {
    final colorScheme = context.colorScheme;
    final isLong = value.length > 22;
    final displayValue =
        isLong ? '${value.substring(0, 8)}...${value.substring(value.length - 6)}' : value;

    return div(classes: 'px-4 py-3.5 flex items-center justify-between text-xs', [
      span(
        classes: 'font-semibold shrink-0 mr-2',
        styles: Styles(color: Color(colorScheme.textMuted)),
        [Component.text(label)],
      ),
      div(classes: 'flex items-center space-x-2 shrink-0', [
        span(
          classes: 'font-bold font-mono text-xs tracking-tight',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text(displayValue)],
        ),
        if (value != 'N/A' && value.isNotEmpty)
          button(
            type: ButtonType.button,
            classes:
                'px-2 py-1 rounded-lg text-[10.5px] font-bold border transition-all cursor-pointer flex items-center gap-1 active:scale-95 shadow-sm',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.primary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            events: {
              'click': (_) => _copyToClipboard(context, value, label),
            },
            [
              div(
                classes: 'w-3 h-3',
                styles: Styles(color: Color(colorScheme.primary)),
                [
                  const AppIcon(AppIcons.copy),
                ],
              ),
            ],
          ),
      ]),
    ]);
  }

  Component _buildVerificationBadge(BuildContext context, String label, bool isVerified) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;

    return div(
      classes:
          'p-4 rounded-2xl border flex items-center justify-between shadow-sm',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'space-y-0.5', [
          span(
            classes: 'font-bold text-xs block',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [Component.text(label)],
          ),
          span(
            classes: 'text-[10.5px] block font-medium',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text(isVerified ? 'Verified Account Record' : 'Unverified Status')],
          ),
        ]),
        span(
          classes:
              'px-3 py-1.5 rounded-xl text-[11px] font-black border shadow-sm flex items-center gap-1.5',
          styles: isVerified
              ? Styles(
                  backgroundColor: isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1),
                  color: isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0),
                  raw: {'border-color': isDark ? 'rgba(16, 185, 129, 0.4)' : 'rgba(16, 185, 129, 0.25)'},
                )
              : Styles(
                  backgroundColor: isDark ? Color.rgba(244, 63, 94, 0.18) : Color.rgba(244, 63, 94, 0.1),
                  color: isDark ? Color.rgba(253, 164, 175, 1.0) : Color.rgba(190, 18, 60, 1.0),
                  raw: {'border-color': isDark ? 'rgba(244, 63, 94, 0.4)' : 'rgba(244, 63, 94, 0.25)'},
                ),
          [
            div(
              classes: 'w-3.5 h-3.5',
              styles: isVerified
                  ? Styles(color: isDark ? Color.rgba(52, 211, 153, 1.0) : Color.rgba(4, 120, 87, 1.0))
                  : Styles(color: isDark ? Color.rgba(251, 113, 133, 1.0) : Color.rgba(190, 18, 60, 1.0)),
              [AppIcon(isVerified ? AppIcons.checkCircle : AppIcons.disputes)],
            ),
            Component.text(isVerified ? 'Verified' : 'Pending'),
          ],
        ),
      ],
    );
  }

  Component _buildPerformanceKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required AppIcons icon,
    required String gradient,
    required Color badgeBg,
    required Color badgeTextColor,
    required String borderColor,
  }) {
    final colorScheme = context.colorScheme;

    return div(
      classes:
          'p-4 rounded-2xl border flex flex-col justify-between space-y-3 shadow-sm hover:shadow-md transition-all group relative overflow-hidden',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.borderInput},
      ),
      [
        // Background gradient overlay
        div(
          classes:
              'absolute inset-0 bg-gradient-to-br $gradient pointer-events-none opacity-70',
          [],
        ),
        // Decorative top right corner radial glow accent
        div(
          classes:
              'absolute top-0 right-0 w-16 h-16 rounded-bl-full bg-gradient-to-bl $gradient opacity-50 pointer-events-none',
          [],
        ),
        div(classes: 'relative space-y-2.5', [
          div(classes: 'flex items-center justify-between gap-1', [
            span(
              classes:
                  'text-[10.5px] font-extrabold uppercase tracking-wider block truncate',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text(title)],
            ),
            div(
              classes:
                  'w-8 h-8 rounded-xl border flex items-center justify-center shrink-0 shadow-xs transition-transform group-hover:scale-110',
              styles: Styles(
                backgroundColor: badgeBg,
                color: badgeTextColor,
                raw: {'border-color': borderColor},
              ),
              [
                div(
                  classes: 'w-4 h-4',
                  [AppIcon(icon)],
                ),
              ],
            ),
          ]),
          div(classes: 'space-y-0.5', [
            span(
              classes:
                  'text-lg sm:text-xl font-black block tracking-tight truncate group-hover:translate-x-0.5 transition-transform',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text(value)],
            ),
            span(
              classes: 'text-[10px] font-semibold block opacity-75 truncate',
              styles: Styles(color: Color(colorScheme.textSecondary)),
              [Component.text(subtitle)],
            ),
          ]),
        ]),
      ],
    );
  }

  Component _buildProfileRow(BuildContext context, String label, String value) {
    final colorScheme = context.colorScheme;

    return div(classes: 'flex items-start justify-between text-xs py-2 px-1 gap-4', [
      span(
        classes: 'font-semibold shrink-0 text-left min-w-[80px]',
        styles: Styles(color: Color(colorScheme.textMuted)),
        [Component.text(label)],
      ),
      span(
        classes: 'font-bold text-right flex-1 break-words leading-snug',
        styles: Styles(color: Color(colorScheme.textHeading)),
        [Component.text(value)],
      ),
    ]);
  }

  Component _buildBadgeRow(BuildContext context, String label, String status) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;

    Styles badgeStyles;
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'ONLINE':
      case 'ACTIVE':
      case 'ONLINE_AVAILABLE':
        badgeStyles = Styles(
          backgroundColor: isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1),
          color: isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0),
          raw: {'border-color': isDark ? 'rgba(16, 185, 129, 0.4)' : 'rgba(16, 185, 129, 0.25)'},
        );
        break;
      case 'PENDING_SUBMISSION':
      case 'SUBMITTED':
      case 'PENDING':
        badgeStyles = Styles(
          backgroundColor: isDark ? Color.rgba(245, 158, 11, 0.18) : Color.rgba(245, 158, 11, 0.1),
          color: isDark ? Color.rgba(253, 230, 138, 1.0) : Color.rgba(180, 83, 9, 1.0),
          raw: {'border-color': isDark ? 'rgba(245, 158, 11, 0.4)' : 'rgba(245, 158, 11, 0.25)'},
        );
        break;
      case 'REJECTED':
      case 'OFFLINE':
      default:
        badgeStyles = Styles(
          backgroundColor: Color(colorScheme.inputBg),
          color: Color(colorScheme.textSecondary),
          raw: {'border-color': colorScheme.borderInput},
        );
        break;
    }

    return div(classes: 'flex items-center justify-between text-xs py-1.5 px-1 gap-4', [
      span(
        classes: 'font-semibold shrink-0',
        styles: Styles(color: Color(colorScheme.textMuted)),
        [Component.text(label)],
      ),
      span(
        classes:
            'px-2.5 py-1 rounded-lg text-[10.5px] font-black border uppercase tracking-wider shrink-0',
        styles: badgeStyles,
        [Component.text(status)],
      ),
    ]);
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// User Activation / Deactivation Dialog Component
// ─────────────────────────────────────────────────────────────

class _UpdateUserStatusDialog extends StatefulComponent {
  final String userId;
  final String userName;
  final bool isCurrentlyActive;

  const _UpdateUserStatusDialog({
    required this.userId,
    required this.userName,
    required this.isCurrentlyActive,
  });

  static void show(
    BuildContext context, {
    required String userId,
    required String userName,
    required bool isCurrentlyActive,
  }) {
    context.showDialog(
      _UpdateUserStatusDialog(
        userId: userId,
        userName: userName,
        isCurrentlyActive: isCurrentlyActive,
      ),
      title: isCurrentlyActive ? 'Deactivate User Account' : 'Activate User Account',
    );
  }

  @override
  State<_UpdateUserStatusDialog> createState() => _UpdateUserStatusDialogState();
}

class _UpdateUserStatusDialogState extends State<_UpdateUserStatusDialog> {
  String _reason = '';
  bool _isSubmitting = false;
  String? _errorMessage;

  void _handleSubmit(BuildContext context) {
    if (_reason.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a reason note for this account status change.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final body = AdminUserStatusUpdateBody(reason: _reason.trim());

    if (component.isCurrentlyActive) {
      context.read(adminUserManagementProvider.notifier).deactivateUser(
        component.userId,
        body,
        onSuccess: () {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          context.showFlushbar(
            title: 'User Deactivated',
            message: 'User account has been deactivated successfully.',
            type: FlushbarType.success,
          );
          context.invalidate(adminUserDetailProvider(component.userId));
          context.invalidate(adminUsersProvider(const GetUsersParams()));
          context.invalidate(adminUserStatsProvider);
          context.hideDialog();
        },
        onError: (message) {
          if (!mounted) return;
          setState(() {
            _isSubmitting = false;
            _errorMessage = message;
          });
        },
      );
    } else {
      context.read(adminUserManagementProvider.notifier).activateUser(
        component.userId,
        body,
        onSuccess: () {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          context.showFlushbar(
            title: 'User Activated',
            message: 'User account has been activated successfully.',
            type: FlushbarType.success,
          );
          context.invalidate(adminUserDetailProvider(component.userId));
          context.invalidate(adminUsersProvider(const GetUsersParams()));
          context.invalidate(adminUserStatsProvider);
          context.hideDialog();
        },
        onError: (message) {
          if (!mounted) return;
          setState(() {
            _isSubmitting = false;
            _errorMessage = message;
          });
        },
      );
    }
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDeactivating = component.isCurrentlyActive;

    return div(classes: 'space-y-4 text-xs max-w-lg w-full', [
      // Banner
      div(
        classes: 'p-3.5 rounded-xl border flex items-start space-x-3 text-xs',
        styles: isDeactivating
            ? Styles(
                backgroundColor: Color.rgba(244, 63, 94, 0.1),
                color: Color.rgba(225, 29, 72, 1.0),
                raw: {'border-color': 'rgba(244, 63, 94, 0.3)'},
              )
            : Styles(
                backgroundColor: Color.rgba(16, 185, 129, 0.1),
                color: Color.rgba(4, 120, 87, 1.0),
                raw: {'border-color': 'rgba(16, 185, 129, 0.3)'},
              ),
        [
          div(
            classes: 'w-4 h-4 shrink-0 mt-0.5',
            [AppIcon(isDeactivating ? AppIcons.disputes : AppIcons.checkCircle)],
          ),
          div(classes: 'space-y-0.5 min-w-0 flex-1', [
            h5(classes: 'font-bold text-xs', [
              Component.text(
                isDeactivating
                    ? 'Deactivating Account: ${component.userName}'
                    : 'Activating Account: ${component.userName}',
              ),
            ]),
            p(classes: 'text-[11px] opacity-90 leading-snug', [
              Component.text(
                isDeactivating
                    ? 'Deactivating this account will restrict the user from accessing platform features, requesting services, or managing tasks.'
                    : 'Activating this account will restore full access to platform features and services.',
              ),
            ]),
          ]),
        ],
      ),

      // Error Banner
      if (_errorMessage != null)
        div(
          classes:
              'p-3 rounded-xl border flex items-center space-x-2 text-xs font-semibold animate-shake',
          styles: Styles(
            backgroundColor: Color.rgba(244, 63, 94, 0.1),
            color: Color.rgba(225, 29, 72, 1.0),
            raw: {'border-color': 'rgba(244, 63, 94, 0.3)'},
          ),
          [
            const AppIcon(AppIcons.infoCircle),
            span([Component.text(_errorMessage!)]),
          ],
        ),

      // Reason / Notes Input Field
      div(classes: 'space-y-1.5', [
        label(
          classes: 'block text-xs font-bold uppercase tracking-wider',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Reason / Administrative Notes *')],
        ),
        textarea(
          classes:
              'w-full border rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:ring-2 transition-all resize-none min-h-[100px]',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textPrimary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          attributes: {
            'placeholder': isDeactivating
                ? 'e.g. Violation of terms, suspicious account activity, requested by user...'
                : 'e.g. Identity verification completed, issue resolved, manual admin override...',
            'value': _reason,
          },
          onInput: (val) => setState(() {
            _reason = val.toString();
            _errorMessage = null;
          }),
          [],
        ),
      ]),

      // Dialog Actions
      div(
        classes: 'flex items-center justify-end space-x-3 pt-4 border-t',
        styles: Styles(raw: {'border-color': colorScheme.border}),
        [
          button(
            type: ButtonType.button,
            onClick: () => context.hideDialog(),
            classes:
                'px-4 py-2.5 rounded-xl border text-xs font-bold transition-all cursor-pointer hover:opacity-80',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [Component.text('Cancel')],
          ),
          button(
            type: ButtonType.button,
            onClick: () => _handleSubmit(context),
            disabled: _isSubmitting,
            classes: isDeactivating
                ? 'px-5 py-2.5 rounded-xl text-white text-xs font-bold shadow-md transition-all cursor-pointer border-none flex items-center space-x-2 bg-rose-600 hover:bg-rose-700 ${_isSubmitting ? 'opacity-60 cursor-not-allowed' : 'active:scale-95'}'
                : 'px-5 py-2.5 rounded-xl text-white text-xs font-bold shadow-md transition-all cursor-pointer border-none flex items-center space-x-2 bg-emerald-600 hover:bg-emerald-700 ${_isSubmitting ? 'opacity-60 cursor-not-allowed' : 'active:scale-95'}',
            [
              if (_isSubmitting)
                div(
                  classes:
                      'w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin',
                  [],
                )
              else
                AppIcon(isDeactivating ? AppIcons.disputes : AppIcons.checkCircle),
              span([
                Component.text(
                  _isSubmitting
                      ? (isDeactivating ? 'Deactivating...' : 'Activating...')
                      : (isDeactivating ? 'Deactivate User' : 'Activate User'),
                ),
              ]),
            ],
          ),
        ],
      ),
    ]);
  }
}
