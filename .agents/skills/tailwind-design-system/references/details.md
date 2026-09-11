# jaspr-tailwind-design-system — detailed patterns and worked examples

## Patterns

### Pattern 1: Jaspr Variant Components

Use Dart classes and Jaspr's `classes:` property instead of React, JSX, CVA, or `className`.

```dart
// components/ui/button.dart

import 'package:jaspr/jaspr.dart';

class Button extends StatelessComponent {
  final String? variant;
  final String? size;
  final List<Component> children;

  const Button({
    super.key,
    this.variant = 'default',
    this.size = 'default',
    required this.children,
  });

  String get _classes {
    const base =
        'inline-flex items-center justify-center whitespace-nowrap '
        'rounded-md text-sm font-medium transition-colors '
        'focus-visible:outline-none focus-visible:ring-2 '
        'focus-visible:ring-ring focus-visible:ring-offset-2 '
        'disabled:pointer-events-none disabled:opacity-50';

    const variants = {
      'default': 'bg-primary text-primary-foreground hover:bg-primary/90',
      'destructive':
          'bg-destructive text-destructive-foreground hover:bg-destructive/90',
      'outline':
          'border border-border bg-background hover:bg-accent '
          'hover:text-accent-foreground',
      'secondary':
          'bg-secondary text-secondary-foreground hover:bg-secondary/80',
      'ghost': 'hover:bg-accent hover:text-accent-foreground',
      'link': 'text-primary underline-offset-4 hover:underline',
    };

    const sizes = {
      'default': 'h-10 px-4 py-2',
      'sm': 'h-9 rounded-md px-3',
      'lg': 'h-11 rounded-md px-8',
      'icon': 'size-10',
    };

    return '$base ${variants[variant] ?? variants['default']} '
        '${sizes[size] ?? sizes['default']}';
  }

  @override
  Component build(BuildContext context) {
    return button(
      classes: _classes,
      children: children,
    );
  }
}

// Usage

Button(
  variant: 'destructive',
  size: 'lg',
  children: [
    text('Delete'),
  ],
)

Button(
  variant: 'outline',
  children: [
    text('Cancel'),
  ],
)
```

For reusable Jaspr components, prefer typed Dart properties for variants and sizes. Keep Tailwind classes in the component and expose only the variants that are intentionally supported.

### Pattern 2: Compound Components

```dart
// components/ui/card.dart

import 'package:jaspr/jaspr.dart';

class Card extends StatelessComponent {
  final List<Component> children;

  const Card({
    super.key,
    required this.children,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'rounded-lg border border-border bg-card '
          'text-card-foreground shadow-sm',
      children,
    );
  }
}

class CardHeader extends StatelessComponent {
  final List<Component> children;

  const CardHeader({
    super.key,
    required this.children,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'flex flex-col space-y-1.5 p-6',
      children,
    );
  }
}

class CardTitle extends StatelessComponent {
  final List<Component> children;

  const CardTitle({
    super.key,
    required this.children,
  });

  @override
  Component build(BuildContext context) {
    return h3(
      classes: 'text-2xl font-semibold leading-none tracking-tight',
      children,
    );
  }
}

class CardDescription extends StatelessComponent {
  final List<Component> children;

  const CardDescription({
    super.key,
    required this.children,
  });

  @override
  Component build(BuildContext context) {
    return p(
      classes: 'text-sm text-muted-foreground',
      children,
    );
  }
}

class CardContent extends StatelessComponent {
  final List<Component> children;

  const CardContent({
    super.key,
    required this.children,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'p-6 pt-0',
      children,
    );
  }
}

class CardFooter extends StatelessComponent {
  final List<Component> children;

  const CardFooter({
    super.key,
    required this.children,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'flex items-center p-6 pt-0',
      children,
    );
  }
}

// Usage

Card(
  children: [
    CardHeader(
      children: [
        CardTitle(
          children: [text('Account')],
        ),
        CardDescription(
          children: [text('Manage your account settings')],
        ),
      ],
    ),
    CardContent(
      children: [
        // Form...
      ],
    ),
    CardFooter(
      children: [
        Button(
          children: [text('Save')],
        ),
      ],
    ),
  ],
)
```

Use compound components when a UI element has several semantically related pieces. Jaspr components should compose through Dart children rather than React children or JSX.

### Pattern 3: Form Components

```dart
// components/ui/input.dart

import 'package:jaspr/jaspr.dart';

class Input extends StatelessComponent {
  final String? type;
  final String? id;
  final String? name;
  final String? placeholder;
  final String? error;

  const Input({
    super.key,
    this.type = 'text',
    this.id,
    this.name,
    this.placeholder,
    this.error,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'relative',
      [
        input(
          type: type,
          id: id,
          name: name,
          placeholder: placeholder,
          classes: [
            'flex h-10 w-full rounded-md border border-border '
                'bg-background px-3 py-2 text-sm ring-offset-background '
                'placeholder:text-muted-foreground focus-visible:outline-none '
                'focus-visible:ring-2 focus-visible:ring-ring '
                'focus-visible:ring-offset-2 disabled:cursor-not-allowed '
                'disabled:opacity-50',
            if (error != null)
              'border-destructive focus-visible:ring-destructive',
          ].join(' '),
          attributes: {
            if (error != null) 'aria-invalid': 'true',
            if (error != null && id != null)
              'aria-describedby': '$id-error',
          },
        ),
        if (error != null)
          p(
            id: '$id-error',
            classes: 'mt-1 text-sm text-destructive',
            attributes: {'role': 'alert'},
            [text(error!)],
          ),
      ],
    );
  }
}

// components/ui/label.dart

class Label extends StatelessComponent {
  final String? htmlFor;
  final List<Component> children;

  const Label({
    super.key,
    this.htmlFor,
    required this.children,
  });

  @override
  Component build(BuildContext context) {
    return label(
      htmlFor: htmlFor,
      classes: 'text-sm font-medium leading-none '
          'peer-disabled:cursor-not-allowed peer-disabled:opacity-70',
      children,
    );
  }
}
```

