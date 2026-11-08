import 'package:flutter/material.dart';

/// A white content card in the official Riphah style: 20px radius
/// and a soft shadow on the cream background. (Formerly the frosted
/// "glass" card — same widget and API, new light look.)
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF003366).withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF001E35).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
