import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/payment_detail_side_panels.dart';
import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/payments/admin_payout_item.dart';
import '../core/providers/admin_payments_providers.dart';
import '../core/providers/ui_state_provider.dart';

@client
class PaymentsPage extends StatefulComponent {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  int activeTab = 0; // 0: Transactions, 1: Payouts

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex-1 space-y-6 relative', [
      const _Header(),
      _TabBar(
        activeTab: activeTab,
        onTabChanged: (index) => setState(() => activeTab = index),
      ),
      if (activeTab == 0)
        const _TransactionsTable()
      else
        const _PayoutsTable(),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Header Component
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
              'Inspect transaction ledgers, audit customer payment receipts, track provider payouts, and authorize transfers.',
            ),
          ],
        ),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Tab Bar Switcher Component
// ─────────────────────────────────────────────────────────────

class _TabBar extends StatelessComponent {
  final int activeTab;
  final void Function(int index) onTabChanged;

  const _TabBar({
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return div(
      classes: 'flex items-center space-x-2 border-b pb-2 text-xs font-bold transition-colors',
      styles: Styles(raw: {'border-color': colorScheme.border}),
      [
        button(
          type: ButtonType.button,
          onClick: () => onTabChanged(0),
          classes:
              'px-4 py-2.5 rounded-xl transition-all cursor-pointer flex items-center space-x-2 border',
          styles: activeTab == 0
              ? Styles(
                  backgroundColor: Color(colorScheme.primary),
                  color: Color('#FFFFFF'),
                  raw: {'border-color': colorScheme.primary},
                )
              : Styles(
                  backgroundColor: Color(colorScheme.surface),
                  color: Color(colorScheme.textSecondary),
                  raw: {'border-color': colorScheme.borderInput},
                ),
          [
            div(classes: 'w-4 h-4', [ AppIcon(AppIcons.transaction)]),
            span([Component.text('Transactions Ledger')]),
          ],
        ),
        button(
          type: ButtonType.button,
          onClick: () => onTabChanged(1),
          classes:
              'px-4 py-2.5 rounded-xl transition-all cursor-pointer flex items-center space-x-2 border',
          styles: activeTab == 1
              ? Styles(
                  backgroundColor: Color(colorScheme.primary),
                  color: Color('#FFFFFF'),
                  raw: {'border-color': colorScheme.primary},
                )
              : Styles(
                  backgroundColor: Color(colorScheme.surface),
                  color: Color(colorScheme.textSecondary),
                  raw: {'border-color': colorScheme.borderInput},
                ),
          [
            div(classes: 'w-4 h-4', [const AppIcon(AppIcons.documents)]),
            span([Component.text('Provider Payouts')]),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Transactions Table Component
// ─────────────────────────────────────────────────────────────

class _TransactionsTable extends StatefulComponent {
  const _TransactionsTable();

  @override
  State<_TransactionsTable> createState() => _TransactionsTableState();
}

class _TransactionsTableState extends State<_TransactionsTable> {
  String searchQuery = '';
  String _searchInputValue = '';
  Timer? _searchDebounceTimer;

  String selectedStatus = 'All';
  String selectedType = 'All';
  bool isFilterOpen = false;
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

  void _resetFilters() {
    _searchDebounceTimer?.cancel();
    _searchInputValue = '';
    setState(() {
      searchQuery = '';
      selectedStatus = 'All';
      selectedType = 'All';
      currentPage = 1;
    });
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    final searchTrimmed = searchQuery.trim();
    final transactionsAsync = context.watch(
      listTransactionsProvider(
        ListTransactionsParams(
          search: searchTrimmed.isEmpty ? null : searchTrimmed,
          status: selectedStatus == 'All' ? null : selectedStatus,
          transactionType: selectedType == 'All' ? null : selectedType,
          page: currentPage,
          perPage: 20,
        ),
      ),
    );

    return transactionsAsync.when(
      data: (paginatedData) {
        final items = paginatedData?.items ?? [];
        final total = paginatedData?.total ?? items.length;
        final perPage = paginatedData?.perPage ?? 20;

        return div(
          classes: 'border rounded-2xl p-5 sm:p-6 shadow-sm space-y-5 transition-all',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            // Toolbar Header
            div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4', [
              div(classes: 'flex items-center space-x-2', [
                h3(
                  classes: 'text-base font-bold tracking-tight',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text('Transactions Ledger')],
                ),
                span(
                  classes: 'text-xs font-semibold px-2.5 py-0.5 rounded-full',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.primary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  [
                    Component.text('${items.length} of $total'),
                  ],
                ),
              ]),

              div(classes: 'flex flex-wrap items-center gap-3', [
                // Search Input Pill
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
                    attributes: {'placeholder': 'Search by id:, task:, user:, ref:...'},
                    onInput: _onSearchInput,
                  ),
                ]),

                // Filter Toggle Button
                button(
                  onClick: () {
                    setState(() {
                      isFilterOpen = !isFilterOpen;
                    });
                  },
                  classes:
                      'text-xs font-semibold px-3.5 py-2 rounded-xl flex items-center space-x-1.5 transition-colors cursor-pointer border',
                  styles: isFilterOpen || selectedStatus != 'All' || selectedType != 'All'
                      ? Styles(
                          backgroundColor: Color(colorScheme.primary),
                          color: Color('#FFFFFF'),
                          raw: {'border-color': colorScheme.primary},
                        )
                      : Styles(
                          backgroundColor: Color(colorScheme.inputBg),
                          color: Color(colorScheme.textPrimary),
                          raw: {'border-color': colorScheme.borderInput},
                        ),
                  [
                    const AppIcon(AppIcons.filter),
                    span([Component.text('Filter')]),
                  ],
                ),

                if (selectedStatus != 'All' || selectedType != 'All' || searchQuery.isNotEmpty)
                  button(
                    onClick: _resetFilters,
                    classes: 'text-xs font-bold text-rose-500 hover:underline cursor-pointer border-none bg-transparent',
                    [Component.text('Reset')],
                  ),
              ]),
            ]),

            // Expandable Filter Bar
            if (isFilterOpen)
              _TransactionsFilterBar(
                colorScheme: colorScheme,
                selectedStatus: selectedStatus,
                selectedType: selectedType,
                onSelectStatus: (st) => setState(() {
                  selectedStatus = st;
                  currentPage = 1;
                }),
                onSelectType: (tp) => setState(() {
                  selectedType = tp;
                  currentPage = 1;
                }),
              ),

            // Transactions Data Table
            if (items.isEmpty)
              _EmptyState(colorScheme: colorScheme, message: 'No matching transactions found', onResetFilters: _resetFilters)
            else
              div(
                classes: 'overflow-x-auto rounded-xl border transition-colors',
                styles: Styles(raw: {'border-color': colorScheme.border}),
                [
                  table(classes: 'w-full min-w-[950px] text-left border-collapse text-xs', [
                    thead(
                      classes: 'uppercase tracking-wider text-[10.5px] border-b font-bold',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        color: Color(colorScheme.textMuted),
                        raw: {'border-color': colorScheme.border},
                      ),
                      [
                        tr([
                          th(classes: 'p-3.5 pl-4 whitespace-nowrap', [Component.text('Transaction ID')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Type')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Amount')]),
                          th(classes: 'p-3.5 text-center whitespace-nowrap', [Component.text('Status')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('User ID')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Task ID / Title')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Reference')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Created At')]),
                          th(classes: 'p-3.5 pr-4 text-center whitespace-nowrap', [Component.text('Action')]),
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
                        for (final item in items)
                          tr(
                            classes: 'hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors cursor-pointer',
                            events: {
                              'click': (_) => TransactionDetailSidePanel.show(context, item),
                            },
                            [
                              td(
                                classes: 'p-3.5 pl-4 font-mono font-bold text-[11px] whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textMuted)),
                                [Component.text(_formatId(item.id))],
                              ),
                              td(classes: 'p-3.5 whitespace-nowrap', [
                                span(
                                  classes: 'px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider border',
                                  styles: Styles(
                                    backgroundColor: Color(colorScheme.inputBg),
                                    color: Color(colorScheme.textSecondary),
                                    raw: {'border-color': colorScheme.borderInput},
                                  ),
                                  [Component.text(item.transactionType ?? 'PAYMENT')],
                                ),
                              ]),
                              td(
                                classes: 'p-3.5 font-bold text-xs whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textHeading)),
                                [Component.text(item.amount != null ? '₦${item.amount!.toStringAsFixed(2)}' : 'N/A')],
                              ),
                              td(classes: 'p-3.5 text-center whitespace-nowrap', [
                                _StatusBadgePill(status: item.status ?? 'PENDING', colorScheme: colorScheme),
                              ]),
                              td(
                                classes: 'p-3.5 font-mono text-xs font-semibold whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textSecondary)),
                                [Component.text(_formatId(item.userId))],
                              ),
                              td(classes: 'p-3.5 max-w-xs whitespace-nowrap', [
                                div(
                                  classes: 'font-semibold text-xs truncate',
                                  styles: Styles(color: Color(colorScheme.textPrimary)),
                                  [Component.text(item.task?.title ?? _formatId(item.taskId))],
                                ),
                              ]),
                              td(
                                classes: 'p-3.5 font-mono text-[11px] whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textMuted)),
                                [Component.text(item.reference ?? 'N/A')],
                              ),
                              td(
                                classes: 'p-3.5 text-xs font-medium whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textMuted)),
                                [Component.text(_formatDate(item.createdAt))],
                              ),
                              td(classes: 'p-3.5 pr-4 text-center whitespace-nowrap', [
                                button(
                                  onClick: () => TransactionDetailSidePanel.show(context, item),
                                  classes:
                                      'text-white text-[11px] font-bold px-3 py-1.5 rounded-lg shadow-xs transition-all cursor-pointer border-none whitespace-nowrap shrink-0',
                                  styles: Styles(backgroundColor: Color(colorScheme.primary)),
                                  [Component.text('View Details')],
                                ),
                              ]),
                            ],
                          ),
                      ],
                    ),
                  ]),
                ],
              ),

            // Pagination Footer Bar
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
          ],
        );
      },
      loading: () => _ShimmerLoading(colorScheme: colorScheme),
      error: (err, stack) => _ErrorState(
        colorScheme: colorScheme,
        errorMsg: err.toString(),
        onRetry: () => setState(() {}),
      ),
    );
  }
}

class _TransactionsFilterBar extends StatelessComponent {
  final AppColorScheme colorScheme;
  final String selectedStatus;
  final String selectedType;
  final void Function(String status) onSelectStatus;
  final void Function(String type) onSelectType;

