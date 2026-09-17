import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/tasks/admin_task_item.dart';
import '../core/providers/admin_tasks_providers.dart';
import '../core/providers/ui_state_provider.dart';

class TaskDetailSidePanel extends StatelessComponent {
  final AdminTaskItem task;

  const TaskDetailSidePanel({
    required this.task,
    super.key,
  });

  static void show(BuildContext context, AdminTaskItem task) {
    context.showSidePanel(
      TaskDetailSidePanel(task: task),
      title: 'Task Details',
    );
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

  String _formatCurrency(num? amount) {
    if (amount == null) return '₦0.00';
    return '₦${amount.toStringAsFixed(2)}';
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;
    final taskId = task.id;

    final detailAsync = (taskId != null && taskId.isNotEmpty)
        ? context.watch(adminTaskDetailProvider(taskId))
        : null;
    final detail = detailAsync?.asData?.value;

    final title = detail?.title ?? task.title ?? 'Task Record';
    final status = (detail?.status ?? task.status ?? 'DRAFT').toUpperCase();
    final categoryName = task.category?.name ?? detail?.categoryId ?? 'General Task';
    final totalPrice = detail?.customerTotalPrice ?? task.customerTotalPrice;
    final platformFee = detail?.platformFee ?? task.platformFee;
    final providerPayout = detail?.providerPayout ?? task.providerPayout;

    final assignment = detail?.assignment ?? task.assignment;
    final customer = detail?.customer;
    final payout = detail?.payout;
    final locations = detail?.locations ?? [];
    final attachments = detail?.attachments ?? [];

    return div(classes: 'space-y-6 text-xs pb-8 relative', [
      // ─────────────────────────────────────────────────────────────
      // Hero Task Header Card
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
                'absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-emerald-500 via-teal-400 to-indigo-500',
            [],
          ),
          div(classes: 'flex items-start justify-between gap-3 pt-1', [
            div(classes: 'flex items-center space-x-3.5 min-w-0 flex-1', [
              // Icon Avatar
              div(
                classes:
                    'w-14 h-14 rounded-2xl border-2 shadow-md shrink-0 flex items-center justify-center bg-gradient-to-br from-emerald-500/20 to-teal-500/10',
                styles: Styles(raw: {'border-color': 'rgba(16, 185, 129, 0.4)'}),
                [
                  if (task.category?.imageUrl != null && task.category!.imageUrl!.isNotEmpty)
                    img(
                      src: task.category!.imageUrl!,
                      classes: 'w-8 h-8 object-contain',
                      alt: categoryName,
                    )
                  else
                    div(
                      classes: 'w-7 h-7 text-emerald-500',
                      [const AppIcon(AppIcons.tasks)],
                    ),
                ],
              ),
              div(classes: 'space-y-1 min-w-0 flex-1', [
                h4(
                  classes: 'font-black text-base truncate tracking-tight',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text(title)],
                ),
                p(
                  classes: 'text-xs font-medium truncate',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  [Component.text(categoryName)],
                ),
              ]),
            ]),
          ]),

          // Badges & Quick Action Row
          div(
            classes:
                'flex flex-wrap items-center justify-between gap-2.5 pt-3.5 border-t',
            styles: Styles(raw: {'border-color': colorScheme.border}),
            [
              div(classes: 'flex items-center space-x-2', [
                _buildStatusPill(status, isDark),
                if (detail?.dispatchStatus != null)
                  span(
                    classes:
                        'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border',
                    styles: Styles(
                      backgroundColor: isDark
                          ? Color.rgba(14, 165, 233, 0.18)
                          : Color.rgba(14, 165, 233, 0.1),
                      color: isDark
                          ? Color.rgba(125, 211, 252, 1.0)
                          : Color.rgba(3, 105, 161, 1.0),
                      raw: {
                        'border-color': isDark
                            ? 'rgba(14, 165, 233, 0.4)'
                            : 'rgba(14, 165, 233, 0.25)'
                      },
                    ),
                    [Component.text('Dispatch: ${detail!.dispatchStatus}')],
                  ),
              ]),

              div(classes: 'flex items-center space-x-2', [
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
                        _copyToClipboard(context, task.id ?? '', 'Task ID'),
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
      // Posted By (Customer) Section
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3', [
        _buildSectionHeader('Posted By (Customer)', AppIcons.customer, context),
        div(
          classes: 'border rounded-2xl p-4 shadow-sm space-y-3',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            div(classes: 'flex items-center space-x-3', [
              div(
                classes:
                    'w-10 h-10 rounded-full flex items-center justify-center font-bold text-sm shrink-0 border shadow-xs',
                styles: Styles(
                  backgroundColor: isDark ? Color.rgba(16, 185, 129, 0.15) : Color.rgba(16, 185, 129, 0.1),
                  color: Color(colorScheme.primary),
                  raw: {'border-color': 'rgba(16, 185, 129, 0.3)'},
                ),
                [
                  Component.text(
                    (customer?.fullname != null && customer!.fullname!.isNotEmpty)
                        ? customer.fullname![0].toUpperCase()
                        : 'C',
                  ),
                ],
              ),
              div(classes: 'min-w-0 flex-1 space-y-0.5', [
                div(
                  classes: 'font-bold text-sm truncate',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text(customer?.fullname ?? 'Platform Customer')],
                ),
                div(
                  classes: 'text-xs font-mono truncate',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  [Component.text(customer?.email ?? customer?.phoneNumber ?? 'ID: ${task.customerId ?? detail?.customerId ?? 'N/A'}')],
                ),
              ]),
              if (customer?.averageRatings != null)
                div(
                  classes:
                      'px-2.5 py-1 rounded-lg text-[11px] font-bold bg-amber-500/10 text-amber-500 border border-amber-500/20 shrink-0 flex items-center space-x-1',
                  [
                    Component.text('★ ${customer!.averageRatings!.toStringAsFixed(1)}'),
                  ],
                ),
            ]),
            div(
              classes: 'divide-y border-t pt-2 transition-colors',
              styles: Styles(raw: {'border-color': colorScheme.borderInput}),
              [
                _buildDetailRow('Customer ID', customer?.id ?? task.customerId ?? detail?.customerId ?? 'N/A', context, isCopyable: true),
                if (customer?.email != null && customer!.email!.isNotEmpty)
                  _buildDetailRow('Email Address', customer.email!, context, isCopyable: true),
                if (customer?.phoneNumber != null && customer!.phoneNumber!.isNotEmpty)
                  _buildDetailRow('Phone Number', customer.phoneNumber!, context, isCopyable: true),
                if (customer?.credibilityScore != null)
                  _buildDetailRow('Credibility Score', '${customer!.credibilityScore}', context),
              ],
            ),
          ],
        ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Assigned Provider Section
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3', [
        _buildSectionHeader('Assigned Provider', AppIcons.customersGroup, context),
        if (assignment != null && assignment.providerId != null && assignment.providerId!.isNotEmpty)
          div(
            classes: 'border rounded-2xl p-4 shadow-sm space-y-3',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              raw: {'border-color': colorScheme.border},
            ),
            [
              div(classes: 'flex items-center space-x-3', [
                div(
                  classes:
                      'w-10 h-10 rounded-full flex items-center justify-center font-bold text-sm shrink-0 border shadow-xs',
                  styles: Styles(
                    backgroundColor: isDark ? Color.rgba(59, 130, 246, 0.15) : Color.rgba(59, 130, 246, 0.1),
                    color: Color('#3b82f6'),
                    raw: {'border-color': 'rgba(59, 130, 246, 0.3)'},
                  ),
                  [
                    const AppIcon(AppIcons.customer),
                  ],
                ),
                div(classes: 'min-w-0 flex-1 space-y-0.5', [
                  div(
                    classes: 'font-bold text-sm truncate',
                    styles: Styles(color: Color(colorScheme.textHeading)),
                    [Component.text('Assigned Task Provider')],
                  ),
                  div(
                    classes: 'text-xs font-mono truncate',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text('ID: ${assignment.providerId}')],
                  ),
                ]),
                _buildStatusPill(assignment.status ?? 'ASSIGNED', isDark),
              ]),
              div(
                classes: 'divide-y border-t pt-2 transition-colors',
                styles: Styles(raw: {'border-color': colorScheme.borderInput}),
                [
                  _buildDetailRow('Assignment ID', assignment.id ?? 'N/A', context, isCopyable: true),
                  _buildDetailRow('Provider ID', assignment.providerId!, context, isCopyable: true),
                  _buildDetailRow('Assigned At', _formatDateTime(assignment.assignedAt), context),
                  _buildDetailRow('Started At', _formatDateTime(assignment.startedAt), context),
                  _buildDetailRow('Completed At', _formatDateTime(assignment.completedAt), context),
                ],
              ),
            ],
          )
        else
          div(
            classes:
                'p-4 rounded-2xl border flex items-center justify-between shadow-xs bg-amber-500/5 border-amber-500/20',
            [
              div(classes: 'flex items-center space-x-3', [
                div(
                  classes:
                      'w-8 h-8 rounded-full flex items-center justify-center text-amber-500 bg-amber-500/10 shrink-0',
                  [const AppIcon(AppIcons.infoCircle)],
                ),
                div([
                  div(
                    classes: 'font-bold text-xs text-amber-600 dark:text-amber-400',
                    [Component.text('No Provider Assigned Yet')],
                  ),
                  div(
                    classes: 'text-[11px] opacity-80',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text('Task is currently searching for eligible providers.')],
                  ),
                ]),
              ]),
              span(
                classes:
                    'px-2.5 py-1 rounded-lg text-[10.5px] font-bold uppercase tracking-wider bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20 whitespace-nowrap',
                [Component.text(status == 'DRAFT' ? 'DRAFT' : 'SEARCHING')],
              ),
            ],
          ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Financial & Pricing Summary Cards
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3', [
        _buildSectionHeader('Financial & Pricing Breakdown', AppIcons.transaction, context),
        div(classes: 'grid grid-cols-1 sm:grid-cols-3 gap-3', [
          _buildStatCard('Customer Price', _formatCurrency(totalPrice), colorScheme.primary, context),
          _buildStatCard('Platform Fee', _formatCurrency(platformFee), '#3b82f6', context),
          _buildStatCard('Provider Payout', _formatCurrency(providerPayout), '#10b981', context),
        ]),
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
            _buildDetailRow('Base Price', _formatCurrency(detail?.basePrice ?? task.basePrice), context),
            _buildDetailRow('Distance Fee', _formatCurrency(detail?.distanceFee ?? task.distanceFee), context),
            _buildDetailRow('Time Fee', _formatCurrency(detail?.timeFee ?? task.timeFee), context),
            _buildDetailRow('Urgency Fee', _formatCurrency(detail?.urgencyFee ?? task.urgencyFee), context),
            _buildDetailRow('Complexity Fee', _formatCurrency(detail?.complexityFee ?? task.complexityFee), context),
            _buildDetailRow('Surge Multiplier', '${detail?.surgeMultiplier ?? task.surgeMultiplier ?? 1.0}x', context),
          ],
        ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Task Details Overview
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3', [
        _buildSectionHeader('Task Specifications', AppIcons.documents, context),
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
            _buildDetailRow('Task ID', task.id ?? 'N/A', context, isCopyable: true),
            _buildDetailRow('Title', title, context),
            _buildDetailRow('Description', detail?.description ?? 'No description provided', context),
            _buildDetailRow('Category ID', task.categoryId ?? detail?.categoryId ?? 'N/A', context),
            _buildDetailRow('Service ID', task.serviceId ?? detail?.serviceId ?? 'N/A', context),
            _buildDetailRow('Region ID', detail?.regionId ?? 'Global', context),
            _buildDetailRow('Payment Status', detail?.paymentStatus ?? 'PENDING', context),
            _buildDetailRow('Scheduled Start', _formatDateTime(detail?.scheduledStartAt ?? task.scheduledStartAt), context),
            _buildDetailRow('Expires At', _formatDateTime(detail?.expiresAt), context),
            _buildDetailRow('Created At', _formatDateTime(detail?.createdAt ?? task.createdAt), context),
            _buildDetailRow('Last Updated', _formatDateTime(detail?.updatedAt), context),
          ],
        ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Security Pins & Dispatch Controls
      // ─────────────────────────────────────────────────────────────
      if (detail != null)
        div(classes: 'space-y-3', [
          _buildSectionHeader('Security PINs & Dispatch', AppIcons.kyc, context),
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
              _buildDetailRow('Start PIN', detail.startPin ?? assignment?.identityPin ?? 'Not set', context, isCopyable: detail.startPin != null || assignment?.identityPin != null),
              _buildDetailRow('Completion PIN', detail.completionPin ?? assignment?.cancellationPin ?? 'Not set', context, isCopyable: detail.completionPin != null || assignment?.cancellationPin != null),
              _buildDetailRow('Auto Dispatch Count', '${detail.autoDispatchCount ?? 0}', context),
              _buildDetailRow('Manual Dispatch Count', '${detail.manualDispatchCount ?? 0}', context),
              _buildDetailRow('Next Dispatch At', _formatDateTime(detail.nextDispatchAt), context),
              if (detail.cancellationReason != null && detail.cancellationReason!.isNotEmpty)
                _buildDetailRow('Cancellation Reason', detail.cancellationReason!, context),
              if (detail.cancelledBy != null && detail.cancelledBy!.isNotEmpty)
                _buildDetailRow('Cancelled By', detail.cancelledBy!, context),
            ],
          ),
        ]),

      // ─────────────────────────────────────────────────────────────
      // Locations
      // ─────────────────────────────────────────────────────────────
      if (locations.isNotEmpty)
        div(classes: 'space-y-3', [
          _buildSectionHeader('Task Locations', AppIcons.integration, context),
          div(classes: 'space-y-2', [
            for (final loc in locations)
              div(
                classes: 'p-3.5 border rounded-2xl space-y-1 shadow-sm',
                styles: Styles(
                  backgroundColor: Color(colorScheme.surface),
                  raw: {'border-color': colorScheme.border},
                ),
                [
                  div(classes: 'flex items-center justify-between', [
                    span(
                      classes: 'font-bold text-xs uppercase text-emerald-500',
                      [Component.text(loc.locationType ?? 'Location')],
                    ),
                    if (loc.distanceKm != null)
                      span(
                        classes: 'text-[11px] font-mono font-medium',
                        styles: Styles(color: Color(colorScheme.textMuted)),
                        [Component.text('${loc.distanceKm} km')],
                      ),
                  ]),
                  p(
                    classes: 'text-xs font-medium',
                    styles: Styles(color: Color(colorScheme.textPrimary)),
                    [Component.text(loc.address ?? 'No address string')],
                  ),
                  if (loc.city != null || loc.state != null)
                    p(
                      classes: 'text-[11px] font-medium',
                      styles: Styles(color: Color(colorScheme.textMuted)),
                      [Component.text([loc.city, loc.state, loc.country].where((e) => e != null && e.isNotEmpty).join(', '))],
                    ),
                ],
              ),
          ]),
        ]),

      // ─────────────────────────────────────────────────────────────
      // Attachments
      // ─────────────────────────────────────────────────────────────
      if (attachments.isNotEmpty)
        div(classes: 'space-y-3', [
          _buildSectionHeader('Task Attachments', AppIcons.documents, context),
          div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-2.5', [
            for (final att in attachments)
              div(
                classes: 'p-3 border rounded-xl flex items-center justify-between shadow-xs',
                styles: Styles(
                  backgroundColor: Color(colorScheme.surface),
                  raw: {'border-color': colorScheme.border},
                ),
                [
                  div(classes: 'min-w-0 flex-1 pr-2', [
                    div(
                      classes: 'font-bold text-xs truncate',
                      styles: Styles(color: Color(colorScheme.textHeading)),
                      [Component.text(att.fileName ?? 'Attachment')],
                    ),
                    div(
                      classes: 'text-[10.5px] font-mono',
                      styles: Styles(color: Color(colorScheme.textMuted)),
                      [Component.text(att.mimeType ?? 'File')],
                    ),
                  ]),
                  if (att.url != null && att.url!.isNotEmpty)
                    a(
                      href: att.url!,
                      target: Target.blank,
                      classes:
                          'px-2.5 py-1 rounded-lg text-[11px] font-bold border cursor-pointer transition-all flex items-center space-x-1',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        color: Color(colorScheme.primary),
                        raw: {'border-color': colorScheme.borderInput},
                      ),
                      [
                        const div(classes: 'w-3 h-3', [AppIcon(AppIcons.externalLink)]),
                        span([Component.text('View')]),
                      ],
                    ),
                ],
              ),
          ]),
        ]),

      // ─────────────────────────────────────────────────────────────
      // Payout Ledger Summary
      // ─────────────────────────────────────────────────────────────
      if (payout != null)
        div(classes: 'space-y-3', [
          _buildSectionHeader('Payout Ledger Details', AppIcons.salesTag, context),
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
              _buildDetailRow('Payout ID', payout.id ?? 'N/A', context, isCopyable: true),
              _buildDetailRow('Payout Status', payout.status ?? 'PENDING', context),
              _buildDetailRow('Payout Amount', _formatCurrency(payout.payoutAmount), context),
              _buildDetailRow('Customer Payment', _formatCurrency(payout.customerPaymentAmount), context),
              _buildDetailRow('Reference', payout.reference ?? 'N/A', context, isCopyable: payout.reference != null),
              _buildDetailRow('Description', payout.description ?? '—', context),
              _buildDetailRow('Generated At', _formatDateTime(payout.urlGeneratedAt), context),
            ],
          ),
        ]),
    ]);
  }

  Component _buildStatCard(
    String label,
    String value,
    String accentColorHex,
    BuildContext context,
  ) {
    final colorScheme = context.colorScheme;
    return div(
      classes: 'p-3.5 rounded-2xl border flex flex-col justify-between space-y-1.5 shadow-sm',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        span(
          classes: 'text-[11px] font-bold uppercase tracking-wider',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text(label)],
        ),
        h4(
          classes: 'text-base font-black tracking-tight font-mono',
          styles: Styles(color: Color(accentColorHex)),
          [Component.text(value)],
        ),
      ],
    );
  }

  Component _buildStatusPill(String status, bool isDark) {
    Color bg;
    Color fg;
    String border;

    switch (status) {
      case 'COMPLETED':
        bg = isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1);
        fg = isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0);
        border = isDark ? 'rgba(16, 185, 129, 0.4)' : 'rgba(16, 185, 129, 0.25)';
        break;
      case 'IN_PROGRESS':
      case 'ASSIGNED':
        bg = isDark ? Color.rgba(59, 130, 246, 0.18) : Color.rgba(59, 130, 246, 0.1);
        fg = isDark ? Color.rgba(147, 197, 253, 1.0) : Color.rgba(29, 78, 216, 1.0);
        border = isDark ? 'rgba(59, 130, 246, 0.4)' : 'rgba(59, 130, 246, 0.25)';
        break;
      case 'CANCELLED':
      case 'EXPIRED':
        bg = isDark ? Color.rgba(244, 63, 94, 0.18) : Color.rgba(244, 63, 94, 0.1);
        fg = isDark ? Color.rgba(253, 164, 175, 1.0) : Color.rgba(190, 18, 60, 1.0);
        border = isDark ? 'rgba(244, 63, 94, 0.4)' : 'rgba(244, 63, 94, 0.25)';
        break;
      case 'SEARCHING':
      case 'POSTED':
      case 'PENDING':
      case 'DRAFT':
      default:
        bg = isDark ? Color.rgba(245, 158, 11, 0.18) : Color.rgba(245, 158, 11, 0.1);
        fg = isDark ? Color.rgba(252, 211, 77, 1.0) : Color.rgba(180, 83, 9, 1.0);
        border = isDark ? 'rgba(245, 158, 11, 0.4)' : 'rgba(245, 158, 11, 0.25)';
        break;
    }

    return span(
      classes:
          'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border',
      styles: Styles(
        backgroundColor: bg,
        color: fg,
        raw: {'border-color': border},
      ),
      [Component.text(status)],
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
