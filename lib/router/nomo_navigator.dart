import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/delegate.dart';
import 'package:nomo_router/router/entities/nomo_page.dart';
import 'package:nomo_router/router/entities/route_info.dart';

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

  void push(RoutePath path) => delegate.push(path);

  void replace(RoutePath path) => delegate.replace(path);

  void popUntil(bool Function(NomoPage) predicate) =>
      delegate.popUntil(predicate);

  void pop() => delegate.pop;

  RouteInfo get current => delegate.current;
}
