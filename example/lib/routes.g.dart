// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// RouteGenerator
// **************************************************************************

class AppRouter extends NomoAppRouter {
  AppRouter()
      : super(
          {
            HomeScreenRoute.path: ([a]) => HomeScreenRoute(),
            TestScreenRoute.path: ([a]) {
              final typedArgs = a as TestScreenArguments?;
              return TestScreenRoute(
                id: typedArgs?.id ?? TestEnum.one,
              );
            },
            CoolScreenRoute.path: ([a]) => CoolScreenRoute(),
            SettingsModalNestedRoute.path: ([a]) {
              final typedArgs = a as SettingsModalNestedArguments?;
              return SettingsModalNestedRoute(
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
          _routes.expanded.toList(),
        );
}

class HomeScreenArguments {
  const HomeScreenArguments();
}

class HomeScreenRoute extends AppRoute implements HomeScreenArguments {
  HomeScreenRoute()
      : super(
          name: '/',
          page: HomeScreen(),
        );
  static String path = '/';
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

class CoolScreenArguments {
  const CoolScreenArguments();
}

class CoolScreenRoute extends AppRoute implements CoolScreenArguments {
  CoolScreenRoute()
      : super(
          name: '/cool',
          page: CoolScreen(),
        );
  static String path = '/cool';
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
