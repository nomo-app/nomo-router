// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/entities/transitions.dart';

@immutable
sealed class RouteInfo {
  final String path;
  final Type page;
  final List<RouteInfo>? children;
  final PageTransition? transition;
  final String? routePostfix;

  const RouteInfo({
    required this.path,
    required this.page,
    this.routePostfix,
    this.children,
    this.transition,
  });

  bool get isRoot => path == "/";

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
  int get hashCode => path.hashCode ^ page.hashCode ^ children.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteInfo &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          page == other.page &&
          children == other.children;
}

final class PageRouteInfo extends RouteInfo {
  const PageRouteInfo({
    required super.path,
    required super.page,
    super.routePostfix,
    super.children,
    super.transition,
  });

  @override
  RouteInfo combine(RouteInfo other) {
    if (other.isRoot) return this;
    return PageRouteInfo(
      path: "${other.path}$path",
      page: page,
      children: children,
    );
  }
}

final class ModalRouteInfo extends RouteInfo {
  final bool useRootNavigator;

  const ModalRouteInfo({
    required super.path,
    required super.page,
    super.children,
    super.transition,
    super.routePostfix,
    this.useRootNavigator = true,
  });

  @override
  RouteInfo combine(RouteInfo other) {
    if (other.isRoot) return this;
    return ModalRouteInfo(
      path: "${other.path}$path",
      page: page,
      children: children,
      useRootNavigator: useRootNavigator,
    );
  }
}

final class NestedPageRouteInfo extends PageRouteInfo {
  final Widget Function(Widget nav) wrapper;

  const NestedPageRouteInfo({
    required super.path,
    required super.page,
    required this.wrapper,
    super.children,
    super.transition,
    super.routePostfix,
  });

  @override
  RouteInfo combine(RouteInfo other) {
    if (other.isRoot) return this;
    return NestedPageRouteInfo(
      path: "${other.path}$path",
      page: page,
      wrapper: wrapper,
      children: children,
    );
  }
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
    required super.path,
    required super.page,
    required this.title,
    this.icon,
    this.image,
    super.children,
    super.transition,
    super.routePostfix,
  });

  @override
  RouteInfo combine(RouteInfo other) {
    if (other.isRoot) return this;
    return MenuPageRouteInfo(
      path: "${other.path}$path",
      page: page,
      title: title,
      icon: icon,
      image: image,
      children: children,
    );
  }
}

final class MenuNestedPageRouteInfo extends MenuPageRouteInfo
    implements NestedPageRouteInfo {
  @override
  final Widget Function(Widget nav) wrapper;
  const MenuNestedPageRouteInfo({
    required this.wrapper,
    required super.path,
    required super.page,
    required super.title,
    super.children,
    super.icon,
    super.image,
    super.transition,
    super.routePostfix,
  });

  @override
  RouteInfo combine(RouteInfo other) {
    if (other.isRoot) return this;
    return MenuNestedPageRouteInfo(
      path: "${other.path}$path",
      page: page,
      title: title,
      icon: icon,
      image: image,
      wrapper: wrapper,
      children: children,
    );
  }
}

final class MenuModalRouteInfo extends ModalRouteInfo with MenuRouteInfoMixin {
  @override
  final String title;
  @override
  final IconData? icon;
  @override
  final ImageProvider? image;

  const MenuModalRouteInfo({
    required super.path,
    required super.page,
    required this.title,
    super.children,
    super.transition,
    super.useRootNavigator,
    super.routePostfix,
    this.icon,
    this.image,
  });

  @override
  RouteInfo combine(RouteInfo other) {
    if (other.isRoot) return this;
    return MenuModalRouteInfo(
      path: "${other.path}$path",
      page: page,
      title: title,
      icon: icon,
      image: image,
      children: children,
      useRootNavigator: useRootNavigator,
    );
  }
}

mixin MenuRouteInfoMixin on RouteInfo {
  String get title;
  IconData? get icon;
  ImageProvider? get image;
}
