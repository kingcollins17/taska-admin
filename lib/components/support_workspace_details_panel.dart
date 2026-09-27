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
    final isClosed = status.toUpperCase() == 'CLOSED' || status.toUpperCase() == 'AUTO_CLOSED';

    return div(
      classes: 'flex flex-col h-full overflow-hidden transition-colors',
      styles: Styles(backgroundColor: Color(colorScheme.surface)),
      [
        // ── Header ──────────────────────────────────────────
        div(
          classes: 'px-4 py-3 border-b flex items-center justify-between shrink-0',
          styles: Styles(raw: {'border-color': colorScheme.border}),
          [
            h3(
              classes: 'font-extrabold text-sm tracking-tight',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text('Ticket Details')],
            ),
          ],
        ),

        // ── Scrollable Form Content ─────────────────────────
        div(classes: 'flex-1 overflow-y-auto px-4 py-4 space-y-5', [

          // ── Customer Card ─────────────────────────────────
          div(
            classes: 'p-3.5 rounded-2xl border space-y-3 shadow-2xs',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [
              div(classes: 'flex items-center justify-between', [
                span(
                  classes: 'text-[10.5px] font-bold uppercase tracking-wider',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  [Component.text('Customer Info')],
                ),
                span(
                  classes: 'px-2 py-0.5 rounded-full text-[9.5px] font-bold uppercase tracking-wide border',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.surface),
                    color: Color(colorScheme.primary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  [Component.text('CUSTOMER')],
                ),
              ]),

              div(classes: 'flex items-center space-x-3', [
                div(
                  classes: 'w-10 h-10 rounded-full flex items-center justify-center font-extrabold text-white text-sm shadow-2xs shrink-0',
                  styles: Styles(backgroundColor: Color(_avatarColor(initiatorName))),
                  [Component.text(initiatorName.isNotEmpty ? initiatorName[0].toUpperCase() : 'C')],
                ),
                div(classes: 'flex-1 min-w-0 space-y-0.5', [
                  p(
                    classes: 'font-extrabold text-xs truncate',
                    styles: Styles(color: Color(colorScheme.textHeading)),
                    [Component.text(initiatorName.isNotEmpty ? initiatorName : 'Anonymous Customer')],
                  ),
                  p(
                    classes: 'text-[11px] font-medium truncate',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text(initiator?.email ?? 'No email associated')],
                  ),
                ]),
              ]),
            ],
          ),

          // ── Editable: Set Status ────────────────────────────
          _buildFieldSection(
            label: 'Set Status',
            colorScheme: colorScheme,
            child: _buildDropdown(
              colorScheme: colorScheme,
              accentColor: _statusColor(status),
              onChange: (val) => setState(() => status = val),
              children: [
                option(value: 'OPEN', selected: status == 'OPEN', [Component.text('OPEN')]),
                option(value: 'IN_PROGRESS', selected: status == 'IN_PROGRESS', [Component.text('IN_PROGRESS')]),
                option(value: 'WAITING_FOR_CUSTOMER', selected: status == 'WAITING_FOR_CUSTOMER', [Component.text('WAITING_FOR_CUSTOMER')]),
                option(value: 'WAITING_FOR_PROVIDER', selected: status == 'WAITING_FOR_PROVIDER', [Component.text('WAITING_FOR_PROVIDER')]),
                option(value: 'WAITING_FOR_INTERNAL', selected: status == 'WAITING_FOR_INTERNAL', [Component.text('WAITING_FOR_INTERNAL')]),
                option(value: 'RESOLVED', selected: status == 'RESOLVED', [Component.text('RESOLVED')]),
                option(value: 'CLOSED', selected: status == 'CLOSED', [Component.text('CLOSED')]),
              ],
            ),
          ),

          // ── Editable: Set Priority (Disabled if ticket is CLOSED) ────
          _buildFieldSection(
            label: 'Set Priority',
            colorScheme: colorScheme,
            child: div(classes: 'flex items-center space-x-2', [
              _PriorityChip(
                label: 'Low',
                dotColor: '#10B981',
                isSelected: priority == 'LOW',
                isDisabled: isClosed,
                colorScheme: colorScheme,
                onTap: () {
                  if (!isClosed) setState(() => priority = 'LOW');
                },
              ),
              _PriorityChip(
                label: 'Medium',
                dotColor: '#F59E0B',
                isSelected: priority == 'NORMAL',
                isDisabled: isClosed,
                colorScheme: colorScheme,
                onTap: () {
                  if (!isClosed) setState(() => priority = 'NORMAL');
                },
              ),
              _PriorityChip(
                label: 'High',
                dotColor: '#EF4444',
                isSelected: priority == 'HIGH' || priority == 'URGENT',
                isDisabled: isClosed,
                colorScheme: colorScheme,
                onTap: () {
                  if (!isClosed) setState(() => priority = 'HIGH');
                },
              ),
            ]),
          ),

          // ── Read-only: Subject ─────────────────────────────
          _buildFieldSection(
            label: 'Subject',
            colorScheme: colorScheme,
            child: div(
              classes: 'p-3 rounded-xl border text-xs font-semibold leading-relaxed shadow-2xs',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.textPrimary),
                raw: {'border-color': colorScheme.borderInput},
              ),
              [Component.text(subject.isNotEmpty ? subject : 'No subject')],
            ),
          ),

          // ── Horizontal Divider ────────────────────────────
          div(
            classes: 'h-px w-full',
            styles: Styles(backgroundColor: Color(colorScheme.border)),
            [],
          ),

          // ── Read-only: Redesigned Copyable Attributes Card ───────
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
                _attrRow(context, 'Case ID', '#$caseNo', colorScheme, rawCopyValue: caseNo, isFirst: true),
                _attrRow(
                  context,
                  'Customer',
                  initiatorName.isNotEmpty ? initiatorName : 'Customer',
                  colorScheme,
                  showAvatar: true,
                  avatarInitial: initiatorName.isNotEmpty ? initiatorName[0] : 'C',
                ),
                if (initiator?.email != null)
                  _attrRow(context, 'Email', initiator!.email ?? '', colorScheme),
                if (type.isNotEmpty)
                  _attrRow(context, 'Type', type, colorScheme),
                if (caseDetail?.taskId != null)
                  _attrRow(context, 'Task ID', '#${formatSupportId(caseDetail?.taskId)}', colorScheme, rawCopyValue: caseDetail?.taskId),
                _attrRow(context, 'Date submitted', formatSupportDate(caseDetail?.createdAt), colorScheme),
              ],
            ),
          ]),

          // ── Read-only: Internal Summary / Description ───────
          div(classes: 'space-y-2', [
            h4(
              classes: 'font-bold text-[11px] uppercase tracking-wider',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text('Internal Summary')],
            ),
            div(
              classes: 'p-3 rounded-xl border text-xs font-medium leading-relaxed shadow-2xs min-h-[60px]',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.textPrimary),
                raw: {'border-color': colorScheme.borderInput},
              ),
              [Component.text(description.isNotEmpty ? description : 'No internal summary provided.')],
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
              classes: 'w-full py-2.5 px-4 rounded-xl text-white font-extrabold text-xs shadow-md hover:shadow-lg transition-all cursor-pointer border-none active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2',
              styles: Styles(backgroundColor: Color(colorScheme.primary)),
              [
                if (isUpdating) ...[
                  span(classes: 'animate-spin inline-block w-3.5 h-3.5', [
                    div(classes: 'w-3.5 h-3.5', [const AppIcon(AppIcons.refresh)]),
                  ]),
                  span([Component.text('Saving Updates...')]),
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

  String _avatarColor(String name) {
    final colors = ['#10B981', '#6366F1', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899', '#14B8A6', '#F97316'];
    if (name.isEmpty) return colors[0];
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

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

  /// Attribute table row with copy button
  Component _attrRow(
    BuildContext context,
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isFirst = false,
    bool showAvatar = false,
    String? avatarInitial,
    String? rawCopyValue,
  }) {
    final copyText = rawCopyValue ?? value;

    return div(
      classes: 'flex items-center justify-between px-3.5 py-2 hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors ${isFirst ? '' : 'border-t'} group',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.borderInput},
      ),
      [
        span(
          classes: 'text-[11px] font-medium shrink-0',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text(label)],
        ),
        div(classes: 'flex items-center space-x-1.5 min-w-0', [
          if (showAvatar && avatarInitial != null)
            div(
              classes: 'w-4 h-4 rounded-full flex items-center justify-center font-bold text-white text-[8px] shadow-2xs shrink-0',
              styles: Styles(backgroundColor: Color(colorScheme.primary)),
              [Component.text(avatarInitial.toUpperCase())],
            ),
          span(
            classes: 'font-bold text-xs truncate max-w-[130px] select-all',
            styles: Styles(color: Color(colorScheme.textHeading)),
            attributes: {'title': value},
            [Component.text(value)],
          ),
          button(
            type: ButtonType.button,
            onClick: () {
              web.window.navigator.clipboard.writeText(copyText);
              context.showFlushbar(message: '$label copied to clipboard', type: FlushbarType.success);
            },
            classes: 'w-6 h-6 rounded-lg flex items-center justify-center border text-slate-400 hover:text-emerald-500 hover:border-emerald-500/40 transition-all cursor-pointer shrink-0 border-transparent hover:bg-slate-100 dark:hover:bg-slate-800 active:scale-95',
            attributes: {'title': 'Copy $label'},
            [
              div(classes: 'w-3 h-3', [const AppIcon(AppIcons.copy)]),
            ],
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
      case 'WAITING_FOR_CUSTOMER':
        return '#8B5CF6';
      default:
        return '#64748B';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Priority Chip with colored dot (disabled when closed)
// ─────────────────────────────────────────────────────────────

class _PriorityChip extends StatelessComponent {
  final String label;
  final String dotColor;
  final bool isSelected;
  final bool isDisabled;
  final ColorScheme colorScheme;
  final void Function() onTap;

  const _PriorityChip({
    required this.label,
    required this.dotColor,
    required this.isSelected,
    this.isDisabled = false,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Component build(BuildContext context) {
    return button(
      type: ButtonType.button,
      disabled: isDisabled,
      onClick: isDisabled ? () {} : onTap,
      classes: 'py-1.5 px-3 rounded-full text-[11px] font-bold border transition-all cursor-pointer flex items-center space-x-1.5 active:scale-95 disabled:opacity-40 disabled:cursor-not-allowed disabled:pointer-events-none',
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

class TagPill extends StatelessComponent {
  final String label;
  final ColorScheme colorScheme;

  const TagPill({
    super.key,
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
