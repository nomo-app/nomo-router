import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/entities/route_info.dart';

class NomoNavigatorInformationProvider extends InheritedWidget {
  final RouteInfo current;

  const NomoNavigatorInformationProvider({
    super.key,
    required super.child,
    required this.current,
  });

  static RouteInfo of(BuildContext context) {
    final NomoNavigatorInformationProvider? result = context
        .dependOnInheritedWidgetOfExactType<NomoNavigatorInformationProvider>();
    assert(result != null, 'No RouteInfoProvider found in context');
    return result!.current;
  }

  static RouteInfo? maybeOf(BuildContext context) {
    final NomoNavigatorInformationProvider? result = context
        .dependOnInheritedWidgetOfExactType<NomoNavigatorInformationProvider>();
    return result?.current;
  }

  @override
  bool updateShouldNotify(NomoNavigatorInformationProvider oldWidget) {
    return oldWidget.current != current;
  }
}
