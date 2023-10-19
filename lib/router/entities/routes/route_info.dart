// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';

@immutable
sealed class RouteInfo {
  final String name;
  final Widget page;
  final Iterable<RouteInfo>? children;

  const RouteInfo({
    required this.name,
    required this.page,
    this.children,
  });

  int get depth => name.split('/').length - 1;

  bool get isUnderyling => name.split('/').length > 1;
}

enum ModalTransition {
  SLIDE,
  FADE,
}

final class PageRouteInfo extends RouteInfo {
  const PageRouteInfo({
    required super.name,
    required super.page,
    super.children,
  });
}

final class ModalRouteInfo extends RouteInfo {
  final ModalTransition transition;

  const ModalRouteInfo({
    required super.name,
    required super.page,
    super.children,
    this.transition = ModalTransition.SLIDE,
  });
}
