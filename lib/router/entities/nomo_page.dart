import 'package:flutter/material.dart';
import 'package:nomo_router/router/entities/route_info.dart';
import 'package:nomo_router/router/information_parser.dart';
import 'package:nomo_router/router/providers/route_info_provider.dart';

final class RoutePath extends RouteSettings {
  final JsonMap? urlArguments;

  const RoutePath({
    required super.name,
    this.urlArguments,
    super.arguments,
  });
}

sealed class NomoPage<T> extends Page<T> implements RoutePath {
  final RouteInfo routeInfo;

  @override
  final JsonMap? urlArguments;

  NomoPage({
    required this.routeInfo,
    this.urlArguments,
    super.arguments,
    super.key,
  }) : super(name: routeInfo.name);

  @override
  Route<T> createRoute(BuildContext context) => switch (routeInfo) {
        ModalRouteInfo routeInfo => PageRouteBuilder(
            settings: this,
            opaque: false,
            barrierColor: Colors.black12,
            barrierDismissible: true,
            fullscreenDialog: true,
            transitionDuration: const Duration(milliseconds: 240),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            pageBuilder: (context, _, __) {
              return RouteInfoProvider(
                route: this,
                child: routeInfo.page,
              );
            },
          ),
        PageRouteInfo routeInfo => PageRouteBuilder(
            settings: this,
            transitionDuration: const Duration(milliseconds: 240),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            pageBuilder: (context, _, __) {
              return RouteInfoProvider(
                route: this,
                child: routeInfo.page,
              );
            },
          )
      };

  @override
  String toString() {
    return routeInfo.name;
  }
}

final class RootNomoPage<T> extends NomoPage<T> {
  RootNomoPage({
    required super.routeInfo,
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
    super.arguments,
    super.key,
    super.urlArguments,
  });
}
