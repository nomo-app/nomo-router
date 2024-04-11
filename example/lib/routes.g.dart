// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// RouteGenerator
// **************************************************************************

class AppRouter extends NomoAppRouter {
  final Future<bool> Function()? shouldPop;
  final Future<bool> Function()? willPop;
  late final RouterConfig<Object> config;
  late final NomoRouterDelegate delegate;
  AppRouter({this.shouldPop, this.willPop})
      : super(
          {
            HomeScreenRoute.path: ([a]) {
              final typedArgs = a as HomeScreenArguments?;
              return HomeScreenRoute(
                key: typedArgs?.key,
              );
            },
            TestScreenRoute.path: ([a]) {
              final typedArgs = a as TestScreenArguments?;
              return TestScreenRoute(
                id: typedArgs?.id ?? TestEnum.one,
              );
            },
            SettingsModalNestedRoute.path: ([a]) {
              final typedArgs = a as SettingsModalNestedArguments?;
              return SettingsModalNestedRoute(
                id: typedArgs?.id,
              );
            },
            CoolScreenRoute.path: ([a]) {
              final typedArgs = a as CoolScreenArguments?;
              return CoolScreenRoute(
                key: typedArgs?.key,
              );
            },
            CoolScreen2Route.path: ([a]) {
              final typedArgs = a as CoolScreen2Arguments?;
              return CoolScreen2Route(
                key: typedArgs?.key,
              );
            },
            SettingsModalNestedCoolRoute.path: ([a]) {
              final typedArgs = a as SettingsModalNestedCoolArguments?;
              return SettingsModalNestedCoolRoute(
                id: typedArgs?.id,
              );
            },
            SettingsModalRoute.path: ([a]) {
              final typedArgs = a as SettingsModalArguments?;
              return SettingsModalRoute(
                id: typedArgs?.id,
              );
            },
          },
          _routes.expanded.where((r) => r is! NestedNavigator).toList(),
          _routes.expanded.whereType<NestedNavigator>().toList(),
        ) {
    delegate = NomoRouterDelegate(appRouter: this);
    config = RouterConfig(
        routerDelegate: delegate,
        backButtonDispatcher:
            NomoBackButtonDispatcher(delegate, shouldPop, willPop),
        routeInformationParser: const NomoRouteInformationParser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: RouteInformation(
            uri:
                WidgetsBinding.instance.platformDispatcher.defaultRouteName.uri,
          ),
        ));
  }
}

class HomeScreenArguments {
  final Key? key;
  const HomeScreenArguments({
    this.key,
  });
}

class HomeScreenRoute extends AppRoute implements HomeScreenArguments {
  @override
  final Key? key;
  HomeScreenRoute({
    this.key,
  }) : super(
          name: '/home',
          page: HomeScreen(
            key: key,
          ),
        );
  static String path = '/home';
}

class TestScreenArguments {
  final TestEnum id;
  const TestScreenArguments({
    required this.id,
  });
}

class TestScreenRoute extends AppRoute implements TestScreenArguments {
  @override
  final TestEnum id;
  TestScreenRoute({
    this.id = TestEnum.one,
  }) : super(
          name: '/test',
          page: TestScreen(
            id: id,
          ),
        );
  static String path = '/test';
}

class SettingsModalNestedArguments {
  final String? id;
  const SettingsModalNestedArguments({
    this.id,
  });
}

class SettingsModalNestedRoute extends AppRoute
    implements SettingsModalNestedArguments {
  @override
  final String? id;
  SettingsModalNestedRoute({
    this.id,
  }) : super(
          name: '/nestedSettings',
          page: SettingsModal(
            id: id,
          ),
        );
  static String path = '/nestedSettings';
}

class CoolScreenArguments {
  final Key? key;
  const CoolScreenArguments({
    this.key,
  });
}

class CoolScreenRoute extends AppRoute implements CoolScreenArguments {
  @override
  final Key? key;
  CoolScreenRoute({
    this.key,
  }) : super(
          name: '/c/cool',
          page: CoolScreen(
            key: key,
          ),
        );
  static String path = '/c/cool';
}

class CoolScreen2Arguments {
  final Key? key;
  const CoolScreen2Arguments({
    this.key,
  });
}

class CoolScreen2Route extends AppRoute implements CoolScreen2Arguments {
  @override
  final Key? key;
  CoolScreen2Route({
    this.key,
  }) : super(
          name: '/c/cool2',
          page: CoolScreen(
            key: key,
          ),
        );
  static String path = '/c/cool2';
}

class SettingsModalNestedCoolArguments {
  final String? id;
  const SettingsModalNestedCoolArguments({
    this.id,
  });
}

class SettingsModalNestedCoolRoute extends AppRoute
    implements SettingsModalNestedCoolArguments {
  @override
  final String? id;
  SettingsModalNestedCoolRoute({
    this.id,
  }) : super(
          name: '/c/nestedSettings',
          page: SettingsModal(
            id: id,
          ),
        );
  static String path = '/c/nestedSettings';
}

class SettingsModalArguments {
  final String? id;
  const SettingsModalArguments({
    this.id,
  });
}

class SettingsModalRoute extends AppRoute implements SettingsModalArguments {
  @override
  final String? id;
  SettingsModalRoute({
    this.id,
  }) : super(
          name: '/settings',
          page: SettingsModal(
            id: id,
          ),
        );
  static String path = '/settings';
}
