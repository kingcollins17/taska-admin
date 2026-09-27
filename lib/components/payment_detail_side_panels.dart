import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/payments/admin_payout_item.dart';
import '../core/models/clients/payments/admin_transaction_item.dart';
import '../core/providers/admin_payments_providers.dart';
import '../core/providers/ui_state_provider.dart';

// ─────────────────────────────────────────────────────────────
// Transaction Detail Side Panel
// ─────────────────────────────────────────────────────────────

class TransactionDetailSidePanel extends StatelessComponent {
  final AdminTransactionItem transaction;

  const TransactionDetailSidePanel({
    required this.transaction,
    super.key,
  });

  static void show(BuildContext context, AdminTransactionItem transaction) {
    context.showSidePanel(
      TransactionDetailSidePanel(transaction: transaction),
      title: 'Transaction Details',
    );
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    final amountStr = transaction.amount != null
        ? '₦${transaction.amount!.toStringAsFixed(2)}'
        : 'N/A';

    return div(classes: 'space-y-6 text-xs p-1', [
      // Top Overview Header Card
      div(
        classes: 'p-5 rounded-2xl border space-y-3 transition-all',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [
          div(classes: 'flex items-center justify-between', [
            span(
              classes: 'text-[11px] font-bold uppercase tracking-wider',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text('Transaction Amount')],
            ),
            _StatusBadge(status: transaction.status ?? 'PENDING', colorScheme: colorScheme),
          ]),
          div(
            classes: 'text-2xl sm:text-3xl font-extrabold tracking-tight',
            styles: Styles(color: Color(colorScheme.primary)),
            [Component.text(amountStr)],
          ),
          div(classes: 'flex flex-wrap items-center gap-2 pt-1', [
            span(
              classes: 'px-2.5 py-1 rounded-md text-[10.5px] font-bold uppercase tracking-wider border',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.textSecondary),
                raw: {'border-color': colorScheme.borderInput},
              ),
              [Component.text(transaction.transactionType ?? 'PAYMENT')],
            ),
            if (transaction.reference != null && transaction.reference!.isNotEmpty)
              span(
                classes: 'font-mono text-[11px] text-slate-400',
                [Component.text('Ref: ${transaction.reference}')],
              ),
          ]),
        ],
      ),

