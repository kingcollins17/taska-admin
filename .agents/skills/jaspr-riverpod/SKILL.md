---

name: jaspr-riverpod
description: Use Riverpod 3 with Jaspr applications through jaspr_riverpod. Use when defining providers, reading or watching provider state in Jaspr components, managing provider scopes, syncing provider state between server and client, or working with asynchronous providers.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Jaspr Riverpod

Use `jaspr_riverpod` to manage application state in Jaspr with Riverpod 3.

It is a port of `flutter_riverpod` for Jaspr and supports all Riverpod providers and modifiers.

The main difference from Flutter Riverpod is that Jaspr does not use `Consumer`, `ConsumerWidget`, `StatefulConsumerWidget`, or `WidgetRef`. Instead, provider access is available through `BuildContext` extensions.

## Reading Providers

Use `context.read()` to read a provider without subscribing to changes.

```dart
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    final value = context.read(myProvider);

    return text(value);
  }
}
```

## Watching Providers

Use `context.watch()` when the component should rebuild whenever the provider changes.

```dart
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    final value = context.watch(myProvider);

    return text(value);
  }
}
```

Use `watch` when the UI depends on provider state.

## Listening to Providers

Use `context.listen()` to react to provider changes without rebuilding the component.

```dart
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    context.listen(myProvider, (previous, next) {
      // React to changes.
    });

    return div([
      text('Content'),
    ]);
  }
}
```

Use `context.listenManual()` when manual listener control is required.

## Provider Operations

`BuildContext` provides extensions for common Riverpod operations:

```dart
context.read(provider);
context.watch(provider);
context.listen(provider, listener);
context.listenManual(provider, listener);
context.invalidate(provider);
context.refresh(provider);
context.exists(provider);
```

### Invalidate

Mark a provider as needing to be recomputed:

```dart
context.invalidate(myProvider);
```

### Refresh

Immediately recompute a provider and return its new value:

```dart
final value = context.refresh(myProvider);
```

### Exists

Check whether a provider already exists in the current scope:

```dart
final exists = context.exists(myProvider);
```

## Scoped Rebuilds with Builder

Use `Builder` when only part of a component should rebuild when provider state changes.

```dart
Builder(
  builder: (context) {
    final value = context.watch(myProvider);

    return text(value);
  },
)
```

This is the Jaspr equivalent of using a scoped `Consumer` in Flutter Riverpod.

## ProviderScope

Wrap the application or a subtree with `ProviderScope` to provide a Riverpod container.

```dart
ProviderScope(
  child: App(),
)
```

Providers accessed inside the scope can read and watch the application's Riverpod state.

Provider scopes can also be nested to create isolated or overridden provider state.

## Provider Definitions

Use standard Riverpod provider types.

### Provider

```dart
final userProvider = Provider<User>((ref) {
  return User();
});
```

### FutureProvider

```dart
final userProvider = FutureProvider<User>((ref) async {
  return fetchUser();
});
```

### StreamProvider

```dart
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return messageStream();
});
```

### NotifierProvider

```dart
final counterProvider =
    NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    state++;
  }
}
```

Read or watch these providers from Jaspr components through `BuildContext`.

```dart
final count = context.watch(counterProvider);
```

## Async Providers

Async providers expose an `AsyncValue`.

```dart
final user = context.watch(userProvider);

return user.when(
  data: (value) => text(value.name),
  loading: () => text('Loading...'),
  error: (error, stack) => text('Error: $error'),
);
```

During server-side rendering, async providers are awaited before rendering completes.

This allows server-rendered components to use async provider data normally.

## Provider Synchronization

`jaspr_riverpod` can synchronize provider state between the server and client.

Configure synchronization on `ProviderScope`:

```dart
ProviderScope(
  sync: [
    myProvider.syncWith('some-unique-key'),
  ],
  child: App(),
)
```

The synchronization key must be unique for the provider being synchronized.

### Supported Providers

Provider synchronization supports:

* `NotifierProvider`
* `AsyncNotifierProvider`
* `Provider`
* `FutureProvider`
* `StreamProvider`
* `StateProvider`

### Custom Codecs

A custom codec can be provided when the provider's state requires custom serialization.

```dart
myProvider.syncWith(
  'some-unique-key',
  codec: myCodec,
)
```

Use synchronization when server-rendered provider state needs to be available to the client without unnecessarily fetching or computing the same state again.

## Provider Overrides and Scopes

Provider scopes can override providers for a specific part of the application.

Use nested `ProviderScope`s when a subtree needs different provider values or isolated state.

```dart
ProviderScope(
  overrides: [
    myProvider.overrideWithValue(value),
  ],
  child: MyComponent(),
)
```

This is useful for:

* Feature-specific configuration
* Testing
* Authentication-dependent state
* Providing different implementations
* Isolating state between application sections

## Server and Client Usage

Jaspr applications can use the same Riverpod providers during server-side rendering and client-side execution.

When using asynchronous providers:

1. The provider executes during server rendering.
2. Jaspr waits for the async result.
3. The component renders using the resolved state.
4. Synchronized providers can transfer the state to the client.

Keep provider logic independent from UI components so the same providers can be used across server and client execution.

## Best Practices

### Watch Only What the UI Needs

Use `context.watch()` only for state that should trigger a rebuild.

Use `context.read()` when you only need the current value or want to perform an action without subscribing.

### Use Builder for Localized Rebuilds

When only a small section of a component depends on changing state, use `Builder` to limit the rebuild scope.

### Keep Business Logic in Providers

Components should primarily render state and invoke provider actions.

Put data fetching, transformations, and business logic inside providers and not directly inside component build methods.

### Use Scopes for Overrides

Use nested `ProviderScope`s when a subtree needs different provider implementations or values.

### Synchronize Server State When Appropriate

Use `syncWith()` for provider state that should be transferred from server rendering to the client.

Use unique synchronization keys and a custom codec when the default serialization is insufficient.

## Flutter Riverpod to Jaspr Riverpod

| Flutter Riverpod         | Jaspr Riverpod                           |
| ------------------------ | ---------------------------------------- |
| `Consumer`               | `Builder`                                |
| `ConsumerWidget`         | `StatelessComponent` + `context.watch()` |
| `StatefulConsumerWidget` | Jaspr component + `context.watch()`      |
| `WidgetRef`              | `BuildContext`                           |
| `ref.read()`             | `context.read()`                         |
| `ref.watch()`            | `context.watch()`                        |
| `ref.listen()`           | `context.listen()`                       |
| `ref.invalidate()`       | `context.invalidate()`                   |
| `ref.refresh()`          | `context.refresh()`                      |
| `ProviderScope`          | `ProviderScope`                          |

## Quick Reference

```dart
// Read
final value = context.read(myProvider);

// Watch
final value = context.watch(myProvider);

// Listen
context.listen(myProvider, (previous,
```
