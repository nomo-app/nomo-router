// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';

@immutable
sealed class RouteInfo {
  final String name;
  final Widget page;
  final List<RouteInfo>? children;

  const RouteInfo({
    required this.name,
    required this.page,
    this.children,
  });

  bool get isRoot => name == "/";

  Iterable<RouteInfo> get underlying =>
      children?.expand(
        (routeInfo) => [
          routeInfo.combine(this),
          ...routeInfo.underlying,
        ],
      ) ??
      [];

  RouteInfo combine(RouteInfo other);

  @override
  int get hashCode => name.hashCode ^ page.hashCode ^ children.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          page == other.page &&
          children == other.children;
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

  @override
  RouteInfo combine(RouteInfo other) {
    if (other.isRoot) return this;
    return PageRouteInfo(
      name: "${other.name}$name",
      page: other.page,
      children: other.children,
    );
  }
}

final class ModalRouteInfo extends RouteInfo {
  final ModalTransition transition;

  const ModalRouteInfo({
    required super.name,
    required super.page,
    super.children,
    this.transition = ModalTransition.SLIDE,
  });

  @override
  RouteInfo combine(RouteInfo other) {
    if (other.isRoot) return this;
    return ModalRouteInfo(
      name: "${other.name}$name",
      page: other.page,
      children: other.children,
      transition: transition,
    );
  }
}

final class NestedPageRouteInfo extends PageRouteInfo {
  final Widget Function(Widget nav) wrapper;

  const NestedPageRouteInfo({
    required super.name,
    required super.page,
    required this.wrapper,
    super.children,
  });
}

///
/// RouteInfos for Menu
///

final class MenuPageRouteInfo extends PageRouteInfo {
  final String title;
  final IconData? icon;
  final ImageProvider? image;

  const MenuPageRouteInfo({
    required super.name,
    required super.page,
    required this.title,
    this.icon,
    this.image,
    super.children,
  });
}

final class MenuNestedPageRouteInfo extends MenuPageRouteInfo
    implements NestedPageRouteInfo {
  @override
  final Widget Function(Widget nav) wrapper;
  const MenuNestedPageRouteInfo({
    required this.wrapper,
    required super.name,
    required super.page,
    required super.title,
    super.children,
    super.icon,
    super.image,
  });
}
