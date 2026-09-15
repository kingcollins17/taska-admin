import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/providers/ui_state_provider.dart';

// --- DATA MODELS ---

class UserModel {
  final String id;
  final String name;
  final String email;
  final String department;
  final String avatarUrl;
  final String status; // Pending, Active, Verified, Suspended
  final String assignedBy;
  final String assignedByAvatar;
  final String joinedDate;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.avatarUrl,
    required this.status,
    required this.assignedBy,
    required this.assignedByAvatar,
    required this.joinedDate,
  });
}

class UserReferenceModel {
  final String id;
  final String userName;
  final String userAvatar;
  final String refereeName;
  final String relationship; // Guarantor, Employer, Next of Kin, Colleague
  final String refereePhone;
  final String refereeEmail;
  final String status; // Verified, Pending, Declined
  final String submittedDate;

  const UserReferenceModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.refereeName,
    required this.relationship,
    required this.refereePhone,
    required this.refereeEmail,
    required this.status,
    required this.submittedDate,
  });
}

class KydDocumentModel {
  final String id;
  final String userName;
  final String userAvatar;
  final String documentType; // Driver's License, National ID, Passport, Utility Bill
  final String documentNumber;
  final String submissionDate;
  final String expiryDate;
  final String status; // Approved, Pending Review, Rejected

  const KydDocumentModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.documentType,
    required this.documentNumber,
    required this.submissionDate,
    required this.expiryDate,
    required this.status,
  });
}

// --- MOCK DATA ---

final List<UserModel> mockUsersList = [
  const UserModel(
    id: '#USR-0101',
    name: 'Sarah Johnson',
    email: 'sarah.j@taska.com',
    department: 'Operations',
    avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80',
    status: 'Verified',
    assignedBy: 'Alex Morgan',
    assignedByAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Jul 18, 2025',
  ),
  const UserModel(
    id: '#USR-0102',
    name: 'David Chen',
    email: 'david.chen@taska.com',
    department: 'Logistics',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
    status: 'Active',
    assignedBy: 'Emily Chen',
    assignedByAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Jul 20, 2025',
  ),
  const UserModel(
    id: '#USR-0103',
    name: 'Amara Okezie',
    email: 'amara.o@taska.com',
    department: 'Customer Success',
    avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=80',
    status: 'Pending',
    assignedBy: 'Michael Brown',
    assignedByAvatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Jul 25, 2025',
  ),
  const UserModel(
    id: '#USR-0104',
    name: 'Marcus Vance',
    email: 'marcus.v@taska.com',
    department: 'Procurement',
    avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&auto=format&fit=crop&q=80',
    status: 'Active',
    assignedBy: 'Sarah Johnson',
    assignedByAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Aug 01, 2025',
  ),
  const UserModel(
    id: '#USR-0105',
    name: 'Elena Rostova',
    email: 'elena.r@taska.com',
    department: 'Finance',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
    status: 'Verified',
    assignedBy: 'David Wilson',
    assignedByAvatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Aug 10, 2025',
  ),
  const UserModel(
    id: '#USR-0106',
    name: 'Kofi Mensah',
    email: 'kofi.m@taska.com',
    department: 'Fleet Ops',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=80',
    status: 'Suspended',
    assignedBy: 'Lisa Rodriguez',
    assignedByAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Aug 12, 2025',
  ),
];

final List<UserReferenceModel> mockReferencesList = [
  const UserReferenceModel(
    id: '#REF-801',
    userName: 'Sarah Johnson',
    userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80',
    refereeName: 'Dr. Robert Sterling',
    relationship: 'Employer',
    refereePhone: '+1 (555) 234-5678',
    refereeEmail: 'r.sterling@apexcorp.com',
    status: 'Verified',
    submittedDate: 'Aug 02, 2025',
  ),
  const UserReferenceModel(
    id: '#REF-802',
    userName: 'David Chen',
    userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
    refereeName: 'Chief Inspector James',
    relationship: 'Guarantor',
    refereePhone: '+1 (555) 876-5432',
    refereeEmail: 'james.sec@gov.org',
    status: 'Pending',
    submittedDate: 'Aug 05, 2025',
  ),
  const UserReferenceModel(
    id: '#REF-803',
    userName: 'Amara Okezie',
    userAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=80',
    refereeName: 'Grace Okezie',
    relationship: 'Next of Kin',
    refereePhone: '+1 (555) 345-6789',
    refereeEmail: 'grace.o@gmail.com',
    status: 'Verified',
    submittedDate: 'Aug 08, 2025',
  ),
  const UserReferenceModel(
    id: '#REF-804',
    userName: 'Marcus Vance',
    userAvatar: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&auto=format&fit=crop&q=80',
    refereeName: 'Engr. Victor Hugo',
    relationship: 'Colleague',
    refereePhone: '+1 (555) 901-2345',
    refereeEmail: 'victor.hugo@techbuild.io',
    status: 'Declined',
    submittedDate: 'Aug 11, 2025',
  ),
  const UserReferenceModel(
    id: '#REF-805',
    userName: 'Elena Rostova',
    userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
    refereeName: 'Prof. Alistair Finch',
    relationship: 'Guarantor',
    refereePhone: '+1 (555) 678-9012',
    refereeEmail: 'a.finch@oxford.edu',
    status: 'Pending',
    submittedDate: 'Aug 14, 2025',
  ),
];

final List<KydDocumentModel> mockKydDocsList = [
  const KydDocumentModel(
    id: '#KYD-901',
    userName: 'Sarah Johnson',
    userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80',
    documentType: "Driver's License",
    documentNumber: 'DL-99482710-X',
    submissionDate: 'Aug 01, 2025',
    expiryDate: 'Nov 14, 2028',
    status: 'Approved',
  ),
  const KydDocumentModel(
    id: '#KYD-902',
    userName: 'David Chen',
    userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
    documentType: 'National ID (NIN)',
    documentNumber: 'NIN-4421890312',
    submissionDate: 'Aug 04, 2025',
    expiryDate: 'N/A',
    status: 'Pending Review',
  ),
  const KydDocumentModel(
    id: '#KYD-903',
    userName: 'Amara Okezie',
    userAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=80',
    documentType: 'International Passport',
    documentNumber: 'PASS-A8839201',
    submissionDate: 'Aug 07, 2025',
    expiryDate: 'Jan 22, 2031',
    status: 'Approved',
  ),
  const KydDocumentModel(
    id: '#KYD-904',
    userName: 'Marcus Vance',
    userAvatar: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&auto=format&fit=crop&q=80',
    documentType: 'Utility Bill',
    documentNumber: 'UTIL-2025-0811',
    submissionDate: 'Aug 10, 2025',
    expiryDate: 'Nov 10, 2025',
    status: 'Rejected',
  ),
  const KydDocumentModel(
    id: '#KYD-905',
    userName: 'Kofi Mensah',
    userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=80',
    documentType: "Driver's License",
    documentNumber: 'DL-77382019-B',
    submissionDate: 'Aug 13, 2025',
    expiryDate: 'May 18, 2027',
    status: 'Pending Review',
  ),
];

// --- MAIN COMPONENT ---

class UsersPage extends StatefulComponent {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  int activeTab = 0; // 0: Users, 1: References, 2: KYD Documents
  String searchQuery = '';
  String selectedStatus = 'All';
  bool isFilterOpen = false;
  int currentPage = 1;

  // Local state lists for interactive actions (verifying / approving / rejecting)
  late List<UserModel> usersList;
  late List<UserReferenceModel> referencesList;
  late List<KydDocumentModel> kydDocsList;

  @override
  void initState() {
    super.initState();
    usersList = List.from(mockUsersList);
    referencesList = List.from(mockReferencesList);
    kydDocsList = List.from(mockKydDocsList);
  }

  void _switchTab(int index) {
    setState(() {
      activeTab = index;
      searchQuery = '';
      selectedStatus = 'All';
      isFilterOpen = false;
      currentPage = 1;
    });
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return div(classes: 'flex-1 space-y-6', [
      // 1. Header Title & Subtitle Section
      div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-4', [
        div([
          h2(
            classes: 'text-2xl sm:text-3xl font-extrabold tracking-tight transition-colors',
            styles: Styles(color: Color(colorScheme.textHeading)),
            [Component.text('Resource Management')],
          ),
          p(
            classes: 'text-xs sm:text-sm mt-1 font-medium transition-colors',
            styles: Styles(color: Color(colorScheme.textSecondary)),
            [
              Component.text(
                'Manage users, review submitted references, and inspect KYD compliance documents.',
              ),
            ],
          ),
        ]),
      ]),

      // 2. Tab Navigation Selector Bar
      _buildTabSelector(colorScheme),

      // 3. Dynamic Top Metric Cards Grid
      _buildDynamicMetrics(colorScheme),

      // 4. Main Resource Card Container
      div(
        classes: 'border rounded-2xl p-5 sm:p-6 shadow-sm space-y-5 transition-all',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [
          // Toolbar: Table Title + Search Input + Filter Toggle + Context Primary Button
          div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4', [
            div(classes: 'flex items-center space-x-2', [
              h3(
                classes: 'text-base font-bold tracking-tight',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [
                  Component.text(
                    activeTab == 0
                        ? 'Registered Users'
                        : activeTab == 1
                            ? 'Submitted References'
                            : 'KYD Compliance Documents',
                  ),
                ],
              ),
              span(
                classes: 'text-xs font-semibold px-2.5 py-0.5 rounded-full',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  color: Color(colorScheme.primary),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                [
                  Component.text(
                    '${_getFilteredCount()}',
                  ),
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
                  value: searchQuery,
                  classes:
                      'w-full border rounded-xl pl-9 pr-4 py-2 text-xs font-medium focus:outline-none focus:ring-2 transition-all',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.textPrimary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  attributes: {
                    'placeholder': activeTab == 0
                        ? 'Search users, email, dept...'
                        : activeTab == 1
                            ? 'Search references, referee...'
                            : 'Search KYD docs, user, ID...'
                  },
                  onInput: (value) {
                    setState(() {
                      searchQuery = value.toString();
                    });
                  },
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
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  color: Color(colorScheme.textPrimary),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                [
                  const AppIcon(AppIcons.filter),
                  span([Component.text('Filter')]),
                ],
              ),

              // Primary Contextual Action Button
              _buildPrimaryActionButton(colorScheme),
            ]),
          ]),

          // Interactive Expandable Filter Chip Bar
          if (isFilterOpen) _buildFilterBar(colorScheme),

          // Render Active Tab Data Table
          if (activeTab == 0) _buildUsersTable(colorScheme),
          if (activeTab == 1) _buildReferencesTable(colorScheme),
          if (activeTab == 2) _buildKydDocsTable(colorScheme),

          // Pagination Footer Bar
          _buildPaginationFooter(colorScheme),
        ],
      ),
    ]);
  }

  // --- TAB SELECTOR BAR ---

  Component _buildTabSelector(ColorScheme colorScheme) {
    return div(
      classes: 'flex flex-wrap items-center gap-2 p-1.5 rounded-2xl border transition-colors',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.border},
      ),
      [
        _buildSingleTab(
          index: 0,
          label: 'Users',
          count: usersList.length.toString(),
          icon: AppIcons.customersGroup,
          colorScheme: colorScheme,
        ),
        _buildSingleTab(
          index: 1,
          label: 'User References',
          count: referencesList.length.toString(),
          icon: AppIcons.documents,
          colorScheme: colorScheme,
        ),
        _buildSingleTab(
          index: 2,
          label: 'KYD Documents',
          count: kydDocsList.length.toString(),
          icon: AppIcons.ordersDoc,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Component _buildSingleTab({
    required int index,
    required String label,
    required String count,
    required AppIcons icon,
    required ColorScheme colorScheme,
  }) {
    final isActive = activeTab == index;

    return button(
      onClick: () => _switchTab(index),
      classes:
          'flex items-center space-x-2.5 px-4 py-2.5 rounded-xl font-bold text-xs sm:text-sm transition-all cursor-pointer shadow-none',
      styles: isActive
          ? Styles(
              backgroundColor: Color(colorScheme.primary),
              color: Color('#FFFFFF'),
            )
          : Styles(
              backgroundColor: Color('transparent'),
              color: Color(colorScheme.textSecondary),
            ),
      [
        AppIcon(icon),
        span([Component.text(label)]),
        span(
          classes: 'px-2 py-0.5 rounded-full text-[11px] font-bold',
          styles: isActive
              ? Styles(
                  backgroundColor: Color('rgba(255, 255, 255, 0.25)'),
                  color: Color('#FFFFFF'),
                )
              : Styles(
                  backgroundColor: Color(colorScheme.surface),
                  color: Color(colorScheme.textMuted),
                ),
          [Component.text(count)],
        ),
      ],
    );
  }

  // --- DYNAMIC METRICS SUMMARY CARDS ---

  Component _buildDynamicMetrics(ColorScheme colorScheme) {
    if (activeTab == 0) {
      final activeCount = usersList.where((userItem) => userItem.status == 'Active').length;
      final verifiedCount = usersList.where((userItem) => userItem.status == 'Verified').length;
      final pendingCount = usersList.where((userItem) => userItem.status == 'Pending').length;

      return div(classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4', [
        _buildMetricCard(
          title: 'Total Users',
          count: '${usersList.length}',
          growth: '+12%',
          isPositive: true,
          colorScheme: colorScheme,
        ),
        _buildMetricCard(
          title: 'Active Users',
          count: '$activeCount',
          growth: '+8%',
          isPositive: true,
          colorScheme: colorScheme,
        ),
        _buildMetricCard(
          title: 'Verified Users',
          count: '$verifiedCount',
          growth: '+15%',
          isPositive: true,
          colorScheme: colorScheme,
        ),
        _buildMetricCard(
          title: 'Pending Users',
          count: '$pendingCount',
          growth: '-2%',
          isPositive: false,
          colorScheme: colorScheme,
        ),
      ]);
    } else if (activeTab == 1) {
      final verifiedCount = referencesList.where((r) => r.status == 'Verified').length;
      final pendingCount = referencesList.where((r) => r.status == 'Pending').length;
      final declinedCount = referencesList.where((r) => r.status == 'Declined').length;

      return div(classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4', [
        _buildMetricCard(
          title: 'Total References',
          count: '${referencesList.length}',
          growth: '+10%',
          isPositive: true,
          colorScheme: colorScheme,
        ),
        _buildMetricCard(
          title: 'Verified',
          count: '$verifiedCount',
          growth: '+14%',
          isPositive: true,
          colorScheme: colorScheme,
        ),
        _buildMetricCard(
          title: 'Pending Review',
          count: '$pendingCount',
          growth: '+3%',
          isPositive: true,
          colorScheme: colorScheme,
        ),
        _buildMetricCard(
          title: 'Declined',
          count: '$declinedCount',
          growth: '-5%',
          isPositive: true,
          colorScheme: colorScheme,
        ),
      ]);
    } else {
      final approvedCount = kydDocsList.where((d) => d.status == 'Approved').length;
      final pendingCount = kydDocsList.where((d) => d.status == 'Pending Review').length;
      final rejectedCount = kydDocsList.where((d) => d.status == 'Rejected').length;

      return div(classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4', [
        _buildMetricCard(
          title: 'Total Documents',
          count: '${kydDocsList.length}',
          growth: '+18%',
          isPositive: true,
          colorScheme: colorScheme,
        ),
        _buildMetricCard(
          title: 'Approved Docs',
          count: '$approvedCount',
          growth: '+20%',
          isPositive: true,
          colorScheme: colorScheme,
        ),
        _buildMetricCard(
          title: 'Pending Compliance',
          count: '$pendingCount',
          growth: '+5%',
          isPositive: true,
          colorScheme: colorScheme,
        ),
        _buildMetricCard(
          title: 'Rejected Docs',
          count: '$rejectedCount',
          growth: '-4%',
          isPositive: false,
          colorScheme: colorScheme,
        ),
      ]);
    }
  }

  Component _buildMetricCard({
    required String title,
    required String count,
    required String growth,
    required bool isPositive,
    required ColorScheme colorScheme,
  }) {
    return div(
      classes:
          'border rounded-2xl p-5 shadow-sm flex items-start justify-between relative overflow-hidden transition-all',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'space-y-2', [
          span(
            classes: 'text-xs font-semibold uppercase tracking-wider',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text(title)],
          ),
          div(classes: 'flex items-baseline space-x-2', [
            span(
              classes: 'text-2xl sm:text-3xl font-extrabold tracking-tight',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text(count)],
            ),
            span(
              classes:
                  'text-xs font-bold ${isPositive ? "text-emerald-600 dark:text-emerald-400" : "text-rose-600 dark:text-rose-400"} flex items-center',
              [
                span(classes: 'mr-0.5 text-[11px]', [Component.text('↑')]),
                Component.text(growth),
              ],
            ),
          ]),
        ]),
        div(
          classes: 'w-10 h-10 rounded-full flex items-center justify-center shrink-0 shadow-sm',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.primary),
          ),
          [
            const AppIcon(AppIcons.analytics),
          ],
        ),
      ],
    );
  }

  // --- PRIMARY CONTEXT ACTION BUTTON ---

  Component _buildPrimaryActionButton(ColorScheme colorScheme) {
    String label = '+ Add User';
    if (activeTab == 1) label = 'Verify All';
    if (activeTab == 2) label = 'Upload Document';

    return button(
      onClick: () {},
      classes:
          'active:scale-[0.98] text-white text-xs font-bold px-4 py-2 rounded-xl flex items-center space-x-1.5 shadow-sm transition-all cursor-pointer',
      styles: Styles(backgroundColor: Color(colorScheme.primary)),
      [
        span(classes: 'text-sm font-bold leading-none', [Component.text('+')]),
        span([Component.text(label)]),
      ],
    );
  }

  // --- FILTER BAR ---

  Component _buildFilterBar(ColorScheme colorScheme) {
    List<String> options = [];
    if (activeTab == 0) options = ['All', 'Verified', 'Active', 'Pending', 'Suspended'];
    if (activeTab == 1) options = ['All', 'Verified', 'Pending', 'Declined'];
    if (activeTab == 2) options = ['All', 'Approved', 'Pending Review', 'Rejected'];

    return div(
      classes: 'p-3.5 rounded-xl border flex flex-wrap items-center gap-2 text-xs font-semibold',
      styles: Styles(
        backgroundColor: Color(colorScheme.inputBg),
        raw: {'border-color': colorScheme.borderInput},
      ),
      [
        span(
          classes: 'mr-1 text-[11px] uppercase tracking-wider font-bold',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Filter Status:')],
        ),
        for (final opt in options) _buildStatusChip(opt, colorScheme),
      ],
    );
  }

  Component _buildStatusChip(String statusLabel, ColorScheme colorScheme) {
    final isSelected = selectedStatus == statusLabel;

    return button(
      onClick: () {
        setState(() {
          selectedStatus = statusLabel;
        });
      },
      classes: 'px-3 py-1 rounded-lg transition-all cursor-pointer text-xs font-bold',
      styles: isSelected
          ? Styles(
              backgroundColor: Color(colorScheme.primary),
              color: Color('#FFFFFF'),
            )
          : Styles(
              backgroundColor: Color(colorScheme.surface),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
      [Component.text(statusLabel)],
    );
  }

  int _getFilteredCount() {
    if (activeTab == 0) return _getFilteredUsers().length;
    if (activeTab == 1) return _getFilteredReferences().length;
    return _getFilteredKydDocs().length;
  }

  // --- USERS TABLE ---

  List<UserModel> _getFilteredUsers() {
    return usersList.where((userItem) {
      final query = searchQuery.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          userItem.name.toLowerCase().contains(query) ||
          userItem.email.toLowerCase().contains(query) ||
          userItem.department.toLowerCase().contains(query) ||
          userItem.id.toLowerCase().contains(query);
      final matchesStatus = selectedStatus == 'All' || userItem.status == selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Component _buildUsersTable(ColorScheme colorScheme) {
    final filtered = _getFilteredUsers();
    if (filtered.isEmpty) return _buildEmptyState(colorScheme);

    return div(
      classes: 'overflow-x-auto rounded-xl border transition-colors',
      styles: Styles(raw: {'border-color': colorScheme.border}),
      [
        table(classes: 'w-full text-left border-collapse text-xs', [
          thead(
            classes: 'uppercase tracking-wider text-[10.5px] border-b font-bold',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textMuted),
              raw: {'border-color': colorScheme.border},
            ),
            [
              tr([
                th(classes: 'p-3.5 pl-4', [Component.text('User ID')]),
                th(classes: 'p-3.5', [Component.text('User Details')]),
                th(classes: 'p-3.5', [Component.text('Department')]),
                th(classes: 'p-3.5 text-center', [Component.text('Status')]),
                th(classes: 'p-3.5', [Component.text('Assigned By')]),
                th(classes: 'p-3.5', [Component.text('Joined Date')]),
                th(classes: 'p-3.5 pr-4 text-center', [Component.text('Actions')]),
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
              for (final user in filtered)
                tr(classes: 'hover:opacity-90 transition-colors', [
                  td(
                    classes: 'p-3.5 pl-4 font-mono font-bold text-[11px]',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text(user.id)],
                  ),
                  td(classes: 'p-3.5', [
                    div(classes: 'flex items-center space-x-3', [
                      img(
                        src: user.avatarUrl,
                        classes: 'w-8 h-8 rounded-full object-cover border shrink-0',
                        styles: Styles(raw: {'border-color': colorScheme.border}),
                        alt: user.name,
                      ),
                      div([
                        div(
                          classes: 'font-bold text-xs',
                          styles: Styles(color: Color(colorScheme.textHeading)),
                          [Component.text(user.name)],
                        ),
                        div(
                          classes: 'text-[11px]',
                          styles: Styles(color: Color(colorScheme.textMuted)),
                          [Component.text(user.email)],
                        ),
                      ]),
                    ]),
                  ]),
                  td(
                    classes: 'p-3.5 font-semibold text-xs',
                    styles: Styles(color: Color(colorScheme.textSecondary)),
                    [Component.text(user.department)],
                  ),
                  td(classes: 'p-3.5 text-center', [_buildBadgePill(user.status, colorScheme)]),
                  td(classes: 'p-3.5', [
                    div(classes: 'flex items-center space-x-2', [
                      img(
                        src: user.assignedByAvatar,
                        classes: 'w-6 h-6 rounded-full object-cover border shrink-0',
                        styles: Styles(raw: {'border-color': colorScheme.border}),
                        alt: user.assignedBy,
                      ),
                      span(
                        classes: 'text-xs font-semibold',
                        styles: Styles(color: Color(colorScheme.textSecondary)),
                        [Component.text(user.assignedBy)],
                      ),
                    ]),
                  ]),
                  td(
                    classes: 'p-3.5 text-xs font-medium',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text(user.joinedDate)],
                  ),
                  td(classes: 'p-3.5 pr-4 text-center', [
                    button(
                      onClick: () {},
                      classes:
                          'text-white text-[11px] font-bold px-3 py-1.5 rounded-lg shadow-xs cursor-pointer transition-all',
                      styles: Styles(backgroundColor: Color(colorScheme.primary)),
                      [Component.text('Edit')],
                    ),
                  ]),
                ]),
            ],
          ),
        ]),
      ],
    );
  }

  // --- REFERENCES TABLE ---

  List<UserReferenceModel> _getFilteredReferences() {
    return referencesList.where((r) {
      final query = searchQuery.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          r.userName.toLowerCase().contains(query) ||
          r.refereeName.toLowerCase().contains(query) ||
          r.relationship.toLowerCase().contains(query) ||
          r.id.toLowerCase().contains(query);
      final matchesStatus = selectedStatus == 'All' || r.status == selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Component _buildReferencesTable(ColorScheme colorScheme) {
    final filtered = _getFilteredReferences();
    if (filtered.isEmpty) return _buildEmptyState(colorScheme);

    return div(
      classes: 'overflow-x-auto rounded-xl border transition-colors',
      styles: Styles(raw: {'border-color': colorScheme.border}),
      [
        table(classes: 'w-full text-left border-collapse text-xs', [
          thead(
            classes: 'uppercase tracking-wider text-[10.5px] border-b font-bold',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textMuted),
              raw: {'border-color': colorScheme.border},
            ),
            [
              tr([
                th(classes: 'p-3.5 pl-4', [Component.text('Ref ID')]),
                th(classes: 'p-3.5', [Component.text('Submitted By')]),
                th(classes: 'p-3.5', [Component.text('Referee Name')]),
                th(classes: 'p-3.5', [Component.text('Relationship')]),
                th(classes: 'p-3.5', [Component.text('Contact Details')]),
                th(classes: 'p-3.5 text-center', [Component.text('Status')]),
                th(classes: 'p-3.5', [Component.text('Submitted')]),
                th(classes: 'p-3.5 pr-4 text-center', [Component.text('Actions')]),
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
              for (final ref in filtered)
                tr(classes: 'hover:opacity-90 transition-colors', [
                  td(
                    classes: 'p-3.5 pl-4 font-mono font-bold text-[11px]',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text(ref.id)],
                  ),
                  td(classes: 'p-3.5', [
                    div(classes: 'flex items-center space-x-2.5', [
                      img(
                        src: ref.userAvatar,
                        classes: 'w-7 h-7 rounded-full object-cover border shrink-0',
                        styles: Styles(raw: {'border-color': colorScheme.border}),
                        alt: ref.userName,
                      ),
                      span(
                        classes: 'font-bold text-xs',
                        styles: Styles(color: Color(colorScheme.textHeading)),
                        [Component.text(ref.userName)],
                      ),
                    ]),
                  ]),
                  td(
                    classes: 'p-3.5 font-bold text-xs',
                    styles: Styles(color: Color(colorScheme.textPrimary)),
                    [Component.text(ref.refereeName)],
                  ),
                  td(classes: 'p-3.5', [
                    span(
                      classes: 'px-2.5 py-1 rounded-md text-[11px] font-semibold border',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        color: Color(colorScheme.textSecondary),
                        raw: {'border-color': colorScheme.borderInput},
                      ),
                      [Component.text(ref.relationship)],
                    ),
                  ]),
                  td(classes: 'p-3.5', [
                    div([
                      div(
                        classes: 'font-medium text-xs',
                        styles: Styles(color: Color(colorScheme.textPrimary)),
                        [Component.text(ref.refereePhone)],
                      ),
                      div(
                        classes: 'text-[11px]',
                        styles: Styles(color: Color(colorScheme.textMuted)),
                        [Component.text(ref.refereeEmail)],
                      ),
                    ]),
                  ]),
                  td(classes: 'p-3.5 text-center', [_buildBadgePill(ref.status, colorScheme)]),
                  td(
                    classes: 'p-3.5 text-xs font-medium',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text(ref.submittedDate)],
                  ),
                  td(classes: 'p-3.5 pr-4 text-center', [
                    div(classes: 'flex items-center justify-center space-x-2', [
                      if (ref.status != 'Verified')
                        button(
                          onClick: () {
                            setState(() {
                              final idx = referencesList.indexWhere((r) => r.id == ref.id);
                              if (idx != -1) {
                                referencesList[idx] = UserReferenceModel(
                                  id: ref.id,
                                  userName: ref.userName,
                                  userAvatar: ref.userAvatar,
                                  refereeName: ref.refereeName,
                                  relationship: ref.relationship,
                                  refereePhone: ref.refereePhone,
                                  refereeEmail: ref.refereeEmail,
                                  status: 'Verified',
                                  submittedDate: ref.submittedDate,
                                );
                              }
                            });
                          },
                          classes:
                              'bg-emerald-600 hover:bg-emerald-700 text-white text-[11px] font-bold px-2.5 py-1 rounded-md cursor-pointer transition-all',
                          [Component.text('Verify')],
                        ),
                      button(
                        onClick: () {},
                        classes:
                            'text-[11px] font-bold px-2.5 py-1 rounded-md border cursor-pointer transition-all',
                        styles: Styles(
                          backgroundColor: Color(colorScheme.inputBg),
                          color: Color(colorScheme.textSecondary),
                          raw: {'border-color': colorScheme.borderInput},
                        ),
                        [Component.text('Details')],
                      ),
                    ]),
                  ]),
                ]),
            ],
          ),
        ]),
      ],
    );
  }

  // --- KYD DOCUMENTS TABLE ---

  List<KydDocumentModel> _getFilteredKydDocs() {
    return kydDocsList.where((d) {
      final query = searchQuery.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          d.userName.toLowerCase().contains(query) ||
          d.documentType.toLowerCase().contains(query) ||
          d.documentNumber.toLowerCase().contains(query) ||
          d.id.toLowerCase().contains(query);
      final matchesStatus = selectedStatus == 'All' || d.status == selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Component _buildKydDocsTable(ColorScheme colorScheme) {
    final filtered = _getFilteredKydDocs();
    if (filtered.isEmpty) return _buildEmptyState(colorScheme);

    return div(
      classes: 'overflow-x-auto rounded-xl border transition-colors',
      styles: Styles(raw: {'border-color': colorScheme.border}),
      [
        table(classes: 'w-full text-left border-collapse text-xs', [
          thead(
            classes: 'uppercase tracking-wider text-[10.5px] border-b font-bold',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textMuted),
              raw: {'border-color': colorScheme.border},
            ),
            [
              tr([
                th(classes: 'p-3.5 pl-4', [Component.text('Doc ID')]),
                th(classes: 'p-3.5', [Component.text('Submitted User')]),
                th(classes: 'p-3.5', [Component.text('Document Type')]),
                th(classes: 'p-3.5', [Component.text('Document Number')]),
                th(classes: 'p-3.5', [Component.text('Submission Date')]),
                th(classes: 'p-3.5 text-center', [Component.text('Status')]),
                th(classes: 'p-3.5 pr-4 text-center', [Component.text('Actions')]),
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
              for (final doc in filtered)
                tr(classes: 'hover:opacity-90 transition-colors', [
                  td(
                    classes: 'p-3.5 pl-4 font-mono font-bold text-[11px]',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text(doc.id)],
                  ),
                  td(classes: 'p-3.5', [
                    div(classes: 'flex items-center space-x-2.5', [
                      img(
                        src: doc.userAvatar,
                        classes: 'w-7 h-7 rounded-full object-cover border shrink-0',
                        styles: Styles(raw: {'border-color': colorScheme.border}),
                        alt: doc.userName,
                      ),
                      span(
                        classes: 'font-bold text-xs',
                        styles: Styles(color: Color(colorScheme.textHeading)),
                        [Component.text(doc.userName)],
                      ),
                    ]),
                  ]),
                  td(classes: 'p-3.5', [
                    span(
                      classes: 'px-2.5 py-1 rounded-md text-[11px] font-bold border',
                      styles: Styles(
                        backgroundColor: Color(colorScheme.inputBg),
                        color: Color(colorScheme.primary),
                        raw: {'border-color': colorScheme.borderInput},
                      ),
                      [Component.text(doc.documentType)],
                    ),
                  ]),
                  td(
                    classes: 'p-3.5 font-mono text-xs font-semibold',
                    styles: Styles(color: Color(colorScheme.textPrimary)),
                    [Component.text(doc.documentNumber)],
                  ),
                  td(
                    classes: 'p-3.5 text-xs font-medium',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text(doc.submissionDate)],
                  ),
                  td(classes: 'p-3.5 text-center', [_buildBadgePill(doc.status, colorScheme)]),
                  td(classes: 'p-3.5 pr-4 text-center', [
                    div(classes: 'flex items-center justify-center space-x-2', [
                      if (doc.status == 'Pending Review') ...[
                        button(
                          onClick: () {
                            setState(() {
                              final idx = kydDocsList.indexWhere((d) => d.id == doc.id);
                              if (idx != -1) {
                                kydDocsList[idx] = KydDocumentModel(
                                  id: doc.id,
                                  userName: doc.userName,
                                  userAvatar: doc.userAvatar,
                                  documentType: doc.documentType,
                                  documentNumber: doc.documentNumber,
                                  submissionDate: doc.submissionDate,
                                  expiryDate: doc.expiryDate,
                                  status: 'Approved',
                                );
                              }
                            });
                          },
                          classes:
                              'bg-emerald-600 hover:bg-emerald-700 text-white text-[11px] font-bold px-2.5 py-1 rounded-md cursor-pointer transition-all',
                          [Component.text('Approve')],
                        ),
                        button(
                          onClick: () {
                            setState(() {
                              final idx = kydDocsList.indexWhere((d) => d.id == doc.id);
                              if (idx != -1) {
                                kydDocsList[idx] = KydDocumentModel(
                                  id: doc.id,
                                  userName: doc.userName,
                                  userAvatar: doc.userAvatar,
                                  documentType: doc.documentType,
                                  documentNumber: doc.documentNumber,
                                  submissionDate: doc.submissionDate,
                                  expiryDate: doc.expiryDate,
                                  status: 'Rejected',
                                );
                              }
                            });
                          },
                          classes:
                              'bg-rose-600 hover:bg-rose-700 text-white text-[11px] font-bold px-2.5 py-1 rounded-md cursor-pointer transition-all',
                          [Component.text('Reject')],
                        ),
                      ],
                      button(
                        onClick: () {},
                        classes:
                            'text-[11px] font-bold px-2.5 py-1 rounded-md border cursor-pointer transition-all flex items-center space-x-1',
                        styles: Styles(
                          backgroundColor: Color(colorScheme.inputBg),
                          color: Color(colorScheme.textSecondary),
                          raw: {'border-color': colorScheme.borderInput},
                        ),
                        [
                          const AppIcon(AppIcons.eye),
                          span([Component.text('View')]),
                        ],
                      ),
                    ]),
                  ]),
                ]),
            ],
          ),
        ]),
      ],
    );
  }

  // --- EMPTY STATE ---

  Component _buildEmptyState(ColorScheme colorScheme) {
    return div(classes: 'py-14 text-center space-y-2', [
      p(
        classes: 'text-sm font-semibold',
        styles: Styles(color: Color(colorScheme.textSecondary)),
        [Component.text('No matching items found')],
      ),
      button(
        onClick: () {
          setState(() {
            searchQuery = '';
            selectedStatus = 'All';
          });
        },
        classes: 'text-xs font-bold hover:underline cursor-pointer',
        styles: Styles(color: Color(colorScheme.primary)),
        [Component.text('Reset filters')],
      ),
    ]);
  }

  // --- BADGE PILL BUILDER ---

  Component _buildBadgePill(String status, ColorScheme colorScheme) {
    String badgeClasses =
        'px-3 py-1 rounded-full text-[11px] font-bold inline-block leading-none tracking-tight border';
    String bg = 'bg-slate-100 dark:bg-slate-800';
    String text = 'text-slate-700 dark:text-slate-300';
    String border = 'border-slate-200 dark:border-slate-700';

    if (status == 'Active' || status == 'Approved' || status == 'Verified') {
      bg = 'bg-emerald-50 dark:bg-emerald-950/60';
      text = 'text-emerald-600 dark:text-emerald-400';
      border = 'border-emerald-200/50 dark:border-emerald-800/50';
    } else if (status == 'Pending' || status == 'Pending Review') {
      bg = 'bg-amber-50 dark:bg-amber-950/60';
      text = 'text-amber-600 dark:text-amber-400';
      border = 'border-amber-200/50 dark:border-amber-800/50';
    } else if (status == 'Suspended' || status == 'Declined' || status == 'Rejected') {
      bg = 'bg-rose-50 dark:bg-rose-950/60';
      text = 'text-rose-600 dark:text-rose-400';
      border = 'border-rose-200/50 dark:border-rose-800/50';
    }

    return span(classes: '$badgeClasses $bg $text $border', [
      Component.text(status),
    ]);
  }

  // --- PAGINATION FOOTER ---

  Component _buildPaginationFooter(ColorScheme colorScheme) {
    final count = _getFilteredCount();

    return div(
      classes:
          'flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-2 text-xs transition-colors',
      styles: Styles(color: Color(colorScheme.textMuted)),
      [
        div(classes: 'font-medium', [
          Component.text('Showing 1 to $count of $count entries'),
        ]),
        div(classes: 'flex items-center space-x-1.5 font-semibold self-end sm:self-auto', [
          button(
            onClick: () {
              if (currentPage > 1) {
                setState(() {
                  currentPage--;
                });
              }
            },
            classes: 'px-2.5 py-1 rounded-lg border transition-colors cursor-pointer text-xs font-semibold',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [Component.text('Previous')],
          ),
          button(
            classes: 'w-7 h-7 rounded-lg flex items-center justify-center font-bold text-white shadow-xs text-xs',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [Component.text('1')],
          ),
          button(
            onClick: () {
              setState(() {
                currentPage++;
              });
            },
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
