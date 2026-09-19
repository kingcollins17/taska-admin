import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/support/admin_support_case_item.dart';
import '../core/providers/admin_support_providers.dart';
import '../core/providers/ui_state_provider.dart';

String formatSupportId(String? id) {
  if (id == null || id.isEmpty) return 'SUP-000';
  if (id.length <= 8) return id;
  return '${id.substring(0, 8)}...';
}

String formatSupportTime(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  try {
    final dt = DateTime.parse(raw).toLocal();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  } catch (_) {
    return raw;
  }
}

String formatSupportDate(String? raw) {
  if (raw == null || raw.isEmpty) return 'N/A';
  try {
    final dt = DateTime.parse(raw).toLocal();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} $hour:$minute';
  } catch (_) {
    return raw;
  }
}

class SupportWorkspaceAssignedCasesPanel extends StatefulComponent {
  const SupportWorkspaceAssignedCasesPanel({super.key});

  @override
  State<SupportWorkspaceAssignedCasesPanel> createState() => _SupportWorkspaceAssignedCasesPanelState();
}

class _SupportWorkspaceAssignedCasesPanelState extends State<SupportWorkspaceAssignedCasesPanel> {
  String searchQuery = '';
  String filterMode = 'MY_ASSIGNED'; // 'MY_ASSIGNED' or 'ALL'
  int currentPage = 1;
  static const int _perPage = 20;

