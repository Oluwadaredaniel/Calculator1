import 'dart:math' as math;

/// Whether trigonometric input/output is interpreted in degrees or radians.
enum AngleUnit { degrees, radians }

/// Pure scientific helpers: trigonometry, hyperbolic functions, logs, roots,
/// factorials and combinatorics. Every method is static so the engine carries
/// no state of its own beyond the [AngleUnit] passed per call.
class ScientificEngine {
  const ScientificEngine();

  double _toRadians(double angle, AngleUnit unit) =>
      unit == AngleUnit.degrees ? angle * math.pi / 180.0 : angle;

  // --- Trigonometry -------------------------------------------------------
  double sine(double angle, AngleUnit unit) => math.sin(_toRadians(angle, unit));
  double cosine(double angle, AngleUnit unit) =>
      math.cos(_toRadians(angle, unit));
  double tangent(double angle, AngleUnit unit) =>
      math.tan(_toRadians(angle, unit));

  // --- Hyperbolic functions ----------------------------------------------
  double sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
  double cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;
  double tanh(double x) {
    final e2x = math.exp(2 * x);
    return (e2x - 1) / (e2x + 1);
  }

  // --- Logs, roots, powers -----------------------------------------------
  double naturalLog(double x) {
    if (x <= 0) throw ArgumentError('ln expects a positive value');
    return math.log(x);
  }

  double log10(double x) {
    if (x <= 0) throw ArgumentError('log expects a positive value');
    return math.log(x) / math.ln10;
  }

  double squareRoot(double x) {
    if (x < 0) throw ArgumentError('Cannot take the root of a negative');
    return math.sqrt(x);
  }

  double power(double base, double exponent) =>
      math.pow(base, exponent).toDouble();

  // --- Combinatorics ------------------------------------------------------
  double factorial(int n) {
    if (n < 0) throw ArgumentError('Factorial is undefined for negatives');
    if (n > 170) throw ArgumentError('Value too large for a factorial');
    var result = 1.0;
    for (var i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  /// Permutations: nPr = n! / (n - r)!
  double permutations(int n, int r) {
    if (r < 0 || r > n) throw ArgumentError('Require 0 <= r <= n');
    var result = 1.0;
    for (var i = n; i > n - r; i--) {
      result *= i;
    }
    return result;
  }

  /// Combinations: nCr = nPr / r!
  double combinations(int n, int r) {
    if (r < 0 || r > n) throw ArgumentError('Require 0 <= r <= n');
    final k = math.min(r, n - r);
    var result = 1.0;
    for (var i = 0; i < k; i++) {
      result = result * (n - i) / (i + 1);
    }
    return result;
  }
}
