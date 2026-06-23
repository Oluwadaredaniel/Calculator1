/// Formats doubles for display: trims a trailing ".0", caps runaway decimals,
/// and falls back to scientific notation for very large or very small results.
String formatNumber(double value) {
  if (value.isNaN) return 'Error';
  if (value.isInfinite) return value.isNegative ? '-∞' : '∞';

  final magnitude = value.abs();
  if (magnitude != 0 && (magnitude >= 1e12 || magnitude < 1e-9)) {
    return value.toStringAsExponential(6);
  }

  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }

  // Keep up to 8 significant decimals, then strip trailing zeros.
  var text = value.toStringAsFixed(8);
  text = text.replaceFirst(RegExp(r'0+$'), '');
  text = text.replaceFirst(RegExp(r'\.$'), '');
  return text;
}

/// Renders a matrix as aligned rows, used by the matrix screen's result card.
String formatMatrix(List<List<double>> matrix) {
  return matrix
      .map((row) => row.map(formatNumber).join('   '))
      .join('\n');
}