  const _TransactionsFilterBar({
    required this.colorScheme,
    required this.selectedStatus,
    required this.selectedType,
    required this.onSelectStatus,
    required this.onSelectType,
  });

  @override
  Component build(BuildContext context) {
    final statusOptions = ['All', 'PENDING', 'SUCCESS', 'FAILED'];
    final typeOptions = ['All', 'TASK_PAYMENT', 'PROVIDER_PAYOUT'];

    return div(
      classes: 'p-4 rounded-xl border space-y-3 transition-all shadow-2xs',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.borderInput},
      ),
      [
        div(classes: 'space-y-1.5', [
          span(
            classes: 'text-[11px] font-black uppercase tracking-wider block',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text('Filter Status:')],
          ),
          div(classes: 'flex flex-wrap items-center gap-1.5', [
            for (final st in statusOptions)
              _ChipButton(
                label: st,
                isSelected: selectedStatus == st,
                colorScheme: colorScheme,
                onSelect: () => onSelectStatus(st),
              ),
          ]),
        ]),

        div(classes: 'space-y-1.5 pt-2 border-t', styles: Styles(raw: {'border-color': colorScheme.borderInput}), [
          span(
            classes: 'text-[11px] font-black uppercase tracking-wider block',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text('Filter Transaction Type:')],
          ),
          div(classes: 'flex flex-wrap items-center gap-1.5', [
            for (final tp in typeOptions)
              _ChipButton(
                label: tp,
                isSelected: selectedType == tp,
                colorScheme: colorScheme,
                onSelect: () => onSelectType(tp),
              ),
          ]),
        ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Payouts Table Component
// ─────────────────────────────────────────────────────────────

class _PayoutsTable extends StatefulComponent {
  const _PayoutsTable();

  @override
  State<_PayoutsTable> createState() => _PayoutsTableState();
}

class _PayoutsTableState extends State<_PayoutsTable> {
  String searchQuery = '';
  String _searchInputValue = '';
  Timer? _searchDebounceTimer;

  String selectedStatus = 'All';
  bool isFilterOpen = false;
  int currentPage = 1;
  String? processingPayoutId;

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

  void _resetFilters() {
    _searchDebounceTimer?.cancel();
    _searchInputValue = '';
    setState(() {
      searchQuery = '';
      selectedStatus = 'All';
      currentPage = 1;
    });
  }

  void _triggerTransfer(BuildContext context, String payoutId) async {
    setState(() {
      processingPayoutId = payoutId;
    });

    await context.read(adminPaymentsNotifierProvider.notifier).transferPayout(
      payoutId,
      onSuccess: (message) {
        if (mounted) {
          setState(() {
            processingPayoutId = null;
          });
          context.showFlushbar(
            message: message,
            title: 'Payout Transfer Triggered',
            type: FlushbarType.success,
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            processingPayoutId = null;
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

    final searchTrimmed = searchQuery.trim();
    final payoutsAsync = context.watch(
      listPayoutsProvider(
        ListPayoutsParams(
          search: searchTrimmed.isEmpty ? null : searchTrimmed,
          status: selectedStatus == 'All' ? null : selectedStatus,
          page: currentPage,
          perPage: 20,
        ),
      ),
    );

    return payoutsAsync.when(
      data: (paginatedData) {
        final items = paginatedData?.items ?? [];
        final total = paginatedData?.total ?? items.length;
        final perPage = paginatedData?.perPage ?? 20;

        return div(
          classes: 'border rounded-2xl p-5 sm:p-6 shadow-sm space-y-5 transition-all',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            // Toolbar Header
            div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4', [
              div(classes: 'flex items-center space-x-2', [
                h3(
                  classes: 'text-base font-bold tracking-tight',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text('Provider Payouts')],
                ),
                span(
                  classes: 'text-xs font-semibold px-2.5 py-0.5 rounded-full',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.primary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  [
                    Component.text('${items.length} of $total'),
                  ],
                ),
              ]),

              div(classes: 'flex flex-wrap items-center gap-3', [
                // Search Input Pill
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
                    attributes: {'placeholder': 'Search by id:, task:, ref:, provider:...'},
                    onInput: _onSearchInput,
                  ),
                ]),

                // Filter Toggle Button
                button(
                  onClick: () {
                    setState(() {
                      isFilterOpen = !isFilterOpen;
                    });
                  },
                  classes:
                      'text-xs font-semibold px-3.5 py-2 rounded-xl flex items-center space-x-1.5 transition-colors cursor-pointer border',
                  styles: isFilterOpen || selectedStatus != 'All'
                      ? Styles(
                          backgroundColor: Color(colorScheme.primary),
                          color: Color('#FFFFFF'),
                          raw: {'border-color': colorScheme.primary},
                        )
                      : Styles(
                          backgroundColor: Color(colorScheme.inputBg),
                          color: Color(colorScheme.textPrimary),
                          raw: {'border-color': colorScheme.borderInput},
                        ),
                  [
                    const AppIcon(AppIcons.filter),
                    span([Component.text('Filter')]),
                  ],
                ),

                if (selectedStatus != 'All' || searchQuery.isNotEmpty)
                  button(
                    onClick: _resetFilters,
                    classes: 'text-xs font-bold text-rose-500 hover:underline cursor-pointer border-none bg-transparent',
                    [Component.text('Reset')],
                  ),
              ]),
            ]),

            // Expandable Filter Bar
            if (isFilterOpen)
              _PayoutsFilterBar(
                colorScheme: colorScheme,
                selectedStatus: selectedStatus,
                onSelectStatus: (st) => setState(() {
                  selectedStatus = st;
                  currentPage = 1;
                }),
              ),

            // Payouts Data Table
            if (items.isEmpty)
              _EmptyState(colorScheme: colorScheme, message: 'No matching payouts found', onResetFilters: _resetFilters)
            else
              div(
                classes: 'overflow-x-auto rounded-xl border transition-colors',
                styles: Styles(raw: {'border-color': colorScheme.border}),
                [
                  table(classes: 'w-full min-w-[950px] text-left border-collapse text-xs', [
                    thead(
                      classes: 'uppercase tracking-wider text-[10.5px] border-b font-bold',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        color: Color(colorScheme.textMuted),
                        raw: {'border-color': colorScheme.border},
                      ),
                      [
                        tr([
                          th(classes: 'p-3.5 pl-4 whitespace-nowrap', [Component.text('Payout ID')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Task Title & ID')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Provider ID')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Payout Amount')]),
                          th(classes: 'p-3.5 text-center whitespace-nowrap', [Component.text('Status')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Reference')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Created At')]),
                          th(classes: 'p-3.5 pr-4 text-center whitespace-nowrap', [Component.text('Actions')]),
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
                        for (final item in items)
                          _buildPayoutRow(context, item, colorScheme),
                      ],
                    ),
                  ]),
                ],
              ),

            // Pagination Footer Bar
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
          ],
        );
      },
      loading: () => _ShimmerLoading(colorScheme: colorScheme),
      error: (err, stack) => _ErrorState(
        colorScheme: colorScheme,
        errorMsg: err.toString(),
        onRetry: () => setState(() {}),
      ),
    );
  }

