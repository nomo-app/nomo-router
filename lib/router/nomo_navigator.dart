import 'package:flutter/widgets.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_router/router/entities/route.dart';
import 'package:nomo_router/router/entities/transitions.dart';

abstract class NomoNavigatorFunctions {
  Future<T> push<T>(AppRoute route);

  Future<T> pushNamed<T>(
    String routeName, {
    Object? arguments,
    JsonMap? urlArguments,
  });

  Future<T> replace<T>(AppRoute route);

  Future<T> replaceAll<T>(AppRoute route);

  Future<T> replaceNamed<T>(
    String routeName, {
    Object? arguments,
    JsonMap? urlArguments,
  });

  void popUntil(bool Function(RouteInfo) predicate);

  bool pop<T>([T? result]);

  bool popRoot<T>([T? result]);

  RouteInfo get current;
}

class NomoNavigator extends InheritedWidget implements NomoNavigatorFunctions {
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

  @override
  Future<T> push<T>(AppRoute route) => delegate.push(route);

  @override
  Future<T> pushNamed<T>(
    String routeName, {
    Object? arguments,
    JsonMap? urlArguments,
  }) =>
      delegate.pushNamed(routeName, urlArgs: urlArguments);

  @override
  Future<T> replace<T>(AppRoute route) => delegate.replace(route);

  @override
  Future<T> replaceAll<T>(AppRoute route) => delegate.replaceAll(route);

  @override
  Future<T> replaceNamed<T>(
    String routeName, {
    Object? arguments,
    JsonMap? urlArguments,
  }) =>
      delegate.replaceNamed(routeName, urlArgs: urlArguments);

  @override
  void popUntil(bool Function(RouteInfo) predicate) =>
      delegate.popUntil(predicate);

  @override
  bool pop<T>([T? result]) => delegate.pop(result);

  @override
  bool popRoot<T>([T? result]) => delegate.popRoot(result);

  @override
  RouteInfo get current => delegate.current;
}

class NomoNavigatorWrapper extends StatefulWidget {
  final Widget child;
  final NomoRouterDelegate _delegate;

  const NomoNavigatorWrapper({
    super.key,
    required this.child,
    required NomoRouterDelegate delegate,
  }) : _delegate = delegate;

  @override
  State<NomoNavigatorWrapper> createState() => NomoNavigatorState();
}

class NomoNavigatorState extends State<NomoNavigatorWrapper>
    implements NomoNavigatorFunctions {
  NomoRouterDelegate get _delegate => widget._delegate;

  @override
  Future<T> push<T>(AppRoute route) => _delegate.push(route);

  @override
  Future<T> pushNamed<T>(
    String routeName, {
    Object? arguments,
    JsonMap? urlArguments,
  }) =>
      _delegate.pushNamed(routeName, urlArgs: urlArguments);

  @override
  Future<T> replace<T>(AppRoute route) => _delegate.replace(route);

  @override
  Future<T> replaceAll<T>(AppRoute route) => _delegate.replaceAll(route);

  @override
  Future<T> replaceNamed<T>(
    String routeName, {
    Object? arguments,
    JsonMap? urlArguments,
  }) =>
      _delegate.replaceNamed(routeName, urlArgs: urlArguments);

  @override
  void popUntil(bool Function(RouteInfo) predicate) =>
      _delegate.popUntil(predicate);

  @override
  bool pop<T>([T? result]) => _delegate.pop(result);

  @override
  bool popRoot<T>([T? result]) => _delegate.popRoot(result);

  @override
  RouteInfo get current => _delegate.current;

  @override
  Widget build(BuildContext context) => widget.child;
}
