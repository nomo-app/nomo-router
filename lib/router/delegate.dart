import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/router/entities/pages/nomo_page.dart';
import 'package:nomo_router/router/entities/pages/not_found.dart';
import 'package:nomo_router/router/entities/routes/route_info.dart';
import 'package:nomo_router/router/extensions.dart';
import 'package:nomo_router/router/information_parser.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class NomoRouterDelegate extends RouterDelegate<RouterConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouterConfiguration> {
  final GlobalKey<NavigatorState> _navigatorKey;

  late final NomoPage nestedRouterPage;

  final nestedStackNotifier = ValueNotifier<List<NomoPage>>([]);

  NomoRouterDelegate(
    this._navigatorKey, {
    required this.routes,
    required this.nestedRoutes,
    required this.nestedNavigatorWrapper,
  }) {
    nestedRouterPage = NomoPage(
      routeInfo: PageRouteInfo(
        name: "/",
        page: nestedNavigatorWrapper(
          ValueListenableBuilder(
            valueListenable: nestedStackNotifier,
            builder: (context, pages, child) {
              return Navigator(
                pages: pages,
                onPopPage: (route, result) {
                  if (!route.didPop(result)) {
                    return false;
                  }
                  onNestedConfigChanged(pages.sublist(0, pages.length - 1));
                  return true;
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  RouterConfiguration? get currentConfiguration => (_stack, _nestedStack);

  List<NomoPage> _stack = [];
  List<NomoPage> _nestedStack = [];

  final List<RouteInfo> routes;
  final List<RouteInfo> nestedRoutes;

  final Widget Function(Widget nav) nestedNavigatorWrapper;

  RouteInfo get current {
    return _nestedStack.last.routeInfo;
  }

  bool _handlePopPage(Route route, dynamic result) {
    if (_stack.length <= 1) {
      return false;
    }

    if (!route.didPop(result)) {
      return false;
    }

    _stack = _stack.sublist(0, _stack.length - 1);
    notifyListeners();
    return true;
  }

  void onNestedConfigChanged(List<RouteSettings> nestedConfig) {
    final nestedPages = nestedConfig as List<NomoPage>;

    _nestedStack = nestedPages;
    nestedStackNotifier.value = List.of(_nestedStack);

    _stack = [
      nestedRouterPage,
      ..._stack.sublist(1),
    ];

    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    /// If the nested stack is empty, add the first page
    if (_nestedStack.isEmpty) {
      _nestedStack.add(_pageFromRouteInfo(nestedRoutes.first));
      nestedStackNotifier.value = _nestedStack;
    }

    /// If the root stack is empty, add the first page which contains the nested stack
    if (_stack.isEmpty) {
      _stack.add(nestedRouterPage);
    }

    // print("Root Stack: $_stack");
    // print("Nested Stack: $_nestedStack");
    // print("_____________");

    return Navigator(
      key: _navigatorKey,
      onPopPage: _handlePopPage,
      pages: List.of(_stack),
    );
  }

  @override
  Future<void> setNewRoutePath(RouterConfiguration configuration) async {
    final (config, nestedConfig) = configuration;

    List<NomoPage> nestedPages = [];

    for (final nestedRouteSettings in nestedConfig) {
      final nestedRouteInfo = nestedRoutes.singleWhereOrNull(
        (routeInfo) => routeInfo.name == nestedRouteSettings.name,
      );

      if (nestedRouteInfo == null) continue;

      final nestedPage = _pageFromNestedRoute(
        RouteInformation(uri: nestedRouteInfo.name.uri),
        urlArguments: nestedRouteSettings.arguments as JsonMap?,
      );

      nestedPages.add(nestedPage);
    }

    _nestedStack = nestedPages;
    nestedStackNotifier.value = List.of(_nestedStack);

    List<NomoPage> pages = [];
    for (final routeSettings in config) {
      if (routeSettings.name == "/") {
        pages.add(nestedRouterPage);
        continue;
      }

      final routeInfo = routes.singleWhereOrNull(
        (routeInfo) => routeInfo.name == routeSettings.name,
      );

      if (routeInfo == null) continue;

      final page = _pageFromRouteInfo(
        routeInfo,
        urlArguments: routeSettings.arguments as JsonMap?,
      );

      pages.add(page);
    }

    _stack = [...pages];

    notifyListeners();

    return SynchronousFuture(null);
  }

  void pushRouteInfo(
    RouteInfo info, {
    JsonMap? urlArguments,
    Object? arguments,
  }) {
    final page = _pageFromRouteInfo(
      info,
      urlArguments: urlArguments,
      arguments: arguments,
    );
    final isNested = nestedRoutes.contains(info);

    if (isNested) {
      _nestedStack.add(page);
      nestedStackNotifier.value = List.of(_nestedStack);

      _stack = [nestedRouterPage];
      notifyListeners();
      return;
    }

    _stack.add(page);
    notifyListeners();
  }

  NomoPage _pageFromRouteInfo(
    RouteInfo route, {
    Object? arguments,
    JsonMap? urlArguments,
  }) {
    return NomoPage(
      routeInfo: route,
      arguments: arguments,
      urlArguments: urlArguments,
    );
  }

  NomoPage _pageFromNestedRoute(
    RouteInformation routeInformation, {
    JsonMap? urlArguments,
    Object? arguments,
  }) {
    final route = nestedRoutes.singleWhereOrNull(
          (element) => element.name == routeInformation.uri.path,
        ) ??
        notFound;

    return _pageFromRouteInfo(
      route,
      arguments: arguments,
      urlArguments: urlArguments,
    );
  }
}
