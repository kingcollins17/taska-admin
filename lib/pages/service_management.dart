import 'dart:async';

import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/category_detail_side_panel.dart';
import '../components/create_category_dialog.dart';
import '../components/create_service_dialog.dart';
import '../components/service_detail_side_panel.dart';
import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/services/admin_category_item.dart';
import '../core/models/clients/services/admin_service_item.dart';
import '../core/providers/admin_service_manager_providers.dart';
import '../core/providers/ui_state_provider.dart';

@client
class ServiceManagementPage extends StatelessComponent {
  const ServiceManagementPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex-1 space-y-6 relative', [
      const _Header(),
      const _TabbedContent(),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────

class _Header extends StatelessComponent {
  const _Header();

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return div(classes: 'flex flex-col sm:flex-row sm:items-center justify-between gap-4', [
      div([
        p(
          classes: 'text-xs sm:text-sm mt-1 font-medium transition-colors',
          styles: Styles(color: Color(colorScheme.textSecondary)),
          [
            Component.text(
              'Manage catalog services, categories, take rates, active availability, and service structures.',
            ),
          ],
        ),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Tabbed Content Container
// ─────────────────────────────────────────────────────────────

class _TabbedContent extends StatefulComponent {
  const _TabbedContent();

  @override
  State<_TabbedContent> createState() => _TabbedContentState();
}

class _TabbedContentState extends State<_TabbedContent> {
  int activeTab = 0; // 0 = Services, 1 = Categories

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return div(
      classes: 'border rounded-2xl shadow-sm transition-all overflow-hidden',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        // Tab Bar Header
        div(
          classes: 'flex items-center border-b px-1.5 pt-1.5',
          styles: Styles(raw: {'border-color': colorScheme.border}),
          [
            _TabButton(
              label: 'Services',
              icon: AppIcons.services,
              isActive: activeTab == 0,
              colorScheme: colorScheme,
              onTap: () => setState(() => activeTab = 0),
            ),
            _TabButton(
              label: 'Categories',
              icon: AppIcons.overview,
              isActive: activeTab == 1,
              colorScheme: colorScheme,
              onTap: () => setState(() => activeTab = 1),
            ),
          ],
        ),

        // Tab Content
        div(
          key: Key(activeTab == 0 ? 'services-tab' : 'categories-tab'),
          classes: 'p-5 sm:p-6 animate-fade-in-scaled',
          [
            if (activeTab == 0)
              const _ServicesTable()
            else
              const _CategoriesTable(),
          ],
        ),
      ],
    );
  }
}

class _TabButton extends StatelessComponent {
  final String label;
  final AppIcons icon;
  final bool isActive;
  final ColorScheme colorScheme;
  final void Function() onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Component build(BuildContext context) {
    return button(
      onClick: onTap,
      classes: isActive
          ? 'flex items-center space-x-2 px-4 py-2.5 text-xs font-bold cursor-pointer border-b-2 transition-all bg-transparent border-l-0 border-r-0 border-t-0'
          : 'flex items-center space-x-2 px-4 py-2.5 text-xs font-medium cursor-pointer border-b-2 border-transparent transition-all bg-transparent border-l-0 border-r-0 border-t-0 hover:opacity-80',
      styles: Styles(
        color: isActive ? Color(colorScheme.primary) : Color(colorScheme.textMuted),
        raw: {
          if (isActive) 'border-bottom-color': colorScheme.primary,
        },
      ),
      [
        AppIcon(icon),
        span([Component.text(label)]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 1: Services List Table Component
// ─────────────────────────────────────────────────────────────

class _ServicesTable extends StatefulComponent {
  const _ServicesTable();

  @override
  State<_ServicesTable> createState() => _ServicesTableState();
}

class _ServicesTableState extends State<_ServicesTable> {
  String searchQuery = '';
  String _searchInputValue = '';
  Timer? _searchDebounceTimer;
  String? selectedStatus; // null = All, 'active' = true, 'inactive' = false
  String? selectedCategoryId; // null = All Categories
  int currentPage = 1;

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
        searchQuery = _searchInputValue;
        currentPage = 1;
      });
    });
  }

  bool? get _isActiveFilter {
    if (selectedStatus == 'active') return true;
    if (selectedStatus == 'inactive') return false;
    return null;
  }

  String? _cleanCategoryId(dynamic input) {
    if (input == null) return null;
    String str;
    if (input is List) {
      if (input.isEmpty) return null;
      str = input.first.toString();
    } else {
      str = input.toString();
    }
    str = str.trim();
    if (str.startsWith('[') && str.endsWith(']')) {
      str = str.substring(1, str.length - 1).trim();
    }
    return str.isEmpty ? null : str;
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));
    final categoriesAsync = context.watch(
      adminCategoriesProvider(const ListCategoriesParams(perPage: 100)),
    );
    final categoriesList = categoriesAsync.when(
      data: (data) => data?.items ?? <AdminCategoryItem>[],
      loading: () => <AdminCategoryItem>[],
      error: (_, __) => <AdminCategoryItem>[],
    );

    final cleanCatId = _cleanCategoryId(selectedCategoryId);

    final servicesAsync = context.watch(
      adminServicesProvider(
        ListServicesParams(
          search: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
          categoryId: cleanCatId,
          isActive: _isActiveFilter,
          page: currentPage,
          perPage: 20,
        ),
      ),
    );

    return div(classes: 'space-y-5', [
      // Toolbar Header
      div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4', [
       
        div(classes: 'flex flex-wrap items-center gap-3', [
          // Add Service Primary Button
          button(
            onClick: () {
              CreateServiceDialog.show(context);
            },
            classes:
                'active:scale-[0.98] text-white text-xs font-bold px-3.5 py-2 rounded-xl flex items-center space-x-1.5 shadow-sm transition-all cursor-pointer border-none shrink-0 hover:opacity-95',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [
              const AppIcon(AppIcons.plus),
              span([Component.text('Add Service')]),
            ],
          ),
          // Category Filter Dropdown
          select(
            onChange: (value) {
              final parsed = _cleanCategoryId(value);
              setState(() {
                selectedCategoryId = parsed;
                currentPage = 1;
              });
            },
            classes:
                'border rounded-xl px-3 py-2 text-xs font-semibold focus:outline-none focus:ring-2 transition-all cursor-pointer shadow-xs',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textPrimary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [
              option(value: '', selected: cleanCatId == null || cleanCatId.isEmpty, [
                Component.text('All Categories'),
              ]),
              for (final cat in categoriesList)
                option(
                  value: cat.id ?? '',
                  selected: cleanCatId == cat.id,
                  [
                    Component.text(cat.name ?? 'Category #${cat.id}'),
                  ],
                ),
            ],
          ),

          // Search Input
          div(classes: 'relative w-full sm:w-64', [
            div(
              classes: 'absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none',
              styles: Styles(color: Color(colorScheme.placeholder)),
              [const AppIcon(AppIcons.search)],
            ),
            input(
              type: InputType.text,
              value: _searchInputValue,
              classes:
                  'w-full border rounded-xl pl-9 pr-4 py-2 text-xs font-medium focus:outline-none focus:ring-2 transition-all',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.textPrimary),
                raw: {'border-color': colorScheme.borderInput},
              ),
              attributes: {'placeholder': 'Search services...'},
              onInput: _onSearchInput,
            ),
          ]),

          // Active Status Pills
          for (final status in <String?>[null, 'active', 'inactive'])
            button(
              onClick: () => setState(() {
                selectedStatus = status;
                currentPage = 1;
              }),
              classes: 'px-3 py-1.5 rounded-lg transition-all cursor-pointer text-[11px] font-bold border',
              styles: selectedStatus == status
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
              [Component.text(status == null ? 'All' : (status == 'active' ? 'Active' : 'Inactive'))],
            ),
        ]),
      ]),

