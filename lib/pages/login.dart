import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../core/designs/app_icons.dart';
import '../core/designs/components/app_icon.dart';

@client
class LoginPage extends StatefulComponent {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isSignUp = false;
  bool showPassword = false;
  bool agreeTerms = false;

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

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'w-full min-h-screen lg:h-screen overflow-x-hidden overflow-y-auto grid grid-cols-1 lg:grid-cols-2 bg-white dark:bg-slate-900 font-sans transition-colors duration-200',
      [
        // Left Hero Panel (Fluid Blue Mesh & Branding - Full Height)
        div(
          classes: 'relative bg-gradient-to-br from-blue-600 via-indigo-600 to-blue-700 p-8 lg:p-16 flex flex-col justify-between overflow-hidden text-white min-h-[420px] lg:h-full',
          [
            // Organic background glow shapes
            div(classes: 'absolute -top-32 -left-32 w-[30rem] h-[30rem] bg-blue-400/30 rounded-full blur-3xl pointer-events-none', []),
            div(classes: 'absolute -bottom-32 -right-32 w-[30rem] h-[30rem] bg-indigo-400/30 rounded-full blur-3xl pointer-events-none', []),
            div(classes: 'absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-sky-300/20 rounded-full blur-3xl pointer-events-none', []),

            // Back Link & Top Content
            div(
              classes: 'relative z-10 space-y-8 my-auto max-w-xl',
              [
                a(
                  href: '/',
                  classes: 'inline-flex items-center space-x-1.5 text-xs text-blue-100/90 hover:text-white bg-white/10 hover:bg-white/20 backdrop-blur-sm px-4 py-2 rounded-full transition-all w-fit font-medium border border-white/10 shadow-sm',
                  [
                    span([Component.text('← Back to Dashboard')]),
                  ],
                ),
                div(
                  classes: 'space-y-4',
                  [
                    p(classes: 'text-blue-200 text-xs font-bold tracking-widest uppercase', [Component.text('You can easily')]),
                    h1(classes: 'text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white leading-[1.15] tracking-tight', [
                      Component.text('Speed up your work\nwith our Web App'),
                    ]),
                  ],
                ),
              ],
            ),

            // Bottom Partners Section
            div(
              classes: 'relative z-10 pt-8 border-t border-white/10 mt-auto',
              [
                p(classes: 'text-xs text-blue-200/80 uppercase tracking-widest font-bold mb-4 text-center sm:text-left', [Component.text('Our partners')]),
                div(
                  classes: 'flex flex-wrap items-center justify-center sm:justify-start gap-5 sm:gap-8 text-white/90',
                  [
                    _partnerItem(AppIcons.discord, 'Discord'),
                    _partnerItem(AppIcons.instagram, 'Instagram'),
                    _partnerItem(AppIcons.spotify, 'Spotify'),
                    _partnerItem(AppIcons.youtube, 'YouTube'),
                    _partnerItem(AppIcons.tiktok, 'TikTok'),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Right Form Panel (Full Height & Centered Form)
        div(
          classes: 'p-8 lg:p-16 flex flex-col justify-center items-center bg-white dark:bg-slate-900 lg:h-full overflow-y-auto',
          [
            div(
              classes: 'max-w-md w-full my-auto space-y-6',
              [
                // Header Title
                div(
                  classes: 'space-y-2 text-center sm:text-left',
                  [
                    h2(classes: 'text-3xl lg:text-4xl font-bold text-slate-900 dark:text-white tracking-tight', [
                      Component.text(isSignUp ? 'Create an Account' : 'Get Started Now'),
                    ]),
                    p(classes: 'text-sm text-slate-500 dark:text-slate-400', [
                      Component.text(isSignUp ? 'Please enter your details to register.' : 'Please log in to your account to continue.'),
                    ]),
                  ],
                ),

                // Auth Form
                form(
                  events: {
                    'submit': (e) {
                      e.preventDefault();
                    }
                  },
                  classes: 'space-y-4',
                  [
                    // Name field (Signup mode only)
                    if (isSignUp)
                      div(
                        classes: 'space-y-1.5',
                        [
                          label(classes: 'block text-xs font-semibold text-slate-700 dark:text-slate-300 uppercase tracking-wider', [Component.text('Full Name')]),
                          input(
                            type: InputType.text,
                            attributes: const {'placeholder': 'Enter your full name'},
                            classes: 'w-full px-4 py-3 rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/50 text-slate-900 dark:text-white text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all',
                          ),
                        ],
                      ),

                    // Email Field
                    div(
                      classes: 'space-y-1.5',
                      [
                        label(classes: 'block text-xs font-semibold text-slate-700 dark:text-slate-300 uppercase tracking-wider', [Component.text('Email Address')]),
                        input(
                          type: InputType.email,
                          attributes: const {'placeholder': 'workmail@gmail.com'},
                          classes: 'w-full px-4 py-3 rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/50 text-slate-900 dark:text-white text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all',
                        ),
                      ],
                    ),

                    // Password Field
                    div(
                      classes: 'space-y-1.5',
                      [
                        div(
                          classes: 'flex items-center justify-between',
                          [
                            label(classes: 'block text-xs font-semibold text-slate-700 dark:text-slate-300 uppercase tracking-wider', [Component.text('Password')]),
                            if (!isSignUp)
                              a(
                                href: '#',
                                classes: 'text-xs text-blue-600 dark:text-blue-400 hover:underline font-medium',
                                [Component.text('Forgot Password?')],
                              ),
                          ],
                        ),
                        div(
                          classes: 'relative flex items-center',
                          [
                            input(
                              type: showPassword ? InputType.text : InputType.password,
                              attributes: const {'placeholder': '••••••••••••'},
                              classes: 'w-full pl-4 pr-11 py-3 rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/50 text-slate-900 dark:text-white text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all',
                            ),
                            button(
                              type: ButtonType.button,
                              events: {
                                'click': (e) {
                                  e.preventDefault();
                                  togglePasswordVisibility();
                                }
                              },
                              classes: 'absolute right-3 p-1 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 transition-colors focus:outline-none cursor-pointer',
                              [
                                AppIcon(showPassword ? AppIcons.eyeOff : AppIcons.eye),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Terms Checkbox
                    div(
                      classes: 'flex items-center space-x-2 pt-1',
                      [
                        input(
                          type: InputType.checkbox,
                          attributes: const {'id': 'agreeTerms'},
                          classes: 'rounded border-slate-300 text-blue-600 focus:ring-blue-500 dark:border-slate-700 dark:bg-slate-800',
                        ),
                        label(
                          attributes: const {'for': 'agreeTerms'},
                          classes: 'text-xs text-slate-600 dark:text-slate-400 cursor-pointer select-none',
                          [
                            Component.text('I agree to the '),
                            a(href: '#', classes: 'text-blue-600 dark:text-blue-400 hover:underline font-medium', [Component.text('Terms & Privacy')]),
                          ],
                        ),
                      ],
                    ),

                    // Primary Action Button
                    button(
                      type: ButtonType.submit,
                      classes: 'w-full py-3.5 px-4 bg-blue-600 hover:bg-blue-700 text-white font-semibold text-sm rounded-xl shadow-lg shadow-blue-500/25 hover:shadow-blue-500/35 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 dark:focus:ring-offset-slate-900 active:scale-[0.99] cursor-pointer',
                      [
                        Component.text(isSignUp ? 'Sign Up' : 'Log In'),
                      ],
                    ),
                  ],
                ),

                // Auth Switcher
                div(
                  classes: 'text-center text-xs text-slate-500 dark:text-slate-400',
                  [
                    Component.text(isSignUp ? 'Already have an account? ' : 'Don\'t have an account? '),
                    button(
                      type: ButtonType.button,
                      events: {
                        'click': (e) {
                          e.preventDefault();
                          toggleAuthMode();
                        }
                      },
                      classes: 'text-blue-600 dark:text-blue-400 hover:underline font-semibold focus:outline-none cursor-pointer',
                      [
                        Component.text(isSignUp ? 'Log In' : 'Sign Up'),
                      ],
                    ),
                  ],
                ),

                // Divider
                div(
                  classes: 'relative flex items-center justify-center my-6',
                  [
                    div(classes: 'absolute inset-0 flex items-center', [
                      div(classes: 'w-full border-t border-slate-200 dark:border-slate-800', []),
                    ]),
                    span(classes: 'relative px-3 bg-white dark:bg-slate-900 text-xs font-medium text-slate-400 uppercase tracking-wider', [
                      Component.text('Or'),
                    ]),
                  ],
                ),

                // Social Logins
                div(
                  classes: 'grid grid-cols-2 gap-3',
                  [
                    button(
                      type: ButtonType.button,
                      classes: 'flex items-center justify-center space-x-2 py-2.5 px-4 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 hover:bg-slate-50 dark:hover:bg-slate-750 text-slate-700 dark:text-slate-200 text-xs font-semibold shadow-sm transition-all focus:outline-none cursor-pointer',
                      [
                        AppIcon(AppIcons.google),
                        span([Component.text('Login with Google')]),
                      ],
                    ),
                    button(
                      type: ButtonType.button,
                      classes: 'flex items-center justify-center space-x-2 py-2.5 px-4 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 hover:bg-slate-50 dark:hover:bg-slate-750 text-slate-700 dark:text-slate-200 text-xs font-semibold shadow-sm transition-all focus:outline-none cursor-pointer',
                      [
                        AppIcon(AppIcons.apple),
                        span([Component.text('Login with Apple')]),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Component _partnerItem(AppIcons icon, String label) {
    return div(
      classes: 'flex items-center space-x-2 hover:text-white transition-colors cursor-pointer text-sm font-medium',
      [
        AppIcon(icon),
        span([Component.text(label)]),
      ],
    );
  }
}
