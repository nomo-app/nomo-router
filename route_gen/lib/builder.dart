library route_gen.builder;

import 'package:build/build.dart';
import 'package:route_gen/src/route_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder routeBuilder(BuilderOptions options) =>
    SharedPartBuilder([RouteGenerator()], 'route_builder');
