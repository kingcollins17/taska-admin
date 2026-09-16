import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/users/admin_platform_user_item.dart';
import '../core/models/clients/vetting/admin_schedule_interview_body.dart';
import '../core/providers/admin_user_providers.dart';
import '../core/providers/stats_providers.dart';
import '../core/providers/ui_state_provider.dart';

class ScheduleInterviewDialog extends StatefulComponent {
  final String? initialUserId;
  final AdminPlatformUserItem? initialUser;

  const ScheduleInterviewDialog({
    super.key,
    this.initialUserId,
    this.initialUser,
  });

  static void show(BuildContext context, {String? userId, AdminPlatformUserItem? user}) {
    context.showDialog(
      ScheduleInterviewDialog(initialUserId: userId, initialUser: user),
      title: 'Schedule Provider Interview',
    );
  }

  @override
  State<ScheduleInterviewDialog> createState() => _ScheduleInterviewDialogState();
}

class _ScheduleInterviewDialogState extends State<ScheduleInterviewDialog> {
  AdminPlatformUserItem? _selectedUser;
  String? _selectedUserId;

  // Search state
  String _searchQuery = '';
  String _searchInputValue = '';
  Timer? _searchDebounceTimer;

  // Form state
  String _scheduledAt = '';
  String _meetingLink = '';
  String _notes = '';
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedUser = component.initialUser;
    _selectedUserId = component.initialUserId ?? component.initialUser?.id;
  }

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
        _searchQuery = _searchInputValue;
      });
    });
  }

  void _selectUser(AdminPlatformUserItem user) {
    setState(() {
      _selectedUser = user;
      _selectedUserId = user.id;
    });
  }

  void _clearSelectedUser() {
    setState(() {
      _selectedUser = null;
      _selectedUserId = null;
    });
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final targetUserId = _selectedUserId ?? _selectedUser?.id;
    if (targetUserId == null || targetUserId.isEmpty) {
      setState(() {
        _errorMessage = 'Please select a provider user to schedule the interview for.';
      });
      return;
    }

    if (_scheduledAt.isEmpty) {
      setState(() {
        _errorMessage = 'Please select a scheduled date and time.';
      });
      return;
    }

    String formattedDate = _scheduledAt;
    try {
      final dt = DateTime.parse(_scheduledAt);
      formattedDate = dt.toUtc().toIso8601String();
    } catch (_) {}

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final body = AdminScheduleInterviewBody(
      userId: targetUserId,
      scheduledAt: formattedDate,
      meetingLink: _meetingLink.trim().isEmpty ? null : _meetingLink.trim(),
      notes: _notes.trim().isEmpty ? null : _notes.trim(),
    );

    context.read(adminUserManagementProvider.notifier).scheduleInterview(
      body,
      onSuccess: () {
        context.showFlushbar(
          title: 'Interview Scheduled',
          message: 'Online interview scheduled successfully.',
          type: FlushbarType.success,
        );
        context.hideDialog();
        // Refresh interview stats
        context.read(adminInterviewStatsProvider);
      },
      onError: (msg) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = msg;
        });
      },
    );
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    // If no user is selected, render user search step
    if (_selectedUser == null && (_selectedUserId == null || _selectedUserId!.isEmpty)) {
      return _buildUserSearchStep(context, colorScheme);
    }

    // Otherwise render interview form step
    return _buildFormStep(context, colorScheme);
  }

  // ─────────────────────────────────────────────────────────────
  // Step 1: User Search & Selection View
  // ─────────────────────────────────────────────────────────────
  Component _buildUserSearchStep(BuildContext context, ColorScheme colorScheme) {
    final usersAsync = context.watch(
      adminUsersProvider(
        GetUsersParams(
          search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
          page: 1,
        ),
      ),
    );

    return div(classes: 'space-y-4', [
      div(classes: 'space-y-1', [
        h4(
          classes: 'text-sm font-bold',
          styles: Styles(color: Color(colorScheme.textHeading)),
          [Component.text('Select Provider User')],
        ),
        p(
          classes: 'text-xs font-medium',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Search for a platform user to schedule an online interview.')],
        ),
      ]),

      // Search input field
      div(classes: 'relative w-full', [
        div(
          classes: 'absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none',
          styles: Styles(color: Color(colorScheme.placeholder)),
          [const AppIcon(AppIcons.search)],
        ),
        input(
          type: InputType.text,
          value: _searchInputValue,
          classes:
              'w-full border rounded-xl pl-9 pr-4 py-2.5 text-xs font-medium focus:outline-none focus:ring-2 transition-all',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textPrimary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          attributes: {'placeholder': 'Search user by email, name, or phone...'},
          onInput: _onSearchInput,
        ),
      ]),

      // User search results
      usersAsync.when(
        data: (paginatedData) {
          final items = paginatedData?.items ?? [];

          if (items.isEmpty) {
            return div(
              classes: 'py-10 text-center space-y-2 border rounded-xl p-4',
              styles: Styles(
                backgroundColor: Color(colorScheme.surface),
                raw: {'border-color': colorScheme.border},
              ),
              [
                p(
                  classes: 'text-xs font-semibold',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  [Component.text(_searchQuery.isEmpty ? 'Type to search platform users' : 'No users matching "$_searchQuery"')],
                ),
              ],
            );
          }

          return div(
            classes: 'space-y-2 max-h-72 overflow-y-auto pr-1',
            [
              for (final user in items)
                div(
                  classes:
                      'p-3 border rounded-xl flex items-center justify-between hover:border-emerald-500/50 transition-all cursor-pointer shadow-xs',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.surface),
                    raw: {'border-color': colorScheme.border},
                  ),
                  events: {
                    'click': (_) => _selectUser(user),
                  },
                  [
                    div(classes: 'flex items-center space-x-3 overflow-hidden', [
                      img(
                        src:
                            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.fullname ?? user.email ?? 'User')}&background=0D9488&color=fff',
                        classes: 'w-9 h-9 rounded-full object-cover border shrink-0',
                        styles: Styles(raw: {'border-color': colorScheme.border}),
                        alt: user.fullname ?? 'User',
                      ),
                      div(classes: 'min-w-0', [
                        div(
                          classes: 'font-bold text-xs truncate',
                          styles: Styles(color: Color(colorScheme.textHeading)),
                          [Component.text(user.fullname ?? 'Unknown User')],
                        ),
                        div(
                          classes: 'text-[11px] truncate',
                          styles: Styles(color: Color(colorScheme.textMuted)),
                          [Component.text(user.email ?? user.phoneNumber ?? 'No contact info')],
                        ),
                      ]),
                    ]),

                    div(classes: 'flex items-center space-x-2 shrink-0 ml-2', [
                      span(
                        classes: 'text-[10px] font-bold px-2 py-0.5 rounded-md border uppercase',
                        styles: Styles(
                          backgroundColor: Color(colorScheme.inputBg),
                          color: Color(colorScheme.primary),
                          raw: {'border-color': colorScheme.borderInput},
                        ),
                        [Component.text(user.type ?? 'USER')],
                      ),
                      button(
                        type: ButtonType.button,
                        classes:
                            'text-white text-xs font-bold px-3 py-1.5 rounded-lg shadow-xs cursor-pointer border-none',
                        styles: Styles(backgroundColor: Color(colorScheme.primary)),
                        [Component.text('Select')],
                      ),
                    ]),
                  ],
                ),
            ],
          );
        },
        loading: () => div(classes: 'space-y-2 animate-pulse', [
          for (var i = 0; i < 3; i++)
            div(
              classes: 'h-14 rounded-xl border',
              styles: Styles(
                backgroundColor: colorScheme.isDark ? Color.rgba(31, 45, 39, 0.8) : Color.rgba(226, 232, 240, 0.8),
                raw: {'border-color': colorScheme.border},
              ),
              [],
            ),
        ]),
        error: (err, _) => div(
          classes: 'p-4 rounded-xl border text-xs text-rose-500 font-semibold text-center',
          styles: Styles(raw: {'border-color': colorScheme.border}),
          [Component.text('Error searching users: $err')],
        ),
      ),
    ]);
  }

  // ─────────────────────────────────────────────────────────────
  // Step 2: Interview Form Details View
  // ─────────────────────────────────────────────────────────────
  Component _buildFormStep(BuildContext context, ColorScheme colorScheme) {
    return div(classes: 'space-y-5', [
      // Selected User Summary Card
      div(
        classes: 'p-3.5 border rounded-xl flex items-center justify-between transition-colors shadow-xs',
        styles: Styles(
          backgroundColor: Color(colorScheme.inputBg),
          raw: {'border-color': colorScheme.borderInput},
        ),
        [
          div(classes: 'flex items-center space-x-3 overflow-hidden', [
            img(
              src:
                  'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_selectedUser?.fullname ?? _selectedUser?.email ?? _selectedUserId ?? 'Provider')}&background=0D9488&color=fff',
              classes: 'w-10 h-10 rounded-full object-cover border shrink-0',
              styles: Styles(raw: {'border-color': colorScheme.border}),
              alt: _selectedUser?.fullname ?? 'Provider',
            ),
            div(classes: 'min-w-0', [
              div(
                classes: 'font-bold text-xs truncate',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text(_selectedUser?.fullname ?? 'Provider Candidate')],
              ),
              div(
                classes: 'text-[11px] truncate font-mono',
                styles: Styles(color: Color(colorScheme.textMuted)),
                [Component.text(_selectedUser?.email ?? _selectedUserId ?? '')],
              ),
            ]),
          ]),

          if (component.initialUser == null && component.initialUserId == null)
            button(
              type: ButtonType.button,
              onClick: _clearSelectedUser,
              classes: 'text-xs font-bold cursor-pointer hover:underline border-none bg-transparent',
              styles: Styles(color: Color(colorScheme.primary)),
              [Component.text('Change User')],
            ),
        ],
      ),

      if (_errorMessage != null)
        div(
          classes: 'p-3 rounded-xl border border-rose-500/30 bg-rose-500/10 text-rose-500 text-xs font-semibold',
          [Component.text(_errorMessage!)],
        ),

      // Date & Time Picker
      div(classes: 'space-y-1.5', [
        label(
          classes: 'block text-xs font-bold uppercase tracking-wider',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [
            Component.text('Interview Date & Time *'),
          ],
        ),
        input(
          type: InputType.dateTimeLocal,
          value: _scheduledAt,
          classes:
              'w-full border rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:ring-2 transition-all',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textPrimary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          onInput: (val) {
            setState(() {
              _scheduledAt = val.toString();
              _errorMessage = null;
            });
          },
        ),
      ]),

      // Meeting Link URL Input
      div(classes: 'space-y-1.5', [
        label(
          classes: 'block text-xs font-bold uppercase tracking-wider',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [
            Component.text('Meeting Link (Optional)'),
          ],
        ),
        input(
          type: InputType.url,
          value: _meetingLink,
          classes:
              'w-full border rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:ring-2 transition-all',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textPrimary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          attributes: {'placeholder': 'e.g. https://meet.google.com/abc-defg-hij'},
          onInput: (val) {
            setState(() {
              _meetingLink = val.toString();
            });
          },
        ),
      ]),

      // Notes Input
      div(classes: 'space-y-1.5', [
        label(
          classes: 'block text-xs font-bold uppercase tracking-wider',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [
            Component.text('Admin Notes (Optional)'),
          ],
        ),
        textarea(
          classes:
              'w-full border rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:ring-2 transition-all resize-none',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textPrimary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          attributes: {
            'rows': '3',
            'placeholder': 'Add any preparation notes or background details for this interview...',
            'value': _notes,
          },
          onInput: (val) {
            setState(() {
              _notes = val.toString();
            });
          },
          [],
        ),
      ]),

      // Dialog Actions
      div(classes: 'flex items-center justify-end space-x-3 pt-2', [
        button(
          type: ButtonType.button,
          onClick: () => context.hideDialog(),
          classes: 'px-4 py-2.5 rounded-xl border text-xs font-bold transition-all cursor-pointer',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textSecondary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          [Component.text('Cancel')],
        ),
        button(
          type: ButtonType.button,
          onClick: () => _handleSubmit(context),
          disabled: _isSubmitting,
          classes:
              'px-5 py-2.5 rounded-xl text-white text-xs font-bold shadow-sm transition-all cursor-pointer border-none flex items-center space-x-1.5 ${_isSubmitting ? 'opacity-60 cursor-not-allowed' : 'hover:opacity-95 active:scale-95'}',
          styles: Styles(backgroundColor: Color(colorScheme.primary)),
          [
            if (_isSubmitting)
              span(classes: 'animate-spin border-2 border-white border-t-transparent rounded-full w-3.5 h-3.5 mr-1', []),
            Component.text(_isSubmitting ? 'Scheduling...' : 'Schedule Interview'),
          ],
        ),
      ]),
    ]);
  }
}
