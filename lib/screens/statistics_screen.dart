import 'package:flutter/material.dart';

import '../services/statistics_engine.dart';
import '../utils/number_format.dart';

/// Enter a comma- or space-separated dataset and read back a panel of
/// descriptive statistics. Validation happens inline so the user sees exactly
/// which entry was rejected.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsEngine _engine = const StatisticsEngine();
  final TextEditingController _input = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Map<String, String> _results = const {};

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  List<double>? _parse(String raw) {
    final pieces = raw
        .split(RegExp(r'[,\s]+'))
        .where((p) => p.trim().isNotEmpty)
        .toList();
    if (pieces.isEmpty) return null;
    final values = <double>[];
    for (final piece in pieces) {
      final v = double.tryParse(piece);
      if (v == null) return null;
      values.add(v);
    }
    return values;
  }

  void _analyse() {
    if (!_formKey.currentState!.validate()) return;
    final data = _parse(_input.text)!;
    setState(() {
      _results = {
        'Count': '${data.length}',
        'Sum': formatNumber(_engine.sum(data)),
        'Mean': formatNumber(_engine.mean(data)),
        'Median': formatNumber(_engine.median(data)),
        'Mode': _engine.mode(data).map(formatNumber).join(', '),
        'Range': formatNumber(_engine.range(data)),
        'Variance (pop.)': formatNumber(_engine.variance(data)),
        'Std dev (pop.)': formatNumber(_engine.standardDeviation(data)),
        if (data.length > 1)
          'Std dev (sample)':
              formatNumber(_engine.standardDeviation(data, sample: true)),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _input,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Dataset',
                hintText: 'e.g. 12, 7, 9, 9, 14, 3',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final parsed = _parse(value ?? '');
                if (parsed == null) {
                  return 'Enter numbers separated by commas or spaces.';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _analyse,
            icon: const Icon(Icons.calculate_rounded),
            label: const Text('Analyse'),
          ),
          const SizedBox(height: 20),
          if (_results.isNotEmpty)
            Card(
              child: Column(
                children: [
                  for (final entry in _results.entries)
                    ListTile(
                      title: Text(entry.key),
                      trailing: Text(
                        entry.value,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
