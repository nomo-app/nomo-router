import 'package:example/pages/cool.dart';
import 'package:example/pages/home.dart';
import 'package:example/pages/settings.dart';
import 'package:example/pages/test.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/router/delegate.dart';
import 'package:nomo_router/router/entities/routes/route_info.dart';
import 'package:nomo_router/router/extensions.dart';
import 'package:nomo_router/router/information_parser.dart';
import 'package:nomo_router/router/nomo_navigator.dart';

void main() {
  runApp(const MainApp());
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

class Routes {
  static List<RouteInfo> get allRoutes => [
        ...routes,
        ...nestedRoutes,
      ];

  static List<RouteInfo> get routes => [
        settingsRoute,
      ];

  static List<RouteInfo> get nestedRoutes => [
        homeRoute,
        testRoute,
        testRoute2,
      ];

  static const settingsRoute = ModalRouteInfo(
    name: "/settings",
    page: SettingsModal(),
  );

  static const homeRoute = PageRouteInfo(
    name: "/",
    page: HomeScreen(),
  );

  static const testRoute = PageRouteInfo(
    name: "/test",
    page: TestScreen(),
  );

  static const testRoute2 = PageRouteInfo(
    name: "/test/cool",
    page: CoolScreen(),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final delegate = NomoRouterDelegate(
      rootNavigatorKey,
      routes: Routes.routes,
      nestedRoutes: Routes.nestedRoutes,
      nestedNavigatorWrapper: (nav) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Nested Navigator'),
          ),
          body: nav,
        );
      },
    );

    return NomoNavigator(
      delegate: delegate,
      child: MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: NomoRouteInformationParser(
          nestedRoutes: Routes.nestedRoutes,
        ),
        backButtonDispatcher: RootBackButtonDispatcher(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: RouteInformation(
            uri:
                WidgetsBinding.instance.platformDispatcher.defaultRouteName.uri,
          ),
        ),
      ),
    );
  }
}
