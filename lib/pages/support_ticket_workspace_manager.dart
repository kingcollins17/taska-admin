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

        // 3-Column Layout Workspace Body
        div(
          classes: 'flex-1 grid grid-cols-1 lg:grid-cols-12 overflow-hidden divide-y lg:divide-y-0 lg:divide-x transition-colors duration-200',
          styles: Styles(raw: {'border-color': colorScheme.border}),
          [
            // Component 1: Left Assigned Cases Panel (col-span-3)
            div(classes: 'lg:col-span-3 h-full overflow-hidden flex flex-col', [
              const SupportWorkspaceAssignedCasesPanel(),
            ]),

            // Component 2: Center Chat Messages & Timelines Panel (col-span-6)
            div(classes: 'lg:col-span-6 h-full overflow-hidden flex flex-col', [
              SupportWorkspaceChatPanel(caseId: currentCaseId),
            ]),

            // Component 3: Right Quick Update & Ticket Details Panel (col-span-3)
            div(classes: 'lg:col-span-3 h-full overflow-y-auto flex flex-col', [
              SupportWorkspaceDetailsPanel(caseId: currentCaseId),
            ]),
          ],
        ),
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

    return div(
      classes: 'h-14 px-4 border-b flex items-center justify-between shrink-0 shadow-2xs z-10 transition-colors',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
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
            classes: 'w-8 h-8 rounded-xl flex items-center justify-center border transition-all cursor-pointer hover:scale-105 active:scale-95 shadow-2xs',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textPrimary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            attributes: {'title': 'Back to Support Table'},
            [
              div(classes: 'w-3.5 h-3.5', [const AppIcon(AppIcons.tableSortArrow)]),
            ],
          ),

          div(classes: 'flex items-center space-x-2 min-w-0 truncate', [
            if (caseNo != null) ...[
              span(
                classes: 'font-mono font-bold text-xs px-2 py-0.5 rounded-lg border shrink-0',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  color: Color(colorScheme.primary),
                  raw: {'border-color': colorScheme.borderInput},
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
            span(
              classes: 'hidden sm:inline-flex px-2.5 py-1 rounded-full text-[10.5px] font-bold uppercase tracking-wider border',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.primary),
                raw: {'border-color': colorScheme.borderInput},
              ),
              [Component.text(caseDetail?.status ?? 'OPEN')],
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
            classes: 'px-3 py-1.5 rounded-xl border text-[11px] font-bold flex items-center space-x-1.5 cursor-pointer transition-all hover:bg-slate-100 dark:hover:bg-slate-800',
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
            classes: 'w-8 h-8 rounded-xl border flex items-center justify-center cursor-pointer transition-all hover:bg-slate-100 dark:hover:bg-slate-800',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textPrimary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            attributes: {'title': 'Toggle Dark/Light Mode'},
            [
              div(classes: 'w-3.5 h-3.5', [AppIcon(colorScheme.isDark ? AppIcons.sun : AppIcons.moon)]),
            ],
          ),

          button(
            type: ButtonType.button,
            onClick: () {
              Router.of(context).push('/support');
            },
            classes: 'px-3.5 py-1.5 rounded-xl text-white font-bold text-xs shadow-xs cursor-pointer border-none transition-all active:scale-95',
            styles: Styles(backgroundColor: Color('#EF4444')),
            [Component.text('Close Workspace')],
          ),
        ],
      ),
    ]);
  }
}
