import 'package:flutter/material.dart';
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

  Future<T> popUntilAndPush<T>(
      AppRoute route, bool Function(RouteInfo) predicate);

  bool pop<T>([T? result]);

  bool popRoot<T>([T? result]);

  Future<T?> pushModal<T>({
    required Widget modal,
    PageTransition transition = const PageFadeTransition(),
    bool useRootNavigator = true,
  });

  Future<T?> showModalWithKey<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  });

  Future<T?> showModal<T>({
    required WidgetBuilder builder,
    required BuildContext context,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  });

  RouteInfo get current;

  RouterConfigurationNomo get configuration;
}

class NomoNavigator extends InheritedWidget implements NomoNavigatorFunctions {
  final NomoRouterDelegate _delegate;
  final PageTransition defaultTransistion;
  final PageTransition defaultModalTransistion;
  final Duration defaultTransitionDuration;
  final Duration defaultModalTransitionDuration;

  const NomoNavigator({
    super.key,
    required super.child,
    required NomoRouterDelegate delegate,
    this.defaultModalTransistion = const PageFadeTransition(),
    this.defaultTransistion = const PageFadeThroughTransition(),
    this.defaultTransitionDuration = const Duration(milliseconds: 240),
    this.defaultModalTransitionDuration = const Duration(milliseconds: 200),
  }) : _delegate = delegate;

  static NomoNavigator of(BuildContext context) {
    final NomoNavigator? result =
        context.dependOnInheritedWidgetOfExactType<NomoNavigator>();
    assert(result != null, 'No RouteInfoProvider found in context');
    return result!;
  }

  static NomoNavigator? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NomoNavigator>();
  }

  static NomoNavigatorState get fromKey {
    final state = nomoNavigatorKey.currentState;
    assert(state != null, 'No NomoNavigatorState found in context');
    return state!;
  }

  static NomoNavigatorState? get maybeFromKey {
    return nomoNavigatorKey.currentState;
  }

  @override
  bool updateShouldNotify(covariant NomoNavigator oldWidget) {
    return oldWidget._delegate != _delegate;
  }

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
  bool pop<T>([T? result]) => _delegate.popWithKey(result);

  @override
  bool popRoot<T>([T? result]) => _delegate.popRoot(result);

  @override
  RouteInfo get current => _delegate.current;

  @override
  Future<T?> pushModal<T>({
    required Widget modal,
    PageTransition transition = const PageFadeTransition(),
    bool useRootNavigator = true,
  }) {
    return _delegate.pushModal(
      modal: modal,
      useRootNavigator: useRootNavigator,
      transition: transition,
    );
  }

  @override
  Future<T?> showModal<T>({
    required WidgetBuilder builder,
    required BuildContext context,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) {
    return _delegate.showModal(
      builder: builder,
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
    );
  }

  @override
  Future<T?> showModalWithKey<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) {
    return _delegate.showModalWithKey(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
    );
  }

  @override
  Future<T> popUntilAndPush<T>(
      AppRoute route, bool Function(RouteInfo route) predicate) {
    return _delegate.popUntilAndPush(route, predicate);
  }

  @override
  RouterConfigurationNomo get configuration =>
      _delegate.currentConfiguration.whereType<NomoPage>().toList();
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

  @override
  Future<T?> pushModal<T>({
    required Widget modal,
    PageTransition transition = const PageFadeTransition(),
    bool useRootNavigator = true,
  }) {
    return _delegate.pushModal(
      modal: modal,
      useRootNavigator: useRootNavigator,
      transition: transition,
    );
  }

  @override
  Future<T> popUntilAndPush<T>(
      AppRoute route, bool Function(RouteInfo route) predicate) {
    return _delegate.popUntilAndPush(route, predicate);
  }

  @override
  Future<T?> showModal<T>({
    required WidgetBuilder builder,
    required BuildContext context,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) {
    return _delegate.showModal(
      builder: builder,
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
    );
  }

  @override
  Future<T?> showModalWithKey<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) {
    return _delegate.showModalWithKey(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
    );
  }

  @override
  RouterConfigurationNomo get configuration =>
      _delegate.currentConfiguration.whereType<NomoPage>().toList();
}
