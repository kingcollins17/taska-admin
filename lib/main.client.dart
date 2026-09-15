/// The entrypoint for the **client** app.
library;

import 'package:jaspr/client.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'app.dart';
import 'main.client.options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultClientOptions,
  );
 
  runApp( ProviderScope(child: App()));
}
