import 'package:flutter/material.dart';

import '../services/matrix_engine.dart';
import '../utils/number_format.dart';

/// Interactive matrix studio. The user picks a size (2–4), fills in two
/// matrices, and runs an operation. A unary operation (determinant, transpose)
/// ignores the second matrix.
class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});

  @override
  State<MatrixScreen> createState() => _MatrixScreenState();
}

enum _MatrixOp { add, subtract, multiply, determinantA, transposeA }

class _MatrixScreenState extends State<MatrixScreen> {
  final MatrixEngine _engine = const MatrixEngine();

  int _size = 2;
  _MatrixOp _op = _MatrixOp.add;
  late List<List<TextEditingController>> _a;
  late List<List<TextEditingController>> _b;

  String? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rebuildControllers();
  }

  void _rebuildControllers() {
    _a = _grid(_size);
    _b = _grid(_size);
  }

  List<List<TextEditingController>> _grid(int n) => List.generate(
        n,
        (_) => List.generate(n, (_) => TextEditingController(text: '0')),
      );

  @override
  void dispose() {
    for (final row in [..._a, ..._b]) {
      for (final c in row) {
        c.dispose();
      }
    }
    super.dispose();
  }

  List<List<double>> _read(List<List<TextEditingController>> grid) {
    return grid
        .map((row) =>
            row.map((c) => double.tryParse(c.text.trim()) ?? 0.0).toList())
        .toList();
  }

  void _run() {
    setState(() {
      _error = null;
      _result = null;
    });
    try {
      final a = _read(_a);
      final result = switch (_op) {
        _MatrixOp.add => formatMatrix(_engine.add(a, _read(_b))),
        _MatrixOp.subtract => formatMatrix(_engine.subtract(a, _read(_b))),
        _MatrixOp.multiply => formatMatrix(_engine.multiply(a, _read(_b))),
        _MatrixOp.determinantA => formatNumber(_engine.determinant(a)),
        _MatrixOp.transposeA => formatMatrix(_engine.transpose(a)),
      };
      setState(() => _result = result);
    } on ArgumentError catch (e) {
      setState(() => _error = e.message.toString());
    } catch (_) {
      setState(() => _error = 'Could not complete that operation.');
    }
  }

  bool get _isUnary =>
      _op == _MatrixOp.determinantA || _op == _MatrixOp.transposeA;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matrix studio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Size'),
              for (final n in [2, 3, 4])
                ChoiceChip(
                  label: Text('$n×$n'),
                  selected: _size == n,
                  onSelected: (_) => setState(() {
                    _size = n;
                    _rebuildControllers();
                    _result = null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _MatrixCard(title: 'Matrix A', controllers: _a),
          if (!_isUnary) ...[
            const SizedBox(height: 16),
            _MatrixCard(title: 'Matrix B', controllers: _b),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<_MatrixOp>(
            value: _op,
            decoration: const InputDecoration(
              labelText: 'Operation',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: _MatrixOp.add, child: Text('A + B')),
              DropdownMenuItem(value: _MatrixOp.subtract, child: Text('A − B')),
              DropdownMenuItem(value: _MatrixOp.multiply, child: Text('A × B')),
              DropdownMenuItem(
                  value: _MatrixOp.determinantA, child: Text('det(A)')),
              DropdownMenuItem(
                  value: _MatrixOp.transposeA, child: Text('transpose(A)')),
            ],
            onChanged: (value) => setState(() => _op = value ?? _op),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _run,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Compute'),
          ),
          const SizedBox(height: 20),
          if (_error != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!),
              ),
            ),
          if (_result != null)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Result', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      _result!,
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                        fontSize: 18,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MatrixCard extends StatelessWidget {
  const _MatrixCard({required this.title, required this.controllers});

  final String title;
  final List<List<TextEditingController>> controllers;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final row in controllers)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    for (final controller in row)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextField(
                            controller: controller,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
