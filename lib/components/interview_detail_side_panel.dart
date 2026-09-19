import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/users/admin_platform_user_item.dart';
import '../core/models/clients/vetting/admin_interview_item.dart';
import '../core/models/clients/vetting/admin_update_interview_status_body.dart';
import '../core/providers/admin_user_providers.dart';
import '../core/providers/ui_state_provider.dart';
import 'platform_user_detail_side_panel.dart';

class InterviewDetailSidePanel extends StatefulComponent {
  final AdminInterviewItem interview;

  const InterviewDetailSidePanel({
    required this.interview,
    super.key,
  });

  static void show(BuildContext context, AdminInterviewItem interview) {
    context.showSidePanel(
      InterviewDetailSidePanel(interview: interview),
      title: 'Interview Details',
    );
  }

  @override
  State<InterviewDetailSidePanel> createState() => _InterviewDetailSidePanelState();
}

class _InterviewDetailSidePanelState extends State<InterviewDetailSidePanel> {
  bool isEditingReschedule = false;
  bool isSubmittingAction = false;
  String? currentStatusOverride;
  String? currentMeetingLinkOverride;
  String? currentScheduledAtOverride;
  String? currentNotesOverride;

  // Reschedule form state
  late String _rescheduleDateTime;
  late String _rescheduleMeetingLink;
  late String _rescheduleNotes;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _initFormFields();
  }

  void _initFormFields() {
    final rawDate = component.interview.scheduledAt;
    _rescheduleDateTime = _formatForDateTimeInput(rawDate);
    _rescheduleMeetingLink = component.interview.meetingLink ?? '';
    _rescheduleNotes = component.interview.notes ?? '';
  }

  String _formatForDateTimeInput(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final year = dt.year.toString().padLeft(4, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$year-$month-${day}T$hour:$minute';
    } catch (_) {
      return '';
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

  Future<void> _handleMarkPassed(BuildContext context) async {
    final interviewId = component.interview.id;
    if (interviewId == null || interviewId.isEmpty) return;

    setState(() {
      isSubmittingAction = true;
      _formError = null;
    });

    final body = const AdminUpdateInterviewStatusBody(
      status: 'PASSED',
      notes: null,
      meetingLink: null,
      scheduledAt: null,
    );

    final notifier = context.read(adminUserManagementProvider.notifier);
    await notifier.updateInterviewStatus(
      interviewId,
      body,
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          isSubmittingAction = false;
          currentStatusOverride = 'PASSED';
          currentNotesOverride = null;
          currentMeetingLinkOverride = null;
          currentScheduledAtOverride = null;
        });
        context.showFlushbar(
          title: 'Interview Passed',
          message: 'Interview has been marked as PASSED successfully.',
          type: FlushbarType.success,
        );
      },
      onError: (errorMsg) {
        if (!mounted) return;
        setState(() {
          isSubmittingAction = false;
          _formError = errorMsg;
        });
        context.showFlushbar(
          title: 'Update Failed',
          message: errorMsg,
          type: FlushbarType.error,
        );
      },
    );
  }

  Future<void> _handleMarkFailed(BuildContext context) async {
    final interviewId = component.interview.id;
    if (interviewId == null || interviewId.isEmpty) return;

    setState(() {
      isSubmittingAction = true;
      _formError = null;
    });

    final body = const AdminUpdateInterviewStatusBody(
      status: 'FAILED',
      notes: null,
      meetingLink: null,
      scheduledAt: null,
    );

    final notifier = context.read(adminUserManagementProvider.notifier);
    await notifier.updateInterviewStatus(
      interviewId,
      body,
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          isSubmittingAction = false;
          currentStatusOverride = 'FAILED';
          currentNotesOverride = null;
          currentMeetingLinkOverride = null;
          currentScheduledAtOverride = null;
        });
        context.showFlushbar(
          title: 'Interview Failed',
          message: 'Interview status set to FAILED.',
          type: FlushbarType.error,
        );
      },
      onError: (errorMsg) {
        if (!mounted) return;
        setState(() {
          isSubmittingAction = false;
          _formError = errorMsg;
        });
        context.showFlushbar(
          title: 'Update Failed',
          message: errorMsg,
          type: FlushbarType.error,
        );
      },
    );
  }

  Future<void> _handleRescheduleSubmit(BuildContext context) async {
    final interviewId = component.interview.id;
    if (interviewId == null || interviewId.isEmpty) return;

    if (_rescheduleDateTime.trim().isEmpty) {
      setState(() {
        _formError = 'Please select a date and time for rescheduling.';
      });
      return;
    }

    String isoScheduledAt = _rescheduleDateTime;
    try {
      final dt = DateTime.parse(_rescheduleDateTime);
      isoScheduledAt = dt.toUtc().toIso8601String();
    } catch (_) {}

    setState(() {
      isSubmittingAction = true;
      _formError = null;
    });

    final body = AdminUpdateInterviewStatusBody(
      status: 'RESCHEDULED',
      notes: _rescheduleNotes.trim().isEmpty ? null : _rescheduleNotes.trim(),
      meetingLink: _rescheduleMeetingLink.trim().isEmpty ? null : _rescheduleMeetingLink.trim(),
      scheduledAt: isoScheduledAt,
    );

    final notifier = context.read(adminUserManagementProvider.notifier);
    await notifier.updateInterviewStatus(
      interviewId,
      body,
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          isSubmittingAction = false;
          isEditingReschedule = false;
          currentStatusOverride = 'RESCHEDULED';
          currentScheduledAtOverride = isoScheduledAt;
          currentMeetingLinkOverride = _rescheduleMeetingLink.trim().isEmpty ? null : _rescheduleMeetingLink.trim();
          currentNotesOverride = _rescheduleNotes.trim().isEmpty ? null : _rescheduleNotes.trim();
        });
        context.showFlushbar(
          title: 'Interview Rescheduled',
          message: 'Interview has been rescheduled successfully.',
          type: FlushbarType.success,
        );
      },
      onError: (errorMsg) {
        if (!mounted) return;
        setState(() {
          isSubmittingAction = false;
          _formError = errorMsg;
        });
        context.showFlushbar(
          title: 'Reschedule Failed',
          message: errorMsg,
          type: FlushbarType.error,
        );
      },
    );
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final interview = component.interview;
    final interviewId = interview.id;
    final userId = interview.userId;

    final displayStatus = currentStatusOverride ?? interview.status ?? 'UNKNOWN';
    final displayScheduledAt = currentScheduledAtOverride ?? interview.scheduledAt;
    final displayMeetingLink = currentMeetingLinkOverride ?? interview.meetingLink;
    final displayNotes = currentNotesOverride ?? interview.notes;

    return div(classes: 'space-y-6 text-xs pb-8 relative', [
      // ─────────────────────────────────────────────────────────────
      // Hero Interview Card
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
                'absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-emerald-500 via-teal-400 to-cyan-500',
            [],
          ),

          div(classes: 'flex items-start justify-between gap-3 pt-1', [
            div(classes: 'space-y-1 min-w-0 flex-1', [
              span(
                classes: 'text-[11px] font-bold uppercase tracking-wider block',
                styles: Styles(color: Color(colorScheme.textMuted)),
                [Component.text('Provider Interview')],
              ),
              h4(
                classes: 'font-mono font-black text-base tracking-tight truncate',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text(_formatId(interviewId))],
              ),
            ]),
            _buildBadgePill(displayStatus, colorScheme),
          ]),

          // Date & Meeting Action Row
          div(
            classes: 'p-3.5 rounded-xl border space-y-2.5 shadow-2xs',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [
              div(classes: 'flex items-center justify-between text-xs', [
                span(
                  classes: 'font-semibold',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  [Component.text('Scheduled Time:')],
                ),
                span(
                  classes: 'font-bold font-mono',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text(_formatFullDateTime(displayScheduledAt))],
                ),
              ]),

              if (displayMeetingLink != null && displayMeetingLink.isNotEmpty) ...[
                div(classes: 'flex items-center justify-between pt-1 border-t', styles: Styles(raw: {'border-color': colorScheme.borderInput}), [
                  span(
                    classes: 'font-semibold',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text('Meeting Link:')],
                  ),
                  div(classes: 'flex items-center space-x-2', [
                    a(
                      href: displayMeetingLink,
                      target: Target.blank,
                      classes:
                          'text-white text-[11px] font-bold px-3 py-1.5 rounded-lg shadow-xs transition-all inline-flex items-center space-x-1.5',
                      styles: Styles(backgroundColor: Color(colorScheme.primary)),
                      [
                        const AppIcon(AppIcons.externalLink),
                        span([Component.text('Join Meeting')]),
                      ],
                    ),
                    button(
                      type: ButtonType.button,
                      classes: 'p-1.5 rounded-lg hover:text-emerald-500 transition-colors border-none bg-transparent cursor-pointer',
                      styles: Styles(color: Color(colorScheme.textMuted)),
                      events: {
                        'click': (_) => _copyToClipboard(context, displayMeetingLink, 'Meeting link'),
                      },
                      [
                        div(classes: 'w-3.5 h-3.5', [const AppIcon(AppIcons.copy)]),
                      ],
                    ),
                  ]),
                ]),
              ] else
                div(classes: 'pt-1 border-t flex items-center justify-between text-[11px] text-slate-400 font-medium', styles: Styles(raw: {'border-color': colorScheme.borderInput}), [
                  span([Component.text('Meeting Link:')]),
                  span([Component.text('No link provided')]),
                ]),
            ],
          ),

          // Metadata Grid
          div(
            classes: 'grid grid-cols-2 gap-3 pt-2 border-t text-xs',
            styles: Styles(raw: {'border-color': colorScheme.border}),
            [
              _buildMetaTile(context, 'Interview ID', _formatId(interviewId), isCopyable: true, rawValue: interviewId),
              _buildMetaTile(context, 'Admin ID', _formatId(interview.adminId), isCopyable: true, rawValue: interview.adminId),
              if (displayNotes != null && displayNotes.isNotEmpty)
                _buildMetaTile(context, 'Admin Notes', displayNotes, isFullWidth: true),
            ],
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // User Details Section (adminUserDetailProvider)
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3', [
        _buildSectionHeader('Candidate User Profile', AppIcons.customer, context),
        if (userId != null && userId.isNotEmpty)
          _buildUserDetailCard(context, userId)
        else
          div(
            classes: 'p-4 rounded-2xl border text-center font-medium text-slate-400',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              raw: {'border-color': colorScheme.border},
            ),
            [Component.text('No user ID associated with this interview.')],
          ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Admin Actions & Reschedule Form Section
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3 pt-2', [
        _buildSectionHeader('Interview Review & Actions', AppIcons.calendar, context),
        div(
          classes: 'p-5 rounded-2xl border space-y-4 shadow-sm transition-all',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            if (_formError != null)
              div(
                classes: 'p-3 rounded-xl border border-rose-500/30 bg-rose-500/10 text-rose-500 text-xs font-semibold',
                [Component.text(_formError!)],
              ),

            if (isSubmittingAction)
              div(classes: 'py-6 text-center space-y-2 animate-pulse', [
                span(
                  classes: 'text-xs font-bold',
                  styles: Styles(color: Color(colorScheme.primary)),
                  [Component.text('Updating interview status...')],
                ),
              ])
            else if (!isEditingReschedule) ...[
              // Action Buttons Row
              div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-3', [
                button(
                  type: ButtonType.button,
                  onClick: () => _handleMarkPassed(context),
                  classes:
                      'w-full py-2.5 px-4 rounded-xl text-white font-bold text-xs shadow-md transition-all cursor-pointer flex items-center justify-center space-x-2 active:scale-98 border-none',
                  styles: Styles(backgroundColor: Color('#059669')),
                  [
                    const AppIcon(AppIcons.checkCircle),
                    span([Component.text('Mark as Passed')]),
                  ],
                ),
                button(
                  type: ButtonType.button,
                  onClick: () => _handleMarkFailed(context),
                  classes:
                      'w-full py-2.5 px-4 rounded-xl text-white font-bold text-xs shadow-md transition-all cursor-pointer flex items-center justify-center space-x-2 active:scale-98 border-none',
                  styles: Styles(backgroundColor: Color('#E11D48')),
                  [
                    const AppIcon(AppIcons.disputes),
                    span([Component.text('Mark as Failed')]),
                  ],
                ),
              ]),

              // Toggle Reschedule Form Button
              button(
                type: ButtonType.button,
                onClick: () {
                  setState(() {
                    _initFormFields();
                    isEditingReschedule = true;
                    _formError = null;
                  });
                },
                classes:
                    'w-full py-2.5 px-4 rounded-xl font-bold text-xs shadow-sm transition-all cursor-pointer flex items-center justify-center space-x-2 border active:scale-98',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  color: Color(colorScheme.textPrimary),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                [
                  const AppIcon(AppIcons.calendar),
                  span([Component.text('Reschedule / Edit Interview Details')]),
                ],
              ),
            ] else ...[
              // Expandable Reschedule Form
              div(classes: 'space-y-4 animate-fade-in', [
                div(classes: 'flex items-center justify-between pb-2 border-b', styles: Styles(raw: {'border-color': colorScheme.borderInput}), [
                  h5(
                    classes: 'font-bold text-xs tracking-tight',
                    styles: Styles(color: Color(colorScheme.textHeading)),
                    [Component.text('Reschedule Interview Details')],
                  ),
                  button(
                    type: ButtonType.button,
                    onClick: () => setState(() => isEditingReschedule = false),
                    classes: 'text-[11px] font-bold text-slate-400 hover:underline cursor-pointer border-none bg-transparent',
                    [Component.text('Cancel')],
                  ),
                ]),

                // Scheduled Date & Time
                div(classes: 'space-y-1', [
                  label(
                    classes: 'block text-[11px] font-bold uppercase tracking-wider',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text('New Date & Time *')],
                  ),
                  input(
                    type: InputType.dateTimeLocal,
                    value: _rescheduleDateTime,
                    classes:
                        'w-full border rounded-xl px-3.5 py-2 text-xs font-medium focus:outline-none focus:ring-2 transition-all',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      color: Color(colorScheme.textPrimary),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
                    onInput: (val) {
                      setState(() {
                        _rescheduleDateTime = val.toString();
                        _formError = null;
                      });
                    },
                  ),
                ]),

                // Meeting Link
                div(classes: 'space-y-1', [
                  label(
                    classes: 'block text-[11px] font-bold uppercase tracking-wider',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text('Meeting Link')],
                  ),
                  input(
                    type: InputType.url,
                    value: _rescheduleMeetingLink,
                    classes:
                        'w-full border rounded-xl px-3.5 py-2 text-xs font-medium focus:outline-none focus:ring-2 transition-all',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      color: Color(colorScheme.textPrimary),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
                    attributes: {'placeholder': 'e.g. https://meet.google.com/abc-defg-hij'},
                    onInput: (val) {
                      setState(() {
                        _rescheduleMeetingLink = val.toString();
                      });
                    },
                  ),
                ]),

                // Notes
                div(classes: 'space-y-1', [
                  label(
                    classes: 'block text-[11px] font-bold uppercase tracking-wider',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text('Notes / Reason')],
                  ),
                  textarea(
                    classes:
                        'w-full border rounded-xl p-3 text-xs font-medium focus:outline-none focus:ring-2 transition-all h-20 resize-none',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      color: Color(colorScheme.textPrimary),
                      raw: {'border-color': colorScheme.borderInput},
                    ),
                    attributes: {
                      'placeholder': 'Add details regarding rescheduling reason or instructions...',
                      'value': _rescheduleNotes,
                    },
                    onInput: (val) {
                      setState(() {
                        _rescheduleNotes = val.toString();
                      });
                    },
                    [],
                  ),
                ]),

                button(
                  type: ButtonType.button,
                  onClick: () => _handleRescheduleSubmit(context),
                  classes:
                      'w-full py-2.5 px-4 rounded-xl text-white font-bold text-xs shadow-md transition-all cursor-pointer flex items-center justify-center space-x-2 border-none active:scale-98',
                  styles: Styles(backgroundColor: Color(colorScheme.primary)),
                  [
                    const AppIcon(AppIcons.calendar),
                    span([Component.text('Confirm Reschedule')]),
                  ],
                ),
              ]),
            ],
          ],
        ),
      ]),
    ]);
  }

  // ─────────────────────────────────────────────────────────────
  // User Detail Card (adminUserDetailProvider)
  // ─────────────────────────────────────────────────────────────

  Component _buildUserDetailCard(BuildContext context, String userId) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;
    final userDetailAsync = context.watch(adminUserDetailProvider(userId));

    return userDetailAsync.when(
      data: (userDetail) {
        if (userDetail == null) {
          return div(
            classes: 'p-4 rounded-2xl border text-center font-medium',
            styles: Styles(
              backgroundColor: Color(colorScheme.surface),
              color: Color(colorScheme.textMuted),
              raw: {'border-color': colorScheme.border},
            ),
            [
              Component.text('User ID: ${_formatId(userId)} (No detail profile available)'),
            ],
          );
        }

        final customer = userDetail.customerProfile;
        final provider = userDetail.providerProfile;
        String fullName = 'Candidate User';
        if (customer != null && (customer.firstName != null || customer.lastName != null)) {
          fullName = '${customer.firstName ?? ''} ${customer.lastName ?? ''}'.trim();
        } else if (provider != null && (provider.firstName != null || provider.lastName != null)) {
          fullName = '${provider.firstName ?? ''} ${provider.lastName ?? ''}'.trim();
        } else if (userDetail.email != null && userDetail.email!.isNotEmpty) {
          fullName = userDetail.email!;
        }

        return div(
          classes: 'p-4 border rounded-2xl space-y-4 shadow-sm',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            div(classes: 'flex items-center space-x-3', [
              img(
                src:
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&background=0D9488&color=fff&bold=true',
                classes: 'w-11 h-11 rounded-2xl object-cover border shrink-0',
                styles: Styles(raw: {'border-color': colorScheme.borderInput}),
                alt: fullName,
              ),
              div(classes: 'space-y-0.5 flex-1 min-w-0', [
                div(classes: 'flex items-center space-x-2', [
                  h5(
                    classes: 'font-bold text-sm truncate tracking-tight',
                    styles: Styles(color: Color(colorScheme.textHeading)),
                    [Component.text(fullName)],
                  ),
                  span(
                    classes: 'px-2 py-0.5 rounded text-[10px] font-black uppercase tracking-wider border',
                    styles: userDetail.type == 'PROVIDER'
                        ? Styles(
                            backgroundColor: isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1),
                            color: isDark ? Color.rgba(110, 231, 183, 1.0) : Color.rgba(4, 120, 87, 1.0),
                            raw: {'border-color': isDark ? 'rgba(16, 185, 129, 0.4)' : 'rgba(16, 185, 129, 0.25)'},
                          )
                        : Styles(
                            backgroundColor: isDark ? Color.rgba(14, 165, 233, 0.18) : Color.rgba(14, 165, 233, 0.1),
                            color: isDark ? Color.rgba(125, 211, 252, 1.0) : Color.rgba(3, 105, 161, 1.0),
                            raw: {'border-color': isDark ? 'rgba(14, 165, 233, 0.4)' : 'rgba(14, 165, 233, 0.25)'},
                          ),
                    [Component.text(userDetail.type ?? 'CUSTOMER')],
                  ),
                ]),
                p(
                  classes: 'text-xs font-mono truncate',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  [Component.text(userDetail.email ?? 'No email')],
                ),
              ]),
            ]),

            div(
              classes: 'grid grid-cols-2 gap-2.5 pt-3 border-t text-xs',
              styles: Styles(raw: {'border-color': colorScheme.borderInput}),
              [
                _buildUserRow('Phone', userDetail.phoneNumber ?? 'N/A', colorScheme),
                _buildUserRow('User ID', _formatId(userDetail.id), colorScheme),
                _buildUserRow('Email Verified', userDetail.emailVerified == true ? 'Yes' : 'No', colorScheme),
                _buildUserRow('Phone Verified', userDetail.phoneVerified == true ? 'Yes' : 'No', colorScheme),
              ],
            ),

            button(
              type: ButtonType.button,
              onClick: () {
                final platformUser = AdminPlatformUserItem(
                  id: userDetail.id,
                  email: userDetail.email,
                  fullname: fullName,
                  phoneNumber: userDetail.phoneNumber,
                  type: userDetail.type,
                  isActive: userDetail.isActive,
                  regionId: userDetail.regionId,
                  createdAt: userDetail.createdAt,
                );
                PlatformUserDetailSidePanel.show(context, platformUser);
              },
              classes:
                  'w-full py-2 px-3 rounded-xl text-xs font-bold border transition-all cursor-pointer flex items-center justify-center space-x-1.5 active:scale-98 shadow-2xs',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.primary),
                raw: {'border-color': colorScheme.borderInput},
              ),
              [
                const AppIcon(AppIcons.customer),
                span([Component.text('View Full User Profile')]),
              ],
            ),
          ],
        );
      },
      loading: () => div(
        classes: 'p-4 rounded-2xl border space-y-2 animate-pulse',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [
          div(classes: 'h-6 w-1/2 rounded', styles: Styles(backgroundColor: Color(colorScheme.inputBg)), []),
          div(classes: 'h-4 w-3/4 rounded', styles: Styles(backgroundColor: Color(colorScheme.inputBg)), []),
        ],
      ),
      error: (err, _) => div(
        classes: 'p-3 rounded-xl border text-xs text-rose-500 font-semibold',
        styles: Styles(raw: {'border-color': colorScheme.border}),
        [Component.text('Failed to load user details: $err')],
      ),
    );
  }

  Component _buildUserRow(String label, String value, ColorScheme colorScheme) {
    return div([
      span(
        classes: 'text-[10.5px] font-bold block',
        styles: Styles(color: Color(colorScheme.textMuted)),
        [Component.text(label)],
      ),
      span(
        classes: 'font-semibold text-xs truncate block',
        styles: Styles(color: Color(colorScheme.textHeading)),
        [Component.text(value)],
      ),
    ]);
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────

  Component _buildSectionHeader(String title, AppIcons icon, BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;

    return div(classes: 'flex items-center space-x-2.5 pt-1', [
      div(
        classes:
            'w-7 h-7 rounded-lg flex items-center justify-center shrink-0 border shadow-sm',
        styles: Styles(
          backgroundColor: isDark ? Color.rgba(16, 185, 129, 0.18) : Color.rgba(16, 185, 129, 0.1),
          color: Color(colorScheme.primary),
          raw: {'border-color': isDark ? 'rgba(16, 185, 129, 0.35)' : 'rgba(16, 185, 129, 0.2)'},
        ),
        [
          div(
            classes: 'w-4 h-4',
            styles: Styles(color: Color(colorScheme.primary)),
            [AppIcon(icon)],
          ),
        ],
      ),
      h5(
        classes: 'font-black uppercase text-[11px] tracking-wider',
        styles: Styles(color: Color(colorScheme.textHeading)),
        [Component.text(title)],
      ),
    ]);
  }

  Component _buildMetaTile(
    BuildContext context,
    String label,
    String value, {
    bool isCopyable = false,
    String? rawValue,
    bool isFullWidth = false,
  }) {
    final colorScheme = context.colorScheme;

    return div(
      classes: isFullWidth ? 'col-span-2 space-y-0.5' : 'space-y-0.5',
      [
        span(
          classes: 'text-[10.5px] font-bold uppercase tracking-wider block',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text(label)],
        ),
        div(classes: 'flex items-center space-x-1.5', [
          span(
            classes: 'font-bold font-mono text-xs truncate',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [Component.text(value)],
          ),
          if (isCopyable && rawValue != null && rawValue.isNotEmpty)
            button(
              type: ButtonType.button,
              onClick: () => _copyToClipboard(context, rawValue, label),
              classes: 'p-1 hover:text-emerald-500 cursor-pointer transition-colors border-none bg-transparent',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [
                div(classes: 'w-3 h-3', [const AppIcon(AppIcons.copy)]),
              ],
            ),
        ]),
      ],
    );
  }

  Component _buildBadgePill(String status, ColorScheme colorScheme) {
    String badgeClasses =
        'px-3 py-1 rounded-full text-[11px] font-bold inline-block leading-none tracking-tight border';
    String bg = 'bg-slate-100 dark:bg-slate-800';
    String text = 'text-slate-700 dark:text-slate-300';
    String border = 'border-slate-200 dark:border-slate-700';

    if (status == 'PASSED' || status == 'COMPLETED') {
      bg = 'bg-emerald-50 dark:bg-emerald-950/60';
      text = 'text-emerald-600 dark:text-emerald-400';
      border = 'border-emerald-200/50 dark:border-emerald-800/50';
    } else if (status == 'SCHEDULED' || status == 'RESCHEDULED') {
      bg = 'bg-amber-50 dark:bg-amber-950/60';
      text = 'text-amber-600 dark:text-amber-400';
      border = 'border-amber-200/50 dark:border-amber-800/50';
    } else if (status == 'FAILED' || status == 'CANCELLED') {
      bg = 'bg-rose-50 dark:bg-rose-950/60';
      text = 'text-rose-600 dark:text-rose-400';
      border = 'border-rose-200/50 dark:border-rose-800/50';
    }

    return span(classes: '$badgeClasses $bg $text $border', [
      Component.text(status),
    ]);
  }
}

String _formatId(String? id) {
  if (id == null || id.isEmpty) return '#INT-000';
  if (id.length <= 8) return '#$id';
  return '#${id.substring(0, 8)}...';
}

String _formatFullDateTime(String? raw) {
  if (raw == null || raw.isEmpty) return 'N/A';
  try {
    final dt = DateTime.parse(raw).toLocal();
    final dateStr = '${dt.day}/${dt.month}/${dt.year}';
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$dateStr @ $hour:$minute';
  } catch (_) {
    return raw;
  }
}
