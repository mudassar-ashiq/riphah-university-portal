// Small display formatting helpers (no intl dependency).

String formatRupees(int amount) {
  final s = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return 'Rs $buffer';
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// '20 Nov 2026'
String formatDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

/// '85' for whole marks, '45.5' otherwise.
String formatMarks(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';
