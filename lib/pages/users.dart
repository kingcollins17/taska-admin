import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';

class UserModel {
  final String id;
  final String name;
  final String department;
  final String avatarUrl;
  final String status; // Pending, Active, Verified, Suspended
  final String assignedBy;
  final String assignedByAvatar;
  final String joinedDate;

  const UserModel({
    required this.id,
    required this.name,
    required this.department,
    required this.avatarUrl,
    required this.status,
    required this.assignedBy,
    required this.assignedByAvatar,
    required this.joinedDate,
  });
}

const List<UserModel> mockUsers = [
  UserModel(
    id: '#USER-013',
    name: 'Update customer onboarding flow',
    department: 'Operations',
    avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80',
    status: 'Pending',
    assignedBy: 'Sarah Johnson',
    assignedByAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Jul 18, 2025',
  ),
  UserModel(
    id: '#USER-002',
    name: 'Finalize Q3 operations budget',
    department: 'Finance',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
    status: 'Active',
    assignedBy: 'Alex Morgan',
    assignedByAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Jul 20, 2025',
  ),
  UserModel(
    id: '#USER-003',
    name: 'Conduct team performance reviews',
    department: 'HR',
    avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=80',
    status: 'Verified',
    assignedBy: 'Emily Chen',
    assignedByAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Jul 25, 2025',
  ),
  UserModel(
    id: '#USER-004',
    name: 'Vendor contract negotiations',
    department: 'Procurement',
    avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&auto=format&fit=crop&q=80',
    status: 'Active',
    assignedBy: 'Michael Brown',
    assignedByAvatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Aug 01, 2025',
  ),
  UserModel(
    id: '#USER-005',
    name: 'Implement new inventory system',
    department: 'Operations',
    avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100&auto=format&fit=crop&q=80',
    status: 'Pending',
    assignedBy: 'David Wilson',
    assignedByAvatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Aug 10, 2025',
  ),
  UserModel(
    id: '#USER-006',
    name: 'Quarterly compliance audit',
    department: 'Legal',
    avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100&auto=format&fit=crop&q=80',
    status: 'Verified',
    assignedBy: 'Lisa Rodriguez',
    assignedByAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Jul 21, 2025',
  ),
  UserModel(
    id: '#USER-007',
    name: 'Staff training on new equipment',
    department: 'Operations',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
    status: 'Active',
    assignedBy: 'Jessica Kim',
    assignedByAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Aug 02, 2025',
  ),
  UserModel(
    id: '#USER-008',
    name: 'Update emergency response protocol',
    department: 'Safety',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=80',
    status: 'Pending',
    assignedBy: 'Robert Taylor',
    assignedByAvatar: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&auto=format&fit=crop&q=80',
    joinedDate: 'Aug 15, 2025',
  ),
];

class UsersPage extends StatefulComponent {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String searchQuery = '';
  String selectedStatus = 'All';
  bool isFilterOpen = false;
  int currentPage = 1;

