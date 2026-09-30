import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';
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
  AdminDispatchSession? _selectedSession;

  String _sessionStatusFilter = 'ALL';
  String _attemptStatusFilter = 'ALL';

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
        _selectedSession = null;
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
    return '$month ${local.day}, ${local.year} at $hour:$minute:$second';
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
        ListDispatchSessionsParams(taskId: tId)));
    context.invalidate(listDispatchAttemptsProvider(
        ListDispatchAttemptsParams(taskId: tId, dispatchSessionId: _selectedSessionId)));
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

    // Fetch Task Detail if available
    final taskDetailAsync = context.watch(adminTaskDetailProvider(activeTaskId));
    final taskDetail = taskDetailAsync.asData?.value;

    // Fetch Sessions for Task
    final sessionsAsync = context.watch(listDispatchSessionsProvider(
      ListDispatchSessionsParams(
        taskId: activeTaskId,
        status: _sessionStatusFilter != 'ALL' ? _sessionStatusFilter : null,
      ),
    ));

    // Fetch Attempts for Task / Session
    final attemptsAsync = context.watch(listDispatchAttemptsProvider(
      ListDispatchAttemptsParams(
        taskId: activeTaskId,
        dispatchSessionId: _selectedSessionId,
        status: _attemptStatusFilter != 'ALL' ? _attemptStatusFilter : null,
      ),
    ));

    final sessions = sessionsAsync.asData?.value?.items ?? [];
    final attempts = attemptsAsync.asData?.value?.items ?? [];

    final totalSessions = sessionsAsync.asData?.value?.total ?? sessions.length;
    final totalAttempts = attemptsAsync.asData?.value?.total ?? attempts.length;

    return div(classes: 'space-y-6 pb-12', [
      // ─────────────────────────────────────────────────────────────
      // Header Navigation & Task Hero Banner
      // ─────────────────────────────────────────────────────────────
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

      // ─────────────────────────────────────────────────────────────
      // Two-Tab Header Navigation Bar
      // ─────────────────────────────────────────────────────────────
      div(
        classes: 'border-b flex items-center justify-between gap-4',
        styles: Styles(raw: {'border-color': colorScheme.border}),
        [
          div(classes: 'flex items-center space-x-8', [
            // Tab 1: Dispatch Sessions
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
                span([Component.text('Dispatch Sessions')]),
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

            // Tab 2: Dispatch Attempts
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
                span([Component.text('Dispatch Attempts')]),
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

      // ─────────────────────────────────────────────────────────────
      // Tab Content Rendering
      // ─────────────────────────────────────────────────────────────
      if (_activeTab == 'sessions')
        _buildSessionsTabContent(
          context,
          colorScheme,
          isDark,
          sessionsAsync,
          sessions,
        )
      else
        _buildAttemptsTabContent(
          context,
          colorScheme,
          isDark,
          attemptsAsync,
          attempts,
        ),

      // Modals
      if (_isRedispatchModalOpen) _buildRedispatchModal(context, colorScheme),
      if (_isCancelTaskModalOpen) _buildCancelTaskModal(context, colorScheme),
    ]);
  }

  // ─────────────────────────────────────────────────────────────
  // Tab 1: Dispatch Sessions View
  // ─────────────────────────────────────────────────────────────
  Component _buildSessionsTabContent(
    BuildContext context,
    dynamic colorScheme,
    bool isDark,
    AsyncValue<PaginatedData<AdminDispatchSession>?> asyncVal,
    List<AdminDispatchSession> sessions,
  ) {
    if (asyncVal.isLoading) {
      return _buildLoadingState(colorScheme);
    }

    if (asyncVal.hasError) {
      return _buildErrorState(colorScheme, asyncVal.error.toString());
    }

    return div(classes: 'space-y-4', [
      // Filter Bar
      div(classes: 'flex flex-wrap items-center justify-between gap-4 p-4 rounded-2xl border bg-slate-500/5', [
        div(classes: 'flex items-center space-x-2 text-xs text-slate-500 dark:text-slate-400 font-medium', [
          const div(classes: 'w-3.5 h-3.5', [AppIcon(AppIcons.tasks)]),
          span([Component.text('Showing ${sessions.length} Dispatch Session(s) for Task')]),
        ]),
        div(classes: 'flex items-center space-x-3', [
          span(classes: 'text-xs font-semibold text-slate-500', [Component.text('Status:')]),
          select(
            classes:
                'px-3 py-1.5 rounded-xl border text-xs font-semibold bg-transparent focus:outline-none transition-colors cursor-pointer',
            styles: Styles(raw: {'border-color': colorScheme.borderInput}),
            events: {
              'change': (e) {
                final target = e.target as web.HTMLSelectElement;
                setState(() {
                  _sessionStatusFilter = target.value;
                });
              },
            },
            [
              option(value: 'ALL', selected: _sessionStatusFilter == 'ALL', [Component.text('All Statuses')]),
              option(value: 'PENDING', selected: _sessionStatusFilter == 'PENDING', [Component.text('Pending')]),
              option(value: 'COMPLETED', selected: _sessionStatusFilter == 'COMPLETED', [Component.text('Completed')]),
              option(value: 'FAILED', selected: _sessionStatusFilter == 'FAILED', [Component.text('Failed')]),
              option(value: 'CANCELLED', selected: _sessionStatusFilter == 'CANCELLED', [Component.text('Cancelled')]),
            ],
          ),
        ]),
      ]),

      // List Table / Cards
      if (sessions.isEmpty)
        div(classes: 'p-12 text-center rounded-2xl border bg-slate-500/5 space-y-3', [
          div(classes: 'w-12 h-12 rounded-2xl bg-slate-500/10 flex items-center justify-center mx-auto text-slate-400', [
            const AppIcon(AppIcons.tasks),
          ]),
          h4(classes: 'text-base font-bold text-slate-700 dark:text-slate-200', [Component.text('No Dispatch Sessions Found')]),
          p(classes: 'text-xs text-slate-500 max-w-sm mx-auto', [
            Component.text('There are currently no dispatch sessions recorded matching this filter for Task ID $_taskIdFilter.'),
          ]),
        ])
      else
        div(classes: 'space-y-3', [
          for (final session in sessions)
            _buildSessionCard(context, colorScheme, isDark, session),
        ]),
    ]);
  }

  Component _buildSessionCard(
    BuildContext context,
    dynamic colorScheme,
    bool isDark,
    AdminDispatchSession session,
  ) {
    final isSelected = _selectedSessionId == session.id;

    return div(
      classes:
          'p-5 rounded-2xl border transition-all hover:shadow-md flex flex-col md:flex-row md:items-center justify-between gap-4 relative overflow-hidden ${
        isSelected ? 'ring-2 ring-emerald-500/50 bg-emerald-500/5' : ''
      }',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': isSelected ? colorScheme.primary : colorScheme.border},
      ),
      [
        div(classes: 'flex items-start space-x-4 min-w-0 flex-1', [
          div(
            classes:
                'w-11 h-11 rounded-xl bg-slate-100 dark:bg-slate-800 shrink-0 flex items-center justify-center text-slate-500 dark:text-slate-400',
            [const AppIcon(AppIcons.tasks)],
          ),
          div(classes: 'space-y-1.5 min-w-0 flex-1', [
            div(classes: 'flex flex-wrap items-center gap-2.5', [
              span(classes: 'font-bold text-sm text-slate-800 dark:text-slate-100', [
                Component.text('Session: ${session.id?.substring(0, session.id!.length > 12 ? 12 : session.id!.length) ?? 'N/A'}...'),
              ]),
              _buildSessionStatusPill(session.status, isDark),
              if (session.trigger != null)
                span(classes: 'px-2 py-0.5 rounded text-[10px] font-bold bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300', [
                  Component.text(session.trigger!),
                ]),
            ]),
            div(classes: 'flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-slate-500 dark:text-slate-400', [
              if (session.sequence != null)
                span([Component.text('Sequence: #${session.sequence}')]),
              if (session.searchRadiusKm != null) ...[
                span(classes: 'opacity-40', [Component.text('•')]),
                span([Component.text('Search Radius: ${session.searchRadiusKm} km')]),
              ],
              if (session.batchSize != null) ...[
                span(classes: 'opacity-40', [Component.text('•')]),
                span([Component.text('Batch Size: ${session.batchSize}')]),
              ],
              span(classes: 'opacity-40', [Component.text('•')]),
              span([Component.text('Started: ${_formatDateTime(session.startedAt ?? session.createdAt)}')]),
            ]),
          ]),
        ]),

        // View Attempts Action Button
        div(classes: 'flex items-center space-x-3 shrink-0 pt-2 md:pt-0 border-t md:border-t-0', [
          button(
            type: ButtonType.button,
            classes:
                'px-4 py-2 rounded-xl text-xs font-bold transition-all cursor-pointer flex items-center space-x-2 shadow-sm text-white bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-600 hover:to-teal-700 active:scale-95 border-none',
            events: {
              'click': (_) {
                setState(() {
                  _selectedSessionId = session.id;
                  _selectedSession = session;
                  _activeTab = 'attempts';
                });
              },
            },
            [
              span([Component.text('View Attempts')]),
              const div(classes: 'w-3.5 h-3.5', [AppIcon(AppIcons.chevronRight)]),
            ],
          ),
        ]),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Tab 2: Dispatch Attempts View
  // ─────────────────────────────────────────────────────────────
  Component _buildAttemptsTabContent(
    BuildContext context,
    dynamic colorScheme,
    bool isDark,
    AsyncValue<PaginatedData<AdminDispatchAttempt>?> asyncVal,
    List<AdminDispatchAttempt> attempts,
  ) {
    if (asyncVal.isLoading) {
      return _buildLoadingState(colorScheme);
    }

    if (asyncVal.hasError) {
      return _buildErrorState(colorScheme, asyncVal.error.toString());
    }

    return div(classes: 'space-y-4', [
      // Filter & Session Context Banner
      div(classes: 'space-y-3', [
        if (_selectedSessionId != null)
          div(
            classes:
                'flex items-center justify-between p-4 rounded-2xl border bg-emerald-500/10 border-emerald-500/20 text-xs',
            [
              div(classes: 'flex items-center space-x-2', [
                span(classes: 'font-bold text-emerald-800 dark:text-emerald-200', [
                  Component.text('Filtered Session:'),
                ]),
                code(classes: 'px-2 py-0.5 rounded font-mono bg-emerald-500/20 font-bold text-emerald-900 dark:text-emerald-100', [
                  Component.text(_selectedSessionId!),
                ]),
                if (_selectedSession?.trigger != null)
                  span(classes: 'text-xs text-emerald-700 dark:text-emerald-300 font-medium', [
                    Component.text('(${_selectedSession!.trigger})'),
                  ]),
              ]),
              button(
                type: ButtonType.button,
                classes:
                    'text-xs font-bold text-emerald-700 dark:text-emerald-300 hover:underline cursor-pointer border-none bg-transparent',
                events: {
                  'click': (_) {
                    setState(() {
                      _selectedSessionId = null;
                      _selectedSession = null;
                    });
                  },
                },
                [Component.text('Clear Session Filter (Show All Task Attempts)')],
              ),
            ],
          ),

        div(classes: 'flex flex-wrap items-center justify-between gap-4 p-4 rounded-2xl border bg-slate-500/5', [
          div(classes: 'flex items-center space-x-2 text-xs text-slate-500 dark:text-slate-400 font-medium', [
            const div(classes: 'w-3.5 h-3.5', [AppIcon(AppIcons.tasks)]),
            span([
              Component.text(
                _selectedSessionId != null
                    ? 'Showing ${attempts.length} Attempt(s) for selected session'
                    : 'Showing ${attempts.length} Attempt(s) for task',
              ),
            ]),
          ]),
          div(classes: 'flex items-center space-x-3', [
            span(classes: 'text-xs font-semibold text-slate-500', [Component.text('Status:')]),
            select(
              classes:
                  'px-3 py-1.5 rounded-xl border text-xs font-semibold bg-transparent focus:outline-none transition-colors cursor-pointer',
              styles: Styles(raw: {'border-color': colorScheme.borderInput}),
              events: {
                'change': (e) {
                  final target = e.target as web.HTMLSelectElement;
                  setState(() {
                    _attemptStatusFilter = target.value;
                  });
                },
              },
              [
                option(value: 'ALL', selected: _attemptStatusFilter == 'ALL', [Component.text('All Statuses')]),
                option(value: 'ACCEPTED', selected: _attemptStatusFilter == 'ACCEPTED', [Component.text('Accepted')]),
                option(value: 'DECLINED', selected: _attemptStatusFilter == 'DECLINED', [Component.text('Declined')]),
                option(value: 'EXPIRED', selected: _attemptStatusFilter == 'EXPIRED', [Component.text('Expired')]),
                option(value: 'PENDING', selected: _attemptStatusFilter == 'PENDING', [Component.text('Pending')]),
              ],
            ),
          ]),
        ]),
      ]),

      // List Cards
      if (attempts.isEmpty)
        div(classes: 'p-12 text-center rounded-2xl border bg-slate-500/5 space-y-3', [
          div(classes: 'w-12 h-12 rounded-2xl bg-slate-500/10 flex items-center justify-center mx-auto text-slate-400', [
            const AppIcon(AppIcons.tasks),
          ]),
          h4(classes: 'text-base font-bold text-slate-700 dark:text-slate-200', [Component.text('No Dispatch Attempts Found')]),
          p(classes: 'text-xs text-slate-500 max-w-sm mx-auto', [
            Component.text('No matching provider dispatch attempts recorded for this query.'),
          ]),
        ])
      else
        div(classes: 'space-y-3', [
          for (final attempt in attempts)
            _buildAttemptCard(context, colorScheme, isDark, attempt),
        ]),
    ]);
  }

  Component _buildAttemptCard(
    BuildContext context,
    dynamic colorScheme,
    bool isDark,
    AdminDispatchAttempt attempt,
  ) {
    final providerName = (attempt.provider?.firstName != null || attempt.provider?.lastName != null)
        ? '${attempt.provider?.firstName ?? ''} ${attempt.provider?.lastName ?? ''}'.trim()
        : null;

    return div(
      classes: 'p-5 rounded-2xl border transition-all hover:shadow-md space-y-3',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'flex flex-wrap items-center justify-between gap-3', [
          div(classes: 'flex items-center space-x-3', [
            _buildAttemptStatusPill(attempt.status, isDark),
            if (providerName != null && providerName.isNotEmpty)
              span(classes: 'text-xs font-bold text-slate-800 dark:text-slate-100', [
                Component.text(providerName),
              ]),
            if (attempt.providerId != null)
              div(classes: 'flex items-center space-x-1.5 text-xs text-slate-600 dark:text-slate-300 font-medium', [
                span([Component.text('Provider ID:')]),
                code(classes: 'px-2 py-0.5 rounded font-mono bg-slate-100 dark:bg-slate-800 font-bold', [
                  Component.text(attempt.providerId!),
                ]),
                button(
                  type: ButtonType.button,
                  classes: 'p-1 hover:text-emerald-500 transition-colors cursor-pointer border-none bg-transparent',
                  events: {
                    'click': (_) => _copyToClipboard(context, attempt.providerId!, 'Provider ID'),
                  },
                  [const div(classes: 'w-3 h-3', [AppIcon(AppIcons.copy)])],
                ),
              ]),
          ]),
          span(classes: 'text-xs text-slate-400 font-medium', [
            Component.text(_formatDateTime(attempt.pingedAt)),
          ]),
        ]),

        div(classes: 'grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs pt-1', [
          div(classes: 'p-2.5 rounded-xl bg-slate-500/5 space-y-0.5', [
            span(classes: 'text-[10px] text-slate-400 font-bold uppercase tracking-wider', [Component.text('Sequence Order')]),
            p(classes: 'font-semibold text-slate-700 dark:text-slate-200', [
              Component.text('#${attempt.sequenceOrder ?? 1}'),
            ]),
          ]),
          div(classes: 'p-2.5 rounded-xl bg-slate-500/5 space-y-0.5', [
            span(classes: 'text-[10px] text-slate-400 font-bold uppercase tracking-wider', [Component.text('Match Score')]),
            p(classes: 'font-semibold text-slate-700 dark:text-slate-200', [
              Component.text('${attempt.matchScore ?? 'N/A'}'),
            ]),
          ]),
          div(classes: 'p-2.5 rounded-xl bg-slate-500/5 space-y-0.5', [
            span(classes: 'text-[10px] text-slate-400 font-bold uppercase tracking-wider', [Component.text('Offered Payout')]),
            p(classes: 'font-semibold text-emerald-600 dark:text-emerald-400', [
              Component.text(_formatCurrency(attempt.offeredPayout)),
            ]),
          ]),
          div(classes: 'p-2.5 rounded-xl bg-slate-500/5 space-y-0.5', [
            span(classes: 'text-[10px] text-slate-400 font-bold uppercase tracking-wider', [Component.text('Responded At')]),
            p(classes: 'font-semibold text-slate-700 dark:text-slate-200 truncate', [
              Component.text(_formatDateTime(attempt.respondedAt)),
            ]),
          ]),
        ]),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Helper UI States & Modals
  // ─────────────────────────────────────────────────────────────
  Component _buildEmptyState(BuildContext context, dynamic colorScheme) {
    return div(classes: 'flex flex-col items-center justify-center min-h-[60vh] text-center p-6 space-y-4', [
      div(classes: 'w-20 h-20 rounded-3xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-500 shadow-xl', [
        const div(classes: 'w-9 h-9', [AppIcon(AppIcons.tasks)]),
      ]),
      h3(classes: 'text-2xl font-bold text-slate-800 dark:text-slate-100 tracking-tight', [Component.text('No Task Specified')]),
      p(classes: 'text-sm text-slate-500 dark:text-slate-400 max-w-md leading-relaxed', [
        Component.text('Dispatch sessions and attempts are strictly tied to specific tasks. Please navigate to Tasks Management and click "Dispatch Sessions" on a task detail side panel to view its logs.'),
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

  Component _buildLoadingState(dynamic colorScheme) {
    return div(classes: 'p-12 text-center rounded-2xl border bg-slate-500/5 space-y-3', [
      div(classes: 'w-8 h-8 rounded-full border-2 border-emerald-500 border-t-transparent animate-spin mx-auto', []),
      p(classes: 'text-xs text-slate-500 font-medium', [Component.text('Loading dispatch records...')]),
    ]);
  }

  Component _buildErrorState(dynamic colorScheme, String message) {
    return div(classes: 'p-8 rounded-2xl border bg-rose-500/10 border-rose-500/20 text-center space-y-2', [
      h4(classes: 'text-sm font-bold text-rose-600 dark:text-rose-400', [Component.text('Failed to load dispatch records')]),
      p(classes: 'text-xs text-rose-500 max-w-md mx-auto', [Component.text(message)]),
      button(
        type: ButtonType.button,
        classes: 'px-3 py-1.5 rounded-lg text-xs font-bold bg-rose-500/20 text-rose-700 dark:text-rose-300 hover:bg-rose-500/30 transition-colors cursor-pointer border-none',
        events: {'click': (_) => _refreshData()},
        [Component.text('Try Again')],
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

  Component _buildSessionStatusPill(String? status, bool isDark) {
    final s = (status ?? 'PENDING').toUpperCase();
    String colorClasses = 'bg-amber-500/15 text-amber-600 dark:text-amber-400';
    if (s == 'COMPLETED') {
      colorClasses = 'bg-emerald-500/15 text-emerald-600 dark:text-emerald-400';
    } else if (s == 'FAILED' || s == 'CANCELLED') {
      colorClasses = 'bg-rose-500/15 text-rose-600 dark:text-rose-400';
    }

    return span(
      classes: 'px-2.5 py-0.5 rounded-full text-[10px] font-extrabold tracking-wide uppercase $colorClasses',
      [Component.text(s)],
    );
  }

  Component _buildAttemptStatusPill(String? status, bool isDark) {
    final s = (status ?? 'PENDING').toUpperCase();
    String colorClasses = 'bg-amber-500/15 text-amber-600 dark:text-amber-400';
    if (s == 'ACCEPTED') {
      colorClasses = 'bg-emerald-500/15 text-emerald-600 dark:text-emerald-400';
    } else if (s == 'DECLINED' || s == 'EXPIRED') {
      colorClasses = 'bg-rose-500/15 text-rose-600 dark:text-rose-400';
    }

    return span(
      classes: 'px-2.5 py-0.5 rounded-full text-[10px] font-extrabold tracking-wide uppercase $colorClasses',
      [Component.text(s)],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Redispatch Modal
  // ─────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────
  // Cancel Task Modal
  // ─────────────────────────────────────────────────────────────
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
