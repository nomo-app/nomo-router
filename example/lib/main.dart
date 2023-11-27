import 'package:example/pages/cool.dart';
import 'package:example/pages/home.dart';
import 'package:example/pages/settings.dart';
import 'package:example/pages/test.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:nomo_router/router/entities/transitions.dart';

void main() {
  usePathUrlStrategy();

  runApp(const MainApp());
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

class Routes {
  static final routes = [
    const ModalRouteInfo(
      name: "/settings",
      page: SettingsModal(),
    ),
    NestedPageRouteInfo(
      name: "/",
      page: const HomeScreen(),
      wrapper: (nav) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Nested Navigator Cheese'),
            leading: Builder(builder: (context) {
              return IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
              );
            }),
          ),
          body: nav,
        );
      },
      children: const [
        MenuPageRouteInfo(
          name: "/test",
          title: "Test",
          page: TestScreen(),
          children: [
            PageRouteInfo(
              name: "/cool",
              page: CoolScreen(),
            ),
            ModalRouteInfo(
              name: "/settingsNested",
              page: SettingsModal(),
            ),
          ],
        ),
        ModalRouteInfo(
          name: "/settingsNested",
          page: SettingsModal(),
        ),
      ],
    ),
  ].expanded;
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final delegate = NomoRouterDelegate(
      rootNavigatorKey,
      routes: Routes.routes,
    );

    return NomoNavigator(
      delegate: delegate,
      defaultTransistion: const PageSharedAxisTransition(type: SharedAxisTransitionType.horizontal),
      child: MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: const NomoRouteInformationParser(),
        backButtonDispatcher: RootBackButtonDispatcher(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: RouteInformation(
            uri: WidgetsBinding.instance.platformDispatcher.defaultRouteName.uri,
          ),
        ),
      ),
    );
  }
}
