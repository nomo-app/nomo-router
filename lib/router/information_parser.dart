import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/extensions.dart';

typedef RouterConfiguration = List<RouteSettings>;

typedef JsonMap = Map<String, dynamic>;

const emptyRoute = RouteSettings(name: "/");

class NomoRouteInformationParser
    extends RouteInformationParser<RouterConfiguration> {
  const NomoRouteInformationParser();

  @override
  Future<RouterConfiguration> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;

    if (uri.pathSegments.isEmpty) {
      return SynchronousFuture(
        [const RouteSettings(name: '/')],
      );
    }

    final paths = uri.pathSegments.map((e) => "/$e");
    final args = uri.queryParameters;

    String currentPath = "";

    final config = [
      const RouteSettings(name: '/'),
      for (final path in paths)
        () {
          currentPath += path;
          return RouteSettings(
            name: currentPath,
            arguments: paths.last == path ? args : null,
          );
        }.call()
    ];

    return SynchronousFuture(config);
  }

  @override
  RouteInformation restoreRouteInformation(RouterConfiguration configuration) {
    if (configuration.isEmpty) {
      return RouteInformation(uri: "/".uri);
    }

    return RouteInformation(uri: configuration.last.name.uri);
  }
}
