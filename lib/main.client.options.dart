// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:taska_admin/pages/home.dart' deferred as _home;
import 'package:taska_admin/pages/login.dart' deferred as _login;
import 'package:taska_admin/app.dart' deferred as _app;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'app': ClientLoader((p) => _app.App(), loader: _app.loadLibrary),
    'home': ClientLoader((p) => _home.Home(), loader: _home.loadLibrary),
    'login': ClientLoader(
      (p) => _login.LoginPage(),
      loader: _login.loadLibrary,
    ),
  },
);
