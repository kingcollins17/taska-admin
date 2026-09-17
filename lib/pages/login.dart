import 'package:jaspr/dom.dart' hide ColorScheme;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:taska_admin/core/providers/network_providers.dart';

import '../core/designs/app_icons.dart';
import '../core/designs/colors.dart';
import '../core/designs/components/app_icon.dart';
import '../core/models/clients/auth/accept_invitation_request.dart';
import '../core/models/clients/auth/login_request.dart';
import '../core/providers/admin_providers.dart';
import '../core/providers/ui_state_provider.dart';

/// Page shell. Holds no state of its own, it only splits the screen
/// between the form and the side panel.
@client
class LoginPage extends StatelessComponent {
  const LoginPage({super.key});

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return div(
      classes: 'flex min-h-screen w-full flex-col lg:flex-row lg:gap-8 lg:p-5',
      styles: Styles(backgroundColor: Color(colorScheme.surface)),
      [
        const _LoginForm(),
        const _SidePanel(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Login form
// ─────────────────────────────────────────────────────────────

class _LoginForm extends StatefulComponent {
  const _LoginForm();

  @override
  State<_LoginForm> createState() {
    return _LoginFormState();
  }
}

class _LoginFormState extends State<_LoginForm> {
  bool isSignUp = false;
  bool showPassword = false;
  bool keepSignedIn = false;
  bool agreeTerms = false;
  bool isLoading = false;

  String fullName = '';
  String email = '';
  String password = '';
  String inviteToken = '';

  void toggleAuthMode() {
    setState(() {
      isSignUp = !isSignUp;
    });
  }

  void togglePasswordVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  void setKeepSignedIn(bool value) {
    setState(() {
      keepSignedIn = value;
    });
  }

  void setAgreeTerms(bool value) {
    setState(() {
      agreeTerms = value;
    });
  }

  void handleSubmit(BuildContext context) {
    if (isLoading) return;

    if (isSignUp) {
      if (fullName.trim().isEmpty || password.trim().isEmpty || inviteToken.trim().isEmpty) {
        context.showFlushbar(
          message: 'Please enter all required details to continue',
          type: FlushbarType.warning,
        );
        return;
      }

      if (!agreeTerms) {
        context.showFlushbar(
          message: 'Please agree to the Terms & Privacy policy to continue',
          type: FlushbarType.error,
        );
        return;
      }
    } else {
      final trimmedEmail = email.trim();
      final trimmedPassword = password.trim();

      if (trimmedEmail.isEmpty && trimmedPassword.isEmpty) {
        context.showFlushbar(
          message: 'Please enter your email and password to continue',
          type: FlushbarType.warning,
        );
        return;
      } else if (trimmedEmail.isEmpty) {
        context.showFlushbar(
          message: 'Please enter your email address to continue',
          type: FlushbarType.warning,
        );
        return;
      } else if (trimmedPassword.isEmpty) {
        context.showFlushbar(
          message: 'Please enter your password to continue',
          type: FlushbarType.warning,
        );
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    if (isSignUp) {
      context.read(adminAuthProvider.notifier).acceptInvite(
        AcceptInvitationRequest(
          fullname: fullName.trim(),
          password: password.trim(),
          token: inviteToken.trim(),
        ),
        onSuccess: (user) {
          setState(() {
            isLoading = false;
          });
          Router.of(context).push('/');
        },
        onError: (message) {
          setState(() {
            isLoading = false;
          });
          context.showFlushbar(
            message: message,
            type: FlushbarType.error,
          );
        },
      );
    } else {
      context.read(adminAuthProvider.notifier).login(
        LoginRequest(
          email: email.trim(),
          password: password,
        ),
        onSuccess: (data) {
          setState(() {
            isLoading = false;
          });
          context.invalidate(isAuthenticatedProvider);
          Router.of(context).push('/');
        },
        onError: (message) {
          setState(() {
            isLoading = false;
          });
          context.showFlushbar(
            message: message,
            type: FlushbarType.error,
          );
        },
      );
    }
  }

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return div(
      classes: 'flex w-full flex-col px-7 py-10 sm:px-12 lg:w-[43%] lg:px-16 lg:py-10',
      styles: Styles(backgroundColor: Color(colorScheme.surface)),
      [
        buildWordmark(colorScheme),
        div(
          classes: 'flex flex-1 flex-col justify-center py-12 lg:py-0',
          [
            div(
              key: Key(isSignUp ? 'signup-container' : 'login-container'),
              classes: 'w-full max-w-[420px] space-y-6 animate-fade-in-scaled',
              [
                buildHeading(colorScheme),
                buildForm(colorScheme),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Component buildWordmark(ColorScheme colorScheme) {
    return a(
      href: '/',
      classes: 'text-2xl font-extrabold tracking-tight no-underline',
      styles: Styles(color: Color(colorScheme.textHeading)),
      [
        Component.text('Taska'),
        span(
          styles: Styles(color: Color(colorScheme.primary)),
          [Component.text('.')],
        ),
      ],
    );
  }

  Component buildHeading(ColorScheme colorScheme) {
    String title;
    String prompt;
    String action;

    if (isSignUp) {
      title = 'Accept invite';
      prompt = 'Already registered? ';
      action = 'Log in here';
    } else {
      title = 'Welcome back!';
      prompt = 'New user? ';
      action = 'Accept invite';
    }

    return div(
      classes: 'flex flex-wrap items-baseline gap-x-4 gap-y-2',
      [
        h1(
          classes: 'text-[2rem] font-extrabold leading-tight tracking-tight',
          styles: Styles(color: Color(colorScheme.textPrimary)),
          [Component.text(title)],
        ),
        span(
          classes: 'text-sm',
          styles: Styles(color: Color(colorScheme.textMuted)),
          [
            Component.text(prompt),
            button(
              type: ButtonType.button,
              classes: 'cursor-pointer border-none bg-transparent p-0 text-sm font-semibold underline underline-offset-4 transition-colors',
              styles: Styles(color: Color(colorScheme.primary)),
              events: {
                'click': (event) {
                  toggleAuthMode();
                },
              },
              [Component.text(action)],
            ),
          ],
        ),
      ],
    );
  }

  Component buildForm(ColorScheme colorScheme) {
    String submitLabel;

    if (isSignUp) {
      submitLabel = 'Accept invite';
    } else {
      submitLabel = 'Log in';
    }

    return form(
      classes: 'space-y-4',
      events: {
        'submit': (event) {
          event.preventDefault();
          handleSubmit(context);
        },
      },
      [
        if (isSignUp) ...[
          _TextField(
            type: InputType.text,
            placeholder: 'Full name',
            autocomplete: 'name',
            value: fullName,
            disabled: isLoading,
            onInput: (val) => fullName = val,
          ),
          buildPasswordField(colorScheme),
          _TextField(
            type: InputType.text,
            placeholder: 'Paste your invite token here',
            autocomplete: 'off',
            value: inviteToken,
            disabled: isLoading,
            onInput: (val) => inviteToken = val,
          ),
        ] else ...[
          _TextField(
            type: InputType.email,
            placeholder: 'Email',
            autocomplete: 'email',
            value: email,
            disabled: isLoading,
            onInput: (val) => email = val,
          ),
          buildPasswordField(colorScheme),
        ],
        buildOptionsRow(colorScheme),
        button(
          type: ButtonType.submit,
          disabled: isLoading,
          classes: isLoading
              ? 'w-full cursor-not-allowed rounded-full border-none bg-slate-400 py-4 text-sm font-bold uppercase tracking-[0.12em] text-white opacity-60 transition-colors duration-200'
              : 'w-full cursor-pointer rounded-full border-none py-4 text-sm font-bold uppercase tracking-[0.12em] text-white shadow-[0_10px_25px_-5px_rgba(0,168,112,0.4)] transition-colors duration-200 focus-visible:outline-2 focus-visible:outline-offset-2',
          styles: Styles(backgroundColor: Color(colorScheme.primary)),
          events: {
            'click': (event) {
              if (isLoading) {
                event.preventDefault();
              }
            },
          },
          [Component.text(isLoading ? 'Processing...' : submitLabel)],
        ),
      ],
    );
  }

  Component buildPasswordField(ColorScheme colorScheme) {
    InputType passwordType;
    AppIcons passwordIcon;
    String passwordAction;

    if (showPassword) {
      passwordType = InputType.text;
      passwordIcon = AppIcons.eyeOff;
      passwordAction = 'Hide password';
    } else {
      passwordType = InputType.password;
      passwordIcon = AppIcons.eye;
      passwordAction = 'Show password';
    }

    return _TextField(
      type: passwordType,
      placeholder: 'Password',
      autocomplete: 'current-password',
      value: password,
      disabled: isLoading,
      onInput: (val) => password = val,
      trailing: button(
        type: ButtonType.button,
        classes:
            'absolute right-5 flex cursor-pointer items-center justify-center border-none bg-transparent p-1 transition-colors',
        styles: Styles(color: Color(colorScheme.placeholder)),
        attributes: {'aria-label': passwordAction},
        events: {
          'click': (event) {
            event.preventDefault();
            togglePasswordVisibility();
          },
        },
        [AppIcon(passwordIcon)],
      ),
    );
  }

  Component buildOptionsRow(ColorScheme colorScheme) {
    if (isSignUp) {
      return _CheckboxRow(
        id: 'agreeTerms',
        checked: agreeTerms,
        onChanged: setAgreeTerms,
        content: [
          Component.text('I agree to the '),
          a(
            href: '#',
            classes: 'text-sm font-semibold underline underline-offset-4 transition-colors',
            styles: Styles(color: Color(colorScheme.primary)),
            [Component.text('Terms & Privacy')],
          ),
        ],
      );
    }

    return div(
      classes: 'flex flex-wrap items-center justify-between gap-3',
      [
        _CheckboxRow(
          id: 'keepSignedIn',
          checked: keepSignedIn,
          onChanged: setKeepSignedIn,
          content: [Component.text('Keep me signed in')],
        ),
        a(
          href: '#',
          classes: 'text-sm font-semibold underline underline-offset-4 transition-colors',
          styles: Styles(color: Color(colorScheme.primary)),
          [Component.text('Forgot your password?')],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Side panel
// ─────────────────────────────────────────────────────────────

class _SidePanel extends StatelessComponent {
  const _SidePanel();

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return div(
      classes: 'relative flex w-full flex-col overflow-hidden p-8 text-white lg:w-[57%] lg:rounded-[32px] lg:p-12',
      styles: Styles(
        raw: {
          'background':
              'linear-gradient(135deg, ${colorScheme.primaryDarkest} 0%, ${colorScheme.primaryDark} 30%, ${colorScheme.primaryHover} 60%, ${colorScheme.primary} 100%)',
        },
      ),
      [
        buildGlow(),
        buildContent(colorScheme),
        span(
          classes: 'relative z-10 text-sm font-medium text-white/65',
          [Component.text('© 2026 Taska Workspace. All rights reserved.')],
        ),
      ],
    );
  }

  Component buildGlow() {
    return Component.fragment([
      div(
        classes:
            'pointer-events-none absolute -right-24 -top-24 h-96 w-96 rounded-full bg-white/10 blur-3xl',
        [],
      ),
      div(
        classes:
            'pointer-events-none absolute -bottom-32 -left-32 h-96 w-96 rounded-full bg-[#00F5A0]/15 blur-3xl',
        [],
      ),
    ]);
  }

  Component buildContent(ColorScheme colorScheme) {
    return div(
      classes: 'relative z-10 my-auto flex flex-col justify-center space-y-8 py-10',
      [
        buildBadge(colorScheme),
        h2(
          classes: 'text-[2.25rem] font-black leading-[1.12] tracking-[-0.025em] lg:text-[3.25rem] leading-tight text-white',
          [
            Component.text('Empowering Seamless '),
            span(
              classes:
                  'bg-gradient-to-r from-white via-[#E0F7ED] to-[#00F5A0] bg-clip-text text-transparent',
              [Component.text('Task Operations')],
            ),
          ],
        ),
        p(
          classes: 'text-[1.05rem] leading-relaxed max-w-lg text-white/80',
          [
            Component.text(
              'The central hub for administrative oversight, customer service management, and escrow control.',
            ),
          ],
        ),
        buildFeatureHighlights(colorScheme),
      ],
    );
  }

  Component buildBadge(ColorScheme colorScheme) {
    return div(
      classes:
          'inline-flex items-center gap-2 self-start rounded-full border border-white/20 bg-white/10 px-4 py-1.5 backdrop-blur-md',
      [
        span(
          classes: 'h-2 w-2 rounded-full animate-pulse',
          styles: Styles(backgroundColor: Color(colorScheme.mint)),
          [],
        ),
        span(
          classes: 'text-xs font-bold tracking-[0.12em] font-semibold uppercase tracking-wider text-white',
          [Component.text('Taska Admin Hub')],
        ),
      ],
    );
  }

  Component buildFeatureHighlights(ColorScheme colorScheme) {
    return div(
      classes: 'mt-2 flex flex-col gap-3 max-w-[460px]',
      [
        buildFeatureItem(
          colorScheme: colorScheme,
          title: 'User Management',
          description: 'Identity vetting & account administration',
        ),
        buildFeatureItem(
          colorScheme: colorScheme,
          title: 'Task Management',
          description: 'Operations, broadcasts & escrow oversight',
        ),
        buildFeatureItem(
          colorScheme: colorScheme,
          title: 'Customer Support',
          description: 'Dispute resolution & support triage',
        ),
      ],
    );
  }

  Component buildFeatureItem({
    required ColorScheme colorScheme,
    required String title,
    required String description,
  }) {
    return div(
      classes:
          'flex items-start gap-3.5 rounded-2xl border border-white/10 bg-white/5 p-3.5 backdrop-blur-md',
      [
        div(
          classes:
              'mt-0.5 flex h-6 w-6 shrink-0 items-center justify-center rounded-full',
          styles: Styles(
            backgroundColor: Color.rgba(0, 245, 160, 0.2),
            color: Color(colorScheme.mint),
          ),
          [
            span(
              classes: 'h-2 w-2 rounded-full',
              styles: Styles(backgroundColor: Color(colorScheme.mint)),
              [],
            ),
          ],
        ),
        div(
          classes: 'flex flex-col gap-0.5',
          [
            span(classes: 'text-sm font-semibold text-white', [Component.text(title)]),
            span(classes: 'text-xs text-white/70', [Component.text(description)]),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared pieces
// ─────────────────────────────────────────────────────────────

class _TextField extends StatelessComponent {
  const _TextField({
    required this.type,
    required this.placeholder,
    required this.autocomplete,
    this.value = '',
    this.onInput,
    this.trailing,
    this.disabled = false,
  });

  final InputType type;
  final String placeholder;
  final String autocomplete;
  final String value;
  final void Function(String value)? onInput;
  final Component? trailing;
  final bool disabled;

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    final fieldClasses = trailing == null
        ? (disabled
            ? 'w-full rounded-full border px-6 py-4 text-[0.95rem] outline-none transition-colors duration-200 focus:ring-4 focus:ring-[rgba(0,168,112,0.12)] opacity-50 cursor-not-allowed'
            : 'w-full rounded-full border px-6 py-4 text-[0.95rem] outline-none transition-colors duration-200 focus:ring-4 focus:ring-[rgba(0,168,112,0.12)]')
        : (disabled
            ? 'w-full rounded-full border py-4 pl-6 pr-14 text-[0.95rem] outline-none transition-colors duration-200 focus:ring-4 focus:ring-[rgba(0,168,112,0.12)] opacity-50 cursor-not-allowed'
            : 'w-full rounded-full border py-4 pl-6 pr-14 text-[0.95rem] outline-none transition-colors duration-200 focus:ring-4 focus:ring-[rgba(0,168,112,0.12)]');

    return div(
      classes: 'relative flex items-center',
      [
        input(
          type: type,
          classes: fieldClasses,
          styles: Styles(
            raw: {
              'border-color': colorScheme.border,
              'background-color': colorScheme.inputBg,
              'color': colorScheme.textPrimary,
            },
          ),
          value: value,
          disabled: disabled,
          onInput: onInput,
          attributes: {
            'placeholder': placeholder,
            'autocomplete': autocomplete,
            'aria-label': placeholder,
          },
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _CheckboxRow extends StatelessComponent {
  const _CheckboxRow({
    required this.id,
    required this.checked,
    required this.onChanged,
    required this.content,
  });

  final String id;
  final bool checked;
  final void Function(bool checked) onChanged;
  final List<Component> content;

  @override
  Component build(BuildContext context) {
    final colorScheme = context.watch(uiStateProvider.select((state) => state.colorScheme));

    return div(
      classes: 'flex items-center gap-2.5',
      [
        input(
          type: InputType.checkbox,
          checked: checked,
          classes: 'h-[18px] w-[18px] cursor-pointer rounded-md border',
          styles: Styles(
            raw: {
              'border-color': colorScheme.borderInput,
              'accent-color': colorScheme.primary,
            },
          ),
          attributes: {
            'id': id,
          },
          onChange: onChanged,
        ),
        label(
          attributes: {'for': id},
          classes: 'cursor-pointer select-none text-sm',
          styles: Styles(color: Color(colorScheme.textMuted)),
          content,
        ),
      ],
    );
  }
}
