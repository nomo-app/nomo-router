import 'package:example/main.dart';
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
        for (final r in Routes.allRoutes)
          ElevatedButton(
            onPressed: () {
              NomoNavigator.of(context).push(r);
            },
            child: Text(r.name),
          ),
      ],
    );
  }
}
