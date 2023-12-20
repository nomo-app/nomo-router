import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_router/router/entities/route.dart';

const notFoundRouteInfo = PageRouteInfo(path: "/notFound", page: NotFound);

class NotFoundRoute<A> implements AppRoute {
  @override
  final Widget page = const NotFound();

  @override
  final String name = "/notFound";

  const NotFoundRoute();
}

class NotFound extends StatelessWidget {
  const NotFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Column(
            children: [
              Text(
                "404",
                style: TextStyle(fontSize: 128),
              ),
              Text(
                "Page not Found",
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => NomoNavigator.of(context).replaceNamed("/"),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                "Head back home",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
