import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:nomo_router/router/entities/route.dart';

class InitalAppRoute implements AppRoute {
  @override
  final String name = "/";

  @override
  final Widget page;

  const InitalAppRoute(this.page);
}

class NestedRouterAppRoute implements AppRoute {
  @override
  final String name = "/";

  @override
  final Widget page;

  const NestedRouterAppRoute(this.page);
}

class NomoRouterDelegate extends RouterDelegate<RouterConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouterConfiguration> {
  final GlobalKey<NavigatorState> _navigatorKey;
  final NomoAppRouter appRouter;
  late final List<RouteInfo> routeInfos;

  final nestedStackNotifier = ValueNotifier<List<NestedNomoPage>>([]);

  late final PageRouteInfo nestedRouterPageInfo;
  late final AppRoute nestedRouterRoute;
  late final Iterable<RouteInfo> nestedRoutes;

  final Widget? initial;

  final List<NavigatorObserver> observers;
  final List<NavigatorObserver> nestedObservers;

  NomoRouterDelegate(
    this._navigatorKey, {
    this.initial,
    required this.appRouter,
    this.observers = const [],
    this.nestedObservers = const [],
  }) {
    routeInfos = [
      if (initial != null)
        PageRouteInfo(
          name: "/",
          page: initial!.runtimeType,
        ),
      ...appRouter.routeInfos,
    ];

    final nestedPageRoute =
        routeInfos.whereType<NestedPageRouteInfo>().firstOrNull;

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

    nestedRouterPageInfo = const PageRouteInfo(
      name: "/",
      page: Object, // Can be anything since we dont generate this route
    );

    nestedRouterRoute = NestedRouterAppRoute(
      nestedPageRoute?.wrapper(nestedNav) ?? nestedNav,
    );
  }

  NomoPage get nestedRouterPage => RootNomoPage(
        route: nestedRouterRoute,
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
      final home = routeInfos.singleWhereOrNull((route) => route.name == "/") ??
          routeInfos.first;
      final homeRoute = appRouter.getRouteForPath(home.name)();
      final isNested = nestedRoutes.contains(home);
      if (isNested) {
        _stack.add(nestedRouterPage);
        _stack.add(_nestedPageFromRouteInfo(home, homeRoute));
        nestedStackNotifier.value = nestedStack;
      } else {
        _stack.add(
          _pageFromRouteInfo(home, homeRoute),
        );
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

    for (final routeSettings in configuration) {
      final routeInfo = routeInfos.singleWhereOrNull(
        (element) => element.name == routeSettings.name,
      );

      if (routeInfo == null) {
        continue;
      }

      final route = appRouter.getRouteForPath(routeInfo.name)();

      final isNested = nestedRoutes.contains(routeInfo);

      if (isNested && !containtsNestedRouterPage(newStack)) {
        newStack.add(nestedRouterPage);
        newStack.add(_nestedPageFromRouteInfo(routeInfo, route));
        continue;
      }

      newStack.add(
        switch (isNested) {
          true => _nestedPageFromRouteInfo(
              routeInfo,
              route,
              urlArguments: routeSettings.arguments as JsonMap?,
            ),
          false => _pageFromRouteInfo(
              routeInfo,
              route,
              urlArguments: routeSettings.arguments as JsonMap?,
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

  bool popRoot<T>([T? result]) {
    throw UnimplementedError();
  }

  Future<T> pushNamed<T>() {
    throw UnimplementedError();
  }

  Future<T> replaceNamed<T>() {
    throw UnimplementedError();
  }

  Future<T> push<T, A>(AppRoute route, {JsonMap? urlArguments}) {
    final info = routeInfos.singleWhereOrNull(
      (routeInfo) => routeInfo.name == route.name,
    );

    final useRoot = switch (info) {
      ModalRouteInfo info => info.useRootNavigator,
      _ => false,
    };

    final isNested = nestedRoutes.contains(info) && !useRoot;

    final page = switch ((info, isNested)) {
      (null, _) => _pageFromRouteInfo<T>(
          notFoundRouteInfo,
          const NotFoundRoute(),
        ),
      (RouteInfo info, true) => _nestedPageFromRouteInfo<T>(
          info,
          route,
          urlArguments: urlArguments,
        ),
      (RouteInfo info, false) => _pageFromRouteInfo<T>(
          info,
          route,
          urlArguments: urlArguments,
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

  void replace(AppRoute route) {
    _stack.removeLast();
    push(route);
  }

  void popUntil(bool Function(NomoPage) predicate) {
    while (predicate(_stack.last)) {
      pop();
    }
  }

  NomoPage<T> _pageFromRouteInfo<T>(
    RouteInfo routeInfo,
    AppRoute route, {
    JsonMap? urlArguments,
  }) {
    return RootNomoPage(
      routeInfo: routeInfo,
      route: route,
      urlArguments: urlArguments,
      key: UniqueKey(),
    );
  }

  NestedNomoPage<T> _nestedPageFromRouteInfo<T>(
    RouteInfo routeInfo,
    AppRoute route, {
    JsonMap? urlArguments,
  }) {
    return NestedNomoPage(
      routeInfo: routeInfo,
      route: route,
      urlArguments: urlArguments,
      key: UniqueKey(),
    );
  }
}
