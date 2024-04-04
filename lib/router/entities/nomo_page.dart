import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_router/router/entities/route.dart';
import 'package:nomo_router/router/entities/transitions.dart';

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

  static Route<T> _pageRoute<T>({
    required RouteInfo routeInfo,
    required NomoPage<T> pageRoute,
    required Duration transitionDuration,
    required PageTransition transition,
  }) {
    return PageRouteBuilder(
      settings: pageRoute,
      transitionDuration: transitionDuration,
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
        if (navInfo.containsValue(pageRoute.key) == false &&
            pageRoute is! NestedNavigatorPage) {
          return RouteInfoProvider(
            route: pageRoute,
            type: RouteType.page,
            child: pageRoute.pageWithoutKey,
          );
        }
        return RouteInfoProvider(
          route: pageRoute,
          type: RouteType.page,
          child: pageRoute.page,
        );
      },
    );
  }

  static Route<T> _modalRoute<T>({
    required RouteInfo routeInfo,
    required NomoPage<T> pageRoute,
    required Duration transitionDuration,
    required PageTransition transition,
    required BuildContext context,
  }) {
    return NomoModalRoute(
      context: context,
      settings: pageRoute,
      barrierColor: Colors.black12,
      barrierDismissible: true,
      transitionDuration: transitionDuration,
      transitionBuilder: (context, anim, secAnim, child) {
        return transition.getTransition(context, anim, secAnim, child);
      },
      builder: (context) {
        final navInfo = NomoNavigatorInformationProvider.of(context).keys;

        if (navInfo.containsValue(pageRoute.key) == false) {
          return SafeArea(
            child: RouteInfoProvider(
              route: pageRoute,
              type: RouteType.modal,
              child: Center(child: pageRoute.pageWithoutKey),
            ),
          );
        }

        return SafeArea(
          child: RouteInfoProvider(
            route: pageRoute,
            type: RouteType.modal,
            child: Center(child: pageRoute.page),
          ),
        );
      },
    );
  }

  @override
  Route<T> createRoute(BuildContext context) {
    return switch (routeInfo) {
      DynamicRouteInfo dynamicRouteInfo => () {
          final type = dynamicRouteInfo.when.call(context);

          return switch (type) {
            RouteType.modal => _modalRoute(
                routeInfo: dynamicRouteInfo,
                pageRoute: this,
                transitionDuration:
                    NomoNavigator.of(context).defaultModalTransitionDuration,
                transition: dynamicRouteInfo.transition ??
                    NomoNavigator.of(context).defaultModalTransistion,
                context: context,
              ),
            RouteType.page => _pageRoute(
                routeInfo: dynamicRouteInfo,
                pageRoute: this,
                transitionDuration:
                    NomoNavigator.of(context).defaultTransitionDuration,
                transition: dynamicRouteInfo.transition ??
                    NomoNavigator.of(context).defaultTransistion,
              ),
          };
        }.call(),
      ModalRouteInfo modalRouteInfo => _modalRoute(
          routeInfo: modalRouteInfo,
          pageRoute: this,
          transitionDuration:
              NomoNavigator.of(context).defaultModalTransitionDuration,
          transition: modalRouteInfo.transition ??
              NomoNavigator.of(context).defaultModalTransistion,
          context: context,
        ),
      _ => _pageRoute(
          routeInfo: routeInfo,
          pageRoute: this,
          transitionDuration:
              NomoNavigator.of(context).defaultTransitionDuration,
          transition: routeInfo.transition ??
              NomoNavigator.of(context).defaultTransistion,
        ),
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
  final NestedNavigator routeInfo;

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
