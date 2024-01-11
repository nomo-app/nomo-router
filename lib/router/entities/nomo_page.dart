import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';

sealed class NomoPage<T> extends Page {
  final RouteInfo routeInfo;
  final Widget page;

  final Completer<T> _popCompleter = Completer<T>();

  Future<T> get popped => _popCompleter.future;

  void didPop([T? result]) {
    _popCompleter.complete(result);
  }

  final JsonMap? urlArguments;

  NomoPage({
    required this.routeInfo,
    required this.page,
    this.urlArguments,
    super.arguments,
    super.key,
  }) : super(name: routeInfo.path);

  @override
  Route<T> createRoute(BuildContext context) {
    final transition =
        routeInfo.transition ?? NomoNavigator.of(context).defaultTransistion;

    return switch (routeInfo) {
      ModalRouteInfo _ => NomoModalRoute(
          context: context,
          settings: this,
          barrierColor: Colors.black12,
          barrierDismissible: true,
          transitionDuration:
              NomoNavigator.of(context).defaultModalTransitionDuration,
          transitionBuilder: (context, anim, secAnim, child) {
            return transition.getTransition(context, anim, secAnim, child);
          },
          builder: (context) {
            return SafeArea(
              child: RouteInfoProvider(
                route: this,
                child: page,
              ),
            );
          },
        ),
      PageRouteInfo _ => PageRouteBuilder(
          settings: this,
          transitionDuration:
              NomoNavigator.of(context).defaultTransitionDuration,
          maintainState: true,
          opaque: true,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return transition.getTransition(
              context,
              animation,
              secondaryAnimation,
              child,
            );
          },
          pageBuilder: (context, _, __) {
            return RouteInfoProvider(
              route: this,
              child: page,
            );
          },
        ),
      MenuRouteInfoMixin _ => throw Exception("Should never be reached")
    };
  }

  @override
  String toString() {
    return routeInfo.path;
  }
}

final class RootNomoPage<T> extends NomoPage<T> {
  RootNomoPage({
    required super.routeInfo,
    required super.page,
    super.arguments,
    super.key,
    super.urlArguments,
  });

  @override
  String toString() {
    return "r(${super.toString()})";
  }
}

final class NestedNomoPage<T> extends NomoPage<T> {
  @override
  String toString() {
    return "n(${super.toString()})";
  }

  NestedNomoPage({
    required super.routeInfo,
    required super.page,
    super.arguments,
    super.key,
    super.urlArguments,
  });
}

class NomoModalRoute<T> extends RawDialogRoute<T> {
  NomoModalRoute({
    required BuildContext context,
    required WidgetBuilder builder,
    String? barrierLabel,
    bool useSafeArea = true,
    super.settings,
    super.anchorPoint,
    super.traversalEdgeBehavior,
    super.transitionBuilder,
    super.transitionDuration,
    super.barrierColor,
    super.barrierDismissible,
  }) : super(
          pageBuilder: (
            BuildContext buildContext,
            Animation<double> _,
            Animation<double> __,
          ) =>
              builder(buildContext),
          barrierLabel: barrierLabel ??
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
        );
}
