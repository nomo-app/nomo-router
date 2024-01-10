import 'package:example/main.dart';
import 'package:example/pages/test.dart';
import 'package:example/routes.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/router/nomo_navigator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Center(
          child: Text('Home Screen'),
        ),
        RouteSelector(),
      ],
    );
  }
}

class RouteSelector extends StatelessWidget {
  const RouteSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final r in appRouter.routeInfos)
          ElevatedButton(
            onPressed: () {
              NomoNavigator.of(context).push(
                appRouter.getRouteForPath(r.path)(),
              );
            },
            child: Text(r.path),
          ),
        ElevatedButton(
          onPressed: () {
            NomoNavigator.of(context).push(TestScreenRoute(
              id: TestEnum.two,
            ));
          },
          child: const Text("Test with Id"),
        ),
        ElevatedButton(
          onPressed: () {
            NomoNavigator.of(context).pushNamed("/amkrandom");
          },
          child: const Text("Random"),
        ),
        ElevatedButton(
          onPressed: () {
            nomoNavigatorKey.currentState?.delegate.push(TestScreenRoute());
          },
          child: const Text("Without Context"),
        ),
      ],
    );
  }
}
