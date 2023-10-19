// TestScreen
import 'package:example/pages/home.dart';
import 'package:flutter/widgets.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Center(
          child: Text('Test SCreen'),
        ),
        RouteSelector(),
      ],
    );
  }
}
