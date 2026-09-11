# Jaspr Tailwind Design System: Advanced Patterns

Advanced Tailwind CSS v4 patterns for Jaspr applications, including animations, dark mode theming, custom utilities, theme modifiers, namespace overrides, and the v3-to-v4 migration checklist.

## Pattern 5: Native CSS Animations (v4)

Use native CSS animations with Jaspr rather than framework-specific animation libraries where possible.

```css
/* web/styles.tw.css - native @starting-style for entry animations */

@theme {
  --animate-dialog-in: dialog-fade-in 0.2s ease-out;
  --animate-dialog-out: dialog-fade-out 0.15s ease-in;
}

@keyframes dialog-fade-in {
  from {
    opacity: 0;
    transform: scale(0.95) translateY(-0.5rem);
  }

  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

@keyframes dialog-fade-out {
  from {
    opacity: 1;
    transform: scale(1) translateY(0);
  }

  to {
    opacity: 0;
    transform: scale(0.95) translateY(-0.5rem);
  }
}

/* Native popover animations using @starting-style */

[popover] {
  transition:
    opacity 0.2s,
    transform 0.2s,
    display 0.2s allow-discrete;

  opacity: 0;
  transform: scale(0.95);
}

[popover]:popover-open {
  opacity: 1;
  transform: scale(1);
}

@starting-style {
  [popover]:popover-open {
    opacity: 0;
    transform: scale(0.95);
  }
}
```

A Jaspr dialog can use the native HTML dialog/popover APIs and Tailwind classes:

```dart
// components/ui/dialog.dart

import 'package:jaspr/jaspr.dart';

class DialogOverlay extends StatelessComponent {
  final List<Component> children;

  const DialogOverlay({
    super.key,
    this.children = const [],
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'fixed inset-0 z-50 bg-black/80 '
          'data-[state=open]:animate-fade-in '
          'data-[state=closed]:animate-fade-out',
      children,
    );
  }
}

class DialogContent extends StatelessComponent {
  final List<Component> children;

  const DialogContent({
    super.key,
    required this.children,
  });

  @override
  Component build(BuildContext context) {
    return dialog(
      classes: 'fixed left-1/2 top-1/2 z-50 grid w-full max-w-lg '
          '-translate-x-1/2 -translate-y-1/2 gap-4 border border-border '
          'bg-background p-6 shadow-lg sm:rounded-lg '
          'animate-dialog-in',
      children,
    );
  }
}
```

Prefer native browser capabilities and CSS transitions over unnecessary JavaScript animation logic.

## Pattern 6: Dark Mode with CSS (v4)

Jaspr can manage the theme through Dart state while Tailwind handles the visual theme through the `.dark` class.

```dart
// providers/theme_provider.dart

import 'package:jaspr/jaspr.dart';

enum ThemeMode {
  dark,
  light,
  system,
}

class ThemeProvider extends StatelessComponent {
  final ThemeMode defaultTheme;
  final List<Component> children;

  const ThemeProvider({
    super.key,
    this.defaultTheme = ThemeMode.system,
    required this.children,
  });

  @override
  Component build(BuildContext context) {
    return children.length == 1 ? children.first : div(children: children);
  }
}
```

The theme class should be applied to the document root:

```html
<html class="dark">
```

Or dynamically through client-side Dart code:

```dart
import 'dart:html' as html;

void applyTheme(String theme) {
  final root = html.document.documentElement;

  root?.classes.removeAll(['light', 'dark']);

  final resolved = theme == 'system'
      ? (html.window.matchMedia('(prefers-color-scheme: dark)').matches
          ? 'dark'
          : 'light')
      : theme;

  root?.classes.add(resolved);

  final metaThemeColor =
      html.document.querySelector('meta[name="theme-color"]');

  metaThemeColor?.setAttribute(
    'content',
    resolved == 'dark' ? '#09090b' : '#ffffff',
  );
}
```

The Tailwind CSS configuration remains CSS-first:

```css
@custom-variant dark (&:where(.dark, .dark *));

.dark {
  --color-background: oklch(14.5% 0.025 264);
  --color-foreground: oklch(98% 0.01 264);
  --color-primary: oklch(98% 0.01 264);
  --color-primary-foreground: oklch(14.5% 0.025 264);
  --color-secondary: oklch(22% 0.02 264);
  --color-secondary-foreground: oklch(98% 0.01 264);
  --color-muted: oklch(22% 0.02 264);
  --color-muted-foreground: oklch(65% 0.02 264);
  --color-accent: oklch(22% 0.02 264);
  --color-accent-foreground: oklch(98% 0.01 264);
  --color-destructive: oklch(42% 0.15 27);
  --color-destructive-foreground: oklch(98% 0.01 264);
  --color-border: oklch(22% 0.02 264);
  --color-ring: oklch(83% 0.02 264);
  --color-card: oklch(14.5% 0.025 264);
  --color-card-foreground: oklch(98% 0.01 264);
  --color-ring-offset: oklch(14.5% 0.025 264);
}
```

