import 'package:flutter/material.dart';

/// Warm cream backdrop in the official Riphah colours, with very
/// subtle navy and gold tints in opposite corners. (This widget used
/// to render the animated dark glow background — same place in the
/// tree, new light look.)
class GlowBackground extends StatelessWidget {
  const GlowBackground({super.key, required this.child});

  final Widget child;

  Widget _tint(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.07),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFFF7F5EA)),
        Positioned(
          top: -120,
          right: -80,
          child: _tint(300, const Color(0xFF003366)),
        ),
        Positioned(
          bottom: -140,
          left: -90,
          child: _tint(340, const Color(0xFFFFCC22)),
        ),
        child,
      ],
    );
  }
}
