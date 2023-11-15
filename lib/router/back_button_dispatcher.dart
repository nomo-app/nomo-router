import 'package:flutter/widgets.dart';
import 'package:nomo_router/router/delegate.dart';

class NomoBackButtonDispatcher extends RootBackButtonDispatcher {
  final NomoRouterDelegate delegate;
  NomoBackButtonDispatcher(this.delegate);

  @override
  Future<bool> didPopRoute() async {
    return delegate.pop();
  }
}