      // Table Content
      servicesAsync.when(
        data: (paginatedData) {
          final items = paginatedData?.items ?? [];
          final total = paginatedData?.total ?? items.length;
          final perPage = paginatedData?.perPage ?? 20;

          if (items.isEmpty) {
            return _EmptyState(
              colorScheme: colorScheme,
              message: 'No service offerings found',
              onReset: () {
                _searchDebounceTimer?.cancel();
                _searchInputValue = '';
                setState(() {
                  searchQuery = '';
                  selectedStatus = null;
                  selectedCategoryId = null;
                  currentPage = 1;
                });
              },
            );
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
                        th(classes: 'p-3.5 pl-4 whitespace-nowrap', [Component.text('Service')]),
                        th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Category')]),
                        th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Take Rate')]),
                        th(classes: 'p-3.5 text-center whitespace-nowrap', [Component.text('Status')]),
                        th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Created At')]),
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
                      for (final service in items)
                        tr(
                          classes: 'hover:opacity-90 transition-colors cursor-pointer',
                          events: {
                            'click': (_) => _showServiceDetail(context, service),
                          },
                          [
                            // Service info
                            td(classes: 'p-3.5 pl-4 whitespace-nowrap', [
                              div(classes: 'flex items-center space-x-3', [
                                if (service.imageUrl != null && service.imageUrl!.isNotEmpty)
                                  img(
                                    src: service.imageUrl!,
                                    classes: 'w-8 h-8 rounded-lg object-cover border shrink-0',
                                    styles: Styles(raw: {'border-color': colorScheme.border}),
                                    alt: service.name ?? 'Service',
                                  )
                                else
                                  div(
                                    classes:
                                        'w-8 h-8 rounded-lg flex items-center justify-center shrink-0 shadow-xs',
                                    styles: Styles(
                                      backgroundColor: Color(colorScheme.inputBg),
                                      color: Color(colorScheme.primary),
                                    ),
                                    [const AppIcon(AppIcons.services)],
                                  ),
                                div([
                                  div(
                                    classes: 'font-bold text-xs',
                                    styles: Styles(color: Color(colorScheme.textHeading)),
                                    [Component.text(service.name ?? 'Unnamed Service')],
                                  ),
                                  div(
                                    classes: 'text-[10.5px] font-mono',
                                    styles: Styles(color: Color(colorScheme.textMuted)),
                                    [Component.text(_formatId(service.id))],
                                  ),
                                ]),
                              ]),
                            ]),
                            // Category
                            td(
                              classes: 'p-3.5 text-xs font-semibold whitespace-nowrap',
                              styles: Styles(color: Color(colorScheme.textSecondary)),
                              [Component.text(service.category?.name ?? service.categoryId ?? '—')],
                            ),
                            // Take Rate
                            td(
                              classes: 'p-3.5 font-mono font-bold text-xs whitespace-nowrap',
                              styles: Styles(color: Color(colorScheme.primary)),
                              [Component.text(_formatTakeRate(service.takeRate))],
                            ),
                            // Status
                            td(
                              classes: 'p-3.5 text-center whitespace-nowrap',
                              [
                                _StatusBadge(
                                  isActive: service.isActive == true,
                                  colorScheme: colorScheme,
                                ),
                              ],
                            ),
                            // Created At
                            td(
                              classes: 'p-3.5 text-xs font-medium whitespace-nowrap',
                              styles: Styles(color: Color(colorScheme.textMuted)),
                              [Component.text(_formatDate(service.createdAt))],
                            ),
                            // Actions
                            td(classes: 'p-3.5 pr-4 text-center whitespace-nowrap', [
                              button(
                                onClick: () => _showServiceDetail(context, service),
                                classes:
                                    'text-white text-[11px] font-bold px-3 py-1.5 rounded-lg shadow-xs cursor-pointer transition-all border-none whitespace-nowrap shrink-0',
                                styles: Styles(backgroundColor: Color(colorScheme.primary)),
                                [Component.text('View')],
                              ),
                            ]),
                          ],
                        ),
                    ],
                  ),
                ]),
              ],
            ),
            // Pagination
            _PaginationFooter(
              colorScheme: colorScheme,
              total: total,
              perPage: perPage,
              currentPage: currentPage,
              onPreviousPage: () {
                if (currentPage > 1) {
                  setState(() => currentPage--);
                }
              },
              onNextPage: () {
                final maxPage = (total / perPage).ceil().clamp(1, 9999);
                if (currentPage < maxPage) {
                  setState(() => currentPage++);
                }
              },
            ),
          ]);
        },
        loading: () => _ShimmerLoading(colorScheme: colorScheme),
        error: (err, _) => _ErrorState(
          colorScheme: colorScheme,
          errorMsg: err.toString(),
          onRetry: () => setState(() {}),
        ),
      ),
    ]);
  }

  void _showServiceDetail(BuildContext context, AdminServiceItem service) {
    ServiceDetailSidePanel.show(context, service);
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 2: Categories List Table Component
// ─────────────────────────────────────────────────────────────

class _CategoriesTable extends StatefulComponent {
  const _CategoriesTable();

  @override
  State<_CategoriesTable> createState() => _CategoriesTableState();
}

class _CategoriesTableState extends State<_CategoriesTable> {
  String searchQuery = '';
  String _searchInputValue = '';
  Timer? _searchDebounceTimer;
  String? selectedStatus; // null = All, 'active' = true, 'inactive' = false
  int currentPage = 1;

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
        searchQuery = _searchInputValue;
        currentPage = 1;
      });
    });
  }

  bool? get _isActiveFilter {
    if (selectedStatus == 'active') return true;
    if (selectedStatus == 'inactive') return false;
    return null;
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));
    final categoriesAsync = context.watch(
      adminCategoriesProvider(
        ListCategoriesParams(
          search: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
          isActive: _isActiveFilter,
          page: currentPage,
          perPage: 20,
        ),
      ),
    );

    return div(classes: 'space-y-5', [
      // Toolbar Header
      div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4', [
       
        div(classes: 'flex flex-wrap items-center gap-3', [
          // Add Category Primary Button
          button(
            onClick: () {
              CreateCategoryDialog.show(context);
            },
            classes:
                'active:scale-[0.98] text-white text-xs font-bold px-3.5 py-2 rounded-xl flex items-center space-x-1.5 shadow-sm transition-all cursor-pointer border-none shrink-0 hover:opacity-95',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [
              const AppIcon(AppIcons.plus),
              span([Component.text('Add Category')]),
            ],
          ),
          // Search Input
          div(classes: 'relative w-full sm:w-64', [
            div(
              classes: 'absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none',
              styles: Styles(color: Color(colorScheme.placeholder)),
              [const AppIcon(AppIcons.search)],
            ),
            input(
              type: InputType.text,
              value: _searchInputValue,
              classes:
                  'w-full border rounded-xl pl-9 pr-4 py-2 text-xs font-medium focus:outline-none focus:ring-2 transition-all',
              styles: Styles(
                backgroundColor: Color(colorScheme.inputBg),
                color: Color(colorScheme.textPrimary),
                raw: {'border-color': colorScheme.borderInput},
              ),
              attributes: {'placeholder': 'Search categories...'},
              onInput: _onSearchInput,
            ),
          ]),

          // Active Status Pills
          for (final status in <String?>[null, 'active', 'inactive'])
            button(
              onClick: () => setState(() {
                selectedStatus = status;
                currentPage = 1;
              }),
              classes: 'px-3 py-1.5 rounded-lg transition-all cursor-pointer text-[11px] font-bold border',
              styles: selectedStatus == status
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
              [Component.text(status == null ? 'All' : (status == 'active' ? 'Active' : 'Inactive'))],
            ),
        ]),
      ]),

      // Table Content
      categoriesAsync.when(
        data: (paginatedData) {
          final items = paginatedData?.items ?? [];
          final total = paginatedData?.total ?? items.length;
          final perPage = paginatedData?.perPage ?? 20;

          if (items.isEmpty) {
            return _EmptyState(
              colorScheme: colorScheme,
              message: 'No service categories found',
              onReset: () {
                _searchDebounceTimer?.cancel();
                _searchInputValue = '';
                setState(() {
                  searchQuery = '';
                  selectedStatus = null;
                  currentPage = 1;
                });
              },
            );
          }

          return div(classes: 'space-y-5', [
            div(
              classes: 'overflow-x-auto rounded-xl border transition-colors',
              styles: Styles(raw: {'border-color': colorScheme.border}),
              [
                table(classes: 'w-full min-w-[850px] text-left border-collapse text-xs', [
                  thead(
                    classes: 'uppercase tracking-wider text-[10.5px] border-b font-bold',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.inputBg),
                      color: Color(colorScheme.textMuted),
                      raw: {'border-color': colorScheme.border},
                    ),
                    [
                      tr([
                        th(classes: 'p-3.5 pl-4 whitespace-nowrap', [Component.text('Category')]),
                        th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Description')]),
                        th(classes: 'p-3.5 text-center whitespace-nowrap', [Component.text('Status')]),
                        th(classes: 'p-3.5 whitespace-nowrap', [Component.text('Created At')]),
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
                      for (final category in items)
                        tr(
                          classes: 'hover:opacity-90 transition-colors cursor-pointer',
                          events: {
                            'click': (_) => _showCategoryDetail(context, category),
                          },
                          [
                            // Category info
                            td(classes: 'p-3.5 pl-4 whitespace-nowrap', [
                              div(classes: 'flex items-center space-x-3', [
                                if (category.imageUrl != null && category.imageUrl!.isNotEmpty)
                                  img(
                                    src: category.imageUrl!,
                                    classes: 'w-8 h-8 rounded-lg object-cover border shrink-0',
                                    styles: Styles(raw: {'border-color': colorScheme.border}),
                                    alt: category.name ?? 'Category',
                                  )
                                else
                                  div(
                                    classes:
                                        'w-8 h-8 rounded-lg flex items-center justify-center shrink-0 shadow-xs',
                                    styles: Styles(
                                      backgroundColor: Color(colorScheme.inputBg),
                                      color: Color(colorScheme.primary),
                                    ),
                                    [const AppIcon(AppIcons.overview)],
                                  ),
                                div([
                                  div(
                                    classes: 'font-bold text-xs',
                                    styles: Styles(color: Color(colorScheme.textHeading)),
                                    [Component.text(category.name ?? 'Unnamed Category')],
                                  ),
                                  div(
                                    classes: 'text-[10.5px] font-mono',
                                    styles: Styles(color: Color(colorScheme.textMuted)),
                                    [Component.text(_formatId(category.id))],
                                  ),
                                ]),
                              ]),
                            ]),
                            // Description
                            td(
                              classes: 'p-3.5 text-xs max-w-xs truncate whitespace-nowrap',
                              styles: Styles(color: Color(colorScheme.textSecondary)),
                              [Component.text(category.description ?? '—')],
                            ),
                            // Status
                            td(
                              classes: 'p-3.5 text-center whitespace-nowrap',
                              [
                                _StatusBadge(
                                  isActive: category.isActive == true,
                                  colorScheme: colorScheme,
                                ),
                              ],
                            ),
                            // Created At
                            td(
                              classes: 'p-3.5 text-xs font-medium whitespace-nowrap',
                              styles: Styles(color: Color(colorScheme.textMuted)),
                              [Component.text(_formatDate(category.createdAt))],
                            ),
                            // Actions
                            td(classes: 'p-3.5 pr-4 text-center whitespace-nowrap', [
                              button(
                                onClick: () => _showCategoryDetail(context, category),
                                classes:
                                    'text-white text-[11px] font-bold px-3 py-1.5 rounded-lg shadow-xs cursor-pointer transition-all border-none whitespace-nowrap shrink-0',
                                styles: Styles(backgroundColor: Color(colorScheme.primary)),
                                [Component.text('View')],
                              ),
                            ]),
                          ],
                        ),
                    ],
                  ),
                ]),
              ],
            ),
            // Pagination
            _PaginationFooter(
              colorScheme: colorScheme,
              total: total,
              perPage: perPage,
              currentPage: currentPage,
              onPreviousPage: () {
                if (currentPage > 1) {
                  setState(() => currentPage--);
                }
              },
              onNextPage: () {
                final maxPage = (total / perPage).ceil().clamp(1, 9999);
                if (currentPage < maxPage) {
                  setState(() => currentPage++);
                }
              },
            ),
          ]);
        },
        loading: () => _ShimmerLoading(colorScheme: colorScheme),
        error: (err, _) => _ErrorState(
          colorScheme: colorScheme,
          errorMsg: err.toString(),
          onRetry: () => setState(() {}),
        ),
      ),
    ]);
  }

  void _showCategoryDetail(BuildContext context, AdminCategoryItem category) {
    CategoryDetailSidePanel.show(context, category);
  }
}

