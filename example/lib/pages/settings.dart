import 'package:example/pages/home.dart';
import 'package:example/routes.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/router/nomo_navigator.dart';

class SettingsModal extends StatelessWidget {
  final String? id;

  const SettingsModal({this.id});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        height: 400,
        color: Colors.red,
        child: Column(
          children: [
            Center(
              child: Text('Settings:  $id'),
            ),
            RouteSelector(),
            ElevatedButton(
              onPressed: () {
                NomoNavigator.of(context).push(
                  SettingsModalRoute(id: "amk"),
                );
              },
              child: Text(
                "Settings with id",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
