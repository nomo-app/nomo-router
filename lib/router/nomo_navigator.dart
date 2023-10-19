import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/delegate.dart';
import 'package:nomo_router/router/entities/pages/nomo_page.dart';
import 'package:nomo_router/router/entities/routes/route_info.dart';
import 'package:nomo_router/router/information_parser.dart';

class NomoNavigator extends InheritedWidget {
  final NomoRouterDelegate delegate;

  const NomoNavigator({
    super.key,
    required super.child,
    required this.delegate,
  });

  static NomoNavigator of(BuildContext context) {
    final NomoNavigator? result =
        context.dependOnInheritedWidgetOfExactType<NomoNavigator>();
    assert(result != null, 'No RouteInfoProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant NomoNavigator oldWidget) {
    return oldWidget.delegate != delegate;
  }

  void push(RouteInfo info, {Object? arguments, JsonMap? urlArguments}) {
    delegate.pushRouteInfo(
      info,
      arguments: arguments,
      urlArguments: urlArguments,
    );
  }

  void pop() {
    delegate.popRoute();
  }
}

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
