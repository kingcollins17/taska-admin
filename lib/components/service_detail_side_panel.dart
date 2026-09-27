import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/web.dart' as web;

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/services/admin_category_item.dart';
import '../core/models/clients/services/admin_service_item.dart';
import '../core/models/clients/services/update_service_request.dart';
import '../core/providers/admin_service_manager_providers.dart';
import '../core/providers/ui_state_provider.dart';
import '../core/utils/currency_formatter.dart';

class ServiceDetailSidePanel extends StatefulComponent {
  final AdminServiceItem service;

  const ServiceDetailSidePanel({
    required this.service,
    super.key,
  });

  static void show(BuildContext context, AdminServiceItem service) {
    context.showSidePanel(
      ServiceDetailSidePanel(service: service),
      title: 'Service Offering Details',
    );
  }

  @override
  State<ServiceDetailSidePanel> createState() => _ServiceDetailSidePanelState();
}

class _ServiceDetailSidePanelState extends State<ServiceDetailSidePanel> {
  late String _name;
  late String _categoryId;
  late String _basePrice;
  late String _defaultDurationMin;
  late String _perKmRate;
  late String _perMinuteRate;
  late String _takeRate;
  late String _minTierRequired;
  late bool _isHighRisk;
  late bool _isActive;
  late String _imageUrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initFields(component.service);
  }

  void _initFields(AdminServiceItem s) {
    _name = s.name ?? '';
    _categoryId = s.categoryId ?? '';
    _basePrice = s.basePrice?.toString() ?? '0';
    _defaultDurationMin = s.defaultDurationMin?.toString() ?? '60';
    _perKmRate = s.perKmRate?.toString() ?? '150';
    _perMinuteRate = s.perMinuteRate?.toString() ?? '20';
    final double raw = s.takeRate?.toDouble() ?? 0;
    final double pct = (raw > 0 && raw <= 1.0) ? raw * 100 : raw;
    _takeRate = pct % 1 == 0 ? pct.toInt().toString() : pct.toString();
    _minTierRequired = s.minTierRequired?.toString() ?? '4';
    _isHighRisk = s.isHighRisk ?? false;
    _imageUrl = s.imageUrl ?? '';
    _isActive = s.isActive ?? true;
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

  String _formattedTakeRate(num? rate) {
    if (rate == null) return '0%';
    final double val = rate.toDouble();
    final double percentage = (val > 0 && val <= 1.0) ? val * 100 : val;
    final formatted = percentage % 1 == 0 ? percentage.toInt().toString() : percentage.toStringAsFixed(1);
    return '$formatted%';
  }

  void _handleSave(BuildContext context, String serviceId) {
    if (_name.trim().isEmpty) {
      context.showFlushbar(
        title: 'Validation Error',
        message: 'Service name cannot be empty',
        type: FlushbarType.warning,
      );
      return;
    }

    final parsedTakeRate = double.tryParse(_takeRate.trim());
    if (parsedTakeRate == null || parsedTakeRate < 0 || parsedTakeRate > 100) {
      context.showFlushbar(
        title: 'Validation Error',
        message: 'Please enter a valid take rate percentage (0 - 100)',
        type: FlushbarType.warning,
      );
      return;
    }

    final takeRatePayload = (parsedTakeRate > 1.0) ? parsedTakeRate / 100 : parsedTakeRate;

    setState(() => _isSubmitting = true);

    final request = UpdateServiceRequest(
      name: _name.trim(),
      categoryId: _categoryId.trim().isEmpty ? null : _categoryId.trim(),
      imageUrl: _imageUrl.trim().isEmpty ? null : _imageUrl.trim(),
      basePrice: double.tryParse(_basePrice.trim()),
      defaultDurationMin: int.tryParse(_defaultDurationMin.trim()),
      perKmRate: double.tryParse(_perKmRate.trim()),
      perMinuteRate: double.tryParse(_perMinuteRate.trim()),
      takeRate: takeRatePayload,
      minTierRequired: int.tryParse(_minTierRequired.trim()),
      isHighRisk: _isHighRisk,
      isActive: _isActive,
    );

    context.read(adminServiceManagerNotifierProvider.notifier).updateService(
      serviceId,
      request,
      onSuccess: (msg) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        context.showFlushbar(
          title: 'Service Updated',
          message: msg,
          type: FlushbarType.success,
        );
        context.invalidate(adminServiceDetailProvider(serviceId));
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

  void _handleQuickToggleStatus(BuildContext context, String serviceId) {
    final nextStatus = !_isActive;
    setState(() {
      _isActive = nextStatus;
    });
    _handleSave(context, serviceId);
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.isDark;
    final serviceId = component.service.id ?? '';

    final detailAsync = serviceId.isNotEmpty
        ? context.watch(adminServiceDetailProvider(serviceId))
        : null;
    final service = detailAsync?.asData?.value ?? component.service;

    final categoriesAsync = context.watch(
      adminCategoriesProvider(const ListCategoriesParams(perPage: 100)),
    );
    final categoriesList = categoriesAsync.when(
      data: (data) => data?.items ?? <AdminCategoryItem>[],
      loading: () => <AdminCategoryItem>[],
      error: (_, __) => <AdminCategoryItem>[],
    );

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
                'absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-teal-500 via-emerald-400 to-indigo-500',
            [],
          ),
          div(classes: 'flex items-start justify-between gap-3 pt-1', [
            div(classes: 'flex items-center space-x-3.5 min-w-0 flex-1', [
              // Image / Icon
              div(classes: 'relative shrink-0', [
                if (_imageUrl.isNotEmpty)
                  img(
                    src: _imageUrl,
                    classes:
                        'w-14 h-14 rounded-2xl object-cover border-2 shadow-md shrink-0',
                    styles: Styles(raw: {'border-color': 'rgba(16, 185, 129, 0.4)'}),
                    alt: service.name ?? 'Service',
                  )
                else
                  div(
                    classes:
                        'w-14 h-14 rounded-2xl border-2 shadow-md shrink-0 flex items-center justify-center text-teal-500',
                    styles: Styles(
                      backgroundColor: Color(colorScheme.surface),
                      raw: {'border-color': 'rgba(16, 185, 129, 0.3)'},
                    ),
                    [const AppIcon(AppIcons.services)],
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
                  [Component.text(service.name ?? 'Service Offering')],
                ),
                div(
                  classes: 'flex items-center space-x-2 text-xs font-mono',
                  styles: Styles(color: Color(colorScheme.textSecondary)),
                  [
                    span(classes: 'font-medium', [
                      Component.text(service.category?.name ?? 'Category #${service.categoryId ?? 'N/A'}'),
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
              div(classes: 'flex flex-wrap items-center gap-2', [
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

                // High Risk Badge
                if (_isHighRisk)
                  span(
                    classes:
                        'px-2.5 py-1 rounded-lg text-[10.5px] font-black tracking-wider uppercase border',
                    styles: Styles(
                      backgroundColor: Color.rgba(244, 63, 94, 0.15),
                      color: Color.rgba(190, 18, 60, 1.0),
                      raw: {'border-color': 'rgba(244, 63, 94, 0.4)'},
                    ),
                    [Component.text('⚡ High Risk')],
                  ),

                // Take Rate Chip
                span(
                  classes:
                      'px-2.5 py-1 rounded-lg text-[10.5px] font-bold tracking-wider uppercase border',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.surface),
                    color: Color(colorScheme.primary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  [
                    Component.text('${_formattedTakeRate(service.takeRate)} Take Rate'),
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
                        _copyToClipboard(context, serviceId, 'Service ID'),
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
        _buildSectionHeader('Edit Service Offering', AppIcons.editPen, context),
        div(
          classes: 'p-5 rounded-2xl border space-y-4 shadow-sm',
          styles: Styles(
            backgroundColor: Color(colorScheme.surface),
            raw: {'border-color': colorScheme.border},
          ),
          [
            // Service Name Field
            div(classes: 'space-y-1.5', [
              label(
                classes: 'block text-xs font-bold',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('Service Name')],
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
                attributes: {'placeholder': 'e.g. Plumbing Repair'},
                onInput: (val) => setState(() => _name = val.toString()),
              ),
            ]),

            // Category Selection Dropdown
            div(classes: 'space-y-1.5', [
              label(
                classes: 'block text-xs font-bold',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('Category')],
              ),
              select(
                onChange: (val) {
                  String? catId;
                  final dynamic listVal = val;
                  if (listVal is List && listVal.isNotEmpty) {
                    catId = listVal.first.toString();
                  } else if (listVal != null) {
                    catId = listVal.toString();
                  }
                  if (catId != null && catId.startsWith('[') && catId.endsWith(']')) {
                    catId = catId.substring(1, catId.length - 1);
                  }
                  setState(() => _categoryId = catId?.trim() ?? '');
                },
                classes:
                    'w-full border rounded-xl px-3.5 py-2.5 text-xs font-semibold focus:outline-none focus:ring-2 transition-all cursor-pointer',
                styles: Styles(
                  backgroundColor: Color(colorScheme.inputBg),
                  color: Color(colorScheme.textPrimary),
                  raw: {'border-color': colorScheme.borderInput},
                ),
                [
                  option(value: '', selected: _categoryId.isEmpty, [
                    Component.text('Select a category'),
                  ]),
                  for (final cat in categoriesList)
                    option(
                      value: cat.id ?? '',
                      selected: _categoryId == cat.id,
                      [
                        Component.text(cat.name ?? 'Category #${cat.id}'),
                      ],
                    ),
                ],
              ),
            ]),

            // Pricing & Duration Fields
            div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-3', [
              div(classes: 'space-y-1.5', [
                label(
                  classes: 'block text-xs font-bold',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text('Base Price')],
                ),
                input(
                  type: InputType.number,
                  value: _basePrice,
                  classes:
                      'w-full border rounded-xl px-3.5 py-2.5 text-xs font-semibold focus:outline-none focus:ring-2 transition-all',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.textPrimary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  attributes: {'placeholder': '0.00', 'step': '0.01', 'min': '0'},
                  onInput: (val) => setState(() => _basePrice = val.toString()),
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

            // Rates Fields
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

            // Take Rate & Min Tier
            div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-3', [
              div(classes: 'space-y-1.5', [
                label(
                  classes: 'block text-xs font-bold',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text('Take Rate (%)')],
                ),
                input(
                  type: InputType.number,
                  value: _takeRate,
                  classes:
                      'w-full border rounded-xl px-3.5 py-2.5 text-xs font-semibold focus:outline-none focus:ring-2 transition-all',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.textPrimary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  attributes: {'placeholder': 'e.g. 15.0', 'step': '0.1', 'min': '0', 'max': '100'},
                  onInput: (val) => setState(() => _takeRate = val.toString()),
                ),
              ]),
              div(classes: 'space-y-1.5', [
                label(
                  classes: 'block text-xs font-bold',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text('Min Tier Required')],
                ),
                input(
                  type: InputType.number,
                  value: _minTierRequired,
                  classes:
                      'w-full border rounded-xl px-3.5 py-2.5 text-xs font-semibold focus:outline-none focus:ring-2 transition-all',
                  styles: Styles(
                    backgroundColor: Color(colorScheme.inputBg),
                    color: Color(colorScheme.textPrimary),
                    raw: {'border-color': colorScheme.borderInput},
                  ),
                  attributes: {'placeholder': '4', 'step': '1', 'min': '0'},
                  onInput: (val) => setState(() => _minTierRequired = val.toString()),
                ),
              ]),
            ]),

            // Image URL Field
            div(classes: 'space-y-1.5', [
              label(
                classes: 'block text-xs font-bold',
                styles: Styles(color: Color(colorScheme.textHeading)),
                [Component.text('Image URL')],
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
                attributes: {'placeholder': 'https://example.com/image.png'},
                onInput: (val) => setState(() => _imageUrl = val.toString()),
              ),
            ]),

            // Toggles
            div(classes: 'space-y-3 pt-2 border-t',
              styles: Styles(raw: {'border-color': colorScheme.border}),
              [
                // High Risk Toggle
                div(classes: 'flex items-center justify-between', [
                  div(classes: 'space-y-0.5', [
                    span(
                      classes: 'block text-xs font-bold',
                      styles: Styles(color: Color(colorScheme.textHeading)),
                      [Component.text('High Risk Service')],
                    ),
                    span(
                      classes: 'block text-[11px]',
                      styles: Styles(color: Color(colorScheme.textMuted)),
                      [Component.text('Requires additional provider vetting')],
                    ),
                  ]),
                  button(
                    type: ButtonType.button,
                    onClick: () => setState(() => _isHighRisk = !_isHighRisk),
                    classes:
                        'px-3 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer border shadow-xs',
                    styles: _isHighRisk
                        ? Styles(
                            backgroundColor: Color.rgba(244, 63, 94, 0.15),
                            color: Color.rgba(190, 18, 60, 1.0),
                            raw: {'border-color': 'rgba(244, 63, 94, 0.4)'},
                          )
                        : Styles(
                            backgroundColor: Color.rgba(100, 116, 139, 0.15),
                            color: Color(colorScheme.textSecondary),
                            raw: {'border-color': colorScheme.borderInput},
                          ),
                    [
                      Component.text(_isHighRisk ? '⚡ High Risk' : 'Standard'),
                    ],
                  ),
                ]),

                // Active Status Checkbox / Toggle
                div(classes: 'flex items-center justify-between', [
                  div(classes: 'space-y-0.5', [
                    span(
                      classes: 'block text-xs font-bold',
                      styles: Styles(color: Color(colorScheme.textHeading)),
                      [Component.text('Service Active Status')],
                    ),
                    span(
                      classes: 'block text-[11px]',
                      styles: Styles(color: Color(colorScheme.textMuted)),
                      [Component.text('Active services are visible to users & providers')],
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
                ]),
              ],
            ),
          ],
        ),
      ]),

      // ─────────────────────────────────────────────────────────────
      // Service Metadata Section
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
            _buildMetaRow('Service ID', service.id ?? 'N/A', context, copyable: true),
            _buildMetaRow('Category Name', service.category?.name ?? 'N/A', context),
            _buildMetaRow('Category ID', service.categoryId ?? 'N/A', context, copyable: true),
            _buildMetaRow('Base Price', (service.basePrice ?? 0).toNaira(), context),
            _buildMetaRow('Default Duration', '${service.defaultDurationMin ?? 60} mins', context),
            _buildMetaRow('Per KM Rate', (service.perKmRate ?? 0).toNaira(), context),
            _buildMetaRow('Per Minute Rate', (service.perMinuteRate ?? 0).toNaira(), context),
            _buildMetaRow('Take Rate', _formattedTakeRate(service.takeRate), context),
            _buildMetaRow('Min Tier Required', service.minTierRequired?.toString() ?? '4', context),
            _buildMetaRow('High Risk', service.isHighRisk == true ? 'Yes' : 'No', context),
            _buildMetaRow('Created At', _formatDateTime(service.createdAt), context),
            _buildMetaRow('Updated At', _formatDateTime(service.updatedAt), context),
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
            onClick: () => _handleQuickToggleStatus(context, serviceId),
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
              Component.text(_isActive ? 'Deactivate Service' : 'Reactivate Service'),
            ],
          ),

          button(
            type: ButtonType.button,
            onClick: () => _handleSave(context, serviceId),
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