Use Jaspr's form elements and Dart state/event handling rather than React Hook Form or React-specific form libraries.

```dart
// Usage

form(
  classes: 'space-y-4',
  [
    div(
      classes: 'space-y-2',
      [
        Label(
          htmlFor: 'email',
          children: [text('Email')],
        ),
        Input(
          id: 'email',
          type: 'email',
          placeholder: 'you@example.com',
          error: emailError,
        ),
      ],
    ),

    div(
      classes: 'space-y-2',
      [
        Label(
          htmlFor: 'password',
          children: [text('Password')],
        ),
        Input(
          id: 'password',
          type: 'password',
          error: passwordError,
        ),
      ],
    ),

    Button(
      children: [text('Sign In')],
    ),
  ],
)
```

Keep validation logic separate from presentation components. Form components should expose clear error states and preserve accessible relationships between labels, inputs, and error messages.

### Pattern 4: Responsive Grid System

```dart
// components/ui/grid.dart

import 'package:jaspr/jaspr.dart';

class Grid extends StatelessComponent {
  final int cols;
  final String gap;
  final List<Component> children;

  const Grid({
    super.key,
    this.cols = 3,
    this.gap = 'md',
    required this.children,
  });

  String get _classes {
    const columns = {
      1: 'grid-cols-1',
      2: 'grid-cols-1 sm:grid-cols-2',
      3: 'grid-cols-1 sm:grid-cols-2 lg:grid-cols-3',
      4: 'grid-cols-1 sm:grid-cols-2 lg:grid-cols-4',
      5: 'grid-cols-2 sm:grid-cols-3 lg:grid-cols-5',
      6: 'grid-cols-2 sm:grid-cols-3 lg:grid-cols-6',
    };

    const gaps = {
      'none': 'gap-0',
      'sm': 'gap-2',
      'md': 'gap-4',
      'lg': 'gap-6',
      'xl': 'gap-8',
    };

    return 'grid ${columns[cols] ?? columns[3]} ${gaps[gap] ?? gaps['md']}';
  }

  @override
  Component build(BuildContext context) {
    return div(
      classes: _classes,
      children,
    );
  }
}

// Container component

class Container extends StatelessComponent {
  final String size;
  final List<Component> children;

  const Container({
    super.key,
    this.size = 'xl',
    required this.children,
  });

  @override
  Component build(BuildContext context) {
    const sizes = {
      'sm': 'max-w-screen-sm',
      'md': 'max-w-screen-md',
      'lg': 'max-w-screen-lg',
      'xl': 'max-w-screen-xl',
      '2xl': 'max-w-screen-2xl',
      'full': 'max-w-full',
    };

    return div(
      classes: 'mx-auto w-full px-4 sm:px-6 lg:px-8 '
          '${sizes[size] ?? sizes['xl']}',
      children,
    );
  }
}
```

Usage:

```dart
Container(
  children: [
    Grid(
      cols: 4,
      gap: 'lg',
      children: [
        // ProductCard(...),
        // ProductCard(...),
        // ProductCard(...),
      ],
    ),
  ],
)
```

For advanced animation and dark mode patterns, see `references/advanced-patterns.md`:

* **Pattern 5: Native CSS Animations** — dialog `@keyframes`, native popover API with `@starting-style`, `allow-discrete` transitions, and complete Jaspr dialog/overlay implementations using Tailwind CSS.
* **Pattern 6: Dark Mode** — theme state management, `localStorage` persistence, `prefers-color-scheme` detection, meta `theme-color` updates, and a Jaspr theme toggle component.

## Utility Functions

Unlike the React version, Jaspr does not require `clsx`, `tailwind-merge`, or a React-specific `cn()` helper by default. Prefer composing class strings directly or creating small Dart helpers when conditional classes are needed.

```dart
// lib/ui/utils.dart

String cn(
  Iterable<String?> classes,
) {
  return classes
      .where((value) => value != null && value.isNotEmpty)
      .join(' ');
}

// Focus ring utility

const focusRing =
    'focus-visible:outline-none focus-visible:ring-2 '
    'focus-visible:ring-ring focus-visible:ring-offset-2';

// Disabled utility

const disabled =
    'disabled:pointer-events-none disabled:opacity-50';
```

Usage:

```dart
div(
  classes: cn([
    'rounded-md border',
    focusRing,
    disabled,
    isActive ? 'bg-primary text-primary-foreground' : null,
  ]),
  [
    text('Content'),
  ],
)
```

For advanced v4 CSS patterns, the full v3-to-v4 migration checklist, and complete best practices, see `references/advanced-patterns.md`:

* **Custom `@utility`** — reusable CSS utilities for decorative lines and text gradients
* **Theme modifiers** — `@theme inline` (reference other CSS vars), `@theme static` (always output), `@import "tailwindcss" theme(static)`
* **Namespace overrides** — clearing default Tailwind color scales with `--color-*: initial`
* **Semi-transparent variants** — `color-mix()` for alpha scale generation
* **Container queries** — `--container-*` token definitions
* **v3→v4 migration checklist** — 10-item checklist covering config, directives, colors, dark mode, animations, and framework-specific migration considerations
* **Best practices** — full Do's and Don'ts list
