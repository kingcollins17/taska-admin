import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/users/admin_platform_user_item.dart';
import '../core/providers/admin_user_providers.dart';
import '../core/providers/ui_state_provider.dart';

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
                  classes: user.isActive == true
                      ? 'w-3.5 h-3.5 rounded-full ring-4 absolute -bottom-1 -right-1 shadow-sm'
                      : 'w-3.5 h-3.5 rounded-full ring-4 absolute -bottom-1 -right-1 shadow-sm',
                  styles: user.isActive == true
                      ? Styles(
                          backgroundColor: Color.rgba(52, 211, 153, 1.0),
                          raw: {'ring-color': colorScheme.surface},
                        )
                      : Styles(
                          backgroundColor: Color.rgba(148, 163, 184, 1.0),
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

          // Badges & Copy ID Action Row
          div(
            classes:
                'flex flex-wrap items-center justify-between gap-2.5 pt-3.5 border-t',
            styles: Styles(raw: {'border-color': colorScheme.border}),
            [
              div(classes: 'flex items-center space-x-2', [
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
                  styles: user.isActive == true
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
                    Component.text(user.isActive == true ? '● Active' : '○ Inactive'),
                  ],
                ),
              ]),

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
                _buildStatCard(context, 'Credibility', '${stats.credibilityScore ?? 0}', icon: AppIcons.guarantors),
                _buildStatCard(context, 'Rating', '★ ${stats.averageRatings ?? 0}', icon: AppIcons.salesTag),
                _buildStatCard(context, 'Completed', '${stats.totalTasksCompleted ?? 0}', icon: AppIcons.tasks),
                _buildStatCard(context, 'Posted', '${stats.totalTasksPosted ?? 0}', icon: AppIcons.ordersDoc),
                _buildStatCard(context, '30d Rate', '${stats.completionRate30d ?? 0}%', icon: AppIcons.chartGrowth),
                _buildStatCard(context, 'Current Tier', 'Tier ${stats.currentTier ?? 1}', icon: AppIcons.overview),
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

  Component _buildStatCard(BuildContext context, String label, String value, {AppIcons? icon}) {
    final colorScheme = context.colorScheme;

    return div(
      classes:
          'p-4 rounded-2xl border space-y-2 shadow-sm transition-all flex flex-col justify-between relative overflow-hidden',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'flex items-center justify-between gap-1', [
          span(
            classes: 'text-[10.5px] font-black uppercase tracking-wider block truncate',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text(label)],
          ),
          if (icon != null)
            div(
              classes: 'w-4 h-4 shrink-0',
              styles: Styles(color: Color(colorScheme.primary)),
              [AppIcon(icon)],
            ),
        ]),
        span(
          classes: 'text-lg sm:text-xl font-black block tracking-tight mt-1',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text(value)],
        ),
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
