import 'package:flutter/widgets.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_router/router/entities/route.dart';
import 'package:nomo_router/router/entities/transitions.dart';

class NomoNavigator extends InheritedWidget {
  final NomoRouterDelegate delegate;
  final PageTransition defaultTransistion;
  final PageTransition defaultModalTransistion;

  const NomoNavigator({
    super.key,
    required super.child,
    required this.delegate,
    this.defaultModalTransistion = const PageFadeTransition(),
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

  Future<T> push<T>(AppRoute route) => delegate.push(route);

  Future<T> pushNamed<T>(
    String routeName, {
    Object? arguments,
    JsonMap? urlArguments,
  }) =>
      delegate.pushNamed(routeName, urlArgs: urlArguments);

  Future<T> replace<T>(AppRoute route) => delegate.replace(route);

  Future<T> replaceNamed<T>(
    String routeName, {
    Object? arguments,
    JsonMap? urlArguments,
  }) =>
      delegate.replaceNamed(routeName, urlArgs: urlArguments);

  void popUntil(bool Function(RouteInfo) predicate) =>
      delegate.popUntil(predicate);

  bool pop<T>([T? result]) => delegate.pop(result);

  bool popRoot<T>([T? result]) => delegate.popRoot(result);

  RouteInfo get current => delegate.current;
}