A theme toggle in Jaspr should update the theme state and apply the corresponding root class:

```dart
class ThemeToggle extends StatelessComponent {
  final String currentTheme;
  final void Function() onToggle;

  const ThemeToggle({
    super.key,
    required this.currentTheme,
    required this.onToggle,
  });

  @override
  Component build(BuildContext context) {
    return button(
      classes: 'inline-flex items-center justify-center rounded-md '
          'size-10 hover:bg-accent hover:text-accent-foreground',
      onClick: (_) => onToggle(),
      [
        span(
          classes: 'sr-only',
          [text('Toggle theme')],
        ),
        text(currentTheme == 'dark' ? '☀' : '☾'),
      ],
    );
  }
}
```

## Advanced v4 Patterns

### Custom Utilities with `@utility`

Define reusable custom utilities:

```css
/* Custom utility for decorative lines */

@utility line-t {
  @apply relative before:absolute before:top-0 before:-left-[100vw]
    before:h-px before:w-[200vw]
    before:bg-gray-950/5 dark:before:bg-white/10;
}

/* Custom utility for text gradients */

@utility text-gradient {
  @apply bg-gradient-to-r from-primary to-accent
    bg-clip-text text-transparent;
}
```

These utilities can then be used directly through Jaspr's `classes:` property.

### Theme Modifiers

```css
/* Use @theme inline when referencing other CSS variables */

@theme inline {
  --font-sans: var(--font-inter), system-ui;
}

/* Use @theme static to always generate CSS variables */

@theme static {
  --color-brand: oklch(65% 0.15 240);
}

/* Import with theme options */

@import "tailwindcss" theme(static);
```

### Namespace Overrides

```css
@theme {
  /* Clear all default colors and define your own */

  --color-*: initial;

  --color-white: #fff;
  --color-black: #000;
  --color-primary: oklch(45% 0.2 260);
  --color-secondary: oklch(65% 0.15 200);

  /* Clear ALL defaults for a minimal setup */

  /* --*: initial; */
}
```

### Semi-transparent Color Variants

```css
@theme {
  /* Use color-mix() for alpha variants */

  --color-primary-50: color-mix(
    in oklab,
    var(--color-primary) 5%,
    transparent
  );

  --color-primary-100: color-mix(
    in oklab,
    var(--color-primary) 10%,
    transparent
  );

  --color-primary-200: color-mix(
    in oklab,
    var(--color-primary) 20%,
    transparent
  );
}
```

### Container Queries

```css
@theme {
  --container-xs: 20rem;
  --container-sm: 24rem;
  --container-md: 28rem;
  --container-lg: 32rem;
}
```

## v3 to v4 Migration Checklist

* [ ] Replace `tailwind.config.ts` with CSS `@theme` block
* [ ] Change `@tailwind base/components/utilities` to `@import "tailwindcss"`
* [ ] Move color definitions to `@theme { --color-*: value }`
* [ ] Replace `darkMode: "class"` with `@custom-variant dark`
* [ ] Move `@keyframes` inside `@theme` blocks when they should be generated with the theme
* [ ] Replace `require("tailwindcss-animate")` with native CSS animations
* [ ] Update `h-10 w-10` to `size-10`
* [ ] Replace React-specific `forwardRef` patterns with normal Jaspr component properties
* [ ] Consider OKLCH colors for better color perception
* [ ] Replace custom plugins with `@utility` directives

## Best Practices

### Do's

* **Use `@theme` blocks** — CSS-first configuration is v4's core pattern
* **Use OKLCH colors** — Better perceptual uniformity than HSL
* **Use typed Dart component variants** — Keep Jaspr component APIs predictable
* **Use semantic tokens** — `bg-primary` instead of `bg-blue-500`
* **Use `size-*`** — Shorthand for equal width and height
* **Add accessibility** — ARIA attributes, focus states, labels, and semantic HTML
* **Use Jaspr's `classes:` property** — Keep Tailwind classes directly in component definitions

### Don'ts

* **Don't use `tailwind.config.ts`** — Use CSS `@theme` instead
* **Don't use `@tailwind` directives** — Use `@import "tailwindcss"`
* **Don't use React-specific patterns** — Use Jaspr components and Dart APIs
* **Don't use arbitrary values unnecessarily** — Extend `@theme` instead
* **Don't hardcode colors** — Use semantic tokens
* **Don't forget dark mode** — Test both themes