  void _onSearchInput(dynamic val) {
    setState(() {
      searchQuery = val.toString();
      currentPage = 1;
    });
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));
    final selectedCaseId = context.watch(currentSupportTicketProvider);

    final assignedCasesAsync = filterMode == 'MY_ASSIGNED'
        ? context.watch(
            adminMyAssignedSupportCasesProvider(
              GetAdminSupportCasesParams(
                search: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
                page: currentPage,
                perPage: _perPage,
              ),
            ),
          )
        : context.watch(
            adminSupportCasesProvider(
              GetAdminSupportCasesParams(
                search: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
                page: currentPage,
                perPage: _perPage,
              ),
            ),
          );

    return div(
      classes: 'flex flex-col h-full overflow-hidden transition-colors',
      styles: Styles(backgroundColor: Color(colorScheme.surface)),
      [
        // ── Header Toolbar ──────────────────────────────────
        div(
          classes: 'p-3.5 border-b space-y-3 shrink-0',
          styles: Styles(raw: {'border-color': colorScheme.border}),
          [
            // Title row with ticket count
            div(classes: 'flex items-center justify-between', [
              div(classes: 'flex items-center space-x-2', [
                div(
                  classes: 'w-7 h-7 rounded-lg flex items-center justify-center border shadow-2xs',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.primary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  [
                    const AppIcon(AppIcons.customer),
                  ],
                ),
                h3(
                  classes: 'font-extrabold text-sm tracking-tight',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text('Assigned Tickets')],
                ),
                // Total count badge – shows when data is loaded
                assignedCasesAsync.when(
                  data: (paginatedData) {
                    final total = paginatedData?.total ?? 0;
                    return span(
                      classes: 'px-1.5 py-0.5 rounded-md text-[10px] font-bold',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        color: Color(colorScheme.primary),
                        raw: {'border-color': colorScheme.borderInput},
                      ),
                      [Component.text('$total')],
                    );
                  },
                  loading: () => Component.empty(),
                  error: (_, __) => Component.empty(),
                ),
              ]),
            ]),

            // Sort dropdown row
            div(classes: 'flex items-center justify-between', [
              span(
                classes: 'text-[11px] font-semibold',
                styles: Styles(color: Color(colorScheme.textMuted)),
                [Component.text('Sort: Newest first')],
              ),
              div(classes: 'flex items-center space-x-1', [
                div(classes: 'w-3 h-3', styles: Styles(color: Color(colorScheme.textMuted)), [
                  const AppIcon(AppIcons.filter),
                ]),
              ]),
            ]),

            // Search Bar Input Box
            div(classes: 'relative w-full', [
              div(
                classes: 'absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none',
                styles: Styles(color: Color(colorScheme.placeholder)),
                [const AppIcon(AppIcons.search)],
              ),
              input(
                type: InputType.text,
                value: searchQuery,
                classes: 'w-full border rounded-xl pl-9 pr-3 py-1.5 text-xs font-medium focus:outline-none focus:ring-2 transition-all',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  color: Color(colorScheme.textPrimary),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                attributes: {'placeholder': 'Search tickets, case #, user...'},
                onInput: _onSearchInput,
              ),
            ]),
          ],
        ),

        // ── Cases List Container ────────────────────────────
        div(classes: 'flex-1 overflow-y-auto transition-colors', [
          assignedCasesAsync.when(
            data: (paginatedData) {
              final items = paginatedData?.items ?? [];

              // Auto-select first ticket if current selected ticket is null
              if (selectedCaseId == null && items.isNotEmpty && items.first.id != null) {
                Timer.run(() {
                  if (mounted && context.read(currentSupportTicketProvider) == null) {
                    context.read(currentSupportTicketProvider.notifier).setTicketId(items.first.id);
                  }
                });
              }

              if (items.isEmpty) {
                return div(classes: 'p-8 text-center space-y-2', [
                  div(
                    classes: 'w-12 h-12 mx-auto rounded-2xl flex items-center justify-center border shadow-2xs mb-3',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      color: Color(colorScheme.textMuted),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
                    [const AppIcon(AppIcons.search)],
                  ),
                  p(
                    classes: 'text-xs font-bold',
                    styles: Styles(color: Color(colorScheme.textSecondary)),
                    [Component.text('No support tickets found')],
                  ),
                  p(
                    classes: 'text-[11px] font-medium',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text('Try adjusting your search or filters')],
                  ),
                ]);
              }

              return div(classes: 'divide-y', styles: Styles(raw: {'border-color': colorScheme.border}), [
                for (final item in items)
                  TicketCardItem(
                    item: item,
                    isSelected: item.id != null && item.id == selectedCaseId,
                    colorScheme: colorScheme,
                    onTap: () {
                      if (item.id != null) {
                        context.read(currentSupportTicketProvider.notifier).setTicketId(item.id);
                      }
                    },
                  ),
              ]);
            },
            loading: () => div(classes: 'p-4 space-y-3 animate-pulse', [
              for (var i = 0; i < 6; i++)
                div(
                  classes: 'h-[72px] rounded-xl border p-3',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  [],
                ),
            ]),
            error: (err, _) => div(classes: 'p-6 text-center text-xs text-rose-500 font-bold', [
              Component.text('Error loading tickets: $err'),
            ]),
          ),
        ]),

        // ── Pagination Footer ───────────────────────────────
        assignedCasesAsync.when(
          data: (paginatedData) {
            final total = paginatedData?.total ?? 0;
            final maxPage = total <= 0 ? 1 : (total / _perPage).ceil().clamp(1, 9999);

            if (maxPage <= 1) return Component.empty();

            return div(
              classes: 'px-3.5 py-2.5 border-t flex items-center justify-between shrink-0',
              styles: Styles(
                backgroundColor: Color(colorScheme.surface),
                raw: {'border-color': colorScheme.border},
              ),
              [
                // Page info text
                span(
                  classes: 'text-[10.5px] font-semibold',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  [Component.text('Page $currentPage of $maxPage')],
                ),

                // Prev / Next buttons
                div(classes: 'flex items-center space-x-1.5', [
                  button(
                    type: ButtonType.button,
                    disabled: currentPage <= 1,
                    onClick: () {
                      if (currentPage > 1) setState(() => currentPage--);
                    },
                    classes: 'px-2 py-1 rounded-lg border text-[10.5px] font-bold cursor-pointer transition-all disabled:opacity-40 disabled:cursor-not-allowed',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      color: Color(colorScheme.textPrimary),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
                    [Component.text('‹ Prev')],
                  ),
                  // Current page pill
                  span(
                    classes: 'px-2 py-1 rounded-lg text-[10.5px] font-bold text-white shadow-xs',
                    styles: Styles(backgroundColor: Color(colorScheme.primary)),
                    [Component.text('$currentPage')],
                  ),
                  button(
                    type: ButtonType.button,
                    disabled: currentPage >= maxPage,
                    onClick: () {
                      if (currentPage < maxPage) setState(() => currentPage++);
                    },
                    classes: 'px-2 py-1 rounded-lg border text-[10.5px] font-bold cursor-pointer transition-all disabled:opacity-40 disabled:cursor-not-allowed',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      color: Color(colorScheme.textPrimary),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
                    [Component.text('Next ›')],
                  ),
                ]),
              ],
            );
          },
          loading: () => Component.empty(),
          error: (_, __) => Component.empty(),
        ),
      ],
    );
  }
}