  Component _buildPayoutRow(
    BuildContext context,
    AdminPayoutItem item,
    ColorScheme colorScheme,
  ) {
    final isCustomerPaid = (item.status ?? '').toUpperCase() == 'CUSTOMER_PAID';
    final isTransferring = processingPayoutId == item.id;

    return tr(
      classes: 'hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors cursor-pointer',
      events: {
        'click': (_) => PayoutDetailSidePanel.show(context, item),
      },
      [
        td(
          classes: 'p-3.5 pl-4 font-mono font-bold text-[11px] whitespace-nowrap',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text(_formatId(item.id))],
        ),
        td(classes: 'p-3.5 max-w-xs whitespace-nowrap', [
          div(
            classes: 'font-semibold text-xs truncate',
            styles: Styles(color: Color(colorScheme.textPrimary)),
            [Component.text(item.task?.title ?? _formatId(item.taskId))],
          ),
          if (item.taskId != null)
            div(
              classes: 'text-[10.5px] font-mono truncate',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text('Task: ${_formatId(item.taskId)}')],
            ),
        ]),
        td(
          classes: 'p-3.5 font-mono text-xs font-semibold whitespace-nowrap',
          styles: Styles(color: Color(colorScheme.textSecondary)),
          [Component.text(_formatId(item.providerId))],
        ),
        td(
          classes: 'p-3.5 font-bold text-xs whitespace-nowrap',
          styles: Styles(color: Color(colorScheme.primary)),
          [Component.text(item.payoutAmount != null ? '₦${item.payoutAmount!.toStringAsFixed(2)}' : 'N/A')],
        ),
        td(classes: 'p-3.5 text-center whitespace-nowrap', [
          _StatusBadgePill(status: item.status ?? 'PENDING', colorScheme: colorScheme),
        ]),
        td(
          classes: 'p-3.5 font-mono text-[11px] whitespace-nowrap',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text(item.reference ?? 'N/A')],
        ),
        td(
          classes: 'p-3.5 text-xs font-medium whitespace-nowrap',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text(_formatDate(item.createdAt))],
        ),
        td(classes: 'p-3.5 pr-4 text-center whitespace-nowrap', [
          div(classes: 'flex items-center justify-center gap-1.5', [
            if (isCustomerPaid)
              button(
                type: ButtonType.button,
                onClick: isTransferring || item.id == null
                    ? null
                    : () => _triggerTransfer(context, item.id!),
                classes:
                    'text-white text-[11px] font-bold px-3 py-1.5 rounded-lg shadow-xs transition-all cursor-pointer border-none flex items-center gap-1 active:scale-95 shrink-0',
                styles: Styles(backgroundColor: Color(colorScheme.primary)),
                [
                  if (isTransferring)
                    span(classes: 'animate-spin border-2 border-white border-t-transparent rounded-full w-3 h-3 mr-1', [])
                  else
                    div(classes: 'w-3 h-3', [const AppIcon(AppIcons.externalLink)]),
                  Component.text(isTransferring ? 'Transferring...' : 'Transfer Payout'),
                ],
              ),
            button(
              onClick: () => PayoutDetailSidePanel.show(context, item),
              classes:
                  'text-[11px] font-bold px-3 py-1.5 rounded-lg transition-all cursor-pointer border shrink-0',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.textPrimary),
                raw: {'border-color': colorScheme.borderInput},
              ),
              [Component.text('Details')],
            ),
          ]),
        ]),
      ],
    );
  }
}

