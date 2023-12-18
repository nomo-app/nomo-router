import 'package:example/routes.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:nomo_router/router/entities/transitions.dart';

void main() {
  usePathUrlStrategy();

  runApp(const MainApp());
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = AppRouter();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final delegate = NomoRouterDelegate(
      rootNavigatorKey,
      appRouter: appRouter,
    );

    return NomoNavigator(
      delegate: delegate,
      defaultTransistion: const PageSharedAxisTransition(
          type: SharedAxisTransitionType.horizontal),
      child: MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: const NomoRouteInformationParser(),
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
