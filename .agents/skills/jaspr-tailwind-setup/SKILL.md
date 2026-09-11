---
name: jaspr-tailwindcss-v4
description: Set up Tailwind CSS v4 in a Jaspr (Dart web framework) project using the jaspr_tailwind package. Use this whenever the user wants to add Tailwind CSS to a Jaspr app, style Jaspr components with Tailwind utility classes, or mentions jaspr_tailwind, styles.tw.css, or Tailwind config for Jaspr/Dart projects.
---

# Jaspr + Tailwind CSS v4 Setup

Precise, ordered steps for wiring Tailwind CSS v4 into a Jaspr project via `jaspr_tailwind`. Follow in order — later steps assume earlier ones are done.

## 1. Install the standalone Tailwind CLI

`jaspr_tailwind` requires the `tailwindcss` executable on PATH (it does not bundle Tailwind itself).

```bash
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-<your-platform>
chmod +x tailwindcss-<your-platform>
mv tailwindcss-<your-platform> /usr/local/bin/tailwindcss   # or any dir on PATH
```

Verify: `tailwindcss -h`

## 2. Add the dev dependency

```bash
dart pub add jaspr_tailwind --dev
```

## 3. Create the input CSS file

Add `web/styles.tw.css` (any file under `web/` ending in `.tw.css` is picked up automatically and compiled to a same-named `.css` file):

```css
@import "tailwindcss";
```

Do **not** use the v3 `@tailwind base/components/utilities` directives — v4 uses this single `@import`.

## 4. Link the compiled stylesheet

The CLI outputs `styles.css` next to the `.tw.css` source. Link the **`.css`** file, not the `.tw.css` file.

**Static/server mode** (`lib/main.dart`):

```dart
import 'package:jaspr/server.dart';
import './app.dart';

void main() {
  runApp(Document(
    title: 'My Tailwind Site',
    head: [
      link(href: 'styles.css', rel: 'stylesheet'),
    ],
    body: App(),
  ));
}
```

**Client mode** (`web/index.html`):

```html
<head>
  <link href="styles.css" rel="stylesheet" />
</head>
```

## 5. Use Tailwind classes in components

Pass classes via the `classes:` parameter on Jaspr elements:

```dart
class SimpleCard extends StatelessComponent {
  const SimpleCard({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Component build(BuildContext context) {
    return div(classes: 'p-6 max-w-sm mx-auto bg-white rounded-xl shadow-lg flex items-center space-x-4', [
      div(classes: 'shrink-0', [
        img(classes: 'h-12 w-12', src: '/img/logo.svg', alt: '$title Logo'),
      ]),
      div([
        div(classes: 'text-xl font-medium text-black', [.text(title)]),
        p(classes: 'text-slate-500', [.text(message)]),
      ]),
    ]);
  }
}
```

No config file is needed by default — `jaspr_tailwind` auto-scans the project's `.dart` files for class names.

## 6. Custom config (optional)

For v4, prefer **CSS-first configuration** (`@theme`, CSS variables, etc. inside `styles.tw.css`) over a JS config file.

Only add `tailwind.config.js` if you need something CSS-first config can't express. If you do, set `content` explicitly so Dart files are scanned:

```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./{lib,web}/**/*.dart"],
  theme: { extend: {} },
  plugins: [],
};
```

⚠️ Caveat: with a custom `content` config, changes to those files do **not** trigger auto-recompilation — only edits to `.dart` files do.

## 7. VS Code IntelliSense (optional)

1. Install the **Tailwind CSS IntelliSense** extension.
2. Add to User Settings (JSON):

```json
{
  "tailwindCSS.includeLanguages": { "dart": "html" },
  "tailwindCSS.classAttributes": ["class", "className", "ngClass", "class:list", "classes"],
  "tailwindCSS.experimental.classRegex": ["\\W\\s*classes:\\s*'(.*)'"]
}
```

3. Reload the extension.

(On v4 no config file is needed for the extension to detect the Tailwind version — this is only required on v3.)

## Quick checklist

- [ ] `tailwindcss` CLI on PATH
- [ ] `jaspr_tailwind` added as dev dependency
- [ ] `web/*.tw.css` contains `@import "tailwindcss";`
- [ ] Compiled `.css` (not `.tw.css`) linked in `Document.head` (server) or `index.html` (client)
- [ ] Classes applied via `classes:` parameter