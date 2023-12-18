// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// RouteGenerator
// **************************************************************************

class AppRouter extends NomoAppRouter {
  AppRouter()
      : super(
          {
            '/': ([a]) => HomeScreenRoute(),
            '/test': ([a]) {
              final typedArgs = a as TestScreenArguments?;
              return TestScreenRoute(
                id: typedArgs?.id ?? TestEnum.one,
              );
            },
            '/settings': ([a]) {
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
}
