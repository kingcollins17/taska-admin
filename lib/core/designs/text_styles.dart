/// Centralized typography & text style design tokens.
enum AppTextStyles {
  /// Main logo / wordmark style (`text-2xl font-extrabold tracking-tight`).
  wordmark('text-2xl font-extrabold tracking-tight'),

  /// Primary page heading (`text-[2rem] font-extrabold leading-tight tracking-tight`).
  h1('text-[2rem] font-extrabold leading-tight tracking-tight'),

  /// Hero display heading (`text-[2.25rem] font-black leading-[1.12] tracking-[-0.025em] lg:text-[3.25rem]`).
  h2('text-[2.25rem] font-black leading-[1.12] tracking-[-0.025em] lg:text-[3.25rem]'),

  /// Main body paragraph text (`text-[1.05rem] leading-relaxed`).
  body('text-[1.05rem] leading-relaxed'),

  /// Small body / muted text (`text-sm`).
  bodySmall('text-sm'),

  /// Primary uppercase button text (`text-sm font-bold uppercase tracking-[0.12em]`).
  button('text-sm font-bold uppercase tracking-[0.12em]'),

  /// Action link text (`text-sm font-semibold underline underline-offset-4 transition-colors`).
  link('text-sm font-semibold underline underline-offset-4 transition-colors'),

  /// Form input text (`text-[0.95rem] outline-none`).
  input('text-[0.95rem] outline-none'),

  /// Badge / pill label text (`text-xs font-bold tracking-[0.12em]`).
  badge('text-xs font-bold tracking-[0.12em]'),

  /// Footer caption text (`text-sm font-medium`).
  caption('text-sm font-medium');

  const AppTextStyles(this.className);

  /// Tailwind CSS classes for this typography token.
  final String className;

  @override
  String toString() => className;
}