  @override
  Component build(BuildContext context) {
    // Filter users list
    final filteredUsers = mockUsers.where((user) {
      final matchesSearch = searchQuery.isEmpty ||
          user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.department.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.assignedBy.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus = selectedStatus == 'All' || user.status == selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    return div(classes: 'flex-1 space-y-6', [
      // Header Title Section
      div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-3', [
        div([
          h2(classes: 'text-xl sm:text-2xl font-bold text-slate-900 dark:text-white tracking-tight', [
            Component.text('Work Update'),
          ]),
          p(classes: 'text-xs sm:text-sm text-slate-500 dark:text-slate-400 mt-1', [
            Component.text('Manage and track all operations tasks in one place'),
          ]),
        ]),
      ]),

      // 4 Top Metric Cards Grid
      div(classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-5', [
        _buildMetricCard(
          title: 'Total Tasks',
          count: '42',
          growth: '+12%',
          isPositive: true,
          iconBg: 'bg-blue-50 dark:bg-blue-950/60',
          iconColor: 'text-blue-600 dark:text-blue-400',
          svgPath: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z',
        ),
        _buildMetricCard(
          title: 'Pending',
          count: '12',
          growth: '+5%',
          isPositive: true,
          iconBg: 'bg-amber-50 dark:bg-amber-950/60',
          iconColor: 'text-amber-600 dark:text-amber-400',
          svgPath: 'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z',
        ),
        _buildMetricCard(
          title: 'In Progress',
          count: '18',
          growth: '+7%',
          isPositive: true,
          iconBg: 'bg-indigo-50 dark:bg-indigo-950/60',
          iconColor: 'text-indigo-600 dark:text-indigo-400',
          svgPath: 'M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15',
        ),
        _buildMetricCard(
          title: 'Completed',
          count: '12',
          growth: '+14%',
          isPositive: true,
          iconBg: 'bg-emerald-50 dark:bg-emerald-950/60',
          iconColor: 'text-emerald-600 dark:text-emerald-400',
          svgPath: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z',
        ),
      ]),

      // Main User List Card Table
      div(classes: 'bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 rounded-2xl p-5 sm:p-6 shadow-sm space-y-5', [
        // Toolbar: Title + Search + Filter + Add User Button
        div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4', [
          h3(classes: 'text-base font-bold text-slate-900 dark:text-white tracking-tight', [
            Component.text('Task List'),
          ]),

          div(classes: 'flex flex-wrap items-center gap-3', [
            // Search Input Pill
            div(classes: 'relative w-full sm:w-64', [
              div(classes: 'absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400', [
                const AppIcon(AppIcons.search),
              ]),
              input(
                type: InputType.text,
                value: searchQuery,
                classes: 'w-full bg-slate-50 dark:bg-slate-800/80 border border-slate-200/80 dark:border-slate-700/80 rounded-xl pl-9 pr-4 py-2 text-xs font-medium text-slate-800 dark:text-slate-100 placeholder-slate-400 dark:placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all',
                attributes: {'placeholder': 'Search Tasks...'},
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
              classes: 'bg-slate-50 dark:bg-slate-800 hover:bg-slate-100 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-200 text-xs font-semibold px-3.5 py-2 rounded-xl flex items-center space-x-1.5 transition-colors cursor-pointer border border-slate-200/70 dark:border-slate-700',
              [
                const AppIcon(AppIcons.filter),
                span([Component.text('Filter')]),
              ],
            ),

            // + Add Task Primary Blue Button
            button(
              onClick: () {},
              classes: 'bg-blue-600 hover:bg-blue-700 active:scale-[0.98] text-white text-xs font-bold px-4 py-2 rounded-xl flex items-center space-x-1.5 shadow-md shadow-blue-600/20 transition-all cursor-pointer',
              [
                span(classes: 'text-sm font-bold leading-none', [Component.text('+')]),
                span([Component.text('Add Task')]),
              ],
            ),
          ]),
        ]),

        // Interactive Filter Bar (Expandable)
        if (isFilterOpen)
          div(classes: 'p-3 bg-slate-50/80 dark:bg-slate-800/50 rounded-xl border border-slate-200/60 dark:border-slate-700/60 flex flex-wrap items-center gap-2 text-xs font-semibold', [
            span(classes: 'text-slate-500 dark:text-slate-400 mr-1 text-[11px] uppercase tracking-wider', [
              Component.text('Status:'),
            ]),
            _buildStatusChip('All'),
            _buildStatusChip('Pending'),
            _buildStatusChip('Active'),
            _buildStatusChip('Verified'),
          ]),

        // Data Table Container
        _buildDataTable(filteredUsers),

        // Pagination Bar
        _buildPaginationFooter(filteredUsers.length),
      ]),
    ]);
  }

  // Single Metric Card Builder
  Component _buildMetricCard({
    required String title,
    required String count,
    required String growth,
    required bool isPositive,
    required String iconBg,
    required String iconColor,
    required String svgPath,
  }) {
    return div(classes: 'bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 rounded-2xl p-5 shadow-sm flex items-start justify-between relative overflow-hidden', [
      div(classes: 'space-y-2', [
        span(classes: 'text-xs font-medium text-slate-500 dark:text-slate-400', [
          Component.text(title),
        ]),
        div(classes: 'flex items-baseline space-x-2', [
          span(classes: 'text-2xl sm:text-3xl font-extrabold text-slate-900 dark:text-white tracking-tight', [
            Component.text(count),
          ]),
          span(classes: 'text-xs font-bold ${isPositive ? "text-emerald-600 dark:text-emerald-400" : "text-rose-600 dark:text-rose-400"} flex items-center', [
            span(classes: 'mr-0.5 text-[11px]', [Component.text('↑')]),
            Component.text(growth),
          ]),
        ]),
      ]),

      // Circular Icon Badge
      div(classes: 'w-10 h-10 rounded-full $iconBg flex items-center justify-center $iconColor shrink-0 shadow-sm', [
        RawText('<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="$svgPath"></path></svg>'),
      ]),
    ]);
  }

  // Filter Chip Component
  Component _buildStatusChip(String statusLabel) {
    final isSelected = selectedStatus == statusLabel;
    final classes = isSelected
        ? 'bg-blue-600 text-white shadow-sm'
        : 'bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200/80 dark:border-slate-700';

    return button(
      onClick: () {
        setState(() {
          selectedStatus = statusLabel;
        });
      },
      classes: 'px-3 py-1 rounded-lg transition-all cursor-pointer text-xs $classes',
      [Component.text(statusLabel)],
    );
  }

  // Data Table Builder
  Component _buildDataTable(List<UserModel> users) {
    if (users.isEmpty) {
      return div(classes: 'py-14 text-center space-y-2', [
        p(classes: 'text-sm font-semibold text-slate-600 dark:text-slate-400', [
          Component.text('No items found matching your filters'),
        ]),
        button(
          onClick: () {
            setState(() {
              searchQuery = '';
              selectedStatus = 'All';
            });
          },
          classes: 'text-xs font-bold text-blue-600 hover:underline cursor-pointer',
          [Component.text('Reset filter')],
        ),
      ]);
    }

    return div(classes: 'overflow-x-auto rounded-xl border border-slate-100 dark:border-slate-800', [
      table(classes: 'w-full text-left border-collapse text-xs', [
        // Table Header
        thead(classes: 'bg-slate-50/70 dark:bg-slate-800/40 text-slate-400 dark:text-slate-500 font-semibold border-b border-slate-100 dark:border-slate-800 uppercase tracking-wider text-[10.5px]', [
          tr([
            th(classes: 'p-3.5 pl-4 font-semibold', [Component.text('Task ID')]),
            th(classes: 'p-3.5 font-semibold', [Component.text('Title')]),
            th(classes: 'p-3.5 font-semibold text-center', [Component.text('Status')]),
            th(classes: 'p-3.5 font-semibold', [Component.text('Assigned By')]),
            th(classes: 'p-3.5 font-semibold', [Component.text('Due Date')]),
            th(classes: 'p-3.5 pr-4 text-center font-semibold', [Component.text('Actions')]),
          ]),
        ]),

        // Table Rows
        tbody(classes: 'divide-y divide-slate-100 dark:divide-slate-800/80 text-slate-700 dark:text-slate-300 font-medium', [
          for (final user in users)
            tr(classes: 'hover:bg-slate-50/50 dark:hover:bg-slate-800/30 transition-colors', [
              // ID Column
              td(classes: 'p-3.5 pl-4 font-mono font-semibold text-slate-500 dark:text-slate-400 text-[11px]', [
                Component.text(user.id),
              ]),

              // Title & Department Column
              td(classes: 'p-3.5', [
                div([
                  div(classes: 'font-bold text-slate-900 dark:text-white text-xs', [
                    Component.text(user.name),
                  ]),
                  div(classes: 'text-[10.5px] text-slate-400 dark:text-slate-500 font-medium', [
                    Component.text(user.department),
                  ]),
                ]),
              ]),

              // Status Badge Column (Soft colored pill chips)
              td(classes: 'p-3.5 text-center', [
                _buildStatusPill(user.status),
              ]),

              // Assigned By Column (Avatar + Name)
              td(classes: 'p-3.5', [
                div(classes: 'flex items-center space-x-2.5', [
                  img(
                    src: user.assignedByAvatar,
                    classes: 'w-6 h-6 rounded-full object-cover border border-slate-200 dark:border-slate-700 shadow-sm shrink-0',
                    alt: user.assignedBy,
                  ),
                  span(classes: 'font-semibold text-slate-800 dark:text-slate-200 text-xs', [
                    Component.text(user.assignedBy),
                  ]),
                ]),
              ]),

              // Due Date Column
              td(classes: 'p-3.5 text-slate-500 dark:text-slate-400 font-medium text-xs', [
                Component.text(user.joinedDate),
              ]),

              // Actions Button Column (Blue Action Button)
              td(classes: 'p-3.5 pr-4 text-center', [
                button(
                  classes: 'bg-blue-600 hover:bg-blue-700 active:scale-95 text-white text-[11px] font-bold px-3 py-1.5 rounded-lg transition-all shadow-sm shadow-blue-600/15 cursor-pointer',
                  [Component.text('Edit Task')],
                ),
              ]),
            ]),
        ]),
      ]),
    ]);
  }

  // Status Badge Builder matching the inspiration UI
  Component _buildStatusPill(String status) {
    String badgeClasses = 'px-3 py-1 rounded-full text-[11px] font-semibold inline-block leading-none tracking-tight';

    if (status == 'Pending') {
      badgeClasses += ' bg-amber-50 text-amber-600 dark:bg-amber-950/60 dark:text-amber-400 border border-amber-200/50 dark:border-amber-800/50';
    } else if (status == 'Active') {
      badgeClasses += ' bg-blue-50 text-blue-600 dark:bg-blue-950/60 dark:text-blue-400 border border-blue-200/50 dark:border-blue-800/50';
    } else if (status == 'Verified') {
      badgeClasses += ' bg-emerald-50 text-emerald-600 dark:bg-emerald-950/60 dark:text-emerald-400 border border-emerald-200/50 dark:border-emerald-800/50';
    } else {
      badgeClasses += ' bg-rose-50 text-rose-600 dark:bg-rose-950/60 dark:text-rose-400 border border-rose-200/50 dark:border-rose-800/50';
    }

    return span(classes: badgeClasses, [
      Component.text(status),
    ]);
  }

  // Pagination Footer Builder
  Component _buildPaginationFooter(int count) {
    return div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-2 text-xs text-slate-500 dark:text-slate-400', [
      div(classes: 'font-medium', [
        Component.text('Showing 1 to $count of 42 entries'),
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
          classes: 'px-2.5 py-1 rounded-lg border border-slate-200 dark:border-slate-800 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors cursor-pointer text-slate-600 dark:text-slate-300 text-xs',
          [Component.text('Previous')],
        ),
        button(
          classes: 'w-7 h-7 rounded-lg flex items-center justify-center bg-blue-600 text-white font-bold shadow-sm text-xs',
          [Component.text('1')],
        ),
        button(
          classes: 'w-7 h-7 rounded-lg flex items-center justify-center border border-slate-200 dark:border-slate-800 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors cursor-pointer text-slate-600 dark:text-slate-300 text-xs',
          [Component.text('2')],
        ),
        button(
          classes: 'w-7 h-7 rounded-lg flex items-center justify-center border border-slate-200 dark:border-slate-800 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors cursor-pointer text-slate-600 dark:text-slate-300 text-xs',
          [Component.text('3')],
        ),
        button(
          onClick: () {
            setState(() {
              currentPage++;
            });
          },
          classes: 'px-2.5 py-1 rounded-lg border border-slate-200 dark:border-slate-800 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors cursor-pointer text-slate-600 dark:text-slate-300 text-xs',
          [Component.text('Next')],
        ),
      ]),
    ]);
  }
}
