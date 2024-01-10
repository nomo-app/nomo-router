// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// RouteGenerator
// **************************************************************************

class AppRouter extends NomoAppRouter {
  AppRouter()
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
            TestScreenRootRoute.path: ([a]) {
              final typedArgs = a as TestScreenRootArguments?;
              return TestScreenRootRoute(
                id: typedArgs?.id ?? TestEnum.one,
              );
            },
          },
          _routes.expanded.toList(),
        );
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
          name: '/',
          page: HomeScreen(
            key: key,
          ),
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
          name: '/cool',
          page: CoolScreen(
            key: key,
          ),
        );
  static String path = '/cool';
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
          name: '/cool2',
          page: CoolScreen(
            key: key,
          ),
        );
  static String path = '/cool2';
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

class TestScreenRootArguments {
  final TestEnum id;
  const TestScreenRootArguments({
    required this.id,
  });
}

class TestScreenRootRoute extends AppRoute implements TestScreenRootArguments {
  @override
  final TestEnum id;
  TestScreenRootRoute({
    this.id = TestEnum.one,
  }) : super(
          name: '/rootTest',
          page: TestScreen(
            id: id,
          ),
        );
  static String path = '/rootTest';
}
