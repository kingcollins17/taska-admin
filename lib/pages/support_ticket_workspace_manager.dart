import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../components/support_workspace_assigned_cases_panel.dart';
import '../components/support_workspace_chat_panel.dart';
import '../components/support_workspace_details_panel.dart';
import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/providers/admin_support_providers.dart';
import '../core/providers/ui_state_provider.dart';

@client
class SupportTicketWorkspaceManagerPage extends StatefulComponent {
  const SupportTicketWorkspaceManagerPage({super.key});

  @override
  State<SupportTicketWorkspaceManagerPage> createState() => _SupportTicketWorkspaceManagerPageState();
}

class _SupportTicketWorkspaceManagerPageState extends State<SupportTicketWorkspaceManagerPage> {
  int activeMobileTab = 1; // 0: Cases, 1: Chat, 2: Details

  @override
  Component build(BuildContext context) {
    final uiState = context.watch(uiStateProvider);
    final colorScheme = uiState.colorScheme;
    final currentCaseId = context.watch(currentSupportTicketProvider);

    return div(
      classes: 'w-full h-screen flex flex-col overflow-hidden text-xs antialiased selection:bg-[#00A870] selection:text-white',
      styles: Styles(backgroundColor: Color(colorScheme.background)),
      [
        // Top Navbar Header
        WorkspaceHeader(colorScheme: colorScheme, currentCaseId: currentCaseId),

        // Mobile responsive tab switcher (visible on small screens < lg)
        div(
          classes: 'lg:hidden border-b flex items-center justify-around px-2 py-1.5 shrink-0 transition-colors',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            _mobileTabButton(0, 'Tickets', AppIcons.customer, colorScheme),
            _mobileTabButton(1, 'Chat', AppIcons.disputes, colorScheme),
            _mobileTabButton(2, 'Details', AppIcons.documents, colorScheme),
          ],
        ),

        // 3-Column Layout Workspace Body
        div(
          classes: 'flex-1 grid grid-cols-1 lg:grid-cols-12 overflow-hidden divide-y lg:divide-y-0 lg:divide-x transition-colors duration-200',
          styles: Styles(raw: {'border-color': colorScheme.border}),
          [
            // Component 1: Left Assigned Cases Panel (col-span-3)
            div(
              classes: '${activeMobileTab == 0 ? 'block' : 'hidden'} lg:block lg:col-span-3 h-full overflow-hidden flex flex-col',
              [
                const SupportWorkspaceAssignedCasesPanel(),
              ],
            ),

            // Component 2: Center Chat Messages & Timelines Panel (col-span-6)
            div(
              classes: '${activeMobileTab == 1 ? 'block' : 'hidden'} lg:block lg:col-span-6 h-full overflow-hidden flex flex-col',
              [
                SupportWorkspaceChatPanel(caseId: currentCaseId),
              ],
            ),

            // Component 3: Right Quick Update & Ticket Details Panel (col-span-3)
            div(
              classes: '${activeMobileTab == 2 ? 'block' : 'hidden'} lg:block lg:col-span-3 h-full overflow-y-auto flex flex-col',
              [
                SupportWorkspaceDetailsPanel(caseId: currentCaseId),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Component _mobileTabButton(int index, String title, AppIcons icon, ColorScheme colorScheme) {
    final isActive = activeMobileTab == index;
    return button(
      type: ButtonType.button,
      onClick: () => setState(() => activeMobileTab = index),
      classes: 'flex-1 py-1.5 px-3 rounded-xl flex items-center justify-center space-x-1.5 font-bold text-[11px] transition-all cursor-pointer border-none',
      styles: Styles(
        backgroundColor: isActive ? Color(colorScheme.primary) : Color('transparent'),
        color: isActive ? Color('#FFFFFF') : Color(colorScheme.textMuted),
      ),
      [
        div(classes: 'w-3.5 h-3.5', [AppIcon(icon)]),
        span([Component.text(title)]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Workspace Header Bar
// ─────────────────────────────────────────────────────────────

class WorkspaceHeader extends StatelessComponent {
  final ColorScheme colorScheme;
  final String? currentCaseId;

  const WorkspaceHeader({
    super.key,
    required this.colorScheme,
    required this.currentCaseId,
  });

  @override
  Component build(BuildContext context) {
    final caseDetailAsync = currentCaseId != null
        ? context.watch(adminSupportCaseDetailProvider(currentCaseId!))
        : null;

    final caseDetail = caseDetailAsync?.value;
    final subject = caseDetail?.subject ?? 'Support Ticket Workspace';
    final caseNo = caseDetail?.caseNumber ?? (currentCaseId != null ? formatSupportId(currentCaseId!) : null);
    final status = caseDetail?.status ?? 'OPEN';

    return div(
      classes: 'h-14 px-4 border-b flex items-center justify-between shrink-0 shadow-xs z-10 transition-colors backdrop-blur-md',
      styles: Styles(
        backgroundColor: colorScheme.isDark
            ? Color.rgba(18, 26, 23, 0.85)
            : Color.rgba(255, 255, 255, 0.85),
        raw: {'border-color': colorScheme.border},
      ),
      [
        // Left: Back button & Breadcrumb Title
        div(classes: 'flex items-center space-x-3 min-w-0 flex-1', [
          button(
            type: ButtonType.button,
            onClick: () {
              Router.of(context).push('/support');
            },
            classes: 'w-8 h-8 rounded-xl flex items-center justify-center border transition-all cursor-pointer hover:scale-105 active:scale-95 shadow-2xs group',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textPrimary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            attributes: {'title': 'Back to Support Desk'},
            [
              div(classes: 'w-4 h-4 transition-transform group-hover:-translate-x-0.5', [const AppIcon(AppIcons.tableSortArrow)]),
            ],
          ),

          div(classes: 'flex items-center space-x-2 min-w-0 truncate', [
            if (caseNo != null) ...[
              span(
                classes: 'font-mono font-extrabold text-[11px] px-2 py-0.5 rounded-lg border shrink-0 tracking-tight shadow-2xs',
                styles: Styles(
                  backgroundColor: colorScheme.isDark ? Color.rgba(0, 168, 112, 0.15) : Color.rgba(0, 168, 112, 0.08),
                  color: Color(colorScheme.primary),
                  raw: {'border-color': colorScheme.isDark ? 'rgba(0, 168, 112, 0.3)' : 'rgba(0, 168, 112, 0.2)'},
                ),
                [Component.text('#$caseNo')],
              ),
              span(classes: 'text-slate-400 font-bold', [Component.text('·')]),
            ],
            h2(
              classes: 'font-extrabold text-sm truncate tracking-tight',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text(subject)],
            ),
          ]),
        ]),

        // Right: Workspace Quick Tools & Actions
        div(classes: 'flex items-center space-x-2 shrink-0 pl-2', [
          if (currentCaseId != null)
            div(
              classes: 'hidden sm:inline-flex items-center space-x-1.5 px-3 py-1 rounded-full text-[10.5px] font-extrabold uppercase tracking-wider border shadow-2xs',
              styles: Styles(
                backgroundColor: Color(_statusBg(status, colorScheme)),
                color: Color(_statusText(status, colorScheme)),
                raw: {'border-color': _statusBorder(status, colorScheme)},
              ),
              [
                span(classes: 'w-2 h-2 rounded-full ${_statusPulse(status)}', styles: Styles(backgroundColor: Color(_statusDotColor(status))), []),
                span([Component.text(status)]),
              ],
            ),

          button(
            type: ButtonType.button,
            onClick: () {
              if (currentCaseId != null) {
                context.invalidate(adminSupportCaseDetailProvider(currentCaseId!));
                context.invalidate(adminSupportMessagesProvider(GetAdminSupportMessagesParams(caseId: currentCaseId!)));
                context.invalidate(adminSupportTimelineProvider(GetAdminSupportTimelineParams(caseId: currentCaseId!)));
              }
            },
            classes: 'px-3 py-1.5 rounded-xl border text-[11px] font-bold flex items-center space-x-1.5 cursor-pointer transition-all hover:scale-105 active:scale-95 shadow-2xs',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textPrimary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [
              div(classes: 'w-3.5 h-3.5', [const AppIcon(AppIcons.refresh)]),
              span(classes: 'hidden sm:inline', [Component.text('Refresh')]),
            ],
          ),

          button(
            type: ButtonType.button,
            onClick: () {
              context.read(uiStateProvider.notifier).toggleTheme();
            },
            classes: 'w-8 h-8 rounded-xl border flex items-center justify-center cursor-pointer transition-all hover:scale-105 active:scale-95 shadow-2xs',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textPrimary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            attributes: {'title': 'Toggle Dark/Light Theme'},
            [
              div(classes: 'w-3.5 h-3.5', [AppIcon(colorScheme.isDark ? AppIcons.sun : AppIcons.moon)]),
            ],
          ),

          button(
            type: ButtonType.button,
            onClick: () {
              Router.of(context).push('/support');
            },
            classes: 'px-3.5 py-1.5 rounded-xl text-white font-bold text-xs shadow-xs cursor-pointer border-none transition-all hover:bg-rose-600 active:scale-95',
            styles: Styles(backgroundColor: Color('#EF4444')),
            [Component.text('Close Workspace')],
          ),
        ]),
      ],
    );
  }

  String _statusDotColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return '#10B981';
      case 'IN_PROGRESS':
        return '#F59E0B';
      case 'WAITING_FOR_CUSTOMER':
      case 'WAITING_FOR_PROVIDER':
        return '#3B82F6';
      case 'RESOLVED':
        return '#8B5CF6';
      case 'CLOSED':
        return '#64748B';
      default:
        return '#10B981';
    }
  }

  String _statusPulse(String status) {
    if (status == 'OPEN' || status == 'IN_PROGRESS') return 'animate-pulse';
    return '';
  }

  String _statusBg(String status, ColorScheme colorScheme) {
    if (colorScheme.isDark) {
      return 'rgba(31, 45, 39, 0.8)';
    }
    return colorScheme.inputBg;
  }

  String _statusText(String status, ColorScheme colorScheme) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return '#10B981';
      case 'IN_PROGRESS':
        return '#F59E0B';
      case 'RESOLVED':
        return '#8B5CF6';
      case 'CLOSED':
        return '#64748B';
      default:
        return colorScheme.primary;
    }
  }

  String _statusBorder(String status, ColorScheme colorScheme) {
    return colorScheme.borderInput;
  }
}
