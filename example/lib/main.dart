import 'package:example/routes.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:nomo_router/router/entities/transitions.dart';

void main() {
  usePathUrlStrategy();

  runApp(const MainApp());
}

final appRouter = AppRouter();

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final Uri initalUri =
      WidgetsBinding.instance.platformDispatcher.defaultRouteName.uri;

  late final delegate = NomoRouterDelegate(appRouter: appRouter);

  @override
  Widget build(BuildContext context) {
    return NomoNavigator(
      delegate: delegate,
      defaultTransistion: const PageSharedAxisTransition(
        type: SharedAxisTransitionType.horizontal,
      ),
      child: MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: const NomoRouteInformationParser(),
        backButtonDispatcher: RootBackButtonDispatcher(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: RouteInformation(
            uri: initalUri,
          ),
        ),
      ),
    );
  }
}
