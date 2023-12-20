import 'package:nomo_router/nomo_router.dart';

extension UriUtil on String? {
  Uri get uri {
    return Uri.parse(this ?? "");
  }

  Uri? get uriOrNull {
    return Uri.tryParse(this ?? "");
  }
}

extension RouteInfoUtil on Iterable<RouteInfo> {
  Iterable<RouteInfo> get expanded {
    return [
      for (final route in this) ...[
        route,
        ...route.underlying,
      ]
    ];
  }

  Iterable<MenuRouteInfoMixin> get toMenuRoutes {
    return whereType<MenuRouteInfoMixin>();
  }
}
