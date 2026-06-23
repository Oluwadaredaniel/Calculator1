import 'dart:math' as math;

/// Descriptive statistics over a list of samples. Variance and standard
/// deviation default to the population form; pass [sample] = true for the
/// unbiased (n - 1) estimator.
class StatisticsEngine {
  const StatisticsEngine();

  double mean(List<double> xs) {
    _requireData(xs);
    return xs.reduce((a, b) => a + b) / xs.length;
  }

  double median(List<double> xs) {
    _requireData(xs);
    final sorted = [...xs]..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }

  /// Returns every value that ties for the highest frequency. A perfectly
  /// uniform set yields all of its members.
  List<double> mode(List<double> xs) {
    _requireData(xs);
    final counts = <double, int>{};
    for (final x in xs) {
      counts[x] = (counts[x] ?? 0) + 1;
    }
    final highest = counts.values.reduce(math.max);
    return counts.entries
        .where((e) => e.value == highest)
        .map((e) => e.key)
        .toList()
      ..sort();
  }

  double variance(List<double> xs, {bool sample = false}) {
    _requireData(xs);
    final divisor = sample ? xs.length - 1 : xs.length;
    if (divisor <= 0) throw ArgumentError('Need 2+ values for sample variance');
    final m = mean(xs);
    final ss = xs.fold<double>(0, (sum, x) => sum + math.pow(x - m, 2));
    return ss / divisor;
  }

  double standardDeviation(List<double> xs, {bool sample = false}) =>
      math.sqrt(variance(xs, sample: sample));

  double range(List<double> xs) {
    _requireData(xs);
    return xs.reduce(math.max) - xs.reduce(math.min);
  }

  double sum(List<double> xs) {
    _requireData(xs);
    return xs.reduce((a, b) => a + b);
  }

  void _requireData(List<double> xs) {
    if (xs.isEmpty) throw ArgumentError('Provide at least one value');
  }
}
