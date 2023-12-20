import 'package:example/pages/cool.dart';
import 'package:example/pages/home.dart';
import 'package:example/pages/settings.dart';
import 'package:example/pages/test.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_router/router/entities/route.dart';
import 'package:route_gen/anotations.dart';

part 'routes.g.dart';

Widget wrap(Widget nav) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Nomo Router"),
    ),
    body: nav,
  );
}

@AppRoutes()
const _routes = [
  NestedPageRouteInfo(
    path: "/",
    page: HomeScreen,
    wrapper: wrap,
    children: [
      PageRouteInfo(
        path: '/test',
        page: TestScreen,
      ),
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
        routePostfix: "Nested",
      )
    ],
  ),
  ModalRouteInfo(
    path: '/settings',
    page: SettingsModal,
  ),
];
