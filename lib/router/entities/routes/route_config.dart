import 'package:flutter/widgets.dart';

class RouteConfig extends RouteSettings {
  final Map<String, dynamic>? urlArguments;

  const RouteConfig({
    super.name,
    super.arguments,
    this.urlArguments,
  });
}
