import 'package:example/pages/home.dart';
import 'package:example/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nomo_router/router/nomo_navigator.dart';

class SettingsModal extends StatelessWidget {
  final String? id;

  const SettingsModal({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 400,
          height: 800,
          color: Colors.white,
          child: Column(
            children: [
              Center(
                child: Text(
                  'Settings:  $id',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              TextField(),
              const SizedBox(height: 20),
              const RouteSelector(),
              ElevatedButton(
                onPressed: () {
                  NomoNavigator.of(context).push(
                    SettingsModalRoute(id: "amk"),
                  );
                },
                child: const Text(
                  "Settings with id",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
