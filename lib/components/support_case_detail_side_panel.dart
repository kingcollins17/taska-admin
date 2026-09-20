import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/support/admin_support_case_item.dart';
import '../core/models/clients/users/admin_platform_user_item.dart';
import '../core/providers/admin_support_providers.dart';
import '../core/providers/ui_state_provider.dart';
import 'platform_user_detail_side_panel.dart';

class SupportCaseDetailSidePanel extends StatefulComponent {
  final String caseId;
  final AdminSupportCaseItem? initialCaseItem;

  const SupportCaseDetailSidePanel({
    required this.caseId,
    this.initialCaseItem,
    super.key,
  });

  static void show(BuildContext context, String caseId, {AdminSupportCaseItem? caseItem}) {
    context.showSidePanel(
      SupportCaseDetailSidePanel(caseId: caseId, initialCaseItem: caseItem),
      title: 'Support Ticket Details',
    );
  }

  @override
  State<SupportCaseDetailSidePanel> createState() => _SupportCaseDetailSidePanelState();
}

class _SupportCaseDetailSidePanelState extends State<SupportCaseDetailSidePanel> {
  bool isSubmittingAction = false;
  String? errorMessage;

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

  Future<void> _handleClaim(BuildContext context) async {
    setState(() {
      isSubmittingAction = true;
      errorMessage = null;
    });

    final notifier = context.read(adminSupportManagementProvider.notifier);
    await notifier.claimCase(
      component.caseId,
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          isSubmittingAction = false;
        });
        context.showFlushbar(
          title: 'Case Claimed',
          message: 'Support case claimed successfully.',
          type: FlushbarType.success,
        );
      },
      onError: (msg) {
        if (!mounted) return;
        setState(() {
          isSubmittingAction = false;
          errorMessage = msg;
        });
        context.showFlushbar(message: msg, type: FlushbarType.error);
      },
    );
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final caseAsync = context.watch(adminSupportCaseDetailProvider(component.caseId));

    return caseAsync.when(
      data: (caseDetail) {
        final caseNo = caseDetail?.caseNumber ?? component.initialCaseItem?.caseNumber ?? _formatId(component.caseId);
        final status = caseDetail?.status ?? component.initialCaseItem?.status ?? 'OPEN';
        final priority = caseDetail?.priority ?? component.initialCaseItem?.priority ?? 'NORMAL';
        final type = caseDetail?.type ?? component.initialCaseItem?.type ?? 'GENERAL';
        final subject = caseDetail?.subject ?? component.initialCaseItem?.subject ?? 'No Subject';
        final description = caseDetail?.description ?? component.initialCaseItem?.description ?? 'No description provided';

        final initiator = caseDetail?.initiator ?? component.initialCaseItem?.initiator;
        final taskId = caseDetail?.taskId ?? component.initialCaseItem?.taskId;
        final taskObj = caseDetail?.task;

        final initiatorName = initiator != null
            ? '${initiator.firstName ?? ''} ${initiator.lastName ?? ''}'.trim()
            : '';

        return div(classes: 'space-y-5 text-xs pb-8 relative', [
          // Error Banner
          if (errorMessage != null)
            div(
              classes: 'p-3 rounded-xl border-2 border-dashed text-xs font-semibold flex items-center space-x-2',
              styles: Styles(
                backgroundColor: colorScheme.isDark ? Color.rgba(239, 68, 68, 0.08) : Color.rgba(239, 68, 68, 0.06),
                color: Color('#EF4444'),
                raw: {'border-color': 'rgba(239, 68, 68, 0.3)'},
              ),
              [
                div(classes: 'w-4 h-4 shrink-0', [const AppIcon(AppIcons.disputes)]),
                span(classes: 'flex-1', [Component.text(errorMessage!)]),
              ],
            ),

          // ── Hero Summary Card ───────────────────────────────
          div(
            classes: 'rounded-2xl border overflow-hidden shadow-lg transition-all',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [
              // Gradient accent bar
              div(
                classes: 'h-1.5',
                styles: Styles(raw: {
                  'background': 'linear-gradient(90deg, #10B981 0%, #14B8A6 35%, #06B6D4 65%, #3B82F6 100%)',
                }),
                [],
              ),

              // Card content
              div(classes: 'p-5 space-y-4', [
                // Ticket header row
                div(classes: 'flex items-start justify-between gap-3', [
                  div(classes: 'space-y-1.5 min-w-0 flex-1', [
                    // Ticket # label
                    div(classes: 'flex items-center space-x-2', [
                      span(
                        classes: 'text-[10px] font-bold uppercase tracking-widest',
                        styles: Styles(color: Color(colorScheme.textMuted)),
                        [Component.text('Ticket')],
                      ),
                      span(
                        classes: 'font-mono font-bold text-[11px] px-1.5 py-0.5 rounded-md border',
                        styles: Styles(
                          backgroundColor: Color(colorScheme.surface),
                          color: Color(colorScheme.primary),
                          raw: {'border-color': colorScheme.borderInput},
                        ),
                        [Component.text('#$caseNo')],
                      ),
                    ]),
                    // Subject
                    h4(
                      classes: 'font-black text-sm tracking-tight leading-snug',
                      styles: Styles(color: Color(colorScheme.textHeading)),
                      [Component.text(subject)],
                    ),
                  ]),

                  // Copy ID button (compact icon)
                  button(
                    type: ButtonType.button,
                    classes: 'w-8 h-8 rounded-xl flex items-center justify-center border cursor-pointer transition-all hover:shadow-xs shrink-0',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.surface),
                      color: Color(colorScheme.textSecondary),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
                    events: {
                      'click': (_) => _copyToClipboard(context, component.caseId, 'Case ID'),
                    },
                    attributes: {'title': 'Copy Case ID'},
                    [div(classes: 'w-3.5 h-3.5', [const AppIcon(AppIcons.copy)])],
                  ),
                ]),

                // Status / Priority / Type badges row
                div(classes: 'flex flex-wrap items-center gap-1.5', [
                  _buildStatusBadge(status, colorScheme),
                  _buildPriorityBadge(priority, colorScheme),
                  span(
                    classes: 'px-2 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.surface),
                      color: Color(colorScheme.textSecondary),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
                    [Component.text(type)],
                  ),
                ]),
              ]),
            ],
          ),

          // ── Description Section ─────────────────────────────
          _SectionCard(
            colorScheme: colorScheme,
            icon: AppIcons.documents,
            title: 'Description',
            child: div(classes: 'space-y-2', [
              p(
                classes: 'whitespace-pre-wrap text-xs font-medium leading-relaxed',
                styles: Styles(color: Color(colorScheme.textPrimary)),
                [Component.text(description)],
              ),
            ]),
          ),

          // ── Initiator Information ───────────────────────────
          if (initiator != null)
            _SectionCard(
              colorScheme: colorScheme,
              icon: AppIcons.customer,
              title: 'Initiator',
              child: div(classes: 'space-y-3', [
                // Avatar + name row
                div(classes: 'flex items-center space-x-3', [
                  div(
                    classes: 'w-10 h-10 rounded-xl flex items-center justify-center font-bold text-white text-sm shadow-md shrink-0',
                    styles: Styles(backgroundColor: Color(_avatarColor(initiatorName.isNotEmpty ? initiatorName : (initiator.email ?? 'U')))),
                    [Component.text(initiatorName.isNotEmpty ? initiatorName[0].toUpperCase() : 'U')],
                  ),
                  div(classes: 'min-w-0 flex-1 space-y-0.5', [
                    h5(
                      classes: 'font-bold text-xs truncate',
                      styles: Styles(color: Color(colorScheme.textHeading)),
                      [Component.text(initiatorName.isNotEmpty ? initiatorName : 'Initiator')],
                    ),
                    p(
                      classes: 'text-[11px] font-mono truncate',
                      styles: Styles(color: Color(colorScheme.textMuted)),
                      [Component.text(initiator.email ?? initiator.phoneNumber ?? 'No contact info')],
                    ),
                  ]),
                ]),

                // Contact details grid
                div(
                  classes: 'rounded-xl border overflow-hidden',
                  styles: Styles(raw: {'border-color': colorScheme.borderInput}),
                  [
                    _buildAttrRow('Phone', initiator.phoneNumber ?? 'N/A', colorScheme, isFirst: true),
                    _buildAttrRow('Initiator ID', _formatId(initiator.id), colorScheme),
                    if (initiator.email != null)
                      _buildAttrRow('Email', initiator.email!, colorScheme, isLast: true),
                  ],
                ),

                // View Profile button
                if (initiator.id != null && initiator.id!.isNotEmpty)
                  button(
                    type: ButtonType.button,
                    onClick: () {
                      final pUser = AdminPlatformUserItem(
                        id: initiator.id,
                        email: initiator.email,
                        fullname: '${initiator.firstName ?? ''} ${initiator.lastName ?? ''}'.trim(),
                        phoneNumber: initiator.phoneNumber,
                      );
                      PlatformUserDetailSidePanel.show(context, pUser);
                    },
                    classes: 'w-full py-2 px-3 rounded-xl text-[11px] font-bold border transition-all cursor-pointer flex items-center justify-center space-x-1.5 active:scale-95 shadow-2xs',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      color: Color(colorScheme.primary),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
                    [
                      div(classes: 'w-3.5 h-3.5', [const AppIcon(AppIcons.externalLink)]),
                      span([Component.text('View Full Profile')]),
                    ],
                  ),
              ]),
            ),

          // ── Related Task ────────────────────────────────────
          if (taskId != null && taskId.isNotEmpty)
            _SectionCard(
              colorScheme: colorScheme,
              icon: AppIcons.tasks,
              title: 'Related Task',
              child: div(classes: 'space-y-3', [
                div(classes: 'flex items-center justify-between', [
                  div(classes: 'flex items-center space-x-2', [
                    div(
                      classes: 'w-7 h-7 rounded-lg flex items-center justify-center border shadow-2xs',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        color: Color(colorScheme.primary),
                        raw: {'border-color': colorScheme.borderInput},
                      ),
                      [div(classes: 'w-3.5 h-3.5', [const AppIcon(AppIcons.tasks)])],
                    ),
                    span(
                      classes: 'font-bold font-mono text-xs',
                      styles: Styles(color: Color(colorScheme.textHeading)),
                      [Component.text('Task ${_formatId(taskId)}')],
                    ),
                  ]),
                  if (taskObj != null && taskObj['status'] != null)
                    span(
                      classes: 'px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider border',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        color: Color(colorScheme.primary),
                        raw: {'border-color': colorScheme.borderInput},
                      ),
                      [Component.text(taskObj['status'].toString())],
                    ),
                ]),

                if (taskObj != null && taskObj['title'] != null)
                  p(
                    classes: 'font-medium text-xs leading-relaxed',
                    styles: Styles(color: Color(colorScheme.textSecondary)),
                    [Component.text(taskObj['title'].toString())],
                  ),

                button(
                  type: ButtonType.button,
                  onClick: () => _copyToClipboard(context, taskId, 'Task ID'),
                  classes: 'px-3 py-1.5 rounded-xl text-[10.5px] font-bold border transition-all cursor-pointer flex items-center space-x-1.5 active:scale-95',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.textSecondary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  [
                    div(classes: 'w-3 h-3', [const AppIcon(AppIcons.copy)]),
                    span([Component.text('Copy Task ID')]),
                  ],
                ),
              ]),
            ),

          // ── SLA & Dates ─────────────────────────────────────
          _SectionCard(
            colorScheme: colorScheme,
            icon: AppIcons.auditLogs,
            title: 'SLA & Dates',
            child: div(
              classes: 'rounded-xl border overflow-hidden',
              styles: Styles(raw: {'border-color': colorScheme.borderInput}),
              [
                _buildAttrRow(
                  'Created',
                  _formatDate(caseDetail?.createdAt ?? component.initialCaseItem?.createdAt),
                  colorScheme,
                  isFirst: true,
                ),
                _buildAttrRow(
                  'Updated',
                  _formatDate(caseDetail?.updatedAt ?? component.initialCaseItem?.updatedAt),
                  colorScheme,
                ),
                _buildAttrRow(
                  'First Response Due',
                  _formatDate(caseDetail?.firstResponseDueAt ?? component.initialCaseItem?.firstResponseDueAt),
                  colorScheme,
                ),
                _buildAttrRow(
                  'Resolution Due',
                  _formatDate(caseDetail?.resolutionDueAt ?? component.initialCaseItem?.resolutionDueAt),
                  colorScheme,
                ),
                if (caseDetail?.firstRespondedAt != null || component.initialCaseItem?.firstRespondedAt != null)
                  _buildAttrRow(
                    'First Responded',
                    _formatDate(caseDetail?.firstRespondedAt ?? component.initialCaseItem?.firstRespondedAt),
                    colorScheme,
                  ),
                if (caseDetail?.resolvedAt != null || component.initialCaseItem?.resolvedAt != null)
                  _buildAttrRow(
                    'Resolved',
                    _formatDate(caseDetail?.resolvedAt ?? component.initialCaseItem?.resolvedAt),
                    colorScheme,
                  ),
                if (caseDetail?.closedAt != null || component.initialCaseItem?.closedAt != null)
                  _buildAttrRow(
                    'Closed',
                    _formatDate(caseDetail?.closedAt ?? component.initialCaseItem?.closedAt),
                    colorScheme,
                    isLast: true,
                  ),
              ],
            ),
          ),

          // ── Claim Action ────────────────────────────────────
          div(
            classes: 'pt-1',
            [
              if (isSubmittingAction)
                div(
                  classes: 'w-full py-3 px-4 rounded-xl border-2 border-dashed text-center animate-pulse',
                  styles: Styles(
                    backgroundColor: colorScheme.isDark ? Color.rgba(16, 185, 129, 0.08) : Color.rgba(16, 185, 129, 0.05),
                    color: Color(colorScheme.primary),
                    raw: {'border-color': colorScheme.isDark ? 'rgba(16, 185, 129, 0.3)' : 'rgba(16, 185, 129, 0.25)'},
                  ),
                  [
                    span(classes: 'text-xs font-bold', [Component.text('Claiming support ticket...')]),
                  ],
                )
              else
                button(
                  type: ButtonType.button,
                  onClick: () => _handleClaim(context),
                  classes: 'w-full py-3 px-4 rounded-xl text-white font-bold text-xs shadow-lg transition-all cursor-pointer flex items-center justify-center space-x-2 active:scale-95 border-none',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.primary),
                    raw: {
                      'background': 'linear-gradient(135deg, ${colorScheme.primary} 0%, #14B8A6 100%)',
                    },
                  ),
                  [
                    div(classes: 'w-4 h-4', [const AppIcon(AppIcons.customer)]),
                    span([Component.text('Claim Support Ticket')]),
                  ],
                ),
            ],
          ),
        ]);
      },
      loading: () => div(classes: 'space-y-4 py-4 animate-pulse', [
        // Shimmer hero card
        div(
          classes: 'h-32 rounded-2xl border',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            raw: {'border-color': colorScheme.borderInput},
          ),
          [],
        ),
        for (var i = 0; i < 3; i++)
          div(
            classes: 'h-20 rounded-2xl border',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              raw: {'border-color': colorScheme.border},
            ),
            [],
          ),
      ]),
      error: (err, _) => div(
        classes: 'p-5 rounded-2xl border text-center space-y-3',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [
          div(
            classes: 'w-10 h-10 mx-auto rounded-xl flex items-center justify-center border shadow-2xs',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color('#EF4444'),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [const AppIcon(AppIcons.disputes)],
          ),
          p(
            classes: 'text-xs font-bold',
            styles: Styles(color: Color('#EF4444')),
            [Component.text('Failed to load ticket details')],
          ),
          p(
            classes: 'text-[11px] font-medium',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text('$err')],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // UI Helpers
  // ─────────────────────────────────────────────────────────────

  /// Attribute table row – used for SLA dates and contact info
  Component _buildAttrRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return div(
      classes: 'flex items-center justify-between px-3.5 py-2.5 ${isFirst ? '' : 'border-t'}',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.borderInput},
      ),
      [
        span(
          classes: 'text-[11px] font-medium',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text(label)],
        ),
        span(
          classes: 'font-bold text-[11px] font-mono truncate max-w-[140px] text-right',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text(value)],
        ),
      ],
    );
  }

  Component _buildStatusBadge(String status, ColorScheme colorScheme) {
    String dotColor;
    String textColor;
    String bgColor;
    String borderColor;

    switch (status.toUpperCase()) {
      case 'OPEN':
      case 'IN_PROGRESS':
        dotColor = '#F59E0B';
        textColor = colorScheme.isDark ? '#FCD34D' : '#B45309';
        bgColor = colorScheme.isDark ? 'rgba(245, 158, 11, 0.12)' : 'rgba(245, 158, 11, 0.08)';
        borderColor = colorScheme.isDark ? 'rgba(245, 158, 11, 0.25)' : 'rgba(245, 158, 11, 0.2)';
        break;
      case 'RESOLVED':
      case 'CLOSED':
      case 'AUTO_CLOSED':
        dotColor = '#10B981';
        textColor = colorScheme.isDark ? '#6EE7B7' : '#047857';
        bgColor = colorScheme.isDark ? 'rgba(16, 185, 129, 0.12)' : 'rgba(16, 185, 129, 0.08)';
        borderColor = colorScheme.isDark ? 'rgba(16, 185, 129, 0.25)' : 'rgba(16, 185, 129, 0.2)';
        break;
      case 'WAITING_FOR_USER':
      case 'WAITING_FOR_PROVIDER':
      case 'WAITING_FOR_INTERNAL':
        dotColor = '#3B82F6';
        textColor = colorScheme.isDark ? '#93C5FD' : '#1D4ED8';
        bgColor = colorScheme.isDark ? 'rgba(59, 130, 246, 0.12)' : 'rgba(59, 130, 246, 0.08)';
        borderColor = colorScheme.isDark ? 'rgba(59, 130, 246, 0.25)' : 'rgba(59, 130, 246, 0.2)';
        break;
      default:
        dotColor = '#64748B';
        textColor = colorScheme.isDark ? '#CBD5E1' : '#475569';
        bgColor = colorScheme.isDark ? 'rgba(100, 116, 139, 0.12)' : 'rgba(100, 116, 139, 0.08)';
        borderColor = colorScheme.isDark ? 'rgba(100, 116, 139, 0.25)' : 'rgba(100, 116, 139, 0.2)';
    }

    return span(
      classes: 'px-2.5 py-1 rounded-full text-[10px] font-bold inline-flex items-center space-x-1.5 leading-none tracking-tight border',
      styles: Styles(
        backgroundColor: Color(bgColor),
        color: Color(textColor),
        raw: {'border-color': borderColor},
      ),
      [
        div(
          classes: 'w-1.5 h-1.5 rounded-full shrink-0',
          styles: Styles(backgroundColor: Color(dotColor)),
          [],
        ),
        span([Component.text(status)]),
      ],
    );
  }

  Component _buildPriorityBadge(String priority, ColorScheme colorScheme) {
    String dotColor;
    String textColor;
    String bgColor;
    String borderColor;

    switch (priority.toUpperCase()) {
      case 'HIGH':
      case 'URGENT':
        dotColor = '#EF4444';
        textColor = colorScheme.isDark ? '#FCA5A5' : '#B91C1C';
        bgColor = colorScheme.isDark ? 'rgba(239, 68, 68, 0.12)' : 'rgba(239, 68, 68, 0.08)';
        borderColor = colorScheme.isDark ? 'rgba(239, 68, 68, 0.25)' : 'rgba(239, 68, 68, 0.2)';
        break;
      case 'NORMAL':
        dotColor = '#3B82F6';
        textColor = colorScheme.isDark ? '#93C5FD' : '#1D4ED8';
        bgColor = colorScheme.isDark ? 'rgba(59, 130, 246, 0.12)' : 'rgba(59, 130, 246, 0.08)';
        borderColor = colorScheme.isDark ? 'rgba(59, 130, 246, 0.25)' : 'rgba(59, 130, 246, 0.2)';
        break;
      case 'LOW':
        dotColor = '#10B981';
        textColor = colorScheme.isDark ? '#6EE7B7' : '#047857';
        bgColor = colorScheme.isDark ? 'rgba(16, 185, 129, 0.12)' : 'rgba(16, 185, 129, 0.08)';
        borderColor = colorScheme.isDark ? 'rgba(16, 185, 129, 0.25)' : 'rgba(16, 185, 129, 0.2)';
        break;
      default:
        dotColor = '#64748B';
        textColor = colorScheme.isDark ? '#CBD5E1' : '#475569';
        bgColor = colorScheme.isDark ? 'rgba(100, 116, 139, 0.12)' : 'rgba(100, 116, 139, 0.08)';
        borderColor = colorScheme.isDark ? 'rgba(100, 116, 139, 0.25)' : 'rgba(100, 116, 139, 0.2)';
    }

    return span(
      classes: 'px-2.5 py-1 rounded-full text-[10px] font-bold inline-flex items-center space-x-1.5 leading-none tracking-tight border',
      styles: Styles(
        backgroundColor: Color(bgColor),
        color: Color(textColor),
        raw: {'border-color': borderColor},
      ),
      [
        div(
          classes: 'w-1.5 h-1.5 rounded-full shrink-0',
          styles: Styles(backgroundColor: Color(dotColor)),
          [],
        ),
        span([Component.text(priority)]),
      ],
    );
  }

  /// Consistent avatar color from name
  String _avatarColor(String name) {
    final colors = ['#10B981', '#6366F1', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899', '#14B8A6', '#F97316'];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}

// ─────────────────────────────────────────────────────────────
// Reusable Section Card with icon header
// ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessComponent {
  final ColorScheme colorScheme;
  final AppIcons icon;
  final String title;
  final Component child;

  const _SectionCard({
    required this.colorScheme,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Component build(BuildContext context) {
    return div(classes: 'space-y-2.5', [
      // Section header
      div(classes: 'flex items-center space-x-2', [
        div(
          classes: 'w-6 h-6 rounded-lg flex items-center justify-center shrink-0 border shadow-2xs',
          styles: Styles(
            backgroundColor: colorScheme.isDark ? Color.rgba(16, 185, 129, 0.15) : Color.rgba(16, 185, 129, 0.08),
            color: Color(colorScheme.primary),
            raw: {'border-color': colorScheme.isDark ? 'rgba(16, 185, 129, 0.3)' : 'rgba(16, 185, 129, 0.18)'},
          ),
          [div(classes: 'w-3.5 h-3.5', [AppIcon(icon)])],
        ),
        h5(
          classes: 'font-black uppercase text-[11px] tracking-wider',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text(title)],
        ),
      ]),
      // Content card
      div(
        classes: 'p-4 rounded-2xl border shadow-xs transition-all',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [child],
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Local Formatting Helpers
// ─────────────────────────────────────────────────────────────

String _formatId(String? id) {
  if (id == null || id.isEmpty) return '#SUP-000';
  if (id.length <= 8) return '#$id';
  return '#${id.substring(0, 8)}...';
}

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return 'N/A';
  try {
    final dt = DateTime.parse(raw).toLocal();
    final dateStr = '${dt.day}/${dt.month}/${dt.year}';
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$dateStr @ $hour:$minute';
  } catch (_) {
    return raw;
  }
}
