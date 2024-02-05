import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:nomo_router/router/entities/route.dart';
import 'package:nomo_router/router/entities/transitions.dart';

final nomoNavigatorKey = GlobalKey<NomoNavigatorState>();

class NomoRouterDelegate extends RouterDelegate<RouterConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouterConfiguration> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _nestedNavigatorKey =
      GlobalKey<NavigatorState>();

  final NomoAppRouter appRouter;
  late final List<RouteInfo> routeInfos;

  final nestedStackNotifier = ValueNotifier<List<NestedNomoPage>>([]);

  late final PageRouteInfo nestedRouterPageInfo;
  late final Widget nestedRouterRoute;
  late final Iterable<RouteInfo> nestedRoutes;

  final Widget? initial;
  late final RouteInfo? initialRouteInfo;

  final List<NavigatorObserver> observers;
  final List<NavigatorObserver> nestedObservers;

  NomoRouterDelegate({
    this.initial,
    required this.appRouter,
    this.observers = const [],
    this.nestedObservers = const [],
  }) {
    initialRouteInfo = initial != null
        ? PageRouteInfo(
            path: "/",
            page: initial!.runtimeType,
          )
        : null;

    routeInfos = [
      if (initial != null) initialRouteInfo!,
      ...appRouter.routeInfos,
    ];

    final nestedPageRoute = appRouter.nestedRoutes.firstOrNull;

    nestedRoutes = [
      if (nestedPageRoute != null) ...[
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
          key: _nestedNavigatorKey,
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
      path: nestedPageRoute?.path ?? '/',
      page: Object, // Can be anything since we dont generate this route
    );

    nestedRouterRoute = nestedPageRoute?.wrapper(nestedNav) ?? nestedNav;
  }

  NomoPage get nestedRouterPage => RootNomoPage(
        page: nestedRouterRoute,
        routeInfo: nestedRouterPageInfo,
        route: null,
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
      final home = routeInfos.singleWhereOrNull((route) => route.path == "/") ??
          routeInfos.first;
      final homePage = initial != null
          ? initial!
          : appRouter.getRouteForPath(home.path)().page;
      final isNested = nestedRoutes.contains(home);
      if (isNested) {
        _stack.add(nestedRouterPage);
        _stack.add(_nestedPageFromRouteInfo(home, homePage));
        nestedStackNotifier.value = nestedStack;
      } else {
        _stack.add(
          _pageFromRouteInfo(home, homePage),
        );
      }
    }

    return NomoNavigatorWrapper(
      delegate: this,
      key: nomoNavigatorKey,
      child: NomoNavigatorInformationProvider(
        current: current,
        child: Navigator(
          key: _navigatorKey,
          onPopPage: _handlePopPage,
          pages: rootStack,
          observers: observers,
        ),
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
        (element) => element.path == routeSettings.name,
      );

      if (routeInfo == null) {
        continue;
      }

      final isInital = routeInfo == initialRouteInfo;

      final page = isInital
          ? initial!
          : appRouter.getRouteForPath(routeInfo.path)().page;

      final isNested = nestedRoutes.contains(routeInfo);

      if (isNested && !containtsNestedRouterPage(newStack)) {
        newStack.add(nestedRouterPage);
        newStack.add(_nestedPageFromRouteInfo(routeInfo, page));
        continue;
      }

      newStack.add(
        switch (isNested) {
          true => _nestedPageFromRouteInfo(
              routeInfo,
              page,
              urlArguments: routeSettings.arguments as JsonMap?,
            ),
          false => _pageFromRouteInfo(
              routeInfo,
              page,
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
    if (!route.didPop(result)) {
      return false;
    }

    final routeInfo = routeInfos.singleWhereOrNull(
      (element) => element.path == route.settings.name,
    );

    if (routeInfo is ModalRouteInfo) {
      if (routeInfo.useRootNavigator) {
        return popRoot(result);
      }
    }

    return pop(result);
  }

  bool popWithKey<T>([T? result]) {
    _navigatorKey.currentState?.pop(result);
    return true;
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
    if (rootStack.length <= 1) {
      return false;
    }

    final lastRootIndex = _stack.indexOf(rootStack.last);

    _stack.removeAt(lastRootIndex).didPop(result);

    notifyListeners();

    return true;
  }

  Future<T> pushNamed<T>(String path, {Object? arguments, JsonMap? urlArgs}) {
    final appRoute = appRouter.getRouteForPath(path)(arguments);

    return push(appRoute, urlArguments: urlArgs);
  }

  Future<T> replaceNamed<T>(
    String path, {
    Object? arguments,
    JsonMap? urlArgs,
  }) {
    pop();
    return pushNamed(path, arguments: arguments, urlArgs: urlArgs);
  }

  Future<T> push<T, A>(AppRoute route, {JsonMap? urlArguments}) {
    final info = routeInfos.singleWhereOrNull(
      (routeInfo) => routeInfo.path == route.name,
    );

    final useRoot = switch (info) {
      ModalRouteInfo info => info.useRootNavigator,
      _ => false,
    };

    final isNested = nestedRoutes.contains(info) && !useRoot;

    final page = switch ((info, isNested)) {
      (null, _) => _pageFromRouteInfo<T>(
          notFoundRouteInfo,
          const NotFound(),
        ),
      (RouteInfo info, true) => _nestedPageFromRouteInfo<T>(
          info,
          route.page,
          route: route,
          urlArguments: urlArguments,
        ),
      (RouteInfo info, false) => _pageFromRouteInfo<T>(
          info,
          route.page,
          route: route,
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

  Future<T> replace<T>(AppRoute route) {
    _stack.removeLast().didPop();
    return push(route);
  }

  Future<T> replaceAll<T>(AppRoute route) {
    _stack.clear();
    return push(route);
  }

  void popUntil(bool Function(RouteInfo) predicate) {
    while (!predicate(_stack.last.routeInfo)) {
      pop();
    }
  }

  Future<T> popUntilAndPush<T>(
      AppRoute route, bool Function(RouteInfo) predicate) {
    popUntil(predicate);
    return push(route);
  }

  Future<T?> pushModal<T>({
    required Widget modal,
    bool useRootNavigator = true,
    PageTransition transition = const PageSlideTransition(),
  }) {
    final info = ModalRouteInfo(
      path: "",
      page: modal.runtimeType,
      useRootNavigator: useRootNavigator,
      transition: transition,
    );

    final page = useRootNavigator
        ? _pageFromRouteInfo<T>(info, modal)
        : _nestedPageFromRouteInfo<T>(info, modal);

    if (useRootNavigator && !containsNestedRouterPage) {
      _stack.add(nestedRouterPage);
    }

    _stack.add(page);

    nestedStackNotifier.value = nestedStack;

    notifyListeners();

    return page.popped;
  }

  Future<T?> showModalWithKey<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) {
    final navKey = useRootNavigator ? _navigatorKey : _nestedNavigatorKey;

    if (navKey.currentContext == null || navKey.currentState == null) {
      return Future.value(null);
    }

    return navKey.currentState!.push<T>(
      DialogRoute(
        context: navKey.currentContext!,
        builder: builder,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        useSafeArea: useSafeArea,
        settings: routeSettings,
        anchorPoint: anchorPoint,
        traversalEdgeBehavior:
            traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop,
      ),
    );
  }

  Future<T?> showModal<T>({
    required WidgetBuilder builder,
    required BuildContext context,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) {
    return showDialog<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
    );
  }

  NomoPage<T> _pageFromRouteInfo<T>(
    RouteInfo routeInfo,
    Widget page, {
    AppRoute? route,
    JsonMap? urlArguments,
  }) {
    return RootNomoPage(
      routeInfo: routeInfo,
      page: page,
      urlArguments: urlArguments,
      route: route,
      key: UniqueKey(),
    );
  }

  NestedNomoPage<T> _nestedPageFromRouteInfo<T>(
    RouteInfo routeInfo,
    Widget page, {
    AppRoute? route,
    JsonMap? urlArguments,
  }) {
    return NestedNomoPage(
      routeInfo: routeInfo,
      page: page,
      urlArguments: urlArguments,
      route: route,
      key: UniqueKey(),
    );
  }
}
