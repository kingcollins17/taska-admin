import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/support/admin_update_support_case_body.dart';
import '../core/providers/admin_support_providers.dart';
import '../core/providers/ui_state_provider.dart';
import 'support_workspace_assigned_cases_panel.dart';

class SupportWorkspaceDetailsPanel extends StatefulComponent {
  final String? caseId;

  const SupportWorkspaceDetailsPanel({super.key, required this.caseId});

  @override
  State<SupportWorkspaceDetailsPanel> createState() => _SupportWorkspaceDetailsPanelState();
}

class _SupportWorkspaceDetailsPanelState extends State<SupportWorkspaceDetailsPanel> {
  String status = 'OPEN';
  String priority = 'NORMAL';
  String type = 'GENERAL';
  String subject = '';
  String description = '';
  bool isUpdating = false;
  String? initializedCaseId;

  void _syncStateFromDetail(dynamic caseDetail) {
    if (caseDetail != null && caseDetail.id != initializedCaseId) {
      initializedCaseId = caseDetail.id;
      status = caseDetail.status ?? 'OPEN';
      priority = caseDetail.priority ?? 'NORMAL';
      type = caseDetail.type ?? 'GENERAL';
      subject = caseDetail.subject ?? '';
      description = caseDetail.description ?? '';
    }
  }