class TicketCardItem extends StatelessComponent {
  final AdminSupportCaseItem item;
  final bool isSelected;
  final ColorScheme colorScheme;
  final void Function() onTap;

  const TicketCardItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Component build(BuildContext context) {
    final caseNo = item.caseNumber ?? formatSupportId(item.id);
    final subject = item.subject ?? 'No Subject';
    final initiatorName = item.initiator != null
        ? '${item.initiator?.firstName ?? ''} ${item.initiator?.lastName ?? ''}'.trim()
        : null;
    final displayName = initiatorName != null && initiatorName.isNotEmpty ? initiatorName : (item.initiator?.email ?? 'Customer');
    final priority = item.priority ?? 'NORMAL';
    final status = item.status ?? 'OPEN';

    // Determine the selected left-border accent
    final leftBorderColor = isSelected ? colorScheme.primary : 'transparent';
    final selectedBg = isSelected
        ? (colorScheme.isDark ? Color.rgba(0, 168, 112, 0.12) : Color.rgba(0, 168, 112, 0.06))
        : Color('transparent');

    return div(
      events: {'click': (_) => onTap()},
      classes: 'px-3.5 py-3 cursor-pointer transition-all border-l-[3px] flex items-start space-x-3 relative group',
      styles: Styles(
        backgroundColor: selectedBg,
        raw: {'border-left-color': leftBorderColor},
      ),
      [
        // Avatar circle with initial letter
        div(
          classes: 'w-9 h-9 rounded-full flex items-center justify-center font-bold text-white text-xs shrink-0 shadow-2xs mt-0.5',
          styles: Styles(backgroundColor: Color(_avatarColor(displayName))),
          [Component.text(displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C')],
        ),

        // Content area
        div(classes: 'flex-1 min-w-0 space-y-1', [
          // Top row: case number + time
          div(classes: 'flex items-center justify-between gap-1.5', [
            div(classes: 'flex items-center space-x-1.5 min-w-0', [
              span(
                classes: 'font-mono font-bold text-[11px]',
                styles: Styles(color: Color(isSelected ? colorScheme.primary : colorScheme.textMuted)),
                [Component.text('#$caseNo')],
              ),
              _buildPriorityDot(priority),
            ]),
            span(
              classes: 'text-[10px] font-medium text-slate-400 shrink-0',
              [Component.text(formatSupportTime(item.createdAt))],
            ),
          ]),

          // Name row with optional unread badge
          div(classes: 'flex items-center justify-between gap-1', [
            p(
              classes: 'font-semibold text-xs truncate leading-snug',
              styles: Styles(color: Color(colorScheme.textPrimary)),
              [Component.text(displayName)],
            ),
            // Show unread count only if status is OPEN (visual indicator)
            if (status == 'OPEN')
              span(
                classes: 'w-5 h-5 rounded-full flex items-center justify-center text-[9px] font-bold text-white shrink-0',
                styles: Styles(backgroundColor: Color('#EF4444')),
                [Component.text('!')],
              ),
          ]),

          // Subject line
          p(
            classes: 'text-[11px] truncate font-normal leading-snug',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text(subject)],
          ),
        ]),
      ],
    );
  }

  /// Generate a consistent avatar color based on the display name
  String _avatarColor(String name) {
    final colors = ['#10B981', '#6366F1', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899', '#14B8A6', '#F97316'];
    if (name.isEmpty) return colors[0];
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  Component _buildPriorityDot(String priority) {
    String colorClass = 'bg-sky-500';
    switch (priority.toUpperCase()) {
      case 'HIGH':
      case 'URGENT':
        colorClass = 'bg-rose-500';
        break;
      case 'LOW':
        colorClass = 'bg-emerald-500';
        break;
    }
    return div(classes: 'w-2 h-2 rounded-full shrink-0 $colorClass', []);
  }
}
