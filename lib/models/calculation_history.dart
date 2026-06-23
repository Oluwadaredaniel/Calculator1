/// A single completed calculation, kept so the display can show a running
/// ledger of recent work. Immutable by design.
class CalculationEntry {
  const CalculationEntry({
    required this.expression,
    required this.result,
  });

  final String expression;
  final String result;

  @override
  String toString() => '$expression = $result';
}
