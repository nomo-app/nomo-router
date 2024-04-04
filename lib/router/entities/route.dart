import 'package:flutter/widgets.dart';
import 'package:nomo_router/nomo_router.dart';

abstract class NomoAppRouter {
  final List<RouteInfo> routeInfos;
  final List<NestedNavigator> nestedRoutes;

  final Map<String, AppRoute Function([dynamic args])> routes;

  AppRoute Function([dynamic args]) getRouteForPath(String path) {
    final route = routes[path];
    if (route == null) {
      return ([args]) => const NotFoundRoute();
    }
    return route;
  }

  const NomoAppRouter(this.routes, this.routeInfos, this.nestedRoutes);
}

class AppRoute {
  final Widget page;
  final String name;

  const AppRoute({
    required this.page,
    required this.name,
  });
}
