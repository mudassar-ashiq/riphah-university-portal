import 'package:flutter/material.dart';

/// Dark backdrop with two large, slowly drifting glow blobs (cyan and
/// violet). The glass card sits on top and blurs this light through.
class GlowBackground extends StatefulWidget {
  const GlowBackground({super.key, required this.child});

  final Widget child;

  @override
  State<GlowBackground> createState() => _GlowBackgroundState();
}

class _GlowBackgroundState extends State<GlowBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.55), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFF050B14)),
            Positioned(
              top: -90 + t * 50,
              left: -70 + t * 90,
              child: _blob(320, const Color(0xFF0891B2)),
            ),
            Positioned(
              bottom: -110 + t * 40,
              right: -60 - t * 70,
              child: _blob(360, const Color(0xFF6D28D9)),
            ),
            Positioned(
              top: 240 - t * 60,
              right: 30 + t * 40,
              child: _blob(150, const Color(0xFF0EA5E9)),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}
