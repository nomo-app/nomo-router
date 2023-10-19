import 'package:example/pages/home.dart';
import 'package:flutter/widgets.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Center(
          child: Text('Settings'),
        ),
        RouteSelector(),
      ],
    );
  }
}
