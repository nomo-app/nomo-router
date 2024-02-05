import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/delegate.dart';

class NomoBackButtonDispatcher extends RootBackButtonDispatcher {
  final NomoRouterDelegate delegate;
  final Future<bool> Function()? shouldPop;
  final Future<bool> Function()? willPop;

  NomoBackButtonDispatcher(this.delegate, this.shouldPop, this.willPop);

  @override
  Future<bool> didPopRoute() async {
    ///
    /// Will Pop
    ///
    if (willPop != null) {
      final will = await willPop!();
      if (will == false) return true;
    }

    ///
    /// Pop
    ///
    final didPop = delegate.pop();
    if (didPop) return true;

    ///
    /// Should Pop
    ///
    if (shouldPop == null) return false;

    final should = await shouldPop!();
    return !should;
  }
}