      // Key Attributes Section
      div(
        classes: 'p-5 rounded-2xl border space-y-4 transition-all',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [
          h4(
            classes: 'text-xs font-bold uppercase tracking-wider pb-2 border-b',
            styles: Styles(
              color: Color(colorScheme.textHeading),
              raw: {'border-color': colorScheme.border},
            ),
            [Component.text('Transaction Attributes')],
          ),
          div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-4', [
            _DetailItem(label: 'Transaction ID', value: transaction.id ?? 'N/A', isMono: true, colorScheme: colorScheme),
            _DetailItem(label: 'User ID', value: transaction.userId ?? 'N/A', isMono: true, colorScheme: colorScheme),
            _DetailItem(label: 'Task ID', value: transaction.taskId ?? 'N/A', isMono: true, colorScheme: colorScheme),
            _DetailItem(label: 'Gateway Reference', value: transaction.reference ?? 'N/A', isMono: true, colorScheme: colorScheme),
            _DetailItem(label: 'Created At', value: _formatDate(transaction.createdAt), colorScheme: colorScheme),
            _DetailItem(label: 'Updated At', value: _formatDate(transaction.updatedAt), colorScheme: colorScheme),
          ]),
        ],
      ),

      // Task Breakdown (if available)
      if (transaction.task != null)
        div(
          classes: 'p-5 rounded-2xl border space-y-4 transition-all',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            h4(
              classes: 'text-xs font-bold uppercase tracking-wider pb-2 border-b flex items-center justify-between',
              styles: Styles(
                color: Color(colorScheme.textHeading),
                raw: {'border-color': colorScheme.border},
              ),
              [
                Component.text('Associated Task Info'),
                span(
                  classes: 'px-2 py-0.5 rounded text-[10px] font-bold uppercase',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.primary),
                  ),
                  [Component.text(transaction.task?.status ?? 'STATUS')],
                ),
              ],
            ),
            div(classes: 'space-y-2', [
              div(
                classes: 'font-bold text-sm',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text(transaction.task?.title ?? 'No Task Title')],
              ),
              if (transaction.task?.description != null && transaction.task!.description!.isNotEmpty)
                p(
                  classes: 'text-xs leading-relaxed',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  [Component.text(transaction.task!.description!)],
                ),
            ]),
            div(classes: 'grid grid-cols-3 gap-2 pt-2 text-center', [
              div(
                classes: 'p-2.5 rounded-xl border space-y-1',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                [
                  span(classes: 'text-[10px] text-slate-400 font-medium block', [Component.text('Customer Total')]),
                  span(
                    classes: 'font-bold text-xs',
                    styles: Styles(color: Color(colorScheme.textHeading)),
                    [Component.text('₦${(transaction.task?.customerTotalPrice ?? 0).toStringAsFixed(2)}')],
                  ),
                ],
              ),
              div(
                classes: 'p-2.5 rounded-xl border space-y-1',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                [
                  span(classes: 'text-[10px] text-slate-400 font-medium block', [Component.text('Platform Fee')]),
                  span(
                    classes: 'font-bold text-xs text-amber-500',
                    [Component.text('₦${(transaction.task?.platformFee ?? 0).toStringAsFixed(2)}')],
                  ),
                ],
              ),
              div(
                classes: 'p-2.5 rounded-xl border space-y-1',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                [
                  span(classes: 'text-[10px] text-slate-400 font-medium block', [Component.text('Provider Payout')]),
                  span(
                    classes: 'font-bold text-xs text-emerald-500',
                    [Component.text('₦${(transaction.task?.providerPayout ?? 0).toStringAsFixed(2)}')],
                  ),
                ],
              ),
            ]),
          ],
        ),

      // Metadata Info Box (if non-empty)
      if (transaction.metadataInfo != null && transaction.metadataInfo!.isNotEmpty)
        div(
          classes: 'p-5 rounded-2xl border space-y-3 transition-all',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            h4(
              classes: 'text-xs font-bold uppercase tracking-wider pb-2 border-b',
              styles: Styles(
                color: Color(colorScheme.textHeading),
                raw: {'border-color': colorScheme.border},
              ),
              [Component.text('Metadata Info')],
            ),
            div(
              classes: 'p-3 rounded-xl font-mono text-[11px] overflow-x-auto leading-relaxed',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.textPrimary),
                raw: {'border-color': colorScheme.borderInput},
              ),
              [
                for (final entry in transaction.metadataInfo!.entries)
                  div(classes: 'flex items-start justify-between py-1 border-b border-slate-200/40 dark:border-slate-800/40 last:border-none', [
                    span(classes: 'font-bold text-slate-500 mr-2', [Component.text('${entry.key}:')]),
                    span(classes: 'text-right break-all', [Component.text('${entry.value}')]),
                  ]),
              ],
            ),
          ],
        ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Payout Detail Side Panel
// ─────────────────────────────────────────────────────────────

class PayoutDetailSidePanel extends StatefulComponent {
  final AdminPayoutItem payout;

  const PayoutDetailSidePanel({
    required this.payout,
    super.key,
  });

  static void show(BuildContext context, AdminPayoutItem payout) {
    context.showSidePanel(
      PayoutDetailSidePanel(payout: payout),
      title: 'Payout Details',
    );
  }

  @override
  State<PayoutDetailSidePanel> createState() => _PayoutDetailSidePanelState();
}

class _PayoutDetailSidePanelState extends State<PayoutDetailSidePanel> {
  bool isSubmitting = false;