// ─────────────────────────────────────────────────────────────
// Shared Sub-components & Helpers
// ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessComponent {
  final bool isActive;
  final ColorScheme colorScheme;

  const _StatusBadge({required this.isActive, required this.colorScheme});

  @override
  Component build(BuildContext context) {
    String bgClass;
    String textClass;
    String borderClass;

    if (isActive) {
      bgClass = 'bg-emerald-50 dark:bg-emerald-950/60';
      textClass = 'text-emerald-600 dark:text-emerald-400';
      borderClass = 'border-emerald-200/50 dark:border-emerald-800/50';
    } else {
      bgClass = 'bg-rose-50 dark:bg-rose-950/60';
      textClass = 'text-rose-600 dark:text-rose-400';
      borderClass = 'border-rose-200/50 dark:border-rose-800/50';
    }

    return span(
      classes:
          'px-3 py-1 rounded-full text-[11px] font-bold inline-block leading-none border whitespace-nowrap $bgClass $textClass $borderClass',
      [Component.text(isActive ? 'Active' : 'Inactive')],
    );
  }
}


class _EmptyState extends StatelessComponent {
  final ColorScheme colorScheme;
  final String message;
  final void Function() onReset;

  const _EmptyState({
    required this.colorScheme,
    required this.message,
    required this.onReset,
  });

