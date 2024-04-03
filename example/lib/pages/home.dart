import 'package:example/main.dart';
import 'package:example/pages/test.dart';
import 'package:example/routes.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/router/entities/transitions.dart';
import 'package:nomo_router/router/nomo_navigator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Center(
          child: Text(
            'Home Screen',
            style: TextStyle(fontSize: 32),
          ),
        ),
        SizedBox(height: 20),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: () {
                NomoNavigator.of(context).push(
                  appRouter.getRouteForPath(r.path)(),
                );
              },
              child: Text(r.path),
            ),
          ),
        const SizedBox(
          height: 8,
        ),
        ElevatedButton(
          onPressed: () {
            NomoNavigator.of(context).push(TestScreenRoute(
              id: TestEnum.two,
            ));
          },
          child: const Text("Test with Id"),
        ),
        const SizedBox(
          height: 8,
        ),
        ElevatedButton(
          onPressed: () {
            NomoNavigator.of(context).pushNamed("/amkrandom");
          },
          child: const Text("Random"),
        ),
        const SizedBox(
          height: 8,
        ),
        ElevatedButton(
          onPressed: () {
            NomoNavigator.fromKey.push(TestScreenRoute(
              id: TestEnum.two,
            ));
          },
          child: const Text("Without Context"),
        ),
        const SizedBox(
          height: 8,
        ),
        ElevatedButton(
          onPressed: () {
            NomoNavigator.of(context).pushModal(
              transition: const PageFadeScaleTransition(),
              modal: const Center(
                child: Modal(),
              ),
            );
          },
          child: const Text("Show Dialog"),
        ),
        const SizedBox(
          height: 8,
        ),
        ElevatedButton(
          onPressed: () {
            NomoNavigator.of(context).pushModal(
              transition: const PageFadeScaleTransition(),
              modal: const Center(
                child: Modal(),
              ),
            );
          },
          child: const Text("Show Dialog / Page"),
        ),
      ],
    );
  }
}

class Modal extends StatelessWidget {
  const Modal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      color: Colors.white,
      child: Center(
        child: TextButton(
          onPressed: () => NomoNavigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ),
    );
  }
}
