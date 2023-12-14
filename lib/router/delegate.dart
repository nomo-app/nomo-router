import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class NomoRouterDelegate extends RouterDelegate<RouterConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouterConfiguration> {
  final GlobalKey<NavigatorState> _navigatorKey;
  late final Iterable<RouteInfo> routes;
  final nestedStackNotifier = ValueNotifier<List<NestedNomoPage>>([]);

  late final PageRouteInfo nestedRouterPageInfo;
  late final Iterable<RouteInfo> nestedRoutes;

  final Widget? initial;

  final List<NavigatorObserver> observers;
  final List<NavigatorObserver> nestedObservers;

  NomoRouterDelegate(
    this._navigatorKey, {
    this.initial,
    required Iterable<RouteInfo> routes,
    this.observers = const [],
    this.nestedObservers = const [],
  }) : assert(routes.isNotEmpty) {
    this.routes = [
      if (initial != null)
        PageRouteInfo(
          name: "/",
          page: initial!,
        ),
      ...routes,
    ];

    final nestedPageRoute = routes.whereType<NestedPageRouteInfo>().firstOrNull;

    nestedRoutes = [
      if (nestedPageRoute != null) ...[
        nestedPageRoute,
        ...nestedPageRoute.underlying,
      ]
    ];

    final nestedNav = ValueListenableBuilder(
      valueListenable: nestedStackNotifier,
      builder: (context, pages, child) {
        if (pages.isEmpty) {
          return const SizedBox();
        }
        return Navigator(
          pages: pages,
          observers: nestedObservers,
          onPopPage: (route, result) {
            if (!route.didPop(result)) {
              return false;
            }
            return pop();
          },
        );
      },
    );

    nestedRouterPageInfo = PageRouteInfo(
      name: "/",
      page: nestedPageRoute?.wrapper(nestedNav) ?? nestedNav,
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

  bool get containsNestedRouterPage {
    return _stack.map((page) => page.routeInfo).contains(nestedRouterPageInfo);
  }

  @override
  Widget build(BuildContext context) {
    /// If the root stack is empty, add the first page which contains the nested stack
    if (_stack.isEmpty) {
      final home = routes.singleWhereOrNull((route) => route.name == "/") ??
          routes.first;
      final isNested = nestedRoutes.contains(home);
      if (isNested) {
        _stack.add(nestedRouterPage);
        _stack.add(_nestedPageFromRouteInfo(home));
        nestedStackNotifier.value = nestedStack;
      } else {
        _stack.add(_pageFromRouteInfo(home));
      }
    }

    return NomoNavigatorInformationProvider(
      current: current,
      child: Navigator(
        key: _navigatorKey,
        onPopPage: _handlePopPage,
        pages: rootStack,
        observers: observers,
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(RouterConfiguration configuration) async {
    var newStack = <NomoPage>[];

    bool containtsNestedRouterPage(List<NomoPage> stack) {
      return stack.map((page) => page.routeInfo).contains(nestedRouterPageInfo);
    }

    for (final route in configuration) {
      final routeInfo = routes.singleWhereOrNull(
        (element) => element.name == route.name,
      );

      if (routeInfo == null) {
        continue;
      }

      final isNested = nestedRoutes.contains(routeInfo);

      if (isNested && !containtsNestedRouterPage(newStack)) {
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
    if (containsNestedRouterPage && _stack.length <= 2) {
      return false;
    }
    if (!containsNestedRouterPage && _stack.length <= 1) {
      return false;
    }

    if (!route.didPop(result)) {
      return false;
    }
    return pop(result);
  }

  bool pop<T>([T? result]) {
    if (containsNestedRouterPage && _stack.length <= 2) {
      return false;
    }
    if (!containsNestedRouterPage && _stack.length <= 1) {
      return false;
    }

    _stack.removeLast().didPop(result);

    if (nestedStack.isEmpty && containsNestedRouterPage) {
      _stack.removeLast();
    }

    nestedStackNotifier.value = nestedStack;

    notifyListeners();

    return true;
  }

  Future<T> push<T>(RoutePath path) {
    final info = routes.singleWhereOrNull(
      (route) => route.name == path.name,
    );

    final useRoot = switch (info) {
      ModalRouteInfo info => info.useRootNavigator,
      _ => false,
    };

    final isNested = nestedRoutes.contains(info) && !useRoot;

    final page = switch ((info, isNested)) {
      (null, _) => _pageFromRouteInfo<T>(notFound),
      (RouteInfo info, true) => _nestedPageFromRouteInfo<T>(
          info,
          urlArguments: path.urlArguments,
          arguments: path.arguments,
        ),
      (RouteInfo info, false) => _pageFromRouteInfo<T>(
          info,
          urlArguments: path.urlArguments,
          arguments: path.arguments,
        ),
    };

    if (isNested && !containsNestedRouterPage) {
      _stack.add(nestedRouterPage);
    }

    _stack.add(page);

    nestedStackNotifier.value = nestedStack;

    notifyListeners();

    return page.popped;
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

  NomoPage<T> _pageFromRouteInfo<T>(
    RouteInfo route, {
    Object? arguments,
    JsonMap? urlArguments,
  }) {
    return RootNomoPage(
      routeInfo: route,
      arguments: arguments,
      urlArguments: urlArguments,
      key: UniqueKey(),
    );
  }

  NestedNomoPage<T> _nestedPageFromRouteInfo<T>(
    RouteInfo route, {
    Object? arguments,
    JsonMap? urlArguments,
  }) {
    return NestedNomoPage(
      routeInfo: route,
      arguments: arguments,
      urlArguments: urlArguments,
      key: UniqueKey(),
    );
  }
}
