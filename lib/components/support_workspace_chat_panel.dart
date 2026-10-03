import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:taska_admin/core/designs/components/gap.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/support/admin_add_support_internal_note_body.dart';
import '../core/models/clients/support/admin_attach_user_to_case_body.dart';
import '../core/models/clients/support/admin_send_support_message_body.dart';
import '../core/models/clients/support/admin_support_attachment_item.dart';
import '../core/models/clients/support/admin_support_case_detail.dart';
import '../core/models/clients/support/admin_support_message_item.dart';
import '../core/models/clients/support/admin_support_timeline_item.dart';
import '../core/providers/admin_support_providers.dart';
import '../core/providers/admin_user_providers.dart';
import '../core/providers/ui_state_provider.dart';
import 'search_users_dialog.dart';
import 'support_workspace_assigned_cases_panel.dart';

class SupportWorkspaceChatPanel extends StatefulComponent {
  final String? caseId;

  const SupportWorkspaceChatPanel({super.key, required this.caseId});

  @override
  State<SupportWorkspaceChatPanel> createState() => _SupportWorkspaceChatPanelState();
}

class _SupportWorkspaceChatPanelState extends State<SupportWorkspaceChatPanel> {
  String messageText = '';
  final String channel = 'IN_APP'; // Constant at IN_APP
  String visibility = 'PUBLIC'; // 'PUBLIC', 'INTERNAL', 'CUSTOMER_ONLY', 'PROVIDER_ONLY'
  bool isSending = false;
  bool _isAttachingUser = false;
  bool isTimelineExpanded = false;
  bool isAttachmentsExpanded = false;

  Future<void> _handleAttachUser(BuildContext context) async {
    if (component.caseId == null || _isAttachingUser) return;

    final selectedUser = await SearchUsersDialog.search(
      context,
      title: 'Attach User to Ticket',
    );

    if (selectedUser == null || selectedUser.id == null || !mounted) return;

    setState(() => _isAttachingUser = true);

    final notifier = context.read(adminSupportManagementProvider.notifier);
    await notifier.attachUser(
      component.caseId!,
      AdminAttachUserToCaseBody(userId: selectedUser.id!),
      onSuccess: () {
        if (!mounted) return;
        setState(() => _isAttachingUser = false);
        context.showFlushbar(
          title: 'User Attached',
          message: 'Successfully attached ${selectedUser.fullname ?? selectedUser.email ?? 'user'} to ticket.',
          type: FlushbarType.success,
        );
      },
      onError: (msg) {
        if (!mounted) return;
        setState(() => _isAttachingUser = false);
        context.showFlushbar(
          title: 'Attach User Failed',
          message: msg,
          type: FlushbarType.error,
        );
      },
    );
  }

  void _onMessageInput(dynamic val) {
    setState(() {
      messageText = val.toString();
    });
  }

  Future<void> _handleSend(BuildContext context) async {
    if (component.caseId == null || messageText.trim().isEmpty || isSending) return;

    setState(() {
      isSending = true;
    });

    final notifier = context.read(adminSupportManagementProvider.notifier);
    final textToSend = messageText.trim();
    final currentCaseId = component.caseId!;

    void onSuccessClear(String toastMsg) {
      if (!mounted) return;
      setState(() {
        messageText = '';
        isSending = false;
      });

      // Clear native DOM textarea input directly
      final elem = web.document.getElementById('chat-message-input') as web.HTMLTextAreaElement?;
      if (elem != null) {
        elem.value = '';
      }

      context.showFlushbar(message: toastMsg, type: FlushbarType.success);
    }

    if (visibility == 'INTERNAL') {
      await notifier.addInternalNote(
        currentCaseId,
        AdminAddSupportInternalNoteBody(body: textToSend),
        onSuccess: () => onSuccessClear('Internal note added'),
        onError: (msg) {
          if (!mounted) return;
          setState(() => isSending = false);
          context.showFlushbar(message: msg, type: FlushbarType.error);
        },
      );
    } else {
      await notifier.sendMessage(
        currentCaseId,
        AdminSendSupportMessageBody(
          body: textToSend,
          channel: channel,
          visibility: visibility,
        ),
        onSuccess: () => onSuccessClear('Message sent successfully'),
        onError: (msg) {
          if (!mounted) return;
          setState(() => isSending = false);
          context.showFlushbar(message: msg, type: FlushbarType.error);
        },
      );
    }
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    if (component.caseId == null) {
      return div(classes: 'h-full flex flex-col items-center justify-center p-8 text-center space-y-4', [
        div(
          classes: 'w-16 h-16 rounded-2xl flex items-center justify-center border shadow-xs',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.primary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          [const AppIcon(AppIcons.customer)],
        ),
        h3(
          classes: 'font-extrabold text-base tracking-tight',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text('Select a Support Ticket')],
        ),
        p(
          classes: 'text-xs max-w-sm leading-relaxed',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Choose a ticket from the left panel to start responding to customer inquiries and viewing SLA timelines.')],
        ),
      ]);
    }

