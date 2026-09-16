import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/vetting/admin_guarantor_item.dart';
import '../core/providers/admin_user_providers.dart';
import '../core/providers/ui_state_provider.dart';

class GuarantorDetailSidePanel extends StatefulComponent {
  final AdminGuarantorItem guarantor;

  const GuarantorDetailSidePanel({
    required this.guarantor,
    super.key,
  });

  static void show(BuildContext context, AdminGuarantorItem guarantor) {
    context.showSidePanel(
      GuarantorDetailSidePanel(guarantor: guarantor),
      title: 'Guarantor Record Details',
    );
  }

  @override
  State<GuarantorDetailSidePanel> createState() => _GuarantorDetailSidePanelState();
}

class _GuarantorDetailSidePanelState extends State<GuarantorDetailSidePanel> {
  bool isRejecting = false;
  String rejectionNotes = '';
  bool isSubmittingAction = false;
  String? currentStatusOverride;

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

  Future<void> _handleVerify(BuildContext context) async {
    final guarantorId = component.guarantor.id;
    if (guarantorId == null || guarantorId.isEmpty) {
      context.showFlushbar(
        title: 'Error',
        message: 'No guarantor ID found',
        type: FlushbarType.error,
      );
      return;
    }

    setState(() {
      isSubmittingAction = true;
    });

    final notifier = context.read(adminUserManagementProvider.notifier);
    await notifier.approveGuarantor(
      guarantorId,
      notes: 'Approved by admin',
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          isSubmittingAction = false;
          currentStatusOverride = 'PASSED';
          isRejecting = false;
        });
        context.showFlushbar(
          title: 'Guarantor Approved',
          message: 'Guarantor record #${_formatId(guarantorId)} has been approved successfully.',
          type: FlushbarType.success,
        );
      },
      onError: (errorMsg) {
        if (!mounted) return;
        setState(() {
          isSubmittingAction = false;
        });
        context.showFlushbar(
          title: 'Approval Failed',
          message: errorMsg,
          type: FlushbarType.error,
        );
      },
    );
  }

  Future<void> _handleReject(BuildContext context) async {
    final guarantorId = component.guarantor.id;
    if (guarantorId == null || guarantorId.isEmpty) {
      context.showFlushbar(
        title: 'Error',
        message: 'No guarantor ID found',
        type: FlushbarType.error,
      );
      return;
    }

    if (rejectionNotes.trim().isEmpty) {
      context.showFlushbar(
        title: 'Reason Required',
        message: 'Please specify a reason for rejecting this guarantor reference.',
        type: FlushbarType.warning,
      );
      return;
    }

    setState(() {
      isSubmittingAction = true;
    });

    final notifier = context.read(adminUserManagementProvider.notifier);
    await notifier.rejectGuarantor(
      guarantorId,
      reason: rejectionNotes.trim(),
      notes: rejectionNotes.trim(),
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          isSubmittingAction = false;
          currentStatusOverride = 'FAILED';
          isRejecting = false;
        });
        context.showFlushbar(
          title: 'Guarantor Rejected',
          message: 'Guarantor record #${_formatId(guarantorId)} has been rejected.',
          type: FlushbarType.error,
        );
      },
      onError: (errorMsg) {
        if (!mounted) return;
        setState(() {
          isSubmittingAction = false;
        });
        context.showFlushbar(
          title: 'Rejection Failed',
          message: errorMsg,
          type: FlushbarType.error,
        );
      },
    );
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final guarantor = component.guarantor;
    final displayStatus = currentStatusOverride ?? guarantor.status ?? 'UNKNOWN';
    final providerId = guarantor.providerId;

    return div(classes: 'space-y-6 text-xs pb-8', [
      // ─────────────────────────────────────────────────────────────
      // Hero Guarantor Card
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
              img(
                src:
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(guarantor.guarantorName ?? 'Guarantor')}&background=0D9488&color=fff&bold=true',
                classes: 'w-14 h-14 rounded-2xl object-cover border-2 shadow-md shrink-0',
                styles: Styles(raw: {'border-color': 'rgba(16, 185, 129, 0.4)'}),
                alt: guarantor.guarantorName ?? 'Guarantor',
              ),
              div(classes: 'space-y-1 min-w-0 flex-1', [
                h4(
                  classes: 'font-black text-base truncate tracking-tight',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text(guarantor.guarantorName ?? 'N/A')],
                ),
                div(
                  classes: 'flex items-center space-x-2 text-xs font-mono',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  [
                    span(classes: 'truncate font-medium', [
                      Component.text(guarantor.guarantorPhone ?? 'No Phone Provided'),
                    ]),
                    if (guarantor.guarantorPhone != null && guarantor.guarantorPhone!.isNotEmpty)
                      button(
                        type: ButtonType.button,
                        onClick: () => _copyToClipboard(context, guarantor.guarantorPhone!, 'Phone Number'),
                        classes: 'p-0.5 hover:text-emerald-500 transition-colors border-none bg-transparent cursor-pointer',
                        styles: Styles(color: Color(colorScheme.textMuted)),
                        [
                          div(classes: 'w-3.5 h-3.5', [const AppIcon(AppIcons.copy)]),
                        ],
                      ),
                  ],
                ),
              ]),
            ]),
            _buildBadgePill(displayStatus, colorScheme),
          ]),

          // Relationship & Metadata Details Grid
          div(
            classes: 'grid grid-cols-2 gap-3 pt-3 border-t',
            styles: Styles(raw: {'border-color': colorScheme.border}),
            [
              _buildMetaTile(context, 'Guarantor ID', _formatId(guarantor.id), isCopyable: true, rawValue: guarantor.id),
              _buildMetaTile(context, 'Relationship', guarantor.relationship ?? 'N/A'),
              _buildMetaTile(context, 'Provider ID', _formatId(guarantor.providerId), isCopyable: true, rawValue: guarantor.providerId),
              _buildMetaTile(context, 'Created At', _formatDate(guarantor.createdAt)),
              if (guarantor.verifiedAt != null && guarantor.verifiedAt!.isNotEmpty)
                _buildMetaTile(context, 'Verified At', _formatDate(guarantor.verifiedAt), isFullWidth: true),
            ],
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // Provider User Information (Via adminUserDetailProvider)
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3', [
        _buildSectionHeader('Associated Provider User', AppIcons.customer, context),
        if (providerId != null && providerId.isNotEmpty)
          _buildUserDetailCard(context, providerId)
        else
          div(
            classes: 'p-4 rounded-2xl border text-center font-medium text-slate-400',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              raw: {'border-color': colorScheme.border},
            ),
            [Component.text('No provider ID associated with this guarantor record.')],
          ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Actions: Verify & Reject Section
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3 pt-2', [
        _buildSectionHeader('Guarantor Verification Actions', AppIcons.guarantors, context),
        div(
          classes: 'p-5 rounded-2xl border space-y-4 shadow-sm transition-all',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            if (isSubmittingAction)
              div(classes: 'py-6 text-center space-y-2 animate-pulse', [
                span(
                  classes: 'text-xs font-bold',
                  styles: Styles(color: Color(colorScheme.primary)),
                  [Component.text('Processing guarantor verification update...')],
                ),
              ])
            else if (displayStatus == 'PASSED' || displayStatus == 'VERIFIED')
              div(
                classes:
                    'p-4 rounded-xl bg-emerald-50 dark:bg-emerald-950/40 border border-emerald-200 dark:border-emerald-800 text-emerald-700 dark:text-emerald-300 font-semibold flex items-center space-x-2',
                [
                  const AppIcon(AppIcons.checkCircle),
                  span([Component.text('This guarantor reference is verified and passed.')]),
                ],
              )
            else if (!isRejecting) ...[
              div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-3', [
                button(
                  type: ButtonType.button,
                  onClick: () => _handleVerify(context),
                  classes:
                      'w-full py-2.5 px-4 rounded-xl text-white font-bold text-xs shadow-md transition-all cursor-pointer flex items-center justify-center space-x-2 active:scale-98',
                  styles: Styles(backgroundColor: Color('#059669')),
                  [
                    const AppIcon(AppIcons.checkCircle),
                    span([Component.text('Verify Guarantor')]),
                  ],
                ),
                button(
                  type: ButtonType.button,
                  onClick: () => setState(() => isRejecting = true),
                  classes:
                      'w-full py-2.5 px-4 rounded-xl text-white font-bold text-xs shadow-md transition-all cursor-pointer flex items-center justify-center space-x-2 active:scale-98',
                  styles: Styles(backgroundColor: Color('#E11D48')),
                  [
                    const AppIcon(AppIcons.disputes),
                    span([Component.text('Fail / Reject')]),
                  ],
                ),
              ]),
            ] else ...[
              // Expandable Rejection Notes Form
              div(classes: 'space-y-3 animate-fade-in', [
                div(classes: 'flex items-center justify-between', [
                  span(
                    classes: 'font-bold text-xs',
                    styles: Styles(color: Color(colorScheme.textHeading)),
                    [Component.text('Rejection Reason / Notes')],
                  ),
                  button(
                    type: ButtonType.button,
                    onClick: () => setState(() => isRejecting = false),
                    classes: 'text-[11px] font-bold text-slate-400 hover:underline cursor-pointer',
                    [Component.text('Cancel')],
                  ),
                ]),
                textarea(
                  classes:
                      'w-full border rounded-xl p-3 text-xs font-medium focus:outline-none focus:ring-2 transition-all h-24 resize-none',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.textPrimary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  attributes: {'placeholder': 'Specify why this guarantor verification failed (e.g., Unable to reach referee, invalid phone)...'},
                  onInput: (value) {
                    setState(() {
                      rejectionNotes = value.toString();
                    });
                  },
                  [],
                ),
                button(
                  type: ButtonType.button,
                  onClick: () => _handleReject(context),
                  classes:
                      'w-full py-2.5 px-4 rounded-xl text-white font-bold text-xs shadow-md transition-all cursor-pointer flex items-center justify-center space-x-2 active:scale-98',
                  styles: Styles(backgroundColor: Color('#E11D48')),
                  [
                    const AppIcon(AppIcons.disputes),
                    span([Component.text('Confirm Rejection')]),
                  ],
                ),
              ]),
            ],
          ],
        ),
      ]),
    ]);
  }

  // ─────────────────────────────────────────────────────────────
  // User Detail Card (watches adminUserDetailProvider)
  // ─────────────────────────────────────────────────────────────

  Component _buildUserDetailCard(BuildContext context, String providerId) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;
    final userDetailAsync = context.watch(adminUserDetailProvider(providerId));

    return userDetailAsync.when(
      data: (userDetail) {
        if (userDetail == null) {
          return div(
            classes: 'p-4 rounded-2xl border text-center font-medium',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              color: Color(colorScheme.textMuted),
              raw: {'border-color': colorScheme.border},
            ),
            [
              Component.text('Provider ID: ${_formatId(providerId)} (No detail profile available)'),
            ],
          );
        }

        final customer = userDetail.customerProfile;
        final provider = userDetail.providerProfile;
        String fullName = 'Provider User';
        if (provider != null && (provider.firstName != null || provider.lastName != null)) {
          fullName = '${provider.firstName ?? ''} ${provider.lastName ?? ''}'.trim();
        } else if (customer != null && (customer.firstName != null || customer.lastName != null)) {
          fullName = '${customer.firstName ?? ''} ${customer.lastName ?? ''}'.trim();
        } else if (userDetail.email != null && userDetail.email!.isNotEmpty) {
          fullName = userDetail.email!;
        }

        return div(
          classes: 'p-4 border rounded-2xl space-y-4 shadow-sm',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            div(classes: 'flex items-center space-x-3', [
              img(
                src:
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&background=0D9488&color=fff&bold=true',
                classes: 'w-11 h-11 rounded-2xl object-cover border shrink-0',
                styles: Styles(raw: {'border-color': colorScheme.borderInput}),
                alt: fullName,
              ),
              div(classes: 'space-y-0.5 flex-1 min-w-0', [
                div(classes: 'flex items-center space-x-2', [
                  h5(
                    classes: 'font-bold text-sm truncate tracking-tight',
                    styles: Styles(color: Color(colorScheme.textHeading)),
                    [Component.text(fullName)],
                  ),
                  span(
                    classes: 'px-2 py-0.5 rounded text-[10px] font-black uppercase tracking-wider border',
                    styles: userDetail.type == 'PROVIDER'
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
                    [Component.text(userDetail.type ?? 'PROVIDER')],
                  ),
                ]),
                p(
                  classes: 'text-xs font-mono truncate',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  [Component.text(userDetail.email ?? 'No email')],
                ),
              ]),
            ]),

            div(
              classes: 'grid grid-cols-2 gap-2.5 pt-3 border-t text-xs',
              styles: Styles(raw: {'border-color': colorScheme.borderInput}),
              [
                _buildUserRow('Phone', userDetail.phoneNumber ?? 'N/A', colorScheme),
                _buildUserRow('Provider ID', _formatId(userDetail.id), colorScheme),
                _buildUserRow('KYC Status', provider?.kycStatus ?? 'N/A', colorScheme),
                _buildUserRow('Duty Status', provider?.dutyStatus ?? 'OFFLINE', colorScheme),
              ],
            ),
          ],
        );
      },
      loading: () => div(
        classes: 'p-4 rounded-2xl border space-y-2 animate-pulse',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [
          div(classes: 'h-6 w-1/2 rounded', styles: Styles(backgroundColor: Color(colorScheme.inputBg)), []),
          div(classes: 'h-4 w-3/4 rounded', styles: Styles(backgroundColor: Color(colorScheme.inputBg)), []),
        ],
      ),
      error: (err, _) => div(
        classes: 'p-3 rounded-xl border text-xs text-rose-500 font-semibold',
        styles: Styles(raw: {'border-color': colorScheme.border}),
        [Component.text('Failed to load provider details: $err')],
      ),
    );
  }

  Component _buildUserRow(String label, String value, ColorScheme colorScheme) {
    return div([
      span(
        classes: 'text-[10.5px] font-bold block',
        styles: Styles(color: Color(colorScheme.textMuted)),
        [Component.text(label)],
      ),
      span(
        classes: 'font-semibold text-xs truncate block',
        styles: Styles(color: Color(colorScheme.textHeading)),
        [Component.text(value)],
      ),
    ]);
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────

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
        classes: 'font-black uppercase text-[11px] tracking-wider',
        styles: Styles(color: Color(colorScheme.textHeading)),
        [Component.text(title)],
      ),
    ]);
  }

  Component _buildMetaTile(
    BuildContext context,
    String label,
    String value, {
    bool isCopyable = false,
    String? rawValue,
    bool isFullWidth = false,
  }) {
    final colorScheme = context.colorScheme;

    return div(
      classes: isFullWidth ? 'col-span-2 space-y-0.5' : 'space-y-0.5',
      [
        span(
          classes: 'text-[10.5px] font-bold uppercase tracking-wider block',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text(label)],
        ),
        div(classes: 'flex items-center space-x-1.5', [
          span(
            classes: 'font-bold font-mono text-xs truncate',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [Component.text(value)],
          ),
          if (isCopyable && rawValue != null && rawValue.isNotEmpty)
            button(
              type: ButtonType.button,
              onClick: () => _copyToClipboard(context, rawValue, label),
              classes: 'p-1 hover:text-emerald-500 cursor-pointer transition-colors border-none bg-transparent',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [
                div(classes: 'w-3 h-3', [const AppIcon(AppIcons.copy)]),
              ],
            ),
        ]),
      ],
    );
  }

  Component _buildBadgePill(String status, ColorScheme colorScheme) {
    String badgeClasses =
        'px-3 py-1 rounded-full text-[11px] font-bold inline-block leading-none tracking-tight border';
    String bg = 'bg-slate-100 dark:bg-slate-800';
    String text = 'text-slate-700 dark:text-slate-300';
    String border = 'border-slate-200 dark:border-slate-700';

    if (status == 'PASSED' || status == 'VERIFIED') {
      bg = 'bg-emerald-50 dark:bg-emerald-950/60';
      text = 'text-emerald-600 dark:text-emerald-400';
      border = 'border-emerald-200/50 dark:border-emerald-800/50';
    } else if (status == 'PENDING' || status == 'UNDER_REVIEW') {
      bg = 'bg-amber-50 dark:bg-amber-950/60';
      text = 'text-amber-600 dark:text-amber-400';
      border = 'border-amber-200/50 dark:border-amber-800/50';
    } else if (status == 'FAILED') {
      bg = 'bg-rose-50 dark:bg-rose-950/60';
      text = 'text-rose-600 dark:text-rose-400';
      border = 'border-rose-200/50 dark:border-rose-800/50';
    }

    return span(classes: '$badgeClasses $bg $text $border', [
      Component.text(status),
    ]);
  }
}

String _formatId(String? id) {
  if (id == null || id.isEmpty) return '#GUA-000';
  if (id.length <= 8) return '#$id';
  return '#${id.substring(0, 8)}...';
}

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return 'N/A';
  try {
    final dt = DateTime.parse(raw);
    return '${dt.day}/${dt.month}/${dt.year}';
  } catch (_) {
    return raw;
  }
}
