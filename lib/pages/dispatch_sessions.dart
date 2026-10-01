import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:taska_admin/core/designs/colors.dart';
import 'package:taska_admin/core/utils/currency_formatter.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/base_response.dart';
import '../core/models/clients/tasks/admin_cancel_task_request.dart';
import '../core/models/clients/tasks/admin_dispatch_attempt.dart';
import '../core/models/clients/tasks/admin_dispatch_session.dart';
import '../core/models/clients/tasks/trigger_admin_redispatch_request.dart';
import '../core/providers/admin_tasks_providers.dart';
import '../core/providers/ui_state_provider.dart';

@client
class DispatchSessionsPage extends StatefulComponent {
  final String? taskId;

  const DispatchSessionsPage({
    this.taskId,
    super.key,
  });

  @override
  State<DispatchSessionsPage> createState() => _DispatchSessionsPageState();
}

class _DispatchSessionsPageState extends State<DispatchSessionsPage> {
  late String _taskIdFilter;
  String _activeTab = 'sessions'; // 'sessions' | 'attempts'
  String? _selectedSessionId;

  String _sessionStatusFilter = 'ALL';
  String _attemptStatusFilter = 'ALL';

  int _sessionPage = 1;
  final int _sessionPerPage = 20;

  int _attemptPage = 1;
  final int _attemptPerPage = 20;

  // Redispatch Modal State
  bool _isRedispatchModalOpen = false;
  String _redispatchFeedback = '';
  bool _isRedispatchSubmitting = false;

  // Cancel Task Modal State
  bool _isCancelTaskModalOpen = false;
  String _cancellationReason = '';
  String _cancellationPin = '';
  bool _isCancelTaskSubmitting = false;

  @override
  void initState() {
    super.initState();
    _taskIdFilter = component.taskId ?? '';
  }

  @override
  void didUpdateComponent(DispatchSessionsPage oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (component.taskId != oldComponent.taskId) {
      setState(() {
        _taskIdFilter = component.taskId ?? '';
        _selectedSessionId = null;
        _sessionPage = 1;
        _attemptPage = 1;
      });
    }
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
    final second = local.second.toString().padLeft(2, '0');
    return '$month ${local.day}, ${local.year} $hour:$minute:$second';
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '₦0.00';
    return amount.toNaira();
  }

  void _handleTriggerRedispatch() {
    final targetTaskId = _taskIdFilter.trim();
    if (targetTaskId.isEmpty) {
      context.showFlushbar(
        message: 'No active Task ID selected for redispatch',
        type: FlushbarType.warning,
      );
      return;
    }

    if (_isRedispatchSubmitting) return;

    setState(() {
      _isRedispatchSubmitting = true;
    });

    context.read(adminTasksProvider.notifier).triggerAdminRedispatch(
          targetTaskId,
          TriggerAdminRedispatchRequest(
            feedback: _redispatchFeedback.trim().isNotEmpty
                ? _redispatchFeedback.trim()
                : null,
          ),
          onSuccess: (message) {
            setState(() {
              _isRedispatchSubmitting = false;
              _isRedispatchModalOpen = false;
              _redispatchFeedback = '';
            });
            context.showFlushbar(
              message: message,
              type: FlushbarType.success,
            );
            _refreshData();
          },
          onError: (message) {
            setState(() {
              _isRedispatchSubmitting = false;
            });
            context.showFlushbar(
              message: message,
              type: FlushbarType.error,
            );
          },
        );
  }

  void _handleCancelTask() {
    final targetTaskId = _taskIdFilter.trim();
    if (targetTaskId.isEmpty) {
      context.showFlushbar(
        message: 'No active Task ID selected for cancellation',
        type: FlushbarType.warning,
      );
      return;
    }
    if (_cancellationReason.trim().isEmpty) {
      context.showFlushbar(
        message: 'Please provide a cancellation reason',
        type: FlushbarType.warning,
      );
      return;
    }

    if (_isCancelTaskSubmitting) return;

    setState(() {
      _isCancelTaskSubmitting = true;
    });

    context.read(adminTasksProvider.notifier).adminCancelTask(
          targetTaskId,
          AdminCancelTaskRequest(
            cancellationReason: _cancellationReason.trim(),
            cancellationPin: _cancellationPin.trim().isNotEmpty
                ? _cancellationPin.trim()
                : null,
          ),
          onSuccess: (message) {
            setState(() {
              _isCancelTaskSubmitting = false;
              _isCancelTaskModalOpen = false;
              _cancellationReason = '';
              _cancellationPin = '';
            });
            context.showFlushbar(
              message: message,
              type: FlushbarType.success,
            );
            _refreshData();
          },
          onError: (message) {
            setState(() {
              _isCancelTaskSubmitting = false;
            });
            context.showFlushbar(
              message: message,
              type: FlushbarType.error,
            );
          },
        );
  }

