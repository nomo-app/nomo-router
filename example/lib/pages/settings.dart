import 'package:example/pages/home.dart';
import 'package:example/routes.dart';
import 'package:flutter/material.dart';
import 'package:nomo_router/nomo_router.dart';

class SettingsModal extends StatefulWidget {
  final String? id;

  const SettingsModal({super.key, this.id});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  @override
  Widget build(BuildContext context) {
    final isPage = RouteInfoProvider.of(context).type == RouteType.page;

    return Material(
      type: MaterialType.card,
      child: SizedBox(
        width: isPage ? null : 400,
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
      ),
    );
  }
}
