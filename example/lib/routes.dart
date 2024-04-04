import 'package:example/pages/cool.dart';
import 'package:example/pages/home.dart';
import 'package:example/pages/settings.dart';
import 'package:example/pages/test.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_router/router/entities/route.dart';
import 'package:nomo_router/router/entities/route_info.dart';
import 'package:nomo_router/router/entities/transitions.dart';
import 'package:route_gen/anotations.dart';

part 'routes.g.dart';

Widget wrap(Widget nav) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.red,
      leading: BackButton(
        onPressed: () {
          NomoNavigator.fromKey.pop();
        },
      ),
      title: const Text("Nomo Router"),
      elevation: 2,
    ),
    body: nav,
  );
}

Widget wrapCool(Widget nav) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue,
      leading: BackButton(
        onPressed: () {
          NomoNavigator.fromKey.pop();
        },
      ),
      title: const Text("Nomo Router Cool"),
      elevation: 2,
    ),
    body: nav,
  );
}

RouteType whenPage(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return switch (width) {
    < 600 => RouteType.modal,
    _ => RouteType.page,
  };
}

@AppRoutes()
const _routes = [
  NestedNavigator(
    wrapper: wrap,
    key: ValueKey("def"),
    children: [
      PageRouteInfo(
        path: '/home',
        page: HomeScreen,
      ),
      PageRouteInfo(
        path: '/test',
        page: TestScreen,
      ),
      DynamicRouteInfo(
        when: whenPage,
        path: "/nestedSettings",
        page: SettingsModal,
        routePostfix: "Nested",
        transition: PageFadeTransition(),
        useRootNavigator: false,
      )
    ],
  ),
  NestedNavigator(
    wrapper: wrapCool,
    key: ValueKey("cool"),
    pathPrefix: "/c",
    children: [
      PageRouteInfo(
        path: '/cool',
        page: CoolScreen,
      ),
      PageRouteInfo(
        path: '/cool2',
        page: CoolScreen,
        routePostfix: "2",
      ),
      ModalRouteInfo(
        path: "/nestedSettings",
        page: SettingsModal,
        routePostfix: "NestedCool",
      )
    ],
  ),
  ModalRouteInfo(
    path: '/settings',
    page: SettingsModal,
  ),
];
