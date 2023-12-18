import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/entities/route_info.dart';

abstract class NomoAppRouter {
  final List<RouteInfo> routeInfos;

  final Map<String, AppRoute Function([dynamic args])> routes;

  AppRoute Function([dynamic args]) getRouteForPath(String path) {
    final route = routes[path];
    if (route == null) {
      throw Exception("Route not found for path: $path");
    }
    return route;
  }

  const NomoAppRouter(this.routes, this.routeInfos);
}

class AppRoute {
  final Widget page;
  final String name;

  const AppRoute({
    required this.page,
    required this.name,
  });
}
