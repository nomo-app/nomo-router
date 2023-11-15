import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/entities/nomo_page.dart';

class RouteInfoProvider extends InheritedWidget {
  final NomoPage route;

  const RouteInfoProvider({
    super.key,
    required super.child,
    required this.route,
  });

  static RouteInfoProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RouteInfoProvider>();
  }

  static RouteInfoProvider of(BuildContext context) {
    final RouteInfoProvider? result =
        context.dependOnInheritedWidgetOfExactType<RouteInfoProvider>();
    assert(result != null, 'No RouteInfoProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(RouteInfoProvider oldWidget) {
    return oldWidget.route != route;
  }
}
