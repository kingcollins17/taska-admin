import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';
import '../core/providers/admin_service_manager_providers.dart';
import '../core/providers/ui_state_provider.dart';

class CreateCategoryDialog extends StatefulComponent {
  const CreateCategoryDialog({super.key});

  static void show(BuildContext context) {
    context.showDialog(
      const CreateCategoryDialog(),
      title: 'Create New Service Category',
    );
  }

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  String _name = '';
  String _description = '';
  String _imageUrl = '';
  bool _isActive = true;

  bool _isSubmitting = false;
  String? _errorMessage;

  void _handleSubmit(BuildContext context) {
    if (_name.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid category name.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final payload = <String, dynamic>{
      'name': _name.trim(),
      'description': _description.trim().isEmpty ? null : _description.trim(),
      'image_url': _imageUrl.trim().isEmpty ? null : _imageUrl.trim(),
      'is_active': _isActive,
    };

    context.read(adminServiceManagerNotifierProvider.notifier).createCategory(
      payload,
      onSuccess: (message) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        context.showFlushbar(
          title: 'Category Created',
          message: message,
          type: FlushbarType.success,
        );
        context.invalidate(adminCategoriesProvider(const ListCategoriesParams()));
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

    return div(classes: 'space-y-4 text-xs max-w-lg w-full', [
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

      // Category Name Field
      div(classes: 'space-y-1.5', [
        label(
          classes: 'block text-xs font-bold uppercase tracking-wider',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Category Name *')],
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
          attributes: {'placeholder': 'e.g. Home Cleaning & Care'},
          onInput: (val) => setState(() {
            _name = val.toString();
            _errorMessage = null;
          }),
        ),
      ]),

      // Description Field
      div(classes: 'space-y-1.5', [
        label(
          classes: 'block text-xs font-bold uppercase tracking-wider',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Description (Optional)')],
        ),
        textarea(
          classes:
              'w-full border rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:ring-2 transition-all resize-none min-h-[80px]',
          styles: Styles(
            backgroundColor: Color(colorScheme.inputBg),
            color: Color(colorScheme.textPrimary),
            raw: {'border-color': colorScheme.borderInput},
          ),
          attributes: {
            'placeholder': 'Provide a brief summary of services listed under this category...',
            'value': _description,
          },
          onInput: (val) => setState(() => _description = val.toString()),
          [],
        ),
      ]),

      // Image URL Field
      div(classes: 'space-y-1.5', [
        label(
          classes: 'block text-xs font-bold uppercase tracking-wider',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [Component.text('Banner / Image URL (Optional)')],
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
          attributes: {'placeholder': 'https://example.com/category-banner.png'},
          onInput: (val) => setState(() => _imageUrl = val.toString()),
        ),
      ]),

      // Active Status Toggle
      div(
        classes: 'flex items-center justify-between pt-2 border-t',
        styles: Styles(raw: {'border-color': colorScheme.border}),
        [
          div(classes: 'space-y-0.5', [
            span(
              classes: 'block text-xs font-bold',
              styles: Styles(color: Color(colorScheme.textHeading)),
              [Component.text('Active Category Status')],
            ),
            span(
              classes: 'block text-[11px]',
              styles: Styles(color: Color(colorScheme.textMuted)),
              [Component.text('Enables listing services under this category')],
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
              span([Component.text(_isSubmitting ? 'Creating...' : 'Create Category')]),
            ],
          ),
        ],
      ),
    ]);
  }
}
