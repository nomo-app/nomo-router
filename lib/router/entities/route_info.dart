// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/entities/transitions.dart';

@immutable
sealed class RouteInfo {
  final String name;
  final Widget page;
  final List<RouteInfo>? children;
  final PageTransition? transition;

  const RouteInfo({
    required this.name,
    required this.page,
    this.children,
    this.transition,
  });

  bool get isRoot => name == "/";

  Iterable<RouteInfo> get underlying {
    if (children == null) return [];
    return children!.expand(
      (routeInfo) => [
        routeInfo.combine(this),
        ...routeInfo.underlying,
      ],
    );
  }

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

final class PageRouteInfo extends RouteInfo {
  const PageRouteInfo({
    required super.name,
    required super.page,
    super.children,
    super.transition,
  });

  @override
  RouteInfo combine(RouteInfo other) {
    if (other.isRoot) return this;
    return PageRouteInfo(
      name: "${other.name}$name",
      page: page,
      children: children,
    );
  }
}

final class ModalRouteInfo extends RouteInfo {
  final bool useRootNavigator;

  const ModalRouteInfo({
    required super.name,
    required super.page,
    super.children,
    super.transition,
    this.useRootNavigator = false,
  });

  @override
  RouteInfo combine(RouteInfo other) {
    if (other.isRoot) return this;
    return ModalRouteInfo(
      name: "${other.name}$name",
      page: page,
      children: children,
      useRootNavigator: useRootNavigator,
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
    super.transition,
  });
}

///
/// RouteInfos for Menu
///

final class MenuPageRouteInfo extends PageRouteInfo with MenuRouteInfoMixin {
  @override
  final String title;
  @override
  final IconData? icon;
  @override
  final ImageProvider? image;

  const MenuPageRouteInfo({
    required super.name,
    required super.page,
    required this.title,
    this.icon,
    this.image,
    super.children,
    super.transition,
  });
}

final class MenuNestedPageRouteInfo extends MenuPageRouteInfo implements NestedPageRouteInfo {
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
    super.transition,
  });
}

final class MenuModalRouteInfo extends ModalRouteInfo with MenuRouteInfoMixin {
  @override
  final String title;
  @override
  final IconData? icon;
  @override
  final ImageProvider? image;

  const MenuModalRouteInfo({
    required super.name,
    required super.page,
    required this.title,
    super.children,
    super.transition,
    super.useRootNavigator,
    this.icon,
    this.image,
  });
}

mixin MenuRouteInfoMixin on RouteInfo {
  String get title;
  IconData? get icon;
  ImageProvider? get image;
}