class _PayoutsFilterBar extends StatelessComponent {
  final ColorScheme colorScheme;
  final String selectedStatus;
  final void Function(String status) onSelectStatus;

  const _PayoutsFilterBar({
    required this.colorScheme,
    required this.selectedStatus,
    required this.onSelectStatus,
  });

  @override
  Component build(BuildContext context) {
    final statusOptions = ['All', 'PENDING', 'CUSTOMER_PAID', 'TRANSFER_INITIATED', 'COMPLETED', 'FAILED'];

    return div(
      classes: 'p-4 rounded-xl border space-y-1.5 transition-all shadow-2xs',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.borderInput},
      ),
      [
        span(
          classes: 'text-[11px] font-black uppercase tracking-wider block',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Filter Payout Status:')],
        ),
        div(classes: 'flex flex-wrap items-center gap-1.5', [
          for (final st in statusOptions)
            _ChipButton(
              label: st,
              isSelected: selectedStatus == st,
              colorScheme: colorScheme,
              onSelect: () => onSelectStatus(st),
            ),
        ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared Helper Widgets
// ─────────────────────────────────────────────────────────────

class _ChipButton extends StatelessComponent {
  final String label;
  final bool isSelected;
  final ColorScheme colorScheme;
  final void Function() onSelect;

  const _ChipButton({
    required this.label,
    required this.isSelected,
    required this.colorScheme,
    required this.onSelect,
  });

  @override
  Component build(BuildContext context) {
    return button(
      type: ButtonType.button,
      onClick: onSelect,
      classes: 'px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer border',
      styles: isSelected
          ? Styles(
              backgroundColor: Color(colorScheme.primary),
              color: Color('#FFFFFF'),
              raw: {'border-color': colorScheme.primary},
            )
          : Styles(
              backgroundColor: Color(colorScheme.surface),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
      [Component.text(label)],
    );
  }
}

class _StatusBadgePill extends StatelessComponent {
  final String status;
  final ColorScheme colorScheme;

  const _StatusBadgePill({required this.status, required this.colorScheme});

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
      classes:
          'px-2.5 py-1 rounded-full text-[10.5px] font-bold inline-block leading-none tracking-tight border $bg $text $border whitespace-nowrap',
      [Component.text(status)],
    );
  }
}

class _EmptyState extends StatelessComponent {
  final ColorScheme colorScheme;
  final String message;
  final void Function() onResetFilters;

  const _EmptyState({
    required this.colorScheme,
    required this.message,
    required this.onResetFilters,
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
        onClick: onResetFilters,
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
      classes: 'border rounded-2xl p-6 space-y-6 animate-pulse',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
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
          classes: 'px-4 py-2 text-xs font-bold text-white rounded-xl shadow-xs cursor-pointer',
          styles: Styles(backgroundColor: Color(colorScheme.primary)),
          [Component.text('Retry')],
        ),
      ],
    );
  }
}

String _formatId(String? id) {
  if (id == null || id.isEmpty) return 'N/A';
  if (id.length <= 10) return id;
  return '${id.substring(0, 10)}...';
}

String _formatDate(DateTime? dt) {
  if (dt == null) return 'N/A';
  return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
