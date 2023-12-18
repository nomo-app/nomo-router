import 'package:example/pages/home.dart';
import 'package:example/pages/settings.dart';
import 'package:example/pages/test.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_router/router/entities/route.dart';
import 'package:nomo_router/router/entities/transitions.dart';
import 'package:route_gen/annotations.dart';

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
    name: "/",
    page: HomeScreen,
    transition: PageFadeTransition(),
    wrapper: wrap,
    children: [
      PageRouteInfo(
        name: '/test',
        page: TestScreen,
      ),
    ],
  ),
  ModalRouteInfo(
    name: '/settings',
    page: SettingsModal,
  ),
];

// class NomoAppRouterImpl extends NomoAppRouter {
//   NomoAppRouterImpl()
//       : super(
//           {
//             '/': ([a]) => HomeScreenRoute(),
//             '/test': ([args]) {
//               final typedArgs = args as TestPage2RouteArgs?;
//               return TestPage2Route(
//                 id: typedArgs?.id ?? "def",
//               );
//             },
//             '/settings': ([a]) {
//               final typedArgs = a as SettingsModalArguments?;
//               return SettingsModalRoute(
//                 typedArgs?.id,
//               );
//             }
//           },
//           routeInfos.expanded.toList(),
//         );
// }

// class HomeScreenArguments {}

// class HomeScreenRoute extends AppRoute implements HomeScreenArguments {
//   HomeScreenRoute()
//       : super(
//           name: '/',
//           page: const HomeScreen(),
//         );
// }

// class TestPage2RouteArgs {
//   final String id;

//   TestPage2RouteArgs(this.id);
// }

// class TestPage2Route extends AppRoute implements TestPage2RouteArgs {
//   @override
//   final String id;

//   TestPage2Route({this.id = "def"})
//       : super(
//           name: '/test',
//           page: TestScreen(
//             id: id,
//           ),
//         );
// }

// class SettingsModalRoute extends AppRoute implements SettingsModalArguments {
//   @override
//   final String? id;

//   SettingsModalRoute(this.id)
//       : super(
//           name: '/settings',
//           page: SettingsModal(
//             id: id,
//           ),
//         );
// }

// class SettingsModalArguments {
//   final String? id;

//   SettingsModalArguments(this.id);
// }
