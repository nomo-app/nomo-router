import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/delegate.dart';

class NomoBackButtonDispatcher extends RootBackButtonDispatcher {
  final NomoRouterDelegate delegate;
  final Future<bool> Function()? shouldPop;

  NomoBackButtonDispatcher(this.delegate, this.shouldPop);

  @override
  Future<bool> didPopRoute() async {
    final didPop = delegate.pop();
    if (didPop) return true;

    if (shouldPop == null) return false;

    final should = await shouldPop!();
    return !should;
  }
}
