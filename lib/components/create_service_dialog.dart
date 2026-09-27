import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/services/admin_category_item.dart';
import '../core/models/clients/services/create_service_request.dart';
import '../core/providers/admin_service_manager_providers.dart';
import '../core/providers/ui_state_provider.dart';

class CreateServiceDialog extends StatefulComponent {
  const CreateServiceDialog({super.key});

  static void show(BuildContext context) {
    context.showDialog(
      const CreateServiceDialog(),
      title: 'Create New Service Offering',
    );
  }

  @override
  State<CreateServiceDialog> createState() => _CreateServiceDialogState();
}

class _CreateServiceDialogState extends State<CreateServiceDialog> {
  String _name = '';
  String _categoryId = '';
  String _basePrice = '0';
  String _defaultDurationMin = '60';
  String _perKmRate = '150';
  String _perMinuteRate = '20';
  String _takeRate = '15.0';
  String _minTierRequired = '4';
  bool _isHighRisk = false;
  bool _isActive = true;
  String _imageUrl = '';

  bool _isSubmitting = false;
  String? _errorMessage;

  void _handleSubmit(BuildContext context) {
    if (_name.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid service name.';
      });
      return;
    }

    final parsedTakeRate = double.tryParse(_takeRate.trim());
    if (parsedTakeRate == null || parsedTakeRate < 0 || parsedTakeRate > 100) {
      setState(() {
        _errorMessage = 'Please enter a valid take rate percentage (0 - 100).';
      });
      return;
    }

    final takeRatePayload = (parsedTakeRate > 1.0) ? parsedTakeRate / 100 : parsedTakeRate;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final request = CreateServiceRequest(
      name: _name.trim(),
      categoryId: _categoryId.trim().isEmpty ? null : _categoryId.trim(),
      imageUrl: _imageUrl.trim().isEmpty ? null : _imageUrl.trim(),
      basePrice: double.tryParse(_basePrice.trim()) ?? 0,
      defaultDurationMin: int.tryParse(_defaultDurationMin.trim()) ?? 60,
      perKmRate: double.tryParse(_perKmRate.trim()) ?? 150,
      perMinuteRate: double.tryParse(_perMinuteRate.trim()) ?? 20,
      takeRate: takeRatePayload,
      minTierRequired: int.tryParse(_minTierRequired.trim()) ?? 4,
      isHighRisk: _isHighRisk,
      isActive: _isActive,
    );

    context.read(adminServiceManagerNotifierProvider.notifier).createService(
      request,
      onSuccess: (message) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        context.showFlushbar(
          title: 'Service Created',
          message: message,
          type: FlushbarType.success,
        );
        context.invalidate(adminServicesProvider(const ListServicesParams()));
        context.hideDialog();
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _errorMessage = message;
        });
      },
    );
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final categoriesAsync = context.watch(
      adminCategoriesProvider(const ListCategoriesParams(perPage: 100)),
    );
    final categoriesList = categoriesAsync.when(
      data: (data) => data?.items ?? <AdminCategoryItem>[],
      loading: () => <AdminCategoryItem>[],
      error: (_, __) => <AdminCategoryItem>[],
    );

    return div(classes: 'space-y-4 text-xs max-w-xl w-full max-h-[80vh] overflow-y-auto pr-1', [
      // Error Banner
      if (_errorMessage != null)
        div(
          classes:
              'p-3 rounded-xl border flex items-center space-x-2 text-xs font-semibold animate-shake',
          styles: Styles(
            backgroundColor: Color.rgba(244, 63, 94, 0.1),
            color: Color.rgba(225, 29, 72, 1.0),
            raw: {'border-color': 'rgba(244, 63, 94, 0.3)'},
          ),
          [
            const AppIcon(AppIcons.infoCircle),
            span([Component.text(_errorMessage!)]),
          ],
        ),

      // Service Name Field
      div(classes: 'space-y-1.5', [
        label(
          classes: 'block text-xs font-bold uppercase tracking-wider',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Service Name *')],
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
          attributes: {'placeholder': 'e.g. Electrical Wiring & Fitting'},
          onInput: (val) => setState(() {
            _name = val.toString();
            _errorMessage = null;
          }),
        ),
      ]),

      // Category Select Field
      div(classes: 'space-y-1.5', [
        label(
          classes: 'block text-xs font-bold uppercase tracking-wider',
          styles: Styles(color: Color(colorScheme.textMuted)),
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
            setState(() {
              _categoryId = catId?.trim() ?? '';
              _errorMessage = null;
            });
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
              Component.text('Select a category (Optional)'),
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

      // Grid for Pricing & Duration
      div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-3', [
        // Base Price Field
        div(classes: 'space-y-1.5', [
          label(
            classes: 'block text-xs font-bold uppercase tracking-wider',
            styles: Styles(color: Color(colorScheme.textMuted)),
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

        // Default Duration Min
        div(classes: 'space-y-1.5', [
          label(
            classes: 'block text-xs font-bold uppercase tracking-wider',
            styles: Styles(color: Color(colorScheme.textMuted)),
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
        // Per KM Rate Field
        div(classes: 'space-y-1.5', [
          label(
            classes: 'block text-xs font-bold uppercase tracking-wider',
            styles: Styles(color: Color(colorScheme.textMuted)),
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

        // Per Minute Rate Field
        div(classes: 'space-y-1.5', [
          label(
            classes: 'block text-xs font-bold uppercase tracking-wider',
            styles: Styles(color: Color(colorScheme.textMuted)),
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

      // Grid for Take Rate & Min Tier
      div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-3', [
        // Take Rate (%) Field
        div(classes: 'space-y-1.5', [
          label(
            classes: 'block text-xs font-bold uppercase tracking-wider',
            styles: Styles(color: Color(colorScheme.textMuted)),
            [Component.text('Take Rate (%) *')],
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
            attributes: {
              'placeholder': '15.0',
              'step': '0.5',
              'min': '0',
              'max': '100',
            },
            onInput: (val) => setState(() {
              _takeRate = val.toString();
              _errorMessage = null;
            }),
          ),
        ]),

        // Min Tier Required Field
        div(classes: 'space-y-1.5', [
          label(
            classes: 'block text-xs font-bold uppercase tracking-wider',
            styles: Styles(color: Color(colorScheme.textMuted)),
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
          classes: 'block text-xs font-bold uppercase tracking-wider',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Image URL (Optional)')],
        ),
        input(
          type: InputType.text,
          value: _imageUrl,
          classes:
              'w-full border rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:ring-2 transition-all font-mono text-[11px]',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textPrimary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          attributes: {'placeholder': 'https://example.com/icon.png'},
          onInput: (val) => setState(() => _imageUrl = val.toString()),
        ),
      ]),

      // Toggles Section
      div(classes: 'space-y-3 pt-2 border-t',
        styles: Styles(raw: {'border-color': colorScheme.border}),
        [
          // High Risk Toggle
          div(
            classes: 'flex items-center justify-between',
            [
              div(classes: 'space-y-0.5', [
                span(
                  classes: 'block text-xs font-bold',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text('High Risk Service')],
                ),
                span(
                  classes: 'block text-[11px]',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  [Component.text('Requires additional provider vetting & verification')],
                ),
              ]),
              button(
                type: ButtonType.button,
                onClick: () => setState(() => _isHighRisk = !_isHighRisk),
                classes:
                    'px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer border shadow-xs',
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
            ],
          ),

          // Active Status Toggle
          div(
            classes: 'flex items-center justify-between',
            [
              div(classes: 'space-y-0.5', [
                span(
                  classes: 'block text-xs font-bold',
                  styles: Styles(color: Color(colorScheme.textHeading)),
                  [Component.text('Active Service Status')],
                ),
                span(
                  classes: 'block text-[11px]',
                  styles: Styles(color: Color(colorScheme.textMuted)),
                  [Component.text('Visible in provider catalog')],
                ),
              ]),
              button(
                type: ButtonType.button,
                onClick: () => setState(() => _isActive = !_isActive),
                classes:
                    'px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer border shadow-xs',
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

      // Dialog Actions
      div(classes: 'flex items-center justify-end space-x-3 pt-4 border-t',
        styles: Styles(raw: {'border-color': colorScheme.border}),
        [
          button(
            type: ButtonType.button,
            onClick: () => context.hideDialog(),
            classes:
                'px-4 py-2.5 rounded-xl border text-xs font-bold transition-all cursor-pointer hover:opacity-80',
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
                'px-5 py-2.5 rounded-xl text-white text-xs font-bold shadow-md transition-all cursor-pointer border-none flex items-center space-x-2 ${_isSubmitting ? 'opacity-60 cursor-not-allowed' : 'hover:opacity-95 active:scale-95'}',
            styles: Styles(backgroundColor: Color(colorScheme.primary)),
            [
              if (_isSubmitting)
                div(
                  classes:
                      'w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin',
                  [],
                )
              else
                const AppIcon(AppIcons.plus),
              span([Component.text(_isSubmitting ? 'Creating...' : 'Create Service')]),
            ],
          ),
        ],
      ),
    ]);
  }
}
