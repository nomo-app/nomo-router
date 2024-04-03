import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_router/router/entities/route.dart';

sealed class NomoPage<T> extends Page {
  final RouteInfo routeInfo;
  final AppRoute? route;
  final Widget page;
  final Completer<T> _popCompleter = Completer<T>();

  final Widget pageWithoutKey;

  Future<T> get popped => _popCompleter.future;

  void didPop([T? result]) {
    _popCompleter.complete(result);
  }

  final JsonMap? urlArguments;

  NomoPage({
    required this.routeInfo,
    required this.page,
    required this.pageWithoutKey,
    required this.route,
    this.urlArguments,
    super.arguments,
    super.key,
  }) : super(name: routeInfo.path);

  NomoPage<T> get copy {
    return switch (this) {
      NestedNomoPage<T> r => NestedNomoPage<T>(
          routeInfo: routeInfo,
          page: page,
          pageWithoutKey: pageWithoutKey,
          route: route,
          navKey: r.navKey,
          arguments: arguments,
          key: UniqueKey(),
          urlArguments: urlArguments,
        ),
      RootNomoPage<T> _ => RootNomoPage<T>(
          routeInfo: routeInfo,
          page: page,
          pageWithoutKey: pageWithoutKey,
          route: route,
          arguments: arguments,
          key: UniqueKey(),
          urlArguments: urlArguments,
        ),
    };
  }

  @override
  Route<T> createRoute(BuildContext context) {
    final transition =
        routeInfo.transition ?? NomoNavigator.of(context).defaultTransistion;

    if (routeInfo is ModalRouteInfo) {
      final modalTransition = routeInfo.transition ??
          NomoNavigator.of(context).defaultModalTransistion;
      final modalRouteInfo = routeInfo as ModalRouteInfo;

      final usePage = modalRouteInfo.whenPage?.call(context);

      if (usePage == false) {
        return NomoModalRoute(
          context: context,
          settings: this,
          barrierColor: Colors.black12,
          barrierDismissible: true,
          transitionDuration:
              NomoNavigator.of(context).defaultModalTransitionDuration,
          transitionBuilder: (context, anim, secAnim, child) {
            return modalTransition.getTransition(context, anim, secAnim, child);
          },
          builder: (context) {
            final navInfo = NomoNavigatorInformationProvider.of(context).keys;

            if (navInfo.containsValue(key) == false) {
              return RouteInfoProvider(
                route: this,
                isModal: true,
                isPage: false,
                child: pageWithoutKey,
              );
            }

            return SafeArea(
              child: RouteInfoProvider(
                route: this,
                isModal: true,
                isPage: false,
                child: Center(child: page),
              ),
            );
          },
        );
      }
    }

    return PageRouteBuilder(
      settings: this,
      transitionDuration: NomoNavigator.of(context).defaultTransitionDuration,
      // reverseTransitionDuration: Duration.zero,
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
        final navInfo = NomoNavigatorInformationProvider.of(context).keys;

        if (navInfo.containsValue(key) == false &&
            this is! NestedNavigatorPage) {
          return RouteInfoProvider(
            route: this,
            isModal: false,
            isPage: true,
            child: pageWithoutKey,
          );
        }
        return RouteInfoProvider(
          route: this,
          isModal: false,
          isPage: true,
          child: page,
        );
      },
    );
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
    required super.route,
    required super.pageWithoutKey,
    super.arguments,
    super.key,
    super.urlArguments,
  });
}

final class NestedNomoPage<T> extends NomoPage<T> {
  final Key navKey;

  @override
  String toString() {
    return "$navKey${super.toString()}";
  }

  NestedNomoPage({
    required super.routeInfo,
    required super.page,
    required super.route,
    required this.navKey,
    required super.pageWithoutKey,
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

final class NestedNavigatorPage extends RootNomoPage {
  @override
  final NestedPageRouteInfo routeInfo;

  NestedNavigatorPage({
    required this.routeInfo,
    required super.page,
    required super.route,
    required super.pageWithoutKey,
    super.arguments,
    super.key,
    super.urlArguments,
  }) : super(
          routeInfo: routeInfo,
        );

  @override
  String toString() {
    return "NestedNav${routeInfo.key}";
  }
}