  void _refreshData() {
    if (_taskIdFilter.trim().isEmpty) return;
    final tId = _taskIdFilter.trim();
    context.invalidate(listDispatchSessionsProvider(
        ListDispatchSessionsParams(taskId: tId, page: _sessionPage, perPage: _sessionPerPage)));
    context.invalidate(listDispatchAttemptsProvider(
        ListDispatchAttemptsParams(taskId: tId, dispatchSessionId: _selectedSessionId, page: _attemptPage, perPage: _attemptPerPage)));
    context.invalidate(adminTaskDetailProvider(tId));
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;

    if (_taskIdFilter.trim().isEmpty) {
      return _buildEmptyState(context, colorScheme);
    }

    final activeTaskId = _taskIdFilter.trim();

    final taskDetailAsync = context.watch(adminTaskDetailProvider(activeTaskId));
    final taskDetail = taskDetailAsync.asData?.value;

    final sessionsAsync = context.watch(listDispatchSessionsProvider(
      ListDispatchSessionsParams(
        taskId: activeTaskId,
        status: _sessionStatusFilter != 'ALL' ? _sessionStatusFilter : null,
        page: _sessionPage,
        perPage: _sessionPerPage,
      ),
    ));

    final attemptsAsync = context.watch(listDispatchAttemptsProvider(
      ListDispatchAttemptsParams(
        taskId: activeTaskId,
        dispatchSessionId: _selectedSessionId,
        status: _attemptStatusFilter != 'ALL' ? _attemptStatusFilter : null,
        page: _attemptPage,
        perPage: _attemptPerPage,
      ),
    ));

    final sessionsData = sessionsAsync.asData?.value;
    final attemptsData = attemptsAsync.asData?.value;

    final sessions = sessionsData?.items ?? [];
    final attempts = attemptsData?.items ?? [];

    final totalSessions = sessionsData?.total ?? sessions.length;
    final totalAttempts = attemptsData?.total ?? attempts.length;

    return div(classes: 'space-y-6 pb-12 animate-fade-in-scaled relative', [
      // Header Navigation & Task Hero Banner
      div(classes: 'flex flex-col space-y-4', [
        // Navigation & Refresh Row
        div(classes: 'flex items-center justify-between', [
          button(
            type: ButtonType.button,
            classes:
                'flex items-center space-x-2 text-xs font-semibold text-slate-600 dark:text-slate-300 hover:text-emerald-500 transition-colors cursor-pointer border-none bg-transparent',
            events: {
              'click': (_) => Router.of(context).push('/tasks'),
            },
            [
              const div(classes: 'w-4 h-4', [AppIcon(AppIcons.overview)]),
              span([Component.text('Back to Tasks Management')]),
            ],
          ),
          button(
            type: ButtonType.button,
            classes:
                'px-3.5 py-1.5 rounded-xl border text-xs font-bold transition-all flex items-center space-x-2 cursor-pointer shadow-sm',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              raw: {'border-color': colorScheme.border},
            ),
            events: {
              'click': (_) => _refreshData(),
            },
            [
              const div(classes: 'w-3.5 h-3.5', [AppIcon(AppIcons.refresh)]),
              span([Component.text('Refresh Logs')]),
            ],
          ),
        ]),

        // Task Detail Card
        div(
          classes:
              'p-6 rounded-2xl border flex flex-col md:flex-row md:items-center justify-between gap-6 shadow-xl relative overflow-hidden transition-all',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            // Left Accent Bar
            div(
              classes:
                  'absolute top-0 left-0 bottom-0 w-1.5 bg-gradient-to-b from-emerald-500 via-teal-400 to-indigo-500',
              [],
            ),

            // Task Info
            div(classes: 'flex items-start space-x-4 pl-2 min-w-0 flex-1', [
              div(
                classes:
                    'w-14 h-14 rounded-2xl border-2 shrink-0 flex items-center justify-center bg-gradient-to-br from-emerald-500/20 to-teal-500/10 shadow-md',
                styles: Styles(raw: {'border-color': 'rgba(16, 185, 129, 0.4)'}),
                [
                  const div(
                    classes: 'w-7 h-7 text-emerald-500',
                    [AppIcon(AppIcons.tasks)],
                  ),
                ],
              ),
              div(classes: 'space-y-1.5 min-w-0 flex-1', [
                div(classes: 'flex flex-wrap items-center gap-2.5', [
                  h2(
                    classes: 'text-xl font-black tracking-tight truncate',
                    styles: Styles(color: Color(colorScheme.textHeading)),
                    [Component.text(taskDetail?.title ?? 'Task Dispatch Logs')],
                  ),
                  if (taskDetail?.status != null)
                    _buildTaskStatusPill(taskDetail!.status!, isDark),
                ]),
                div(classes: 'flex flex-wrap items-center gap-3 text-xs text-slate-500 dark:text-slate-400 font-medium', [
                  div(classes: 'flex items-center space-x-1.5', [
                    span([Component.text('Task ID:')]),
                    code(classes: 'px-2 py-0.5 rounded font-mono bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-200 font-bold', [
                      Component.text(activeTaskId),
                    ]),
                    button(
                      type: ButtonType.button,
                      classes: 'p-1 hover:text-emerald-500 transition-colors cursor-pointer border-none bg-transparent',
                      events: {
                        'click': (_) => _copyToClipboard(context, activeTaskId, 'Task ID'),
                      },
                      [const div(classes: 'w-3.5 h-3.5', [AppIcon(AppIcons.copy)])],
                    ),
                  ]),
                  if (taskDetail?.customerTotalPrice != null) ...[
                    span(classes: 'opacity-40', [Component.text('•')]),
                    span(classes: 'font-semibold text-emerald-600 dark:text-emerald-400', [
                      Component.text('Amount: ${_formatCurrency(taskDetail!.customerTotalPrice)}'),
                    ]),
                  ],
                ]),
              ]),
            ]),

            // Admin Action Buttons
            div(classes: 'flex flex-wrap items-center gap-3 shrink-0 pl-2 md:pl-0', [
              button(
                type: ButtonType.button,
                classes:
                    'px-4 py-2.5 rounded-xl text-xs font-bold transition-all cursor-pointer flex items-center space-x-2 shadow-md text-white bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-600 hover:to-teal-700 active:scale-95 border-none',
                events: {
                  'click': (_) {
                    setState(() {
                      _isRedispatchModalOpen = true;
                    });
                  },
                },
                [
                  const div(classes: 'w-3.5 h-3.5', [AppIcon(AppIcons.refresh)]),
                  span([Component.text('Trigger Redispatch')]),
                ],
              ),
              button(
                type: ButtonType.button,
                classes:
                    'px-4 py-2.5 rounded-xl text-xs font-bold transition-all cursor-pointer flex items-center space-x-2 shadow-md text-rose-600 dark:text-rose-400 bg-rose-500/10 hover:bg-rose-500/20 border border-rose-500/20 active:scale-95',
                events: {
                  'click': (_) {
                    setState(() {
                      _isCancelTaskModalOpen = true;
                    });
                  },
                },
                [
                  const div(classes: 'w-3.5 h-3.5', [AppIcon(AppIcons.close)]),
                  span([Component.text('Cancel Task')]),
                ],
              ),
            ]),
          ],
        ),
      ]),

      // Two-Tab Navigation Bar
      div(
        classes: 'border-b flex items-center justify-between gap-4',
        styles: Styles(raw: {'border-color': colorScheme.border}),
        [
          div(classes: 'flex items-center space-x-8', [
            // Tab 1: Dispatch Sessions Table
            button(
              type: ButtonType.button,
              classes:
                  'pb-3 text-sm font-bold border-b-2 transition-all flex items-center space-x-2.5 cursor-pointer border-none bg-transparent',
              styles: Styles(
                color: Color(_activeTab == 'sessions' ? colorScheme.primary : colorScheme.textSecondary),
                raw: {
                  'border-bottom-color': _activeTab == 'sessions' ? colorScheme.primary : 'transparent',
                },
              ),
              events: {
                'click': (_) {
                  setState(() {
                    _activeTab = 'sessions';
                  });
                },
              },
              [
                span([Component.text('Dispatch Sessions Table')]),
                span(
                  classes:
                      'px-2 py-0.5 rounded-full text-[11px] font-extrabold ${
                    _activeTab == 'sessions'
                        ? 'bg-emerald-500/20 text-emerald-600 dark:text-emerald-400'
                        : 'bg-slate-100 dark:bg-slate-800 text-slate-500'
                  }',
                  [Component.text('$totalSessions')],
                ),
              ],
            ),

            // Tab 2: Dispatch Attempts Table
            button(
              type: ButtonType.button,
              classes:
                  'pb-3 text-sm font-bold border-b-2 transition-all flex items-center space-x-2.5 cursor-pointer border-none bg-transparent',
              styles: Styles(
                color: Color(_activeTab == 'attempts' ? colorScheme.primary : colorScheme.textSecondary),
                raw: {
                  'border-bottom-color': _activeTab == 'attempts' ? colorScheme.primary : 'transparent',
                },
              ),
              events: {
                'click': (_) {
                  setState(() {
                    _activeTab = 'attempts';
                  });
                },
              },
              [
                span([Component.text('Dispatch Attempts Table')]),
                if (_selectedSessionId != null)
                  span(
                    classes:
                        'px-2 py-0.5 rounded-full text-[11px] font-extrabold bg-indigo-500/20 text-indigo-600 dark:text-indigo-400 flex items-center space-x-1',
                    [
                      span([Component.text('Filtered Session')]),
                    ],
                  )
                else
                  span(
                    classes:
                        'px-2 py-0.5 rounded-full text-[11px] font-extrabold ${
                      _activeTab == 'attempts'
                          ? 'bg-emerald-500/20 text-emerald-600 dark:text-emerald-400'
                          : 'bg-slate-100 dark:bg-slate-800 text-slate-500'
                    }',
                    [Component.text('$totalAttempts')],
                  ),
              ],
            ),
          ]),
        ],
      ),

      // Tab Content Rendering
      if (_activeTab == 'sessions')
        _DispatchSessionsTable(
          colorScheme: colorScheme,
          isDark: isDark,
          sessionsAsync: sessionsAsync,
          sessions: sessions,
          total: totalSessions,
          currentPage: _sessionPage,
          perPage: _sessionPerPage,
          statusFilter: _sessionStatusFilter,
          onStatusChange: (status) {
            setState(() {
              _sessionStatusFilter = status;
              _sessionPage = 1;
            });
          },
          onPreviousPage: () {
            if (_sessionPage > 1) {
              setState(() => _sessionPage--);
            }
          },
          onNextPage: () {
            final maxPage = (totalSessions / _sessionPerPage).ceil().clamp(1, 9999);
            if (_sessionPage < maxPage) {
              setState(() => _sessionPage++);
            }
          },
          onSelectSession: (session) {
            setState(() {
              _selectedSessionId = session.id;
              _activeTab = 'attempts';
              _attemptPage = 1;
            });
          },
          selectedSessionId: _selectedSessionId,
          copyToClipboard: _copyToClipboard,
          formatDateTime: _formatDateTime,
        )
      else
        _DispatchAttemptsTable(
          colorScheme: colorScheme,
          isDark: isDark,
          attemptsAsync: attemptsAsync,
          attempts: attempts,
          total: totalAttempts,
          currentPage: _attemptPage,
          perPage: _attemptPerPage,
          statusFilter: _attemptStatusFilter,
          onStatusChange: (status) {
            setState(() {
              _attemptStatusFilter = status;
              _attemptPage = 1;
            });
          },
          onPreviousPage: () {
            if (_attemptPage > 1) {
              setState(() => _attemptPage--);
            }
          },
          onNextPage: () {
            final maxPage = (totalAttempts / _attemptPerPage).ceil().clamp(1, 9999);
            if (_attemptPage < maxPage) {
              setState(() => _attemptPage++);
            }
          },
          selectedSessionId: _selectedSessionId,
          onClearSessionFilter: () {
            setState(() {
              _selectedSessionId = null;
              _attemptPage = 1;
            });
          },
          copyToClipboard: _copyToClipboard,
          formatDateTime: _formatDateTime,
          formatCurrency: _formatCurrency,
        ),

      // Modals
      if (_isRedispatchModalOpen) _buildRedispatchModal(context, colorScheme),
      if (_isCancelTaskModalOpen) _buildCancelTaskModal(context, colorScheme),
    ]);
  }

  Component _buildEmptyState(BuildContext context, dynamic colorScheme) {
    return div(classes: 'flex flex-col items-center justify-center min-h-[60vh] text-center p-6 space-y-4', [
      div(classes: 'w-20 h-20 rounded-3xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-500 shadow-xl', [
        const div(classes: 'w-9 h-9', [AppIcon(AppIcons.tasks)]),
      ]),
      h3(classes: 'text-2xl font-bold text-slate-800 dark:text-slate-100 tracking-tight', [Component.text('No Task Specified')]),
      p(classes: 'text-sm text-slate-500 dark:text-slate-400 max-w-md leading-relaxed', [
        Component.text('Dispatch sessions and attempts are strictly tied to specific tasks. Please navigate to Tasks Management and select "Dispatch Sessions" on a task to view its logs.'),
      ]),
      button(
        type: ButtonType.button,
        classes:
            'px-6 py-3 rounded-xl font-bold text-xs text-white bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-600 hover:to-teal-700 shadow-lg transition-all active:scale-95 cursor-pointer border-none',
        events: {
          'click': (_) => Router.of(context).push('/tasks'),
        },
        [Component.text('Go to Tasks Management')],
      ),
    ]);
  }

  Component _buildTaskStatusPill(String status, bool isDark) {
    String colorClasses = 'bg-slate-500/10 text-slate-600 dark:text-slate-300';
    final s = status.toUpperCase();
    if (s == 'COMPLETED' || s == 'OPEN') {
      colorClasses = 'bg-emerald-500/15 text-emerald-600 dark:text-emerald-400';
    } else if (s == 'IN_PROGRESS' || s == 'ASSIGNED') {
      colorClasses = 'bg-cyan-500/15 text-cyan-600 dark:text-cyan-400';
    } else if (s == 'CANCELLED' || s == 'EXPIRED') {
      colorClasses = 'bg-rose-500/15 text-rose-600 dark:text-rose-400';
    }

    return span(
      classes: 'px-2.5 py-0.5 rounded-full text-[11px] font-extrabold tracking-wide uppercase $colorClasses',
      [Component.text(s)],
    );
  }

  Component _buildRedispatchModal(BuildContext context, dynamic colorScheme) {
    return div(
      classes:
          'fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fadeIn',
      [
        div(
          classes:
              'w-full max-w-md p-6 rounded-3xl border shadow-2xl space-y-5 relative bg-white dark:bg-slate-900',
          styles: Styles(raw: {'border-color': colorScheme.border}),
          [
            div(classes: 'flex items-center justify-between', [
              h3(classes: 'text-lg font-bold text-slate-800 dark:text-slate-100', [
                Component.text('Trigger Admin Redispatch'),
              ]),
              button(
                type: ButtonType.button,
                classes: 'p-1 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 cursor-pointer border-none bg-transparent',
                events: {
                  'click': (_) {
                    setState(() {
                      _isRedispatchModalOpen = false;
                    });
                  },
                },
                [const div(classes: 'w-4 h-4', [AppIcon(AppIcons.close)])],
              ),
            ]),

            p(classes: 'text-xs text-slate-500 dark:text-slate-400', [
              Component.text('This will manually trigger a new dispatch session for Task ID '),
              strong(classes: 'font-mono text-slate-700 dark:text-slate-200', [Component.text(_taskIdFilter)]),
              Component.text('.'),
            ]),

            div(classes: 'space-y-1.5', [
              label(classes: 'text-xs font-bold text-slate-700 dark:text-slate-300', [
                Component.text('Redispatch Reason / Feedback (Optional)'),
              ]),
              textarea(
                const [],
                classes:
                    'w-full p-3 rounded-xl border text-xs bg-slate-500/5 focus:outline-none focus:ring-2 focus:ring-emerald-500/50 resize-none h-24',
                styles: Styles(raw: {'border-color': colorScheme.borderInput}),
                attributes: {'placeholder': 'e.g. Previous provider failed to arrive, manual override required.'},
                onInput: (val) {
                  _redispatchFeedback = val.toString();
                },
              ),
            ]),

            div(classes: 'flex items-center justify-end space-x-3 pt-2', [
              button(
                type: ButtonType.button,
                classes: 'px-4 py-2 rounded-xl text-xs font-bold text-slate-600 dark:text-slate-300 hover:bg-slate-500/10 cursor-pointer border-none bg-transparent',
                events: {
                  'click': (_) {
                    setState(() {
                      _isRedispatchModalOpen = false;
                    });
                  },
                },
                [Component.text('Cancel')],
              ),
              button(
                type: ButtonType.button,
                classes:
                    'px-5 py-2.5 rounded-xl text-xs font-bold text-white bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-600 hover:to-teal-700 shadow-md cursor-pointer border-none',
                events: {'click': (_) => _handleTriggerRedispatch()},
                [
                  if (_isRedispatchSubmitting)
                    span([Component.text('Submitting...')])
                  else
                    span([Component.text('Confirm Redispatch')]),
                ],
              ),
            ]),
          ],
        ),
      ],
    );
  }

  Component _buildCancelTaskModal(BuildContext context, dynamic colorScheme) {
    return div(
      classes:
          'fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fadeIn',
      [
        div(
          classes:
              'w-full max-w-md p-6 rounded-3xl border shadow-2xl space-y-5 relative bg-white dark:bg-slate-900',
          styles: Styles(raw: {'border-color': colorScheme.border}),
          [
            div(classes: 'flex items-center justify-between', [
              h3(classes: 'text-lg font-bold text-rose-600 dark:text-rose-400', [
                Component.text('Cancel Task'),
              ]),
              button(
                type: ButtonType.button,
                classes: 'p-1 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 cursor-pointer border-none bg-transparent',
                events: {
                  'click': (_) {
                    setState(() {
                      _isCancelTaskModalOpen = false;
                    });
                  },
                },
                [const div(classes: 'w-4 h-4', [AppIcon(AppIcons.close)])],
              ),
            ]),

            p(classes: 'text-xs text-slate-500 dark:text-slate-400', [
              Component.text('Are you sure you want to cancel Task ID '),
              strong(classes: 'font-mono text-slate-700 dark:text-slate-200', [Component.text(_taskIdFilter)]),
              Component.text('? This action will terminate active dispatching.'),
            ]),

            div(classes: 'space-y-1.5', [
              label(classes: 'text-xs font-bold text-slate-700 dark:text-slate-300', [
                Component.text('Cancellation Reason (Required)'),
              ]),
              textarea(
                const [],
                classes:
                    'w-full p-3 rounded-xl border text-xs bg-slate-500/5 focus:outline-none focus:ring-2 focus:ring-rose-500/50 resize-none h-20',
                styles: Styles(raw: {'border-color': colorScheme.borderInput}),
                attributes: {'placeholder': 'e.g. Customer requested cancellation via support.'},
                onInput: (val) {
                  _cancellationReason = val.toString();
                },
              ),
            ]),

            div(classes: 'space-y-1.5', [
              label(classes: 'text-xs font-bold text-slate-700 dark:text-slate-300', [
                Component.text('Cancellation Pin (Optional)'),
              ]),
              input(
                type: InputType.password,
                classes:
                    'w-full p-3 rounded-xl border text-xs bg-slate-500/5 focus:outline-none focus:ring-2 focus:ring-rose-500/50',
                styles: Styles(raw: {'border-color': colorScheme.borderInput}),
                attributes: {'placeholder': 'Security PIN'},
                onInput: (val) {
                  _cancellationPin = val.toString();
                },
              ),
            ]),

            div(classes: 'flex items-center justify-end space-x-3 pt-2', [
              button(
                type: ButtonType.button,
                classes: 'px-4 py-2 rounded-xl text-xs font-bold text-slate-600 dark:text-slate-300 hover:bg-slate-500/10 cursor-pointer border-none bg-transparent',
                events: {
                  'click': (_) {
                    setState(() {
                      _isCancelTaskModalOpen = false;
                    });
                  },
                },
                [Component.text('Back')],
              ),
              button(
                type: ButtonType.button,
                classes:
                    'px-5 py-2.5 rounded-xl text-xs font-bold text-white bg-rose-600 hover:bg-rose-700 shadow-md cursor-pointer border-none',
                events: {'click': (_) => _handleCancelTask()},
                [
                  if (_isCancelTaskSubmitting)
                    span([Component.text('Cancelling...')])
                  else
                    span([Component.text('Confirm Cancellation')]),
                ],
              ),
            ]),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dispatch Sessions Table Component
// ─────────────────────────────────────────────────────────────

class _DispatchSessionsTable extends StatelessComponent {
  final AppColorScheme colorScheme;
  final bool isDark;
  final AsyncValue<PaginatedData<AdminDispatchSession>?> sessionsAsync;
  final List<AdminDispatchSession> sessions;
  final int total;
  final int currentPage;
  final int perPage;
  final String statusFilter;
  final void Function(String status) onStatusChange;
  final void Function() onPreviousPage;
  final void Function() onNextPage;
  final void Function(AdminDispatchSession session) onSelectSession;
  final String? selectedSessionId;
  final void Function(BuildContext context, String text, String label) copyToClipboard;
  final String Function(DateTime? dt) formatDateTime;

  const _DispatchSessionsTable({
    required this.colorScheme,
    required this.isDark,
    required this.sessionsAsync,
    required this.sessions,
    required this.total,
    required this.currentPage,
    required this.perPage,
    required this.statusFilter,
    required this.onStatusChange,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onSelectSession,
    required this.selectedSessionId,
    required this.copyToClipboard,
    required this.formatDateTime,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'border rounded-2xl shadow-sm transition-all overflow-hidden p-5 sm:p-6 space-y-5 min-w-0',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        // Filter Bar
        div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-4', [
          div(classes: 'flex items-center space-x-2 text-xs text-slate-500 dark:text-slate-400 font-medium', [
            const div(classes: 'w-4 h-4', [AppIcon(AppIcons.tasks)]),
            span([Component.text('Dispatch Sessions Log Records')]),
          ]),

          div(classes: 'flex flex-wrap items-center gap-2', [
            span(
              classes: 'text-[11px] font-bold uppercase tracking-wider mr-1',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text('Status:')],
            ),
            for (final status in ['ALL', 'PENDING', 'COMPLETED', 'FAILED', 'CANCELLED'])
              button(
                onClick: () => onStatusChange(status),
                classes:
                    'px-3 py-1.5 rounded-lg transition-all cursor-pointer text-[11px] font-bold border',
                styles: statusFilter == status
                    ? Styles(
                        backgroundColor: Color(colorScheme.primary),
                        color: Color('#FFFFFF'),
                        raw: {'border-color': colorScheme.primary},
                      )
                    : Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        color: Color(colorScheme.textSecondary),
                        raw: {'border-color': colorScheme.borderInput},
                      ),
                [Component.text(status)],
              ),
          ]),
        ]),

        // Content / Table
        sessionsAsync.when(
          data: (_) {
            if (sessions.isEmpty) {
              return _buildEmptySessionsState(colorScheme);
            }

            return div(classes: 'space-y-5', [
              div(
                classes: 'overflow-x-auto rounded-xl border transition-colors',
                styles: Styles(raw: {'border-color': colorScheme.border}),
                [
                  table(classes: 'w-full min-w-[900px] text-left border-collapse text-xs', [
                    thead(
                      classes: 'uppercase tracking-wider text-[10.5px] border-b font-bold',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        color: Color(colorScheme.textMuted),
                        raw: {'border-color': colorScheme.border},
                      ),
                      [
                        tr([
                          th(classes: 'p-3.5 pl-4 whitespace-nowrap', [Component.text('Session ID')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Status')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Trigger')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Sequence')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Radius')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Batch Size')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Started At')]),
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
                        for (final session in sessions)
                          tr(
                            classes:
                                'hover:opacity-90 transition-colors cursor-pointer ${selectedSessionId == session.id ? 'bg-emerald-500/10 font-bold' : ''}',
                            events: {
                              'click': (_) => onSelectSession(session),
                            },
                            [
                              // Session ID
                              td(classes: 'p-3.5 pl-4 font-mono text-xs whitespace-nowrap', [
                                div(classes: 'flex items-center space-x-1.5', [
                                  span(
                                    classes: 'font-bold text-xs truncate max-w-[160px]',
                                    styles: Styles(color: Color(colorScheme.textHeading)),
                                    [Component.text(session.id ?? 'N/A')],
                                  ),
                                  if (session.id != null)
                                    button(
                                      type: ButtonType.button,
                                      onClick: () => copyToClipboard(context, session.id!, 'Session ID'),
                                      classes:
                                          'p-1 hover:text-emerald-500 transition-colors cursor-pointer border-none bg-transparent',
                                      [const div(classes: 'w-3 h-3', [AppIcon(AppIcons.copy)])],
                                    ),
                                ]),
                              ]),
                              // Status
                              td(classes: 'p-3.5 whitespace-nowrap', [
                                _buildStatusPill(session.status, isDark),
                              ]),
                              // Trigger
                              td(classes: 'p-3.5 whitespace-nowrap', [
                                span(
                                  classes:
                                      'px-2.5 py-1 rounded-lg text-[10.5px] font-bold uppercase tracking-wider border font-mono',
                                  styles: Styles(
                                    backgroundColor: Color(colorScheme.inputBg),
                                    color: Color(colorScheme.textSecondary),
                                    raw: {'border-color': colorScheme.borderInput},
                                  ),
                                  [Component.text(session.trigger ?? 'N/A')],
                                ),
                              ]),
                              // Sequence
                              td(
                                classes: 'p-3.5 font-mono text-xs whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textSecondary)),
                                [Component.text('#${session.sequence ?? 1}')],
                              ),
                              // Radius
                              td(
                                classes: 'p-3.5 font-mono text-xs whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textSecondary)),
                                [Component.text('${session.searchRadiusKm ?? '—'} km')],
                              ),
                              // Batch Size
                              td(
                                classes: 'p-3.5 font-mono text-xs whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textSecondary)),
                                [Component.text('${session.batchSize ?? '—'}')],
                              ),
                              // Started At
                              td(
                                classes: 'p-3.5 text-xs font-medium whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textMuted)),
                                [Component.text(formatDateTime(session.startedAt ?? session.createdAt))],
                              ),
                              // Action Button
                              td(classes: 'p-3.5 pr-4 text-center whitespace-nowrap', [
                                button(
                                  onClick: () => onSelectSession(session),
                                  classes:
                                      'text-white text-[11px] font-bold px-3 py-1.5 rounded-lg shadow-xs cursor-pointer transition-all border-none whitespace-nowrap shrink-0',
                                  styles: Styles(backgroundColor: Color(colorScheme.primary)),
                                  [Component.text('View Attempts')],
                                ),
                              ]),
                            ],
                          ),
                      ],
                    ),
                  ]),
                ],
              ),

              // Pagination Footer
              _TablePaginationFooter(
                colorScheme: colorScheme,
                total: total,
                perPage: perPage,
                currentPage: currentPage,
                onPreviousPage: onPreviousPage,
                onNextPage: onNextPage,
              ),
            ]);
          },
          loading: () => _buildShimmerTable(colorScheme),
          error: (err, _) => _buildErrorCard(colorScheme, err.toString()),
        ),
      ],
    );
  }

  Component _buildStatusPill(String? status, bool isDark) {
    final s = (status ?? 'PENDING').toUpperCase();
    Color bg;
    Color fg;
    String border;

    if (s == 'COMPLETED') {
      bg = isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1);
      fg = isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0);
      border = isDark ? 'rgba(16, 185, 129, 0.4)' : 'rgba(16, 185, 129, 0.25)';
    } else if (s == 'FAILED' || s == 'CANCELLED') {
      bg = isDark ? Color.rgba(244, 63, 94, 0.18) : Color.rgba(244, 63, 94, 0.1);
      fg = isDark ? Color.rgba(253, 164, 175, 1.0) : Color.rgba(190, 18, 60, 1.0);
      border = isDark ? 'rgba(244, 63, 94, 0.4)' : 'rgba(244, 63, 94, 0.25)';
    } else {
      bg = isDark ? Color.rgba(245, 158, 11, 0.18) : Color.rgba(245, 158, 11, 0.1);
      fg = isDark ? Color.rgba(252, 211, 77, 1.0) : Color.rgba(180, 83, 9, 1.0);
      border = isDark ? 'rgba(245, 158, 11, 0.4)' : 'rgba(245, 158, 11, 0.25)';
    }

    return span(
      classes:
          'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border font-mono whitespace-nowrap',
      styles: Styles(
        backgroundColor: bg,
        color: fg,
        raw: {'border-color': border},
      ),
      [Component.text(s)],
    );
  }

  Component _buildEmptySessionsState(AppColorScheme colorScheme) {
    return div(
      classes: 'py-12 text-center space-y-3 border rounded-xl p-6',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.borderInput},
      ),
      [
        div(
          classes: 'w-12 h-12 rounded-full mx-auto flex items-center justify-center opacity-60',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            color: Color(colorScheme.textMuted),
          ),
          [const AppIcon(AppIcons.tasks)],
        ),
        p(
          classes: 'text-sm font-bold',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text('No dispatch sessions recorded')],
        ),
        p(
          classes: 'text-xs font-medium max-w-sm mx-auto',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('No sessions matched your status filter criteria for this task.')],
        ),
      ],
    );
  }

  Component _buildShimmerTable(AppColorScheme colorScheme) {
    return div(classes: 'space-y-3 animate-pulse py-4', [
      for (var i = 0; i < 5; i++)
        div(
          classes: 'h-14 rounded-xl border',
          styles: Styles(
            backgroundColor:
                colorScheme.isDark ? Color.rgba(31, 45, 39, 0.8) : Color.rgba(226, 232, 240, 0.8),
            raw: {'border-color': colorScheme.border},
          ),
          [],
        ),
    ]);
  }

  Component _buildErrorCard(AppColorScheme colorScheme, String message) {
    return div(
      classes: 'py-8 text-center space-y-2 border rounded-xl p-6 border-rose-500/30 bg-rose-500/5',
      [
        p(classes: 'text-xs font-bold text-rose-500', [Component.text('Failed to load sessions: $message')]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dispatch Attempts Table Component
// ─────────────────────────────────────────────────────────────

class _DispatchAttemptsTable extends StatelessComponent {
  final AppColorScheme colorScheme;
  final bool isDark;
  final AsyncValue<PaginatedData<AdminDispatchAttempt>?> attemptsAsync;
  final List<AdminDispatchAttempt> attempts;
  final int total;
  final int currentPage;
  final int perPage;
  final String statusFilter;
  final void Function(String status) onStatusChange;
  final void Function() onPreviousPage;
  final void Function() onNextPage;
  final String? selectedSessionId;
  final void Function() onClearSessionFilter;
  final void Function(BuildContext context, String text, String label) copyToClipboard;
  final String Function(DateTime? dt) formatDateTime;
  final String Function(num? amount) formatCurrency;

  const _DispatchAttemptsTable({
    required this.colorScheme,
    required this.isDark,
    required this.attemptsAsync,
    required this.attempts,
    required this.total,
    required this.currentPage,
    required this.perPage,
    required this.statusFilter,
    required this.onStatusChange,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.selectedSessionId,
    required this.onClearSessionFilter,
    required this.copyToClipboard,
    required this.formatDateTime,
    required this.formatCurrency,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'border rounded-2xl shadow-sm transition-all overflow-hidden p-5 sm:p-6 space-y-5 min-w-0',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        // Active Filter Context Banner
        if (selectedSessionId != null)
          div(
            classes:
                'flex items-center justify-between p-3.5 rounded-xl border bg-emerald-500/10 border-emerald-500/20 text-xs',
            [
              div(classes: 'flex items-center space-x-2', [
                span(classes: 'font-bold text-emerald-800 dark:text-emerald-200', [
                  Component.text('Filtered Session:'),
                ]),
                code(classes: 'px-2 py-0.5 rounded font-mono bg-emerald-500/20 font-bold text-emerald-900 dark:text-emerald-100', [
                  Component.text(selectedSessionId!),
                ]),
              ]),
              button(
                type: ButtonType.button,
                onClick: onClearSessionFilter,
                classes:
                    'text-xs font-bold text-emerald-700 dark:text-emerald-300 hover:underline cursor-pointer border-none bg-transparent',
                [Component.text('Clear Session Filter (Show All Task Attempts)')],
              ),
            ],
          ),

        // Filter Bar
        div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-4', [
          div(classes: 'flex items-center space-x-2 text-xs text-slate-500 dark:text-slate-400 font-medium', [
            const div(classes: 'w-4 h-4', [AppIcon(AppIcons.tasks)]),
            span([Component.text('Dispatch Attempts Log Records')]),
          ]),

          div(classes: 'flex flex-wrap items-center gap-2', [
            span(
              classes: 'text-[11px] font-bold uppercase tracking-wider mr-1',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text('Status:')],
            ),
            for (final status in ['ALL', 'ACCEPTED', 'DECLINED', 'EXPIRED', 'PENDING'])
              button(
                onClick: () => onStatusChange(status),
                classes:
                    'px-3 py-1.5 rounded-lg transition-all cursor-pointer text-[11px] font-bold border',
                styles: statusFilter == status
                    ? Styles(
                        backgroundColor: Color(colorScheme.primary),
                        color: Color('#FFFFFF'),
                        raw: {'border-color': colorScheme.primary},
                      )
                    : Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        color: Color(colorScheme.textSecondary),
                        raw: {'border-color': colorScheme.borderInput},
                      ),
                [Component.text(status)],
              ),
          ]),
        ]),

        // Content / Table
        attemptsAsync.when(
          data: (_) {
            if (attempts.isEmpty) {
              return _buildEmptyAttemptsState(colorScheme);
            }

            return div(classes: 'space-y-5', [
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
                          th(classes: 'p-3.5 pl-4 whitespace-nowrap', [Component.text('Status')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Provider')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Sequence')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Match Score')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Offered Payout')]),
                          th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Pinged At')]),
                          th(classes: 'p-3.5 pr-4 whitespace-nowrap', [Component.text('Responded At')]),
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
                        for (final attempt in attempts)
                          tr(
                            classes: 'hover:opacity-90 transition-colors',
                            [
                              // Status
                              td(classes: 'p-3.5 pl-4 whitespace-nowrap', [
                                _buildAttemptStatusPill(attempt.status, isDark),
                              ]),
                              // Provider
                              td(classes: 'p-3.5 whitespace-nowrap', [
                                div(classes: 'flex flex-col space-y-0.5 min-w-0', [
                                  span(
                                    classes: 'font-bold text-xs truncate max-w-xs',
                                    styles: Styles(color: Color(colorScheme.textHeading)),
                                    [
                                      Component.text(
                                        (attempt.provider?.firstName != null || attempt.provider?.lastName != null)
                                            ? '${attempt.provider?.firstName ?? ''} ${attempt.provider?.lastName ?? ''}'.trim()
                                            : (attempt.providerId ?? 'Provider Candidate'),
                                      ),
                                    ],
                                  ),
                                  if (attempt.providerId != null)
                                    div(classes: 'flex items-center space-x-1 text-[11px] font-mono', [
                                      span(
                                        classes: 'truncate max-w-[140px]',
                                        styles: Styles(color: Color(colorScheme.textMuted)),
                                        [Component.text('ID: ${attempt.providerId}')],
                                      ),
                                      button(
                                        type: ButtonType.button,
                                        onClick: () => copyToClipboard(context, attempt.providerId!, 'Provider ID'),
                                        classes:
                                            'p-0.5 hover:text-emerald-500 transition-colors cursor-pointer border-none bg-transparent',
                                        [const div(classes: 'w-3 h-3', [AppIcon(AppIcons.copy)])],
                                      ),
                                    ]),
                                ]),
                              ]),
                              // Sequence Order
                              td(
                                classes: 'p-3.5 font-mono text-xs whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textSecondary)),
                                [Component.text('#${attempt.sequenceOrder ?? 1}')],
                              ),
                              // Match Score
                              td(
                                classes: 'p-3.5 font-mono text-xs whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textSecondary)),
                                [Component.text('${attempt.matchScore ?? 'N/A'}')],
                              ),
                              // Offered Payout
                              td(
                                classes: 'p-3.5 font-mono text-xs font-bold whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.primary)),
                                [Component.text(formatCurrency(attempt.offeredPayout))],
                              ),
                              // Pinged At
                              td(
                                classes: 'p-3.5 text-xs font-medium whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textMuted)),
                                [Component.text(formatDateTime(attempt.pingedAt))],
                              ),
                              // Responded At
                              td(
                                classes: 'p-3.5 pr-4 text-xs font-medium whitespace-nowrap',
                                styles: Styles(color: Color(colorScheme.textMuted)),
                                [Component.text(formatDateTime(attempt.respondedAt))],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ]),
                ],
              ),

              // Pagination Footer
              _TablePaginationFooter(
                colorScheme: colorScheme,
                total: total,
                perPage: perPage,
                currentPage: currentPage,
                onPreviousPage: onPreviousPage,
                onNextPage: onNextPage,
              ),
            ]);
          },
          loading: () => _buildShimmerTable(colorScheme),
          error: (err, _) => _buildErrorCard(colorScheme, err.toString()),
        ),
      ],
    );
  }

  Component _buildAttemptStatusPill(String? status, bool isDark) {
    final s = (status ?? 'PENDING').toUpperCase();
    Color bg;
    Color fg;
    String border;

    if (s == 'ACCEPTED') {
      bg = isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1);
      fg = isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0);
      border = isDark ? 'rgba(16, 185, 129, 0.4)' : 'rgba(16, 185, 129, 0.25)';
    } else if (s == 'DECLINED' || s == 'EXPIRED') {
      bg = isDark ? Color.rgba(244, 63, 94, 0.18) : Color.rgba(244, 63, 94, 0.1);
      fg = isDark ? Color.rgba(253, 164, 175, 1.0) : Color.rgba(190, 18, 60, 1.0);
      border = isDark ? 'rgba(244, 63, 94, 0.4)' : 'rgba(244, 63, 94, 0.25)';
    } else {
      bg = isDark ? Color.rgba(245, 158, 11, 0.18) : Color.rgba(245, 158, 11, 0.1);
      fg = isDark ? Color.rgba(252, 211, 77, 1.0) : Color.rgba(180, 83, 9, 1.0);
      border = isDark ? 'rgba(245, 158, 11, 0.4)' : 'rgba(245, 158, 11, 0.25)';
    }

    return span(
      classes:
          'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border font-mono whitespace-nowrap',
      styles: Styles(
        backgroundColor: bg,
        color: fg,
        raw: {'border-color': border},
      ),
      [Component.text(s)],
    );
  }

  Component _buildEmptyAttemptsState(AppColorScheme colorScheme) {
    return div(
      classes: 'py-12 text-center space-y-3 border rounded-xl p-6',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.borderInput},
      ),
      [
        div(
          classes: 'w-12 h-12 rounded-full mx-auto flex items-center justify-center opacity-60',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            color: Color(colorScheme.textMuted),
          ),
          [const AppIcon(AppIcons.tasks)],
        ),
        p(
          classes: 'text-sm font-bold',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text('No dispatch attempts recorded')],
        ),
        p(
          classes: 'text-xs font-medium max-w-sm mx-auto',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('No dispatch attempts matched your status filter criteria for this query.')],
        ),
      ],
    );
  }

  Component _buildShimmerTable(AppColorScheme colorScheme) {
    return div(classes: 'space-y-3 animate-pulse py-4', [
      for (var i = 0; i < 5; i++)
        div(
          classes: 'h-14 rounded-xl border',
          styles: Styles(
            backgroundColor:
                colorScheme.isDark ? Color.rgba(31, 45, 39, 0.8) : Color.rgba(226, 232, 240, 0.8),
            raw: {'border-color': colorScheme.border},
          ),
          [],
        ),
    ]);
  }

  Component _buildErrorCard(AppColorScheme colorScheme, String message) {
    return div(
      classes: 'py-8 text-center space-y-2 border rounded-xl p-6 border-rose-500/30 bg-rose-500/5',
      [
        p(classes: 'text-xs font-bold text-rose-500', [Component.text('Failed to load attempts: $message')]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Reusable Table Pagination Footer
// ─────────────────────────────────────────────────────────────

class _TablePaginationFooter extends StatelessComponent {
  final AppColorScheme colorScheme;
  final int total;
  final int perPage;
  final int currentPage;
  final void Function() onPreviousPage;
  final void Function() onNextPage;

  const _TablePaginationFooter({
    required this.colorScheme,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Component build(BuildContext context) {
    final start = total == 0 ? 0 : (currentPage - 1) * perPage + 1;
    final end = (currentPage * perPage).clamp(0, total);
    final maxPage = (total / perPage).ceil().clamp(1, 9999);

    return div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-2', [
      span(
        classes: 'text-xs font-medium',
        styles: Styles(color: Color(colorScheme.textMuted)),
        [
          Component.text('Showing $start to $end of $total records'),
        ],
      ),
      div(classes: 'flex items-center space-x-2', [
        button(
          onClick: onPreviousPage,
          disabled: currentPage <= 1,
          classes: currentPage <= 1
              ? 'px-3 py-1.5 rounded-lg text-xs font-bold transition-all cursor-not-allowed border opacity-40'
              : 'px-3 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer border hover:opacity-80 active:scale-95',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textPrimary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          [Component.text('Previous')],
        ),
        span(
          classes: 'text-xs font-bold px-2 font-mono',
          styles: Styles(color: Color(colorScheme.textSecondary)),
          [Component.text('$currentPage / $maxPage')],
        ),
        button(
          onClick: onNextPage,
          disabled: currentPage >= maxPage,
          classes: currentPage >= maxPage
              ? 'px-3 py-1.5 rounded-lg text-xs font-bold transition-all cursor-not-allowed border opacity-40'
              : 'px-3 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer border hover:opacity-80 active:scale-95',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textPrimary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          [Component.text('Next')],
        ),
      ]),
    ]);
  }
}