  void _triggerTransfer(BuildContext context) async {
    final payoutId = component.payout.id;
    if (payoutId == null || payoutId.isEmpty) return;

    setState(() {
      isSubmitting = true;
    });

    await context.read(adminPaymentsNotifierProvider.notifier).transferPayout(
      payoutId,
      onSuccess: (message) {
        if (mounted) {
          setState(() {
            isSubmitting = false;
          });
          context.hideSidePanel();
          context.showFlushbar(
            message: message,
            title: 'Transfer Triggered',
            type: FlushbarType.success,
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            isSubmitting = false;
          });
          context.showFlushbar(
            message: error,
            title: 'Transfer Failed',
            type: FlushbarType.error,
          );
        }
      },
    );
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));
    final payout = component.payout;
    final isCustomerPaid = (payout.status ?? '').toUpperCase() == 'CUSTOMER_PAID';

    final payoutAmountStr = payout.payoutAmount != null
        ? '₦${payout.payoutAmount!.toStringAsFixed(2)}'
        : 'N/A';

    final customerPaidAmountStr = payout.customerPaymentAmount != null
        ? '₦${payout.customerPaymentAmount!.toStringAsFixed(2)}'
        : 'N/A';

    return div(classes: 'space-y-6 text-xs p-1', [
      // Top Overview Header Card
      div(
        classes: 'p-5 rounded-2xl border space-y-3 transition-all',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [
          div(classes: 'flex items-center justify-between', [
            span(
              classes: 'text-[11px] font-bold uppercase tracking-wider',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text('Provider Payout Amount')],
            ),
            _StatusBadge(status: payout.status ?? 'PENDING', colorScheme: colorScheme),
          ]),
          div(
            classes: 'text-2xl sm:text-3xl font-extrabold tracking-tight',
            styles: Styles(color: Color(colorScheme.primary)),
            [Component.text(payoutAmountStr)],
          ),
          div(classes: 'flex flex-wrap items-center justify-between pt-1 text-xs', [
            span(classes: 'text-slate-400 font-medium', [
              Component.text('Customer Paid: '),
              strong(
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text(customerPaidAmountStr)],
              ),
            ]),
            if (payout.reference != null && payout.reference!.isNotEmpty)
              span(
                classes: 'font-mono text-[11px] text-slate-400',
                [Component.text('Ref: ${payout.reference}')],
              ),
          ]),
        ],
      ),

      // Trigger Transfer Action Callout (If CUSTOMER_PAID)
      if (isCustomerPaid)
        div(
          classes: 'p-5 rounded-2xl border space-y-3 bg-emerald-500/10 border-emerald-500/30 transition-all',
          [
            div(classes: 'flex items-center space-x-2 text-emerald-600 dark:text-emerald-400 font-bold text-xs', [
              div(classes: 'w-4 h-4', [const AppIcon(AppIcons.checkCircle)]),
              span([Component.text('Payout Ready for Provider Transfer')]),
            ]),
            p(
              classes: 'text-xs text-slate-600 dark:text-slate-300 leading-relaxed',
              [
                Component.text(
                  'The customer has successfully paid for this task. You can now initiate the payout transfer to the provider.',
                ),
              ],
            ),
            button(
              type: ButtonType.button,
              onClick: isSubmitting ? null : () => _triggerTransfer(context),
              classes:
                  'w-full py-2.5 px-4 rounded-xl text-white font-bold text-xs shadow-md transition-all cursor-pointer flex items-center justify-center space-x-2 active:scale-98 border-none',
              styles: Styles(backgroundColor: Color(colorScheme.primary)),
              [
                if (isSubmitting)
                  span(classes: 'animate-spin border-2 border-white border-t-transparent rounded-full w-4 h-4 mr-2', [])
                else
                  div(classes: 'w-4 h-4', [const AppIcon(AppIcons.externalLink)]),
                span([Component.text(isSubmitting ? 'Initiating Transfer...' : 'Trigger Provider Payout Transfer')]),
              ],
            ),
          ],
        ),

      // Attributes Grid
      div(
        classes: 'p-5 rounded-2xl border space-y-4 transition-all',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [
          h4(
            classes: 'text-xs font-bold uppercase tracking-wider pb-2 border-b',
            styles: Styles(
              color: Color(colorScheme.textHeading),
              raw: {'border-color': colorScheme.border},
            ),
            [Component.text('Payout Attributes')],
          ),
          div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-4', [
            _DetailItem(label: 'Payout ID', value: payout.id ?? 'N/A', isMono: true, colorScheme: colorScheme),
            _DetailItem(label: 'Provider ID', value: payout.providerId ?? 'N/A', isMono: true, colorScheme: colorScheme),
            _DetailItem(label: 'Customer ID', value: payout.customerId ?? 'N/A', isMono: true, colorScheme: colorScheme),
            _DetailItem(label: 'Task ID', value: payout.taskId ?? 'N/A', isMono: true, colorScheme: colorScheme),
            _DetailItem(label: 'Reference', value: payout.reference ?? 'N/A', isMono: true, colorScheme: colorScheme),
            _DetailItem(label: 'Created At', value: _formatDate(payout.createdAt), colorScheme: colorScheme),
            _DetailItem(label: 'URL Generated At', value: _formatDate(payout.urlGeneratedAt), colorScheme: colorScheme),
            _DetailItem(label: 'Updated At', value: _formatDate(payout.updatedAt), colorScheme: colorScheme),
          ]),
          if (payout.description != null && payout.description!.isNotEmpty)
            div(classes: 'pt-2 space-y-1 border-t', styles: Styles(raw: {'border-color': colorScheme.border}), [
              span(classes: 'text-[11px] font-bold text-slate-400 block', [Component.text('Description')]),
              p(classes: 'text-xs leading-relaxed font-medium', styles: Styles(color: Color(colorScheme.textPrimary)), [
                Component.text(payout.description!),
              ]),
            ]),
          if (payout.paymentUrl != null && payout.paymentUrl!.isNotEmpty)
            div(classes: 'pt-2 space-y-1', [
              span(classes: 'text-[11px] font-bold text-slate-400 block', [Component.text('Payment URL')]),
              a(
                href: payout.paymentUrl!,
                target: Target.blank,
                classes: 'text-xs font-mono underline font-medium truncate block hover:opacity-80',
                styles: Styles(color: Color(colorScheme.primary)),
                [Component.text(payout.paymentUrl!)],
              ),
            ]),
        ],
      ),

      // Task Summary Card
      if (payout.task != null)
        div(
          classes: 'p-5 rounded-2xl border space-y-3 transition-all',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            h4(
              classes: 'text-xs font-bold uppercase tracking-wider pb-2 border-b flex items-center justify-between',
              styles: Styles(
                color: Color(colorScheme.textHeading),
                raw: {'border-color': colorScheme.border},
              ),
              [
                Component.text('Associated Task'),
                span(
                  classes: 'px-2 py-0.5 rounded text-[10px] font-bold uppercase',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.primary),
                  ),
                  [Component.text(payout.task?.status ?? 'STATUS')],
                ),
              ],
            ),
            div(
              classes: 'font-bold text-sm',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text(payout.task?.title ?? 'No Title')],
            ),
            if (payout.task?.description != null && payout.task!.description!.isNotEmpty)
              p(
                classes: 'text-xs leading-relaxed',
                styles: Styles(color: Color(colorScheme.textSecondary)),
                [Component.text(payout.task!.description!)],
              ),
          ],
        ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Shared Sub-components
