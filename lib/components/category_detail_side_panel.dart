import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/services/admin_category_item.dart';
import '../core/models/clients/services/update_category_request.dart';
import '../core/providers/admin_service_manager_providers.dart';
import '../core/providers/ui_state_provider.dart';
import '../core/utils/currency_formatter.dart';

class CategoryDetailSidePanel extends StatefulComponent {
  final AdminCategoryItem category;

  const CategoryDetailSidePanel({
    required this.category,
    super.key,
  });

  static void show(BuildContext context, AdminCategoryItem category) {
    context.showSidePanel(
      CategoryDetailSidePanel(category: category),
      title: 'Service Category Details',
    );
  }

  @override
  State<CategoryDetailSidePanel> createState() => _CategoryDetailSidePanelState();
}

class _CategoryDetailSidePanelState extends State<CategoryDetailSidePanel> {
  late String _name;
  late String _description;
  late String _imageUrl;
  late String _defaultBasePrice;
  late String _defaultDurationMin;
  late String _perKmRate;
  late String _perMinuteRate;
  late bool _isActive;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initFields(component.category);
  }

  void _initFields(AdminCategoryItem c) {
    _name = c.name ?? '';
    _description = c.description ?? '';
    _imageUrl = c.imageUrl ?? '';
    _defaultBasePrice = c.defaultBasePrice?.toString() ?? '0';
    _defaultDurationMin = c.defaultDurationMin?.toString() ?? '60';
    _perKmRate = c.perKmRate?.toString() ?? '150';
    _perMinuteRate = c.perMinuteRate?.toString() ?? '20';
    _isActive = c.isActive ?? true;
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
    return '$month ${local.day}, ${local.year} at $hour:$minute';
  }

  void _handleSave(BuildContext context, String categoryId) {
    if (_name.trim().isEmpty) {
      context.showFlushbar(
        title: 'Validation Error',
        message: 'Category name cannot be empty',
        type: FlushbarType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final request = UpdateCategoryRequest(
      name: _name.trim(),
      description: _description.trim().isEmpty ? null : _description.trim(),
      imageUrl: _imageUrl.trim().isEmpty ? null : _imageUrl.trim(),
      defaultBasePrice: double.tryParse(_defaultBasePrice.trim()),
      defaultDurationMin: int.tryParse(_defaultDurationMin.trim()),
      perKmRate: double.tryParse(_perKmRate.trim()),
      perMinuteRate: double.tryParse(_perMinuteRate.trim()),
      isActive: _isActive,
    );

    context.read(adminServiceManagerNotifierProvider.notifier).updateCategory(
      categoryId,
      request,
      onSuccess: (msg) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        context.showFlushbar(
          title: 'Category Updated',
          message: msg,
          type: FlushbarType.success,
        );
        context.invalidate(adminCategoryDetailProvider(categoryId));
        context.invalidate(adminCategoriesProvider(const ListCategoriesParams()));
        context.invalidate(adminServicesProvider(const ListServicesParams()));
      },
      onError: (msg) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        context.showFlushbar(
          title: 'Update Failed',
          message: msg,
          type: FlushbarType.error,
        );
      },
    );
  }

  void _handleQuickToggleStatus(BuildContext context, String categoryId) {
    final nextStatus = !_isActive;
    setState(() {
      _isActive = nextStatus;
    });
    _handleSave(context, categoryId);
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;
    final categoryId = component.category.id ?? '';

    final detailAsync = categoryId.isNotEmpty
        ? context.watch(adminCategoryDetailProvider(categoryId))
        : null;
    final category = detailAsync?.asData?.value ?? component.category;

    return div(classes: 'space-y-6 text-xs pb-8 relative', [
      // ─────────────────────────────────────────────────────────────
      // Hero Profile Card
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
            div(classes: 'flex items-center space-x-3.5 min-w-0 flex-1', [
              // Category Banner / Image
              div(classes: 'relative shrink-0', [
                if (_imageUrl.isNotEmpty)
                  img(
                    src: _imageUrl,
                    classes:
                        'w-14 h-14 rounded-2xl object-cover border-2 shadow-md shrink-0',
                    styles: Styles(raw: {'border-color': 'rgba(16, 185, 129, 0.4)'}),
                    alt: category.name ?? 'Category',
                  )
                else
                  div(
                    classes:
                        'w-14 h-14 rounded-2xl border-2 shadow-md shrink-0 flex items-center justify-center text-teal-500',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.surface),
                      raw: {'border-color': 'rgba(16, 185, 129, 0.3)'},
                    ),
                    [const AppIcon(AppIcons.salesTag)],
                  ),
                div(
                  classes:
                      'w-3.5 h-3.5 rounded-full ring-4 absolute -bottom-1 -right-1 shadow-sm',
                  styles: _isActive
                      ? Styles(
                          backgroundColor: Color.rgba(52, 211, 153, 1.0),
                          raw: {'ring-color': colorScheme.surface},
                        )
                      : Styles(
                          backgroundColor: Color.rgba(244, 63, 94, 1.0),
                          raw: {'ring-color': colorScheme.surface},
                        ),
                  [],
                ),
              ]),
              div(classes: 'space-y-1 min-w-0 flex-1', [
                h4(
                  classes: 'font-black text-base truncate tracking-tight',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text(category.name ?? 'Category Details')],
                ),
                div(
                  classes: 'flex items-center space-x-2 text-xs font-mono',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  [
                    span(classes: 'font-medium truncate', [
                      Component.text(category.description ?? 'No description provided'),
                    ]),
                  ],
                ),
              ]),
            ]),
          ]),

          // Badges & Copy ID Action Row
          div(
            classes:
                'flex flex-wrap items-center justify-between gap-2.5 pt-3.5 border-t',
            styles: Styles(raw: {'border-color': colorScheme.border}),
            [
              div(classes: 'flex items-center space-x-2', [
                // Active Status Badge
                span(
                  classes:
                      'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border',
                  styles: _isActive
                      ? Styles(
                          backgroundColor: isDark
                              ? Color.rgba(16, 185, 129, 0.18)
                              : Color.rgba(16, 185, 129, 0.1),
                          color: isDark
                              ? Color.rgba(110, 231, 183, 1.0)
                              : Color.rgba(4, 120, 87, 1.0),
                          raw: {
                            'border-color': isDark
                                ? 'rgba(16, 185, 129, 0.4)'
                                : 'rgba(16, 185, 129, 0.25)'
                          },
                        )
                      : Styles(
                          backgroundColor: isDark
                              ? Color.rgba(244, 63, 94, 0.18)
                              : Color.rgba(244, 63, 94, 0.1),
                          color: isDark
                              ? Color.rgba(253, 164, 175, 1.0)
                              : Color.rgba(190, 18, 60, 1.0),
                          raw: {
                            'border-color': isDark
                                ? 'rgba(244, 63, 94, 0.4)'
                                : 'rgba(244, 63, 94, 0.25)'
                          },
                        ),
                  [
                    Component.text(_isActive ? '● Active' : '○ Inactive'),
                  ],
                ),
              ]),

              div(classes: 'flex items-center space-x-2', [
                button(
                  type: ButtonType.button,
                  classes:
                      'px-3 py-1.5 rounded-xl text-[11px] font-bold transition-all cursor-pointer flex items-center space-x-1.5 active:scale-95 shadow-sm border',
                  styles: Styles(
                    backgroundColor: isDark
                        ? Color.rgba(16, 185, 129, 0.15)
                        : Color.rgba(16, 185, 129, 0.08),
                    color: isDark
                        ? Color.rgba(110, 231, 183, 1.0)
                        : Color.rgba(4, 120, 87, 1.0),
                    raw: {
                      'border-color': isDark
                          ? 'rgba(16, 185, 129, 0.35)'
                          : 'rgba(16, 185, 129, 0.25)'
                    },
                  ),
                  events: {
                    'click': (_) =>
                        _copyToClipboard(context, categoryId, 'Category ID'),
                  },
                  [
                    div(
                      classes: 'w-3.5 h-3.5 shrink-0',
                      styles: Styles(color: Color(colorScheme.primary)),
                      [const AppIcon(AppIcons.copy)],
                    ),
                    span([Component.text('Copy ID')]),
                  ],
                ),
              ]),
            ],
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // Edit Form Section
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-4', [
        _buildSectionHeader('Edit Category Details', AppIcons.editPen, context),
        div(
          classes: 'p-5 rounded-2xl border space-y-4 shadow-sm',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            // Category Name Field
            div(classes: 'space-y-1.5', [
              label(
                classes: 'block text-xs font-bold',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('Category Name')],
              ),
              input(
                type: InputType.text,
                value: _name,
                classes:
                    'w-full border rounded-xl px-3.5 py-2.5 text-xs font-semibold focus:outline-none focus:ring-2 transition-all',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  color: Color(colorScheme.textPrimary),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                attributes: {'placeholder': 'e.g. Home Repairs'},
                onInput: (val) => setState(() => _name = val.toString()),
              ),
            ]),

            // Category Description Field
            div(classes: 'space-y-1.5', [
              label(
                classes: 'block text-xs font-bold',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('Description')],
              ),
              textarea(
                classes:
                    'w-full border rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:ring-2 transition-all resize-none min-h-[90px]',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  color: Color(colorScheme.textPrimary),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                attributes: {'placeholder': 'Brief description of this service category...'},
                onInput: (val) => setState(() => _description = val.toString()),
                [Component.text(_description)],
              ),
            ]),

            // Grid for Category Defaults
            div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-3', [
              div(classes: 'space-y-1.5', [
                label(
                  classes: 'block text-xs font-bold',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text('Default Base Price')],
                ),
                input(
                  type: InputType.number,
                  value: _defaultBasePrice,
                  classes:
                      'w-full border rounded-xl px-3.5 py-2.5 text-xs font-semibold focus:outline-none focus:ring-2 transition-all',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.textPrimary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  attributes: {'placeholder': '0.00', 'step': '0.01', 'min': '0'},
                  onInput: (val) => setState(() => _defaultBasePrice = val.toString()),
                ),
              ]),
              div(classes: 'space-y-1.5', [
                label(
                  classes: 'block text-xs font-bold',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text('Default Duration (Mins)')],
                ),
                input(
                  type: InputType.number,
                  value: _defaultDurationMin,
                  classes:
                      'w-full border rounded-xl px-3.5 py-2.5 text-xs font-semibold focus:outline-none focus:ring-2 transition-all',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.textPrimary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  attributes: {'placeholder': '60', 'step': '1', 'min': '0'},
                  onInput: (val) => setState(() => _defaultDurationMin = val.toString()),
                ),
              ]),
            ]),

            // Grid for Rates
            div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-3', [
              div(classes: 'space-y-1.5', [
                label(
                  classes: 'block text-xs font-bold',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text('Per KM Rate')],
                ),
                input(
                  type: InputType.number,
                  value: _perKmRate,
                  classes:
                      'w-full border rounded-xl px-3.5 py-2.5 text-xs font-semibold focus:outline-none focus:ring-2 transition-all',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.textPrimary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  attributes: {'placeholder': '150', 'step': '1', 'min': '0'},
                  onInput: (val) => setState(() => _perKmRate = val.toString()),
                ),
              ]),
              div(classes: 'space-y-1.5', [
                label(
                  classes: 'block text-xs font-bold',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text('Per Minute Rate')],
                ),
                input(
                  type: InputType.number,
                  value: _perMinuteRate,
                  classes:
                      'w-full border rounded-xl px-3.5 py-2.5 text-xs font-semibold focus:outline-none focus:ring-2 transition-all',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.textPrimary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  attributes: {'placeholder': '20', 'step': '1', 'min': '0'},
                  onInput: (val) => setState(() => _perMinuteRate = val.toString()),
                ),
              ]),
            ]),

            // Image URL Field
            div(classes: 'space-y-1.5', [
              label(
                classes: 'block text-xs font-bold',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('Image / Banner URL')],
              ),
              input(
                type: InputType.text,
                value: _imageUrl,
                classes:
                    'w-full border rounded-xl px-3.5 py-2.5 text-xs font-semibold focus:outline-none focus:ring-2 transition-all font-mono text-[11px]',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  color: Color(colorScheme.textPrimary),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                attributes: {'placeholder': 'https://example.com/category-image.png'},
                onInput: (val) => setState(() => _imageUrl = val.toString()),
              ),
            ]),

            // Active Status Checkbox / Toggle
            div(
              classes: 'flex items-center justify-between pt-2 border-t',
              styles: Styles(raw: {'border-color': colorScheme.border}),
              [
                div(classes: 'space-y-0.5', [
                  span(
                    classes: 'block text-xs font-bold',
                    styles: Styles(color: Color(colorScheme.textHeading)),
                    [Component.text('Category Active Status')],
                  ),
                  span(
                    classes: 'block text-[11px]',
                    styles: Styles(color: Color(colorScheme.textMuted)),
                    [Component.text('Active categories can have services listed under them')],
                  ),
                ]),
                button(
                  type: ButtonType.button,
                  onClick: () => setState(() => _isActive = !_isActive),
                  classes:
                      'px-3 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer border shadow-xs',
                  styles: _isActive
                      ? Styles(
                          backgroundColor: Color.rgba(16, 185, 129, 0.15),
                          color: Color.rgba(4, 120, 87, 1.0),
                          raw: {'border-color': 'rgba(16, 185, 129, 0.4)'},
                        )
                      : Styles(
                          backgroundColor: Color.rgba(244, 63, 94, 0.15),
                          color: Color.rgba(190, 18, 60, 1.0),
                          raw: {'border-color': 'rgba(244, 63, 94, 0.4)'},
                        ),
                  [
                    Component.text(_isActive ? '● Active' : '○ Inactive'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Category Metadata Section
      // ─────────────────────────────────────────────────────────────
      div(classes: 'space-y-3', [
        _buildSectionHeader('System Information', AppIcons.infoCircle, context),
        div(
          classes: 'divide-y border rounded-2xl overflow-hidden shadow-sm',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            _buildMetaRow('Category ID', category.id ?? 'N/A', context, copyable: true),
            _buildMetaRow('Default Base Price', (category.defaultBasePrice ?? 0).toNaira(), context),
            _buildMetaRow('Default Duration', '${category.defaultDurationMin ?? 60} mins', context),
            _buildMetaRow('Per KM Rate', (category.perKmRate ?? 0).toNaira(), context),
            _buildMetaRow('Per Minute Rate', (category.perMinuteRate ?? 0).toNaira(), context),
            _buildMetaRow('Created At', _formatDateTime(category.createdAt), context),
            _buildMetaRow('Updated At', _formatDateTime(category.updatedAt), context),
          ],
        ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Bottom Sticky Action Footer
      // ─────────────────────────────────────────────────────────────
      div(
        classes:
            'pt-4 border-t flex items-center justify-between gap-3 sticky bottom-0 z-10 p-2 rounded-2xl shadow-lg backdrop-blur-md',
        styles: Styles(
          backgroundColor: Color(colorScheme.surface),
          raw: {'border-color': colorScheme.border},
        ),
        [
          button(
            type: ButtonType.button,
            onClick: () => _handleQuickToggleStatus(context, categoryId),
            disabled: _isSubmitting,
            classes:
                'px-4 py-2.5 rounded-xl text-xs font-bold border transition-all cursor-pointer shadow-sm hover:opacity-80 active:scale-95 disabled:opacity-50',
            styles: _isActive
                ? Styles(
                    backgroundColor: isDark
                        ? Color.rgba(244, 63, 94, 0.15)
                        : Color.rgba(244, 63, 94, 0.08),
                    color: isDark
                        ? Color.rgba(253, 164, 175, 1.0)
                        : Color.rgba(190, 18, 60, 1.0),
                    raw: {'border-color': 'rgba(244, 63, 94, 0.3)'},
                  )
                : Styles(
                    backgroundColor: isDark
                        ? Color.rgba(16, 185, 129, 0.15)
                        : Color.rgba(16, 185, 129, 0.08),
                    color: isDark
                        ? Color.rgba(110, 231, 183, 1.0)
                        : Color.rgba(4, 120, 87, 1.0),
                    raw: {'border-color': 'rgba(16, 185, 129, 0.3)'},
                  ),
            [
              Component.text(_isActive ? 'Deactivate Category' : 'Reactivate Category'),
            ],
          ),

          button(
            type: ButtonType.button,
            onClick: () => _handleSave(context, categoryId),
            disabled: _isSubmitting,
            classes:
                'px-5 py-2.5 rounded-xl text-xs font-bold text-white transition-all cursor-pointer shadow-md hover:opacity-90 active:scale-95 flex items-center space-x-2 disabled:opacity-50',
            styles: Styles(
              backgroundColor: Color(colorScheme.primary),
            ),
            [
              if (_isSubmitting)
                div(
                  classes:
                      'w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin',
                  [],
                )
              else
                const AppIcon(AppIcons.checkCircle),
              span([Component.text(_isSubmitting ? 'Saving...' : 'Save Changes')]),
            ],
          ),
        ],
      ),
    ]);
  }

  Component _buildSectionHeader(String title, AppIcons icon, BuildContext context) {
    final colorScheme = context.colorScheme;
    return div(classes: 'flex items-center space-x-2 px-1', [
      div(
        classes: 'w-4 h-4',
        styles: Styles(color: Color(colorScheme.primary)),
        [AppIcon(icon)],
      ),
      h4(
        classes: 'font-extrabold text-xs uppercase tracking-wider',
        styles: Styles(color: Color(colorScheme.textHeading)),
        [Component.text(title)],
      ),
    ]);
  }

  Component _buildMetaRow(String label, String value, BuildContext context,
      {bool copyable = false}) {
    final colorScheme = context.colorScheme;
    return div(
      classes: 'p-3 flex items-center justify-between gap-3 text-xs',
      [
        span(
          classes: 'font-medium shrink-0',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text(label)],
        ),
        div(classes: 'flex items-center space-x-1.5 min-w-0 text-right', [
          span(
            classes: copyable
                ? 'font-mono text-[11px] font-semibold truncate'
                : 'font-semibold truncate',
            styles: Styles(color: Color(colorScheme.textPrimary)),
            [Component.text(value)],
          ),
          if (copyable && value != 'N/A' && value.isNotEmpty)
            button(
              type: ButtonType.button,
              classes:
                  'p-1 rounded-md hover:bg-black/5 dark:hover:bg-white/10 transition-colors cursor-pointer shrink-0',
              events: {'click': (_) => _copyToClipboard(context, value, label)},
              [
                div(
                  classes: 'w-3 h-3',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  [const AppIcon(AppIcons.copy)],
                ),
              ],
            ),
        ]),
      ],
    );
  }
}
