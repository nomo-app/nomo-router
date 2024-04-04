import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:nomo_router/router/entities/route.dart';
import 'package:nomo_router/router/entities/transitions.dart';

final nomoNavigatorKey = GlobalKey<NomoNavigatorState>();

class NomoRouterDelegate extends RouterDelegate<RouterConfiguration>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<RouterConfiguration>,
        WidgetsBindingObserver {
  // Root navigator key
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  late final Map<Key, GlobalKey<NavigatorState>> _nestedNavigatorKeys;

  final NomoAppRouter appRouter;
  late final List<RouteInfo> routeInfos;

  /// Nested Routes for each nested navigator
  late final Map<NestedNavigator, Iterable<RouteInfo>> nestedRoutes;

  NestedNavigator? isNestedRoute(RouteInfo? routeInfo) {
    return nestedRoutes.entries
        .singleWhereOrNull((element) => element.value.contains(routeInfo))
        ?.key;
  }

  final Widget? initial;
  late final RouteInfo? initialRouteInfo;

  final List<NavigatorObserver> observers;
  final List<NavigatorObserver> nestedObservers;

  ///
  /// Used for Dynamic Routes
  ///
  final Map<DynamicRouteInfo, RouteType> _dynRouteStates = {};
  final Map<GlobalKey, LocalKey> _pagesKeys = {};

  NomoRouterDelegate({
    this.initial,
    required this.appRouter,
    this.observers = const [],
    this.nestedObservers = const [],
  }) {
    WidgetsBinding.instance.addObserver(this);

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

    final nestedNavRoutes = appRouter.nestedRoutes;

    _nestedNavigatorKeys = {
      for (final nestedRoute in nestedNavRoutes)
        nestedRoute.key:
            nestedRoute.navigatorKey ?? GlobalKey<NavigatorState>(),
    };

    nestedRoutes = {
      for (final nestedRoute in nestedNavRoutes)
        nestedRoute: nestedRoute.underlying,
    };

    ///
    /// Create the initial stack
    ///
    final home = routeInfos.singleWhereOrNull((route) => route.path == "/") ??
        routeInfos.first;
    final homePage = initial != null
        ? initial!
        : appRouter.getRouteForPath(home.path)().page;
    final navRoute = isNestedRoute(home);
    _stack = [
      if (navRoute != null) ...[
        _getNestedRouterPage(navRoute),
        _nestedPageFromRouteInfo(home, homePage),
      ] else
        _pageFromRouteInfo(home, homePage),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() => recalculateDynamicRoutes();

  void recalculateDynamicRoutes({bool shouldNotify = true}) {
    final dynRoutes = routeInfos.whereType<DynamicRouteInfo>();

    bool notifiy = false;

    for (final dynRoute in dynRoutes) {
      final result = dynRoute.when(nomoNavigatorKey.currentContext!);
      final previousResult = _dynRouteStates[dynRoute];

      if (result == previousResult) continue;

      _dynRouteStates[dynRoute] = result;

      final page = _stack.singleWhereOrNull(
        (page) => page.routeInfo == dynRoute,
      );
      if (page == null) continue;

      final copy = page.copy;
      _stack[_stack.indexOf(page)] = copy;

      if (page.page.key is GlobalKey) {
        _pagesKeys[page.page.key as GlobalKey] = copy.key!;
      }

      notifiy = true;
    }

    if (notifiy && shouldNotify) {
      notifyListeners();
    }
  }

  NestedNavigatorPage _getNestedRouterPage(NestedNavigator info) {
    final key = info.key;
    final navKey = _nestedNavigatorKeys[key]!;
    final child = AnimatedBuilder(
      animation: this,
      builder: (context, child) {
        final pages = nestedStack[key];

        if (pages == null || pages.isEmpty) {
          return const SizedBox();
        }
        return Navigator(
          pages: pages,
          observers: nestedObservers,
          key: navKey,
          onPopPage: (route, result) {
            if (!route.didPop(result)) {
              return false;
            }
            return pop();
          },
        );
      },
    );

    return NestedNavigatorPage(
      page: info.wrapper(child),
      pageWithoutKey: info.wrapper(child),
      routeInfo: info,
      route: null,
      key: ValueKey(key),
    );
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  RouterConfiguration get currentConfiguration {
    print("Stack: $_stack");
    return _stack;
  }

  late List<NomoPage> _stack;

  Map<Key, List<NestedNomoPage>> get nestedStack => {
        for (final nestedNav in _stack.whereType<NestedNavigatorPage>())
          nestedNav.routeInfo.key: _stack
              .whereType<NestedNomoPage>()
              .where((nP) => nP.navKey == nestedNav.routeInfo.key)
              .toList()
      };

  List<RootNomoPage> get rootStack => _stack.whereType<RootNomoPage>().toList();

  RouteInfo get current {
    return _stack.last.routeInfo;
  }

  bool containsNestedRouterPage(Key? key) => nestedStack[key] != null;

  @override
  Widget build(BuildContext context) {
    if (_dynRouteStates.isEmpty) {
      print("Recalculating dynamic routes");

      Future.microtask(() => recalculateDynamicRoutes(shouldNotify: false));
    }

    return NomoNavigatorWrapper(
      delegate: this,
      key: nomoNavigatorKey,
      child: NomoNavigatorInformationProvider(
        current: current,
        keys: _pagesKeys,
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
      return stack.whereType<NestedNavigatorPage>().isNotEmpty;
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

      final nestedNav = isNestedRoute(routeInfo);

      if (nestedNav != null && !containtsNestedRouterPage(newStack)) {
        newStack.add(_getNestedRouterPage(nestedNav));
        newStack.add(_nestedPageFromRouteInfo(routeInfo, page));
        continue;
      }

      newStack.add(
        switch (nestedNav != null) {
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

    if (newStack.isEmpty) {
      return;
    }

    _stack = newStack;

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

  bool _canPop() {
    return _stack.length > 1 + nestedStack.keys.length;
  }

  bool pop<T>([T? result]) {
    if (!_canPop()) {
      return false;
    }

    final page = _stack.removeLast()..didPop(result);

    final nestedNav = isNestedRoute(page.routeInfo)?.key;

    final remPages = nestedStack[nestedNav];

    if (remPages?.isEmpty ?? false) {
      _stack.removeLast().didPop();
    }

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
    _stack.removeLast().didPop();
    return pushNamed(path, arguments: arguments, urlArgs: urlArgs);
  }

  Future<T> push<T, A>(AppRoute route, {JsonMap? urlArguments}) {
    final info = routeInfos
        .singleWhereOrNull((routeInfo) => routeInfo.path == route.name);

    final useRoot = switch (info) {
      ModalRouteInfo info => info.useRootNavigator,
      _ => false,
    };

    final nestedNav = isNestedRoute(info);
    final isNested = nestedNav != null && !useRoot;

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

    if (isNested && !containsNestedRouterPage(nestedNav.key)) {
      _stack.add(_getNestedRouterPage(nestedNav));
    }

    _stack.add(page);

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

  void popUntil(bool Function(NomoPage) predicate) {
    while (!predicate(_stack.last) && _stack.length > 1) {
      pop();
    }
  }

  Future<T> popUntilAndPush<T>(
      AppRoute route, bool Function(NomoPage) predicate) {
    popUntil(predicate);
    return push(route);
  }

  Future<T?> pushModal<T>({
    required Widget modal,
    PageTransition transition = const PageSlideTransition(),
  }) {
    final info = ModalRouteInfo(
      path: "",
      page: modal.runtimeType,
      useRootNavigator: true,
      transition: transition,
    );

    final page = _pageFromRouteInfo<T>(info, modal);

    _stack.add(page);

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
    GlobalKey<NavigatorState>? navKey,
  }) {
    assert(
      useRootNavigator == true || navKey != null,
      "If useRootNavigator is false, a navKey must be provided.",
    );
    final _navKey = useRootNavigator ? _navigatorKey : navKey!;

    if (_navKey.currentContext == null || _navKey.currentState == null) {
      return Future.value(null);
    }

    return _navKey.currentState!.push<T>(
      DialogRoute(
        context: _navKey.currentContext!,
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
    final uk = UniqueKey();
    final child = switch (routeInfo) {
      DynamicRouteInfo _ => () {
          final gk = GlobalKey();
          _pagesKeys[gk] = uk;
          return SizedBox(
            key: gk,
            child: page,
          );
        }.call(),
      _ => page,
    };
    return RootNomoPage(
      routeInfo: routeInfo,
      page: child,
      pageWithoutKey: page,
      urlArguments: urlArguments,
      route: route,
      key: uk,
    );
  }

  NestedNomoPage<T> _nestedPageFromRouteInfo<T>(
    RouteInfo routeInfo,
    Widget page, {
    AppRoute? route,
    JsonMap? urlArguments,
  }) {
    final uk = UniqueKey();
    final child = switch (routeInfo) {
      DynamicRouteInfo _ => () {
          final gk = GlobalKey();
          _pagesKeys[gk] = uk;
          return SizedBox(
            key: gk,
            child: page,
          );
        }.call(),
      _ => page,
    };

    return NestedNomoPage(
      routeInfo: routeInfo,
      page: child,
      pageWithoutKey: page,
      urlArguments: urlArguments,
      route: route,
      key: uk,
      navKey: getNavKeyFromRouteInfo(routeInfo),
    );
  }

  Key getNavKeyFromRouteInfo(RouteInfo routeInfo) {
    return nestedRoutes.entries
        .singleWhereOrNull((element) => element.value.contains(routeInfo))!
        .key
        .key;
  }
}