// ─────────────────────────────────────────────────────────────

class _DetailItem extends StatelessComponent {
  final String label;
  final String value;
  final bool isMono;
  final ColorScheme colorScheme;

  const _DetailItem({
    required this.label,
    required this.value,
    this.isMono = false,
    required this.colorScheme,
  });

  @override
  Component build(BuildContext context) {
    return div(classes: 'space-y-1', [
      span(
        classes: 'text-[10.5px] font-bold uppercase tracking-wider block',
        styles: Styles(color: Color(colorScheme.textMuted)),
        [Component.text(label)],
      ),
      div(
        classes: 'text-xs font-semibold truncate ${isMono ? 'font-mono' : ''}',
        styles: Styles(color: Color(colorScheme.textHeading)),
        [Component.text(value)],
      ),
    ]);
  }
}

class _StatusBadge extends StatelessComponent {
  final String status;
  final ColorScheme colorScheme;

  const _StatusBadge({required this.status, required this.colorScheme});

  @override
  Component build(BuildContext context) {
    String bg = 'bg-slate-100 dark:bg-slate-800';
    String text = 'text-slate-700 dark:text-slate-300';
    String border = 'border-slate-200 dark:border-slate-700';

    switch (status.toUpperCase()) {
      case 'SUCCESS':
      case 'COMPLETED':
        bg = 'bg-emerald-50 dark:bg-emerald-950/60';
        text = 'text-emerald-600 dark:text-emerald-400';
        border = 'border-emerald-200/50 dark:border-emerald-800/50';
        break;
      case 'CUSTOMER_PAID':
        bg = 'bg-sky-50 dark:bg-sky-950/60';
        text = 'text-sky-600 dark:text-sky-400';
        border = 'border-sky-200/50 dark:border-sky-800/50';
        break;
      case 'TRANSFER_INITIATED':
        bg = 'bg-indigo-50 dark:bg-indigo-950/60';
        text = 'text-indigo-600 dark:text-indigo-400';
        border = 'border-indigo-200/50 dark:border-indigo-800/50';
        break;
      case 'PENDING':
        bg = 'bg-amber-50 dark:bg-amber-950/60';
        text = 'text-amber-600 dark:text-amber-400';
        border = 'border-amber-200/50 dark:border-amber-800/50';
        break;
      case 'FAILED':
        bg = 'bg-rose-50 dark:bg-rose-950/60';
        text = 'text-rose-600 dark:text-rose-400';
        border = 'border-rose-200/50 dark:border-rose-800/50';
        break;
    }

    return span(
      classes: 'px-2.5 py-1 rounded-full text-[10.5px] font-bold inline-block leading-none tracking-tight border $bg $text $border',
      [Component.text(status)],
    );
  }
}

String _formatDate(DateTime? dt) {
  if (dt == null) return 'N/A';
  return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
