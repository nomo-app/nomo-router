import 'package:example/pages/home.dart';
import 'package:example/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_router/router/nomo_navigator.dart';

class SettingsModal extends StatefulWidget {
  final String? id;

  const SettingsModal({super.key, this.id});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  @override
  Widget build(BuildContext context) {
    final isPage = RouteInfoProvider.of(context).isPage;

    return Material(
      type: MaterialType.card,
      child: Column(
        mainAxisSize: isPage ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Center(
            child: Text(
              'Settings:  ${widget.id}',
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
    );
  }
}
