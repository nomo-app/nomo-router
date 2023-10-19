import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/entities/pages/nomo_page.dart';
import 'package:nomo_router/router/entities/routes/route_info.dart';
import 'package:nomo_router/router/extensions.dart';

typedef RouterConfiguration = (List<RouteSettings>, List<RouteSettings>);

typedef JsonMap = Map<String, dynamic>;

const emptyRoute = RouteSettings(name: "/");

class NomoRouteInformationParser
    extends RouteInformationParser<RouterConfiguration> {
  final List<RouteInfo> nestedRoutes;

  const NomoRouteInformationParser({
    required this.nestedRoutes,
  });

  @override
  Future<RouterConfiguration> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;

    if (uri.pathSegments.isEmpty) {
      return SynchronousFuture(
        (
          [const RouteSettings(name: '/')],
          [const RouteSettings(name: '/')],
        ),
      );
    }

    final routeSettings = RouteSettings(
      name: uri.path,
      arguments: uri.queryParameters,
    );

    final isNested = nestedRoutes.any(
      (element) => element.name == routeSettings.name,
    );

    return SynchronousFuture((
      [
        emptyRoute,
        if (!isNested) routeSettings,
      ],
      [
        emptyRoute,
        if (isNested) routeSettings,
      ],
    ));
  }

  @override
  RouteInformation restoreRouteInformation(RouterConfiguration configuration) {
    final (config, nestedConfig) = configuration as (
      List<NomoPage>,
      List<NomoPage>,
    );

    if (config.isEmpty || nestedConfig.isEmpty) {
      return RouteInformation(uri: "/".uri);
    }

    if (config.isNotEmpty && config.length > 1) {
      final page = config.last;
      final path = page.name;
      final arguments = page.urlArguments;
      return RouteInformation(uri: Uri(path: path, queryParameters: arguments));
    }

    if (nestedConfig.isNotEmpty) {
      final page = nestedConfig.last;

      final path = page.name;
      final arguments = page.urlArguments;
      return RouteInformation(uri: Uri(path: path, queryParameters: arguments));
    }

    return RouteInformation(uri: config.last.name.uri);
  }
}
