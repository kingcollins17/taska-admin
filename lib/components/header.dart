import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';


class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Component build(BuildContext context) {
    var activePath = RouteState.of(context).location;

    return header(classes: 'bg-slate-900 text-white shadow-md border-b border-slate-800', [
      nav(classes: 'max-w-6xl mx-auto px-6 py-4 flex items-center space-x-8', [
        for (var route in [
          (label: 'Home', path: '/'),
          (label: 'About', path: '/about'),
        ])
          div(classes: activePath == route.path ? 'font-semibold text-blue-400 border-b-2 border-blue-400 pb-1' : 'text-slate-300 hover:text-white transition-colors pb-1', [
            Link(to: route.path, child: Component.text(route.label)),
          ]),
      ]),
    ]);
  }
}