  @override
  Component build(BuildContext context) {
    return div(classes: 'py-14 text-center space-y-2', [
      p(
        classes: 'text-sm font-semibold',
        styles: Styles(color: Color(colorScheme.textSecondary)),
        [Component.text(message)],
      ),
      button(
        onClick: onReset,
        classes: 'text-xs font-bold hover:underline cursor-pointer border-none bg-transparent',
        styles: Styles(color: Color(colorScheme.primary)),
        [Component.text('Reset filters')],
      ),
    ]);
  }
}

class _PaginationFooter extends StatelessComponent {
  final ColorScheme colorScheme;
  final int total;
  final int perPage;
  final int currentPage;
  final void Function() onPreviousPage;
  final void Function() onNextPage;

  const _PaginationFooter({
    required this.colorScheme,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Component build(BuildContext context) {
    final maxPage = (total / perPage).ceil().clamp(1, 9999);

    return div(
      classes:
          'flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-2 text-xs transition-colors',
      styles: Styles(color: Color(colorScheme.textMuted)),
      [
        div(classes: 'font-medium', [
          Component.text('Showing page $currentPage of $maxPage (Total: $total entries)'),
        ]),
        div(classes: 'flex items-center space-x-1.5 font-semibold self-end sm:self-auto', [
          button(
            onClick: onPreviousPage,
            classes: 'px-2.5 py-1 rounded-lg border transition-colors cursor-pointer text-xs font-semibold',
            styles: Styles(
              backgroundColor: Color(colorScheme.inputBg),
              color: Color(colorScheme.textSecondary),
              raw: {'border-color': colorScheme.borderInput},
            ),
            [Component.text('Previous')],
          ),
          span(
            classes: 'px-3 py-1 rounded-lg font-bold text-white shadow-xs text-xs',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [Component.text('$currentPage')],
          ),
          button(
            onClick: onNextPage,
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

class _ShimmerLoading extends StatelessComponent {
  final ColorScheme colorScheme;

  const _ShimmerLoading({required this.colorScheme});

  @override
  Component build(BuildContext context) {
    final blockColor = colorScheme.isDark ? Color.rgba(31, 45, 39, 0.8) : Color.rgba(226, 232, 240, 0.8);

    return div(
      classes: 'space-y-6 animate-pulse',
      [
        div(classes: 'h-10 w-full rounded-xl', styles: Styles(backgroundColor: blockColor), []),
        div(classes: 'h-72 w-full rounded-xl', styles: Styles(backgroundColor: blockColor), []),
      ],
    );
  }
}

class _ErrorState extends StatelessComponent {
  final ColorScheme colorScheme;
  final String errorMsg;
  final void Function() onRetry;

  const _ErrorState({
    required this.colorScheme,
    required this.errorMsg,
    required this.onRetry,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'rounded-2xl p-12 text-center border space-y-4',
      styles: Styles(
        backgroundColor: Color(colorScheme.surface),
        raw: {'border-color': colorScheme.border},
      ),
      [
        div(classes: 'text-rose-500 font-bold text-lg', [Component.text('Failed to Load Catalog Data')]),
        p(classes: 'text-xs text-slate-400 max-w-md mx-auto', [Component.text(errorMsg)]),
        button(
          onClick: onRetry,
          classes: 'px-4 py-2 text-xs font-bold text-white rounded-xl shadow-xs cursor-pointer border-none',
          styles: Styles(backgroundColor: Color(colorScheme.primary)),
          [Component.text('Retry')],
        ),
      ],
    );
  }
}

String _formatId(String? id) {
  if (id == null || id.isEmpty) return '—';
  if (id.length <= 8) return '#$id';
  return '#${id.substring(0, 8)}...';
}

String _formatDate(DateTime? dt) {
  if (dt == null) return '—';
  return '${dt.day}/${dt.month}/${dt.year}';
}

String _formatTakeRate(num? rate) {
  if (rate == null) return '0%';
  final double val = rate.toDouble();
  final double percentage = (val > 0 && val <= 1.0) ? val * 100 : val;
  final formatted = percentage % 1 == 0 ? percentage.toInt().toString() : percentage.toStringAsFixed(1);
  return '$formatted%';
}
