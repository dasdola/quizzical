import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Scrollable page body that is centred, width-limited on large screens and
/// at least as tall as the viewport (so content can be spread out with
/// `MainAxisAlignment.spaceBetween` on tall phones and still scrolls on
/// small ones without overflowing).
class AdaptiveScroll extends StatelessWidget {
  const AdaptiveScroll({
    super.key,
    required this.child,
    this.maxWidth = 520,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = math.max(0.0, constraints.maxHeight - padding.vertical);
        return SingleChildScrollView(
          padding: padding,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: minHeight,
                maxWidth: maxWidth,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
