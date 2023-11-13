import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/router/entities/pages/nomo_page.dart';
import 'package:nomo_router/router/entities/pages/not_found.dart';
import 'package:nomo_router/router/entities/routes/route_info.dart';
import 'package:nomo_router/router/information_parser.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class NomoRouterDelegate extends RouterDelegate<RouterConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouterConfiguration> {
  final GlobalKey<NavigatorState> _navigatorKey;
  final Iterable<RouteInfo> routes;
  final nestedStackNotifier = ValueNotifier<List<NestedNomoPage>>([]);

  late final PageRouteInfo nestedRouterPageInfo;
  late final Iterable<RouteInfo> nestedRoutes;

  NomoRouterDelegate(
    this._navigatorKey, {
    required this.routes,
  }) : assert(routes.isNotEmpty) {
    final nestedPageRoute = routes.whereType<NestedPageRouteInfo>().first;

    nestedRoutes = [
      nestedPageRoute,
      ...nestedPageRoute.underlying,
    ];

    nestedRouterPageInfo = PageRouteInfo(
      name: "/",
      page: nestedPageRoute.wrapper(
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
    );
  }

  NomoPage get nestedRouterPage => RootNomoPage(
        routeInfo: nestedRouterPageInfo,
        key: ValueKey(_stack),
      );

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  RouterConfiguration get currentConfiguration => _stack;

  List<NomoPage> _stack = [];

  List<NestedNomoPage> get nestedStack =>
      _stack.whereType<NestedNomoPage>().toList();

  List<RootNomoPage> get rootStack => _stack.whereType<RootNomoPage>().toList();

  RouteInfo get current {
    return _stack.last.routeInfo;
  }

  @override
  Widget build(BuildContext context) {
    /// If the root stack is empty, add the first page which contains the nested stack
    if (_stack.isEmpty) {
      _stack.add(nestedRouterPage);
      _stack.add(_nestedPageFromRouteInfo(nestedRoutes.first));
      nestedStackNotifier.value = nestedStack;
    }

    return Navigator(
      key: _navigatorKey,
      onPopPage: _handlePopPage,
      pages: rootStack,
    );
  }

  @override
  Future<void> setNewRoutePath(RouterConfiguration configuration) async {
    var newStack = <NomoPage>[];

    for (final route in configuration) {
      final routeInfo = routes.singleWhereOrNull(
        (element) => element.name == route.name,
      );

      if (routeInfo == null) {
        break;
      }

      final isNested = nestedRoutes.contains(routeInfo);

      if (route.name == "/") {
        newStack.add(nestedRouterPage);
        newStack.add(_nestedPageFromRouteInfo(routeInfo));
        continue;
      }

      newStack.add(
        switch (isNested) {
          true => _nestedPageFromRouteInfo(
              routeInfo,
              urlArguments: route.arguments as JsonMap?,
            ),
          false => _pageFromRouteInfo(
              routeInfo,
              urlArguments: route.arguments as JsonMap?,
            ),
        },
      );
    }

    _stack = newStack;
    nestedStackNotifier.value = nestedStack;

    notifyListeners();

    return SynchronousFuture(null);
  }

  bool _handlePopPage(Route route, dynamic result) {
    if (_stack.length <= 2) {
      return false;
    }
    if (!route.didPop(result)) {
      return false;
    }
    return pop();
  }

  void onNestedConfigChanged(List<NestedNomoPage> nestedConfig) {
    nestedStackNotifier.value = nestedConfig;

    _stack = [
      nestedRouterPage,
      ..._stack.sublist(1),
    ];

    notifyListeners();
  }

  bool pop() {
    if (_stack.length <= 2) {
      return false;
    }
    _stack.removeLast();

    nestedStackNotifier.value = nestedStack;

    notifyListeners();

    return true;
  }

  void push(RoutePath path) {
    final info = routes.singleWhereOrNull(
      (route) => route.name == path.name,
    );

    final isNested = nestedRoutes.contains(info);

    final page = switch ((info, isNested)) {
      (null, _) => _pageFromRouteInfo(notFound),
      (RouteInfo info, true) => _nestedPageFromRouteInfo(
          info,
          urlArguments: path.urlArguments,
          arguments: path.arguments,
        ),
      (RouteInfo info, false) => _pageFromRouteInfo(
          info,
          urlArguments: path.urlArguments,
          arguments: path.arguments,
        ),
    };

    _stack.add(page);

    nestedStackNotifier.value = nestedStack;

    notifyListeners();
  }

  void replace(RoutePath path) {
    _stack.removeLast();
    push(path);
  }

  void popUntil(bool Function(NomoPage) predicate) {
    while (predicate(_stack.last)) {
      pop();
    }
  }

  NomoPage _pageFromRouteInfo(
    RouteInfo route, {
    Object? arguments,
    JsonMap? urlArguments,
  }) {
    return RootNomoPage(
      routeInfo: route,
      arguments: arguments,
      urlArguments: urlArguments,
    );
  }

  NestedNomoPage _nestedPageFromRouteInfo(
    RouteInfo route, {
    Object? arguments,
    JsonMap? urlArguments,
  }) {
    return NestedNomoPage(
      routeInfo: route,
      arguments: arguments,
      urlArguments: urlArguments,
    );
  }
}