  Future<void> _handleSave(BuildContext context) async {
    if (component.caseId == null || isUpdating) return;

    setState(() => isUpdating = true);

    final notifier = context.read(adminSupportManagementProvider.notifier);
    await notifier.updateCase(
      component.caseId!,
      AdminUpdateSupportCaseBody(
        status: status,
        priority: priority,
        subject: subject.trim().isEmpty ? null : subject.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
      ),
      onSuccess: () {
        if (!mounted) return;
        setState(() => isUpdating = false);
        context.showFlushbar(title: 'Ticket Updated', message: 'Support ticket saved successfully', type: FlushbarType.success);
      },
      onError: (msg) {
        if (!mounted) return;
        setState(() => isUpdating = false);
        context.showFlushbar(message: msg, type: FlushbarType.error);
      },
    );
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    if (component.caseId == null) {
      return div(classes: 'h-full flex flex-col items-center justify-center p-8 text-center space-y-3', [
        div(
          classes: 'w-12 h-12 rounded-2xl flex items-center justify-center border shadow-2xs',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textMuted),
            raw: {'border-color': colorScheme.borderInput},
          ),
          [const AppIcon(AppIcons.documents)],
        ),
        p(
          classes: 'text-xs font-semibold',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Select a ticket to view and edit details.')],
        ),
      ]);
    }

    final caseDetailAsync = context.watch(adminSupportCaseDetailProvider(component.caseId!));
    final caseDetail = caseDetailAsync.value;
    _syncStateFromDetail(caseDetail);

    final caseNo = caseDetail?.caseNumber ?? formatSupportId(component.caseId);
    final initiator = caseDetail?.initiator;
    final initiatorName = initiator != null
        ? '${initiator.firstName ?? ''} ${initiator.lastName ?? ''}'.trim()
        : '';

    return div(
      classes: 'flex flex-col h-full overflow-hidden transition-colors',
      styles: Styles(backgroundColor: Color(colorScheme.surface)),
      [
        // ── Header ──────────────────────────────────────────
        div(
          classes: 'px-4 py-3 border-b flex items-center justify-between shrink-0',
          styles: Styles(raw: {'border-color': colorScheme.border}),
          [
            div(classes: 'flex items-center space-x-2', [
              h3(
                classes: 'font-extrabold text-sm tracking-tight',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('Ticket details')],
              ),
            ]),
            // Settings / Claim button
            button(
              type: ButtonType.button,
              onClick: () {
                context.read(adminSupportManagementProvider.notifier).claimCase(
                  component.caseId!,
                  onSuccess: () => context.showFlushbar(message: 'Ticket claimed', type: FlushbarType.success),
                );
              },
              classes: 'w-8 h-8 rounded-xl flex items-center justify-center border cursor-pointer transition-all hover:bg-slate-100 dark:hover:bg-slate-800',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.primary),
                raw: {'border-color': colorScheme.borderInput},
              ),
              attributes: {'title': 'Claim this ticket'},
              [div(classes: 'w-3.5 h-3.5', [const AppIcon(AppIcons.setting)])],
            ),
          ],
        ),

        // ── Scrollable Form Content ─────────────────────────
        div(classes: 'flex-1 overflow-y-auto px-4 py-4 space-y-5', [

          // ── Assignee Card ─────────────────────────────────
          _buildFieldSection(
            label: 'Assignee',
            colorScheme: colorScheme,
            child: div(
              classes: 'p-2.5 rounded-xl border flex items-center justify-between cursor-pointer transition-all hover:shadow-xs',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                raw: {'border-color': colorScheme.borderInput},
              ),
              [
                div(classes: 'flex items-center space-x-2.5', [
                  // Agent avatar
                  div(
                    classes: 'w-7 h-7 rounded-full flex items-center justify-center font-bold text-white text-[10px] shadow-2xs',
                    styles: Styles(backgroundColor: Color(caseDetail?.assignedAgentId != null ? colorScheme.primary : '#94A3B8')),
                    [Component.text(caseDetail?.assignedAgentId != null ? 'A' : '?')],
                  ),
                  span(
                    classes: 'font-semibold text-xs',
                    styles: Styles(color: Color(colorScheme.textPrimary)),
                    [Component.text(caseDetail?.assignedAgentId != null ? 'Agent #${formatSupportId(caseDetail!.assignedAgentId)}' : 'Unassigned')],
                  ),
                ]),
                div(
                  classes: 'w-4 h-4',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  [const AppIcon(AppIcons.chevronDown)],
                ),
              ],
            ),
          ),

          // ── Team Selector ─────────────────────────────────
          _buildFieldSection(
            label: 'Team',
            colorScheme: colorScheme,
            child: _buildDropdown(
              colorScheme: colorScheme,
              children: [
                option(value: 'Customer Service', selected: true, [Component.text('Customer Service')]),
                option(value: 'Technical Support', [Component.text('Technical Support')]),
                option(value: 'Billing & Payments', [Component.text('Billing & Payments')]),
              ],
            ),
          ),

          // ── Ticket Type ───────────────────────────────────
          _buildFieldSection(
            label: 'Ticket type',
            colorScheme: colorScheme,
            child: _buildDropdown(
              colorScheme: colorScheme,
              onChange: (val) => setState(() => type = val),
              children: [
                option(value: 'GENERAL', selected: type == 'GENERAL', [Component.text('General Question')]),
                option(value: 'TASK_ISSUE', selected: type == 'TASK_ISSUE', [Component.text('Task Issue / Problem')]),
                option(value: 'DISPUTE', selected: type == 'DISPUTE', [Component.text('Dispute / Claim')]),
                option(value: 'PAYMENT', selected: type == 'PAYMENT', [Component.text('Payment / Payout')]),
              ],
            ),
          ),

          // ── Set Status ────────────────────────────────────
          _buildFieldSection(
            label: 'Set status',
            colorScheme: colorScheme,
            child: _buildDropdown(
              colorScheme: colorScheme,
              accentColor: _statusColor(status),
              onChange: (val) => setState(() => status = val),
              children: [
                option(value: 'OPEN', selected: status == 'OPEN', [Component.text('OPEN')]),
                option(value: 'IN_PROGRESS', selected: status == 'IN_PROGRESS', [Component.text('IN_PROGRESS')]),
                option(value: 'WAITING_FOR_USER', selected: status == 'WAITING_FOR_USER', [Component.text('WAITING_FOR_USER')]),
                option(value: 'WAITING_FOR_PROVIDER', selected: status == 'WAITING_FOR_PROVIDER', [Component.text('WAITING_FOR_PROVIDER')]),
                option(value: 'WAITING_FOR_INTERNAL', selected: status == 'WAITING_FOR_INTERNAL', [Component.text('WAITING_FOR_INTERNAL')]),
                option(value: 'RESOLVED', selected: status == 'RESOLVED', [Component.text('RESOLVED')]),
                option(value: 'CLOSED', selected: status == 'CLOSED', [Component.text('CLOSED')]),
              ],
            ),
          ),

          // ── Set Priority ──────────────────────────────────
          _buildFieldSection(
            label: 'Set priority',
            colorScheme: colorScheme,
            child: div(classes: 'flex items-center space-x-2', [
              _PriorityChip(
                label: 'Low',
                dotColor: '#10B981',
                isSelected: priority == 'LOW',
                colorScheme: colorScheme,
                onTap: () => setState(() => priority = 'LOW'),
              ),
              _PriorityChip(
                label: 'Medium',
                dotColor: '#F59E0B',
                isSelected: priority == 'NORMAL',
                colorScheme: colorScheme,
                onTap: () => setState(() => priority = 'NORMAL'),
              ),
              _PriorityChip(
                label: 'High',
                dotColor: '#EF4444',
                isSelected: priority == 'HIGH' || priority == 'URGENT',
                colorScheme: colorScheme,
                onTap: () => setState(() => priority = 'HIGH'),
              ),
            ]),
          ),

          // ── Subject ───────────────────────────────────────
          _buildFieldSection(
            label: 'Subject',
            colorScheme: colorScheme,
            child: div(
              classes: 'p-2.5 rounded-xl border text-xs font-medium leading-relaxed',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.textPrimary),
                raw: {'border-color': colorScheme.borderInput, 'min-height': '40px'},
              ),
              [
                input(
                  type: InputType.text,
                  value: subject,
                  classes: 'w-full bg-transparent text-xs font-semibold focus:outline-none border-none',
                  styles: Styles(color: Color(colorScheme.textPrimary)),
                  attributes: {'placeholder': 'Enter ticket subject...'},
                  onInput: (val) => setState(() => subject = val.toString()),
                ),
              ],
            ),
          ),

          // ── Tags Section ──────────────────────────────────
          _buildFieldSection(
            label: 'Tags',
            colorScheme: colorScheme,
            child: div(classes: 'space-y-2', [
              // Tag pills
              div(classes: 'flex flex-wrap items-center gap-1.5', [
                if (type.isNotEmpty)
                  _TagPill(label: type, colorScheme: colorScheme),
                if (priority.isNotEmpty)
                  _TagPill(label: priority, colorScheme: colorScheme),
              ]),
              // Add tag input placeholder
              div(
                classes: 'p-2 rounded-xl border text-[11px] font-medium',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  color: Color(colorScheme.placeholder),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                [Component.text('+ Add tag...')],
              ),
            ]),
          ),

          // ── Horizontal Divider ────────────────────────────
          div(
            classes: 'h-px w-full',
            styles: Styles(backgroundColor: Color(colorScheme.border)),
            [],
          ),

          // ── Attributes Card ───────────────────────────────
          div(classes: 'space-y-3', [
            h4(
              classes: 'font-bold text-[11px] uppercase tracking-wider',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text('Attributes')],
            ),
            div(
              classes: 'rounded-2xl border overflow-hidden shadow-2xs',
              styles: Styles(raw: {'border-color': colorScheme.borderInput}),
              [
                _attrRow('ID', '#$caseNo', colorScheme, isFirst: true),
                _attrRow(
                  'Customer',
                  initiatorName.isNotEmpty ? initiatorName : 'Customer',
                  colorScheme,
                  showAvatar: true,
                  avatarInitial: initiatorName.isNotEmpty ? initiatorName[0] : 'C',
                ),
                if (initiator?.email != null)
                  _attrRow('Email', initiator!.email!, colorScheme),
                if (caseDetail?.taskId != null)
                  _attrRow('Task ID', '#${formatSupportId(caseDetail!.taskId)}', colorScheme),
                _attrRow('Date submitted', formatSupportDate(caseDetail?.createdAt), colorScheme, isLast: true),
              ],
            ),
          ]),

          // ── Note Section ──────────────────────────────────
          div(classes: 'space-y-2', [
            h4(
              classes: 'font-bold text-[11px] uppercase tracking-wider',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text('Note')],
            ),
            textarea(
              classes: 'w-full border rounded-xl p-3 text-xs font-medium focus:outline-none focus:ring-2 transition-all resize-none',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.textPrimary),
                raw: {'border-color': colorScheme.borderInput, 'min-height': '72px'},
              ),
              attributes: {'placeholder': 'Add internal note about this ticket...', 'rows': '3'},
              onInput: (val) => setState(() => description = val.toString()),
              [Component.text(description)],
            ),
          ]),
        ]),

        // ── Sticky Save Footer ──────────────────────────────
        div(
          classes: 'px-4 py-3 border-t shrink-0',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            button(
              type: ButtonType.button,
              onClick: () => _handleSave(context),
              disabled: isUpdating,
              classes: 'w-full py-2.5 px-4 rounded-xl text-white font-bold text-xs shadow-md transition-all cursor-pointer border-none active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2',
              styles: Styles(backgroundColor: Color(colorScheme.primary)),
              [
                if (isUpdating) ...[
                  span(classes: 'animate-spin inline-block w-3.5 h-3.5', [
                    div(classes: 'w-3.5 h-3.5', [const AppIcon(AppIcons.refresh)]),
                  ]),
                  span([Component.text('Saving...')]),
                ] else ...[
                  span([Component.text('Save & Update Ticket')]),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────

  /// Field section wrapper with label
  Component _buildFieldSection({
    required String label,
    required ColorScheme colorScheme,
    required Component child,
  }) {
    return div(classes: 'space-y-1.5', [
      span(
        classes: 'font-bold text-[11px] block uppercase tracking-wider',
        styles: Styles(color: Color(colorScheme.textMuted)),
        [Component.text(label)],
      ),
      child,
    ]);
  }

  /// Styled select dropdown
  Component _buildDropdown({
    required ColorScheme colorScheme,
    required List<Component> children,
    void Function(String)? onChange,
    String? accentColor,
  }) {
    return select(
      classes: 'w-full border rounded-xl px-3 py-2.5 text-xs font-semibold focus:outline-none transition-all cursor-pointer appearance-none',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        color: Color(accentColor ?? colorScheme.textPrimary),
        raw: {
          'border-color': colorScheme.borderInput,
          'background-image': 'url("data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' width=\'12\' height=\'12\' viewBox=\'0 0 24 24\' fill=\'none\' stroke=\'%2394a3b8\' stroke-width=\'2\'%3E%3Cpath d=\'M6 9l6 6 6-6\'/%3E%3C/svg%3E")',
          'background-repeat': 'no-repeat',
          'background-position': 'right 10px center',
          'padding-right': '32px',
        },
      ),
      events: onChange != null
          ? {
              'change': (e) {
                final val = (e.target as web.HTMLSelectElement).value;
                onChange(val);
              },
            }
          : null,
      children,
    );
  }

  /// Attribute table row
  Component _attrRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isFirst = false,
    bool isLast = false,
    bool showAvatar = false,
    String? avatarInitial,
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
        div(classes: 'flex items-center space-x-1.5', [
          if (showAvatar && avatarInitial != null)
            div(
              classes: 'w-5 h-5 rounded-full flex items-center justify-center font-bold text-white text-[8px] shadow-2xs',
              styles: Styles(backgroundColor: Color(colorScheme.primary)),
              [Component.text(avatarInitial.toUpperCase())],
            ),
          span(
            classes: 'font-bold text-xs truncate max-w-[140px]',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [Component.text(value)],
          ),
        ]),
      ],
    );
  }

  /// Return a color string for the current status
  String _statusColor(String st) {
    switch (st.toUpperCase()) {
      case 'OPEN':
        return '#F59E0B';
      case 'IN_PROGRESS':
        return '#3B82F6';
      case 'RESOLVED':
        return '#10B981';
      case 'CLOSED':
        return '#64748B';
      case 'WAITING_FOR_USER':
        return '#8B5CF6';
      default:
        return '#64748B';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Priority Chip with colored dot (inspired by reference image)
// ─────────────────────────────────────────────────────────────

class _PriorityChip extends StatelessComponent {
  final String label;
  final String dotColor;
  final bool isSelected;
  final ColorScheme colorScheme;
  final void Function() onTap;

  const _PriorityChip({
    required this.label,
    required this.dotColor,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Component build(BuildContext context) {
    return button(
      type: ButtonType.button,
      onClick: onTap,
      classes: 'py-1.5 px-3 rounded-full text-[11px] font-bold border transition-all cursor-pointer flex items-center space-x-1.5 active:scale-95',
      styles: isSelected
          ? Styles(
              backgroundColor: Color(dotColor),
              color: Color('#FFFFFF'),
              raw: {'border-color': dotColor},
            )
          : Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
      [
        // Colored dot
        div(
          classes: 'w-2 h-2 rounded-full shrink-0',
          styles: Styles(backgroundColor: Color(isSelected ? '#FFFFFF' : dotColor)),
          [],
        ),
        span([Component.text(label)]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tag Pill with remove button
// ─────────────────────────────────────────────────────────────

class _TagPill extends StatelessComponent {
  final String label;
  final ColorScheme colorScheme;

  const _TagPill({
    required this.label,
    required this.colorScheme,
  });

  @override
  Component build(BuildContext context) {
    return span(
      classes: 'inline-flex items-center space-x-1 px-2.5 py-1 rounded-full text-[10.5px] font-bold border',
      styles: Styles(
        backgroundColor: Color(colorScheme.isDark ? 'rgba(0,168,112,0.12)' : 'rgba(0,168,112,0.08)'),
        color: Color(colorScheme.primary),
        raw: {'border-color': colorScheme.isDark ? 'rgba(0,168,112,0.25)' : 'rgba(0,168,112,0.2)'},
      ),
      [
        span([Component.text(label)]),
        span(
          classes: 'cursor-pointer ml-1 opacity-60 hover:opacity-100 transition-opacity',
          [Component.text('×')],
        ),
      ],
    );
  }
}

// Keep the PriorityButton export for backward compatibility
class PriorityButton extends StatelessComponent {
  final String label;
  final bool isSelected;
  final String activeBg;
  final ColorScheme colorScheme;
  final void Function() onTap;

  const PriorityButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.activeBg,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Component build(BuildContext context) {
    return button(
      type: ButtonType.button,
      onClick: onTap,
      classes: 'py-1.5 px-2 rounded-xl text-[11px] font-bold border transition-all cursor-pointer flex items-center justify-center space-x-1',
      styles: isSelected
          ? Styles(backgroundColor: Color(activeBg), color: Color('#FFFFFF'), raw: {'border-color': activeBg})
          : Styles(backgroundColor: Color(colorScheme.inputBg), color: Color(colorScheme.textSecondary), raw: {'border-color': colorScheme.borderInput}),
      [
        span([Component.text(label)]),
      ],
    );
  }
}
