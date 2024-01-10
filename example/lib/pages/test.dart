// TestScreen
import 'package:example/pages/home.dart';
import 'package:flutter/widgets.dart';

enum TestEnum {
  one,
  two,
  three,
}

class TestScreen extends StatelessWidget {
  final TestEnum id;

  const TestScreen({
    super.key,
    this.id = TestEnum.one,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text('Test SCreen: $id'),
        ),
        const RouteSelector(),
      ],
    );
  }
}
