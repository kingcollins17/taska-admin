import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class EmbeddedCounter extends StatelessComponent {
  const EmbeddedCounter({this.count = 0, required this.onChange, super.key});

  final int count;
  final void Function(int) onChange;

  @override
  Component build(BuildContext context) {
    return div([]);
  }
}
