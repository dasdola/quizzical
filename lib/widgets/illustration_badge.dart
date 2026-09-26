import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Decorative illustration used on the welcome, configuration and result
/// screens. The Figma file uses 3D artwork; this draws a simple icon-based
/// version so the app has no image assets. To use exported Figma images,
/// replace the body of [build] with an `Image.asset(...)` (and declare the
/// asset in pubspec.yaml).
class IllustrationBadge extends StatelessWidget {
  const IllustrationBadge({
    super.key,
    required this.icon,
    this.size = 200,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.9,
              height: size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
            Container(
              width: size * 0.62,
              height: size * 0.62,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9B6BFF), Color(0xFFFF7A59)],
                ),
              ),
              child: Icon(icon, size: size * 0.32, color: Colors.white),
            ),
            Positioned(
              top: size * 0.08,
              right: size * 0.14,
              child: _Dot(color: const Color(0xFFFFC94D), size: size * 0.15),
            ),
            Positioned(
              bottom: size * 0.1,
              left: size * 0.1,
              child: _Dot(color: const Color(0xFF5FD4A0), size: size * 0.12),
            ),
            Positioned(
              top: size * 0.2,
              left: size * 0.06,
              child: _Dot(color: const Color(0xFFFF6B8B), size: size * 0.09),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
