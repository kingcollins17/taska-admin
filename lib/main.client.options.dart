// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:taska_admin/pages/guarantors.dart' deferred as _guarantors;
import 'package:taska_admin/pages/home.dart' deferred as _home;
import 'package:taska_admin/pages/interviews.dart' deferred as _interviews;
import 'package:taska_admin/pages/kyc.dart' deferred as _kyc;
import 'package:taska_admin/pages/login.dart' deferred as _login;
import 'package:taska_admin/pages/users.dart' deferred as _users;
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
    'guarantors': ClientLoader(
      (p) => _guarantors.GuarantorsPage(),
      loader: _guarantors.loadLibrary,
    ),
    'home': ClientLoader((p) => _home.Home(), loader: _home.loadLibrary),
    'interviews': ClientLoader(
      (p) => _interviews.InterviewsPage(),
      loader: _interviews.loadLibrary,
    ),
    'kyc': ClientLoader((p) => _kyc.KycPage(), loader: _kyc.loadLibrary),
    'login': ClientLoader(
      (p) => _login.LoginPage(),
      loader: _login.loadLibrary,
    ),
    'users': ClientLoader(
      (p) => _users.UsersPage(),
      loader: _users.loadLibrary,
    ),
  },
);