    final caseDetailAsync = context.watch(adminSupportCaseDetailProvider(component.caseId!));
    final messagesAsync = context.watch(
      adminSupportMessagesProvider(GetAdminSupportMessagesParams(caseId: component.caseId!, perPage: 100)),
    );
    final timelineAsync = context.watch(
      adminSupportTimelineProvider(GetAdminSupportTimelineParams(caseId: component.caseId!, perPage: 50)),
    );
    final attachmentsAsync = context.watch(
      adminSupportAttachmentsProvider(GetAdminSupportAttachmentsParams(caseId: component.caseId!, perPage: 100)),
    );

    final caseDetail = caseDetailAsync.value;
    final caseNo = caseDetail?.caseNumber ?? formatSupportId(component.caseId);
    final subject = caseDetail?.subject ?? 'No Subject';
    final hasBothUsers = (caseDetail?.customerId != null && caseDetail!.customerId!.isNotEmpty || caseDetail?.customer != null) &&
        (caseDetail?.providerId != null && caseDetail!.providerId!.isNotEmpty || caseDetail?.provider != null);

    return div(
      classes: 'flex flex-col h-full overflow-hidden transition-colors',
      styles: Styles(backgroundColor: Color(colorScheme.background)),
      [
        // ── Sub-header Bar ────────────────────────────────────
        div(
          classes: 'px-4 py-3 border-b flex items-center justify-between shrink-0 transition-colors',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            div(classes: 'space-y-0.5 min-w-0 flex-1', [
              div(classes: 'flex items-center space-x-2', [
                span(
                  classes: 'font-mono font-bold text-xs px-1.5 py-0.5 rounded-md border',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.primary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  [Component.text('#$caseNo')],
                ),
                span(classes: 'text-slate-300 dark:text-slate-600 font-bold', [Component.text('·')]),
                h3(
                  classes: 'font-bold text-xs sm:text-sm truncate',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text(subject)],
                ),
              ]),
                _ChatPanelHeaderSubtext(
                  caseDetail: caseDetail,
                  colorScheme: colorScheme,
                ),
            ]),

            // Quick action buttons on the sub-header
            div(classes: 'flex items-center space-x-1.5 shrink-0 pl-2', [
              if (!hasBothUsers)
                button(
                  type: ButtonType.button,
                  onClick: () => _handleAttachUser(context),
                  disabled: _isAttachingUser,
                  classes:
                      'px-2.5 py-1 rounded-lg text-[10.5px] font-bold transition-all cursor-pointer border flex items-center space-x-1 shadow-2xs ${_isAttachingUser ? 'opacity-60 cursor-not-allowed' : 'hover:scale-105 active:scale-95'}',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.primary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  attributes: {'title': 'Attach customer or provider user to ticket'},
                  [
                    if (_isAttachingUser)
                      span(classes: 'animate-spin border-2 border-emerald-500 border-t-transparent rounded-full w-3 h-3 mr-1', [])
                    else
                      Space(),
                    span(classes: 'hidden sm:inline', [Component.text(_isAttachingUser ? 'Attaching...' : 'Attach User')]),
                  ],
                ),
              if (caseDetail?.status != null)
                span(
                  classes: 'px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider border',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.primary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  [Component.text(caseDetail!.status!)],
                ),
            ]),
          ],
        ),

        // ── Scrollable Conversation ───────────────────────────
        div(
          classes: 'flex-1 overflow-y-auto p-5 space-y-5 transition-colors',
          styles: Styles(
            raw: {
              'background-image': colorScheme.isDark
                  ? 'radial-gradient(circle at 20% 50%, rgba(0,168,112,0.04) 0%, transparent 50%)'
                  : 'radial-gradient(circle at 20% 50%, rgba(0,168,112,0.03) 0%, transparent 50%)',
            },
          ),
          [
            messagesAsync.when(
              data: (msgData) {
                final messages = msgData?.items ?? [];
                final timelines = timelineAsync.value?.items ?? [];
                final attachments = attachmentsAsync.value?.items ?? [];

                if (messages.isEmpty && timelines.isEmpty && attachments.isEmpty) {
                  return div(classes: 'py-16 text-center space-y-3', [
                    div(
                      classes: 'w-12 h-12 mx-auto rounded-2xl flex items-center justify-center border shadow-2xs',
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
                      [Component.text('No messages recorded for this ticket yet.')],
                    ),
                  ]);
                }

                return div(classes: 'space-y-5', [
                  // Render initial ticket description bubble if available
                  if (caseDetail?.description != null && caseDetail!.description!.isNotEmpty)
                    UserBubble(
                      body: caseDetail.description!,
                      senderId: caseDetail.initiator?.id ?? caseDetail.customerId ?? caseDetail.providerId,
                      defaultSenderName: '${caseDetail.initiator?.firstName ?? ''} ${caseDetail.initiator?.lastName ?? ''}'.trim(),
                      timestamp: caseDetail.createdAt,
                      channel: 'Initial Request',
                      caseDetail: caseDetail,
                      colorScheme: colorScheme,
                    ),

                  // Collapsible Attachments section (collapsed by default)
                  if (attachments.isNotEmpty) ...[
                    div(
                      classes: 'my-3 flex items-center justify-between px-3.5 py-2 rounded-xl border transition-all cursor-pointer select-none shadow-2xs hover:border-[#00A870]/40',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        raw: {'border-color': colorScheme.borderInput},
                      ),
                      events: {
                        'click': (e) {
                          setState(() => isAttachmentsExpanded = !isAttachmentsExpanded);
                        },
                      },
                      [
                        div(classes: 'flex items-center space-x-2', [
                          div(classes: 'w-4 h-4 text-emerald-500', [const AppIcon(AppIcons.documents)]),
                          span(
                            classes: 'text-xs font-bold',
                            styles: Styles(color: Color(colorScheme.textSecondary)),
                            [Component.text('Case Attachments (${attachments.length})')],
                          ),
                          span(
                            classes: 'text-[10px] px-2 py-0.5 rounded-full font-semibold border',
                            styles: Styles(
                              backgroundColor: Color(colorScheme.surface),
                              color: Color(colorScheme.textMuted),
                              raw: {'border-color': colorScheme.borderInput},
                            ),
                            [Component.text(isAttachmentsExpanded ? 'Expanded' : 'Collapsed')],
                          ),
                        ]),
                        div(
                          classes: 'w-4 h-4 transition-transform duration-200 ${isAttachmentsExpanded ? 'rotate-180' : ''}',
                          styles: Styles(color: Color(colorScheme.textMuted)),
                          [const AppIcon(AppIcons.chevronDown)],
                        ),
                      ],
                    ),
                    if (isAttachmentsExpanded)
                      div(
                        classes: 'grid grid-cols-1 sm:grid-cols-2 gap-2.5 my-2.5',
                        [
                          for (final att in attachments)
                            AttachmentCard(attachment: att, colorScheme: colorScheme),
                        ],
                      ),
                  ],

                  // Messages list
                  for (final msg in messages)
                    if (msg.visibility == 'INTERNAL_NOTE' || msg.visibility == 'INTERNAL')
                      InternalNoteBubble(msg: msg, colorScheme: colorScheme)
                    else if (msg.senderType == 'AGENT' || msg.senderType == 'ADMIN')
                      AgentBubble(msg: msg, colorScheme: colorScheme)
                    else
                      UserBubble(
                        msg: msg,
                        body: msg.body ?? '',
                        senderId: msg.senderId,
                        timestamp: msg.createdAt,
                        channel: msg.channel ?? 'In App',
                        caseDetail: caseDetail,
                        colorScheme: colorScheme,
                      ),

                  // Collapsible Timelines section (collapsed by default)
                  if (timelines.isNotEmpty) ...[
                    div(
                      classes: 'my-3 flex items-center justify-between px-3.5 py-2 rounded-xl border transition-all cursor-pointer select-none shadow-2xs',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        raw: {'border-color': colorScheme.borderInput},
                      ),
                      events: {
                        'click': (e) {
                          setState(() => isTimelineExpanded = !isTimelineExpanded);
                        },
                      },
                      [
                        div(classes: 'flex items-center space-x-2', [
                          div(classes: 'w-4 h-4 text-emerald-500', [const AppIcon(AppIcons.auditLogs)]),
                          span(
                            classes: 'text-xs font-bold',
                            styles: Styles(color: Color(colorScheme.textSecondary)),
                            [Component.text('Timeline Events (${timelines.length})')],
                          ),
                          span(
                            classes: 'text-[10px] px-2 py-0.5 rounded-full font-semibold border',
                            styles: Styles(
                              backgroundColor: Color(colorScheme.surface),
                              color: Color(colorScheme.textMuted),
                              raw: {'border-color': colorScheme.borderInput},
                            ),
                            [Component.text(isTimelineExpanded ? 'Expanded' : 'Collapsed')],
                          ),
                        ]),
                        div(
                          classes: 'w-4 h-4 transition-transform duration-200 ${isTimelineExpanded ? 'rotate-180' : ''}',
                          styles: Styles(color: Color(colorScheme.textMuted)),
                          [const AppIcon(AppIcons.chevronDown)],
                        ),
                      ],
                    ),
                    if (isTimelineExpanded)
                      for (final tl in timelines)
                        TimelineChip(item: tl, colorScheme: colorScheme),
                  ],
                ]);
              },
              loading: () => div(classes: 'space-y-4 py-6 animate-pulse', [
                for (var i = 0; i < 3; i++)
                  div(
                    classes: 'h-20 ${i.isEven ? 'w-3/4' : 'w-2/3 ml-auto'} rounded-2xl border p-3',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
                    [],
                  ),
              ]),
              error: (err, _) => div(classes: 'p-4 text-center text-xs text-rose-500 font-bold', [
                Component.text('Failed to load messages: $err'),
              ]),
            ),
          ],
        ),

        // ── Bottom Message Composer ───────────────────────────
        if (caseDetail?.status?.toUpperCase() == 'CLOSED' || caseDetail?.status?.toUpperCase() == 'AUTO_CLOSED')
          div(
            classes: 'p-4 border-t flex items-center justify-center space-x-2 shrink-0 transition-colors',
            styles: Styles(
              backgroundColor: colorScheme.isDark ? Color.rgba(30, 41, 59, 0.6) : Color.rgba(241, 245, 249, 0.9),
              raw: {'border-color': colorScheme.border},
            ),
            [
              div(classes: 'w-4 h-4 text-slate-400 shrink-0', [const AppIcon(AppIcons.documents)]),
              span(
                classes: 'text-xs font-bold text-slate-500 dark:text-slate-400',
                [Component.text('This ticket is CLOSED. Reopen status to send replies or internal notes.')],
              ),
            ],
          )
        else
          div(
            classes: 'border-t shrink-0 transition-colors',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              raw: {'border-color': colorScheme.border},
            ),
            [
              // Mode Switcher Bar (Public Reply vs Internal Note)
              div(
                classes: 'px-4 py-2 border-b flex items-center justify-between gap-3 transition-colors',
                styles: Styles(raw: {'border-color': colorScheme.border}),
                [
                  div(classes: 'flex items-center space-x-1.5 p-1 rounded-xl border bg-slate-100 dark:bg-slate-800/60 shadow-2xs', [
                    button(
                      type: ButtonType.button,
                      onClick: () => setState(() => visibility = 'PUBLIC'),
                      classes: 'px-3 py-1 rounded-lg text-[11px] font-bold transition-all border-none cursor-pointer flex items-center space-x-1.5',
                      styles: Styles(
                        backgroundColor: visibility == 'PUBLIC' ? Color(colorScheme.primary) : Color('transparent'),
                        color: visibility == 'PUBLIC' ? Color('#FFFFFF') : Color(colorScheme.textMuted),
                      ),
                      [
                        span([Component.text('💬 Public Reply')]),
                      ],
                    ),
                    button(
                      type: ButtonType.button,
                      onClick: () => setState(() => visibility = 'INTERNAL'),
                      classes: 'px-3 py-1 rounded-lg text-[11px] font-bold transition-all border-none cursor-pointer flex items-center space-x-1.5',
                      styles: Styles(
                        backgroundColor: visibility == 'INTERNAL' ? Color('#F59E0B') : Color('transparent'),
                        color: visibility == 'INTERNAL' ? Color('#FFFFFF') : Color(colorScheme.textMuted),
                      ),
                      [
                        span([Component.text('🔒 Internal Note')]),
                      ],
                    ),
                  ]),

                  // Channel indicator pill
                  div(
                    classes: 'hidden sm:inline-flex items-center space-x-1.5 border rounded-full px-3 py-1 text-[10.5px] font-bold shadow-2xs',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      color: Color(colorScheme.textPrimary),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
                    [
                      span(classes: 'w-2 h-2 rounded-full bg-emerald-500 animate-pulse', []),
                      span([Component.text('In-App Support Channel')]),
                    ],
                  ),
                ],
              ),

              // Input field area: Textarea + Send button side-by-side with identical height
              div(classes: 'p-3.5 sm:p-4', [
                div(classes: 'flex items-center space-x-2.5', [
                  // Textarea Message Input
                  div(classes: 'flex-1 relative', [
                    textarea(
                      classes: 'w-full h-12 border rounded-2xl px-4 py-3 text-xs font-medium focus:outline-none focus:ring-2 transition-all resize-none leading-normal',
                      styles: visibility == 'INTERNAL'
                          ? Styles(
                              backgroundColor: Color.rgba(245, 158, 11, 0.08),
                              color: Color(colorScheme.textPrimary),
                              raw: {'border-color': '#F59E0B'},
                            )
                          : Styles(
                              backgroundColor: Color(colorScheme.inputBg),
                              color: Color(colorScheme.textPrimary),
                              raw: {'border-color': colorScheme.borderInput},
                            ),
                      attributes: {
                        'id': 'chat-message-input',
                        'placeholder': visibility == 'INTERNAL'
                            ? 'Write an internal note (only visible to support agents)...'
                            : 'Type public response to customer...',
                        'rows': '1',
                      },
                      onInput: _onMessageInput,
                      [Component.text(messageText)],
                    ),
                  ]),

                  // Send button beside input field with matching h-12 height
                  button(
                    type: ButtonType.button,
                    onClick: () => _handleSend(context),
                    disabled: isSending || messageText.trim().isEmpty,
                    classes: 'h-12 px-5 sm:px-6 rounded-2xl text-white font-extrabold text-xs shadow-md hover:shadow-lg transition-all cursor-pointer flex items-center justify-center space-x-2 shrink-0 active:scale-95 disabled:opacity-40 disabled:cursor-not-allowed border-none',
                    styles: Styles(
                      backgroundColor: Color(visibility == 'INTERNAL' ? '#F59E0B' : colorScheme.primary),
                    ),
                    [
                      if (isSending)
                        span(classes: 'text-xs font-bold tracking-wide', [Component.text('Sending...')])
                      else ...[
                        span(classes: 'hidden sm:inline font-bold tracking-wide text-xs', [
                          Component.text(visibility == 'INTERNAL' ? 'Save Note' : 'Send Reply'),
                        ]),
                        RawText('<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 19V5m0 0l-7 7m7-7l7 7" transform="rotate(45 12 12)"></path></svg>'),
                      ],
                    ],
                  ),
                ]),
              ]),
            ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Customer Message Bubble
// ─────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────
// User Message Bubble (Customer / Provider)
// ─────────────────────────────────────────────────────────────

class UserBubble extends StatelessComponent {
  final AdminSupportMessageItem? msg;
  final String body;
  final String? senderId;
  final String? defaultSenderName;
  final String? timestamp;
  final String channel;
  final AdminSupportCaseDetail? caseDetail;
  final ColorScheme colorScheme;

  const UserBubble({
    this.msg,
    required this.body,
    this.senderId,
    this.defaultSenderName,
    required this.timestamp,
    required this.channel,
    this.caseDetail,
    required this.colorScheme,
  });

  @override
  Component build(BuildContext context) {
    final targetUserId = msg?.senderId ?? senderId ?? caseDetail?.initiator?.id;

    final userDetailAsync = targetUserId != null && targetUserId.isNotEmpty
        ? context.watch(adminUserDetailProvider(targetUserId))
        : null;
    final userDetail = userDetailAsync?.value;

    final typeUpper = userDetail?.type?.toUpperCase();
    final isProvider = typeUpper == 'PROVIDER' ||
        userDetail?.providerProfile != null ||
        (msg?.senderType?.toUpperCase() == 'PROVIDER') ||
        (targetUserId != null && targetUserId == caseDetail?.providerId);

    // Get display name
    String displayName = '';
    if (userDetail != null) {
      if (isProvider && userDetail.providerProfile != null) {
        displayName = '${userDetail.providerProfile?.firstName ?? ''} ${userDetail.providerProfile?.lastName ?? ''}'.trim();
      } else if (userDetail.customerProfile != null) {
        displayName = '${userDetail.customerProfile?.firstName ?? ''} ${userDetail.customerProfile?.lastName ?? ''}'.trim();
      } else if (userDetail.providerProfile != null) {
        displayName = '${userDetail.providerProfile?.firstName ?? ''} ${userDetail.providerProfile?.lastName ?? ''}'.trim();
      }
    }

    if (displayName.isEmpty && targetUserId != null) {
      if (targetUserId == caseDetail?.initiator?.id && caseDetail?.initiator != null) {
        displayName = '${caseDetail!.initiator?.firstName ?? ''} ${caseDetail!.initiator?.lastName ?? ''}'.trim();
      }
    }

    if (displayName.isEmpty && defaultSenderName != null && defaultSenderName!.trim().isNotEmpty) {
      displayName = defaultSenderName!.trim();
    }

    if (displayName.isEmpty) {
      displayName = isProvider ? 'Provider' : 'Customer';
    }

    final roleText = isProvider ? 'PROVIDER' : 'CUSTOMER';

    // Role badge styling
    final badgeBgColor = isProvider
        ? (colorScheme.isDark ? 'rgba(59, 130, 246, 0.15)' : 'rgba(59, 130, 246, 0.10)')
        : (colorScheme.isDark ? 'rgba(0, 168, 112, 0.15)' : 'rgba(0, 168, 112, 0.10)');
    final badgeTextColor = isProvider ? '#3B82F6' : colorScheme.primary;
    final badgeBorderColor = isProvider
        ? (colorScheme.isDark ? 'rgba(59, 130, 246, 0.3)' : 'rgba(59, 130, 246, 0.2)')
        : (colorScheme.isDark ? 'rgba(0, 168, 112, 0.3)' : 'rgba(0, 168, 112, 0.2)');

    // Avatar background
    final avatarBg = isProvider ? '#3B82F6' : _avatarColor(displayName);

    return div(classes: 'flex items-start space-x-2.5 max-w-xl', [
      // Avatar
      div(
        classes: 'w-8 h-8 rounded-full flex items-center justify-center font-extrabold text-white text-xs shrink-0 shadow-2xs',
        styles: Styles(backgroundColor: Color(avatarBg)),
        [Component.text(displayName.isNotEmpty ? displayName[0].toUpperCase() : (isProvider ? 'P' : 'C'))],
      ),
      div(classes: 'space-y-1.5 min-w-0', [
        // Name & Role badge row
        div(classes: 'flex items-center space-x-2 text-[10.5px]', [
          span(
            classes: 'font-bold truncate',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [Component.text(displayName)],
          ),
          span(
            classes: 'px-1.5 py-0.2 rounded-md text-[9px] font-extrabold uppercase tracking-wider border shrink-0',
            styles: Styles(
              backgroundColor: Color(badgeBgColor),
              color: Color(badgeTextColor),
              raw: {'border-color': badgeBorderColor},
            ),
            [Component.text(roleText)],
          ),
        ]),
        // Bubble body
        div(
          classes: 'p-3.5 rounded-2xl rounded-tl-sm border shadow-2xs leading-relaxed text-xs font-medium',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            color: Color(colorScheme.textPrimary),
            raw: {'border-color': colorScheme.border},
          ),
          [Component.text(body)],
        ),
        // Footer row: time + channel
        div(classes: 'flex items-center space-x-2 text-[10px]', [
          span(classes: 'text-slate-400 font-medium', [Component.text(formatSupportTime(timestamp))]),
          span(classes: 'text-slate-300 dark:text-slate-600', [Component.text('•')]),
          span(
            classes: 'font-semibold px-1.5 py-0.5 rounded-md',
            styles: Styles(
              backgroundColor: colorScheme.isDark ? Color.rgba(100, 116, 139, 0.15) : Color.rgba(100, 116, 139, 0.08),
              color: Color(colorScheme.textMuted),
            ),
            [Component.text('Via $channel')],
          ),
        ]),
      ]),
    ]);
  }

  String _avatarColor(String name) {
    final colors = ['#10B981', '#6366F1', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899', '#14B8A6'];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}

class CustomerBubble extends UserBubble {
  const CustomerBubble({
    required String textBody,
    required String senderName,
    required super.timestamp,
    required super.channel,
    required super.colorScheme,
  }) : super(body: textBody, defaultSenderName: senderName);
}

// ─────────────────────────────────────────────────────────────
// Agent (Support) Reply Bubble
// ─────────────────────────────────────────────────────────────

class AgentBubble extends StatelessComponent {
  final AdminSupportMessageItem msg;
  final ColorScheme colorScheme;

  const AgentBubble({super.key, required this.msg, required this.colorScheme});

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex flex-col items-end max-w-xl ml-auto space-y-1.5', [
      // Label
      div(classes: 'flex items-center space-x-2 text-[10.5px] px-1', [
        span(
          classes: 'font-semibold px-1.5 py-0.5 rounded-md',
          styles: Styles(
            backgroundColor: colorScheme.isDark ? Color.rgba(0, 168, 112, 0.15) : Color.rgba(0, 168, 112, 0.08),
            color: Color(colorScheme.primary),
          ),
          [Component.text('Reply by Agent')],
        ),
      ]),
      // Bubble
      div(classes: 'flex items-end space-x-2.5', [
        div(classes: 'space-y-1.5', [
          div(
            classes: 'p-3.5 rounded-2xl rounded-tr-sm text-white shadow-md leading-relaxed text-xs font-medium',
            styles: Styles(
              backgroundColor: Color(colorScheme.primary),
            ),
            [Component.text(msg.body ?? '')],
          ),
          // Footer: time + channel
          div(classes: 'flex items-center justify-end space-x-2 text-[10px]', [
            span(classes: 'text-slate-400 font-medium', [Component.text(formatSupportTime(msg.createdAt))]),
            if (msg.channel != null) ...[
              span(classes: 'text-slate-300 dark:text-slate-600', [Component.text('•')]),
              span(
                classes: 'font-semibold px-1.5 py-0.5 rounded-md',
                styles: Styles(
                  backgroundColor: colorScheme.isDark ? Color.rgba(100, 116, 139, 0.15) : Color.rgba(100, 116, 139, 0.08),
                  color: Color(colorScheme.textMuted),
                ),
                [Component.text('Via ${msg.channel}')],
              ),
            ],
          ]),
        ]),
        // Agent avatar on right
        div(
          classes: 'w-8 h-8 rounded-full flex items-center justify-center font-bold text-white text-xs shrink-0 shadow-2xs',
          styles: Styles(
            backgroundColor: Color(colorScheme.primary),
          ),
          [Component.text('A')],
        ),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Internal Note Bubble
// ─────────────────────────────────────────────────────────────

class InternalNoteBubble extends StatelessComponent {
  final AdminSupportMessageItem msg;
  final ColorScheme colorScheme;

  const InternalNoteBubble({super.key, required this.msg, required this.colorScheme});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'my-2 mx-auto max-w-lg p-3.5 rounded-2xl border-2 border-dashed text-xs space-y-1.5 shadow-2xs',
      styles: Styles(
        backgroundColor: colorScheme.isDark ? Color.rgba(245, 158, 11, 0.08) : Color.rgba(245, 158, 11, 0.06),
        raw: {'border-color': colorScheme.isDark ? 'rgba(245, 158, 11, 0.3)' : 'rgba(245, 158, 11, 0.35)'},
      ),
      [
        div(classes: 'flex items-center justify-between', [
          div(classes: 'flex items-center space-x-1.5', [
            div(classes: 'w-3.5 h-3.5 text-amber-500', [const AppIcon(AppIcons.documents)]),
            span(
              classes: 'font-bold text-[11px]',
              styles: Styles(color: Color(colorScheme.isDark ? '#FCD34D' : '#B45309')),
              [Component.text('Internal Admin Note')],
            ),
          ]),
          span(
            classes: 'text-[10px] font-medium',
            styles: Styles(color: Color(colorScheme.isDark ? '#FCD34D' : '#D97706')),
            [Component.text(formatSupportTime(msg.createdAt))],
          ),
        ]),
        p(
          classes: 'font-medium leading-relaxed',
          styles: Styles(color: Color(colorScheme.isDark ? '#FDE68A' : '#92400E')),
          [Component.text(msg.body ?? '')],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Timeline Event Chip
// ─────────────────────────────────────────────────────────────

class TimelineChip extends StatelessComponent {
  final AdminSupportTimelineItem item;
  final ColorScheme colorScheme;

  const TimelineChip({super.key, required this.item, required this.colorScheme});

  @override
  Component build(BuildContext context) {
    return div(classes: 'my-3 flex items-center justify-center space-x-3', [
      // Left line
      div(
        classes: 'flex-1 h-px',
        styles: Styles(backgroundColor: Color(colorScheme.border)),
        [],
      ),
      // Chip
      div(
        classes: 'px-3 py-1.5 rounded-full text-[10.5px] font-bold border flex items-center space-x-1.5 shadow-2xs shrink-0',
        styles: Styles(
          backgroundColor: Color(colorScheme.inputBg),
          color: Color(colorScheme.textSecondary),
          raw: {'border-color': colorScheme.borderInput},
        ),
        [
          div(classes: 'w-3 h-3 text-emerald-500', [const AppIcon(AppIcons.auditLogs)]),
          span([Component.text(item.title ?? item.description ?? 'Timeline event')]),
          span(classes: 'text-slate-400 font-normal', [Component.text(formatSupportTime(item.timestamp))]),
        ],
      ),
      // Right line
      div(
        classes: 'flex-1 h-px',
        styles: Styles(backgroundColor: Color(colorScheme.border)),
        [],
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Attachment Item Card Component
// ─────────────────────────────────────────────────────────────

class AttachmentCard extends StatelessComponent {
  final AdminSupportAttachmentItem attachment;
  final ColorScheme colorScheme;

  const AttachmentCard({super.key, required this.attachment, required this.colorScheme});

  @override
  Component build(BuildContext context) {
    final filename = attachment.filename ?? 'Attachment File';
    final formattedSize = _formatSize(attachment.size);
    final formattedTime = formatSupportTime(attachment.createdAt);

    return div(
      classes: 'p-3 rounded-xl border flex items-center justify-between transition-all hover:border-[#00A870]/40 shadow-2xs',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.borderInput},
      ),
      [
        div(classes: 'flex items-center space-x-2.5 min-w-0 flex-1 pr-2', [
          div(
            classes: 'w-8 h-8 rounded-lg flex items-center justify-center shrink-0 border',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.primary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [const AppIcon(AppIcons.documents)],
          ),
          div(classes: 'min-w-0 flex-1', [
            div(
              classes: 'font-bold text-xs truncate',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text(filename)],
            ),
            div(
              classes: 'text-[10px] flex items-center space-x-1.5 font-medium',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [
                span([Component.text(formattedSize)]),
                span([Component.text('•')]),
                span([Component.text(formattedTime)]),
              ],
            ),
          ]),
        ]),
        if (attachment.storageKey != null || attachment.id != null)
          a(
            href: attachment.storageKey != null && attachment.storageKey!.startsWith('http')
                ? attachment.storageKey!
                : '#',
            target: Target.blank,
            classes: 'px-2.5 py-1 rounded-lg text-[10.5px] font-bold border transition-all cursor-pointer shrink-0 hover:opacity-80',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.primary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [Component.text('View')],
          ),
      ],
    );
  }

  String _formatSize(num? bytes) {
    if (bytes == null || bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-header text displaying Customer & Provider details
// ─────────────────────────────────────────────────────────────

class _ChatPanelHeaderSubtext extends StatelessComponent {
  final AdminSupportCaseDetail? caseDetail;
  final ColorScheme colorScheme;

  const _ChatPanelHeaderSubtext({
    required this.caseDetail,
    required this.colorScheme,
  });

  @override
  Component build(BuildContext context) {
    if (caseDetail == null) return const Component.fragment([]);

    final customerId = caseDetail!.customerId;
    final providerId = caseDetail!.providerId;
    final initiatorId = caseDetail!.initiator?.id;

    final userIds = <String>[];
    if (initiatorId != null && initiatorId.isNotEmpty) userIds.add(initiatorId);
    if (customerId != null && customerId.isNotEmpty && !userIds.contains(customerId)) userIds.add(customerId);
    if (providerId != null && providerId.isNotEmpty && !userIds.contains(providerId)) userIds.add(providerId);

    final parts = <String>[];

    for (final id in userIds) {
      final userDetail = context.watch(adminUserDetailProvider(id)).value;

      final typeUpper = userDetail?.type?.toUpperCase();
      final isProvider = typeUpper == 'PROVIDER' ||
          userDetail?.providerProfile != null ||
          (id == providerId);

      final roleLabel = isProvider ? 'Provider' : 'Customer';

      String name = '';
      if (userDetail != null) {
        if (isProvider && userDetail.providerProfile != null) {
          name = '${userDetail.providerProfile?.firstName ?? ''} ${userDetail.providerProfile?.lastName ?? ''}'.trim();
        } else if (userDetail.customerProfile != null) {
          name = '${userDetail.customerProfile?.firstName ?? ''} ${userDetail.customerProfile?.lastName ?? ''}'.trim();
        } else if (userDetail.providerProfile != null) {
          name = '${userDetail.providerProfile?.firstName ?? ''} ${userDetail.providerProfile?.lastName ?? ''}'.trim();
        }
      }

      if (name.isEmpty && id == initiatorId && caseDetail!.initiator != null) {
        name = '${caseDetail!.initiator?.firstName ?? ''} ${caseDetail!.initiator?.lastName ?? ''}'.trim();
      }

      if (name.isEmpty && id == customerId && caseDetail!.customer != null) {
        name = caseDetail!.customer?['name']?.toString() ?? '';
      }

      if (name.isEmpty && id == providerId && caseDetail!.provider != null) {
        name = caseDetail!.provider?['name']?.toString() ?? '';
      }

      if (name.isNotEmpty) {
        parts.add('$roleLabel: $name');
      }
    }

    if (parts.isEmpty && caseDetail!.initiator != null) {
      final name = '${caseDetail!.initiator?.firstName ?? ''} ${caseDetail!.initiator?.lastName ?? ''}'.trim();
      if (name.isNotEmpty) parts.add(name);
      if (caseDetail!.initiator?.email != null) parts.add(caseDetail!.initiator!.email!);
    }

    if (parts.isEmpty) return const Component.fragment([]);

    return p(
      classes: 'text-[11px] font-medium truncate',
      styles: Styles(color: Color(colorScheme.textMuted)),
      [Component.text(parts.join('  ·  '))],
    );
  }
}
