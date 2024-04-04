import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/entities/route_info.dart';

class NomoNavigatorInformationProvider extends InheritedWidget {
  final RouteInfo current;

  final Map<GlobalKey, LocalKey> keys;

  const NomoNavigatorInformationProvider({
    super.key,
    required super.child,
    required this.keys,
    required this.current,
  });

  static NomoNavigatorInformationProvider of(BuildContext context) {
    final NomoNavigatorInformationProvider? result = context
        .dependOnInheritedWidgetOfExactType<NomoNavigatorInformationProvider>();
    assert(result != null, 'No RouteInfoProvider found in context');
    return result!;
  }

  static NomoNavigatorInformationProvider? maybeOf(BuildContext context) {
    final NomoNavigatorInformationProvider? result = context
        .dependOnInheritedWidgetOfExactType<NomoNavigatorInformationProvider>();
    return result;
  }

  @override
  bool updateShouldNotify(NomoNavigatorInformationProvider oldWidget) {
    return oldWidget.current != current;
  }
}
