import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_router/router/entities/route.dart';

sealed class NomoPage<T> extends Page {
  final RouteInfo routeInfo;
  final AppRoute route;

  final Completer<T> _popCompleter = Completer<T>();

  Future<T> get popped => _popCompleter.future;

  void didPop([T? result]) {
    _popCompleter.complete(result);
  }

  final JsonMap? urlArguments;

  NomoPage({
    required this.routeInfo,
    required this.route,
    this.urlArguments,
    super.arguments,
    super.key,
  }) : super(name: routeInfo.path);

  @override
  Route<T> createRoute(BuildContext context) => switch (routeInfo) {
        ModalRouteInfo _ => NomoModalRoute(
            context: context,
            settings: this,
            barrierColor: Colors.black12,
            barrierDismissible: true,
            transitionDuration: const Duration(milliseconds: 240),
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              final transition = routeInfo.transition ??
                  NomoNavigator.of(context).defaultModalTransistion;
              return transition.getTransition(
                context,
                animation,
                secondaryAnimation,
                child,
              );
            },
            builder: (
              context,
            ) {
              return PopScope(
                onPopInvoked: (didPop) {
                  print("asdasd");
                },
                child: RouteInfoProvider(
                  route: this,
                  child: route.page,
                ),
              );
            },
          ),
        PageRouteInfo routeInfo => PageRouteBuilder(
            settings: this,
            transitionDuration: const Duration(milliseconds: 240),
            maintainState: true,
            opaque: true,
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              final transition = routeInfo.transition ??
                  NomoNavigator.of(context).defaultTransistion;
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
                child: route.page,
              );
            },
          ),
        MenuRouteInfoMixin _ => throw Exception("Should never be reached")
      };

  @override
  String toString() {
    return routeInfo.path;
  }
}

final class RootNomoPage<T> extends NomoPage<T> {
  RootNomoPage({
    required super.routeInfo,
    required super.route,
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
    required super.route,
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
