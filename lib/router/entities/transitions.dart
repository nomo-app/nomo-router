import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';

export 'package:animations/animations.dart';

sealed class PageTransition {
  const PageTransition();

  Widget getTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return switch (this) {
      PageFadeTransition _ => FadeTransition(
          opacity: animation,
          child: child,
        ),
      PageFadeScaleTransition _ => FadeScaleTransition(
          animation: animation,
          child: child,
        ),
      PageFadeThroughTransition transition => FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          fillColor: transition.fillColor,
          child: child,
        ),
      PageSlideTransition _ => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      PageSharedAxisTransition transition => SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transition.type,
          fillColor: transition.fillColor,
          child: child,
        ),
    };
  }
}

final class PageFadeTransition extends PageTransition {
  const PageFadeTransition();
}

final class PageFadeScaleTransition extends PageTransition {
  const PageFadeScaleTransition();
}

final class PageSlideTransition extends PageTransition {
  const PageSlideTransition();
}

final class PageFadeThroughTransition extends PageTransition {
  final Color? fillColor;

  const PageFadeThroughTransition({this.fillColor});
}

final class PageSharedAxisTransition extends PageTransition {
  final SharedAxisTransitionType type;
  final Color? fillColor;

  const PageSharedAxisTransition({required this.type, this.fillColor});
}
