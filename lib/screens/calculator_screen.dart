import 'package:flutter/material.dart';

import '../models/calculation_history.dart';
import '../services/arithmetic_engine.dart';
import '../services/scientific_engine.dart';
import '../utils/number_format.dart';
import '../widgets/calc_button.dart';
import '../widgets/display_panel.dart';
import 'matrix_screen.dart';
import 'statistics_screen.dart';

/// The home screen. All interaction state (the working expression, history,
/// keypad mode and angle unit) lives here and is mutated with [setState],
/// which is the assignment's state-management style for this project.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final ArithmeticEngine _arithmetic = const ArithmeticEngine();
  final ScientificEngine _scientific = const ScientificEngine();

  // nPr / nCr are written inline as "5P2" / "5C2" and detected on evaluate.
  static final RegExp _combinatoric = RegExp(r'^(\d+)\s*([PC])\s*(\d+)$');

  String _expression = '';
  String _preview = '';
  final List<CalculationEntry> _history = <CalculationEntry>[];
  bool _scientificMode = false;
  AngleUnit _angleUnit = AngleUnit.degrees;

  void _append(String token) {
    setState(() {
      _expression += token;
      _refreshPreview();
    });
  }

  void _clearAll() {
    setState(() {
      _expression = '';
      _preview = '';
    });
  }

  void _backspace() {
    if (_expression.isEmpty) return;
    setState(() {
      _expression = _expression.substring(0, _expression.length - 1);
      _refreshPreview();
    });
  }

  void _refreshPreview() {
    try {
      _preview = formatNumber(_compute(_expression));
    } catch (_) {
      _preview = '';
    }
  }

  double _compute(String raw) {
    final text = raw.trim();
    final combo = _combinatoric.firstMatch(text);
    if (combo != null) {
      final n = int.parse(combo.group(1)!);
      final r = int.parse(combo.group(3)!);
      return combo.group(2) == 'P'
          ? _scientific.permutations(n, r)
          : _scientific.combinations(n, r);
    }
    return _arithmetic.evaluate(text);
  }

  void _evaluate() {
    if (_expression.isEmpty) return;
    try {
      final value = _compute(_expression);
      final formatted = formatNumber(value);
      setState(() {
        _history.add(CalculationEntry(expression: _expression, result: formatted));
        if (_history.length > 12) _history.removeAt(0);
        _expression = formatted;
        _preview = '';
      });
    } on UnsupportedError catch (e) {
      _showError(e.message ?? 'Math error');
    } catch (_) {
      _showError('That expression is incomplete.');
    }
  }

  /// Immediate-execution unary functions: evaluate what's on screen, apply the
  /// function, and replace the expression with the formatted answer.
  void _applyUnary(double Function(double value) fn, String label) {
    if (_expression.isEmpty) return;
    try {
      final input = _compute(_expression);
      final result = fn(input);
      final formatted = formatNumber(result);
      setState(() {
        _history.add(
          CalculationEntry(expression: '$label($_expression)', result: formatted),
        );
        _expression = formatted;
        _preview = '';
      });
    } on ArgumentError catch (e) {
      _showError(e.message.toString());
    } catch (_) {
      _showError('Could not apply $label.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  IconData get _themeIcon => switch (widget.themeMode) {
        ThemeMode.system => Icons.brightness_auto_rounded,
        ThemeMode.light => Icons.light_mode_rounded,
        ThemeMode.dark => Icons.dark_mode_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aurora'),
        actions: [
          IconButton(
            tooltip: 'Matrix studio',
            icon: const Icon(Icons.grid_on_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MatrixScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Statistics',
            icon: const Icon(Icons.insights_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StatisticsScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Theme',
            icon: Icon(_themeIcon),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          DisplayPanel(
            expression: _expression,
            preview: _preview,
            history: _history,
          ),
          const SizedBox(height: 8),
          _ModeBar(
            scientificMode: _scientificMode,
            angleUnit: _angleUnit,
            onModeChanged: (value) => setState(() => _scientificMode = value),
            onAngleChanged: (value) => setState(() => _angleUnit = value),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_scientificMode) _buildScientificPad(),
                    _buildBasicPad(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScientificPad() {
    Widget fn(String label, double Function(double) op) =>
        CalcButton(label: label, tone: KeyTone.accent, onTap: () => _applyUnary(op, label));

    return Column(
      children: [
        Row(children: [
          fn('sin', (v) => _scientific.sine(v, _angleUnit)),
          fn('cos', (v) => _scientific.cosine(v, _angleUnit)),
          fn('tan', (v) => _scientific.tangent(v, _angleUnit)),
        ]),
        Row(children: [
          fn('sinh', _scientific.sinh),
          fn('cosh', _scientific.cosh),
          fn('tanh', _scientific.tanh),
        ]),
        Row(children: [
          fn('ln', _scientific.naturalLog),
          fn('log', _scientific.log10),
          fn('√', _scientific.squareRoot),
        ]),
        Row(children: [
          fn('x²', (v) => _scientific.power(v, 2)),
          CalcButton(label: 'xⁿ', tone: KeyTone.accent, onTap: () => _append('^')),
          fn('x!', (v) => _scientific.factorial(v.round())),
        ]),
        Row(children: [
          CalcButton(label: 'π', tone: KeyTone.accent, onTap: () => _append('3.14159265359')),
          CalcButton(label: 'e', tone: KeyTone.accent, onTap: () => _append('2.71828182846')),
          fn('1/x', (v) => 1 / v),
        ]),
        Row(children: [
          CalcButton(label: 'nPr', tone: KeyTone.accent, onTap: () => _append('P')),
          CalcButton(label: 'nCr', tone: KeyTone.accent, onTap: () => _append('C')),
          const _Spacer(),
        ]),
      ],
    );
  }

  Widget _buildBasicPad() {
    return Column(
      children: [
        Row(children: [
          CalcButton(label: 'AC', tone: KeyTone.danger, onTap: _clearAll),
          CalcButton(label: '⌫', onTap: _backspace),
          CalcButton(label: '(', onTap: () => _append('(')),
          CalcButton(label: ')', onTap: () => _append(')')),
        ]),
        Row(children: [
          CalcButton(label: '7', onTap: () => _append('7')),
          CalcButton(label: '8', onTap: () => _append('8')),
          CalcButton(label: '9', onTap: () => _append('9')),
          CalcButton(label: '÷', tone: KeyTone.operator, onTap: () => _append('/')),
        ]),
        Row(children: [
          CalcButton(label: '4', onTap: () => _append('4')),
          CalcButton(label: '5', onTap: () => _append('5')),
          CalcButton(label: '6', onTap: () => _append('6')),
          CalcButton(label: '×', tone: KeyTone.operator, onTap: () => _append('*')),
        ]),
        Row(children: [
          CalcButton(label: '1', onTap: () => _append('1')),
          CalcButton(label: '2', onTap: () => _append('2')),
          CalcButton(label: '3', onTap: () => _append('3')),
          CalcButton(label: '−', tone: KeyTone.operator, onTap: () => _append('-')),
        ]),
        Row(children: [
          CalcButton(label: '%', tone: KeyTone.operator, onTap: () => _append('%')),
          CalcButton(label: '0', onTap: () => _append('0')),
          CalcButton(label: '.', onTap: () => _append('.')),
          CalcButton(label: '+', tone: KeyTone.operator, onTap: () => _append('+')),
        ]),
        Row(children: [
          CalcButton(label: '=', tone: KeyTone.accent, flex: 4, onTap: _evaluate),
        ]),
      ],
    );
  }
}

/// Segmented Basic/Scientific switch with a degrees/radians toggle that only
/// appears in scientific mode.
class _ModeBar extends StatelessWidget {
  const _ModeBar({
    required this.scientificMode,
    required this.angleUnit,
    required this.onModeChanged,
    required this.onAngleChanged,
  });

  final bool scientificMode;
  final AngleUnit angleUnit;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<AngleUnit> onAngleChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Basic')),
                ButtonSegment(value: true, label: Text('Scientific')),
              ],
              selected: {scientificMode},
              onSelectionChanged: (s) => onModeChanged(s.first),
            ),
          ),
          if (scientificMode) ...[
            const SizedBox(width: 12),
            IconButton.filledTonal(
              tooltip: angleUnit == AngleUnit.degrees ? 'Degrees' : 'Radians',
              onPressed: () => onAngleChanged(
                angleUnit == AngleUnit.degrees
                    ? AngleUnit.radians
                    : AngleUnit.degrees,
              ),
              icon: Text(angleUnit == AngleUnit.degrees ? 'DEG' : 'RAD'),
            ),
          ],
        ],
      ),
    );
  }
}

/// An empty grid cell that keeps a partially-filled keypad row aligned.
class _Spacer extends StatelessWidget {
  const _Spacer();

  @override
  Widget build(BuildContext context) => const Expanded(child: SizedBox());
}
