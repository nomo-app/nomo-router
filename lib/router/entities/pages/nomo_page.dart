import 'package:flutter/material.dart';
import 'package:nomo_router/router/entities/routes/route_info.dart';
import 'package:nomo_router/router/information_parser.dart';
import 'package:nomo_router/router/nomo_navigator.dart';

class NomoPage<T> extends Page<T> implements RouteSettings {
  final RouteInfo routeInfo;
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
}
