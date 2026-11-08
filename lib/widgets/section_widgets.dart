import 'package:flutter/material.dart';

/// Shared building blocks so every portal screen keeps the same
/// glass look: screen title, small label, progress bar, form fields.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}

class AttendanceBar extends StatelessWidget {
  const AttendanceBar({super.key, required this.value});

  final double value; // 0-100

  Color get _color {
    if (value >= 85) return const Color(0xFF34D399);
    if (value >= 75) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(_color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${value.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _color,
          ),
        ),
      ],
    );
  }
}

/// The standard glass text-field look, shared by all forms.
InputDecoration glassFieldDecoration({
  required String label,
  IconData? icon,
  String? hint,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon, size: 20),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.06),
    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
    border: border(Colors.white.withValues(alpha: 0.15)),
    enabledBorder: border(Colors.white.withValues(alpha: 0.15)),
    focusedBorder: border(const Color(0xFF22D3EE), 1.6),
    errorBorder: border(const Color(0xFFF87171)),
    focusedErrorBorder: border(const Color(0xFFF87171), 1.6),
  );
}

/// Centred icon + message used when a section has nothing to show yet.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: Colors.white.withValues(alpha: 0.35)),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(actionLabel!),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF22D3EE),
                side: BorderSide(
                  color: const Color(0xFF22D3EE).withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Honest footer note shown at the bottom of portal screens.
class InfoNote extends StatelessWidget {
  const InfoNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        'Courses and timetable are real for BSSE-A, Semester 5. Results, '
        'fees and attendance are your own entries. This app is a student '
        'project — it is not Riphah\u2019s official system.',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
