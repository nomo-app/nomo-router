import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/delegate.dart';
import 'package:nomo_router/router/entities/nomo_page.dart';
import 'package:nomo_router/router/entities/route_info.dart';
import 'package:nomo_router/router/entities/transitions.dart';

class NomoNavigator extends InheritedWidget {
  final NomoRouterDelegate delegate;
  final PageTransition defaultTransistion;

  const NomoNavigator({
    super.key,
    required super.child,
    required this.delegate,
    this.defaultTransistion = const PageFadeThroughTransition(),
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

  Future<T> push<T>(RoutePath path) => delegate.push(path);

  void replace(RoutePath path) => delegate.replace(path);

  void popUntil(bool Function(NomoPage) predicate) =>
      delegate.popUntil(predicate);

  bool pop<T>([T? result]) => delegate.pop(result);

  RouteInfo get current => delegate.current;
}
