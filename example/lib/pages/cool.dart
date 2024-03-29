import 'package:example/pages/home.dart';
import 'package:flutter/widgets.dart';

class CoolScreen extends StatelessWidget {
  const CoolScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Center(
          child: Text(
            'Cool Screen',
            style: TextStyle(fontSize: 32),
          ),
        ),
        SizedBox(height: 20),
        RouteSelector(),
      ],
    );
  }
}
