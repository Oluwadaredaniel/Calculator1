import 'package:flutter/material.dart';

import '../models/calculation_history.dart';

/// The upper readout: the live expression, the most recent answer, and a
/// scrollable ribbon of prior calculations.
class DisplayPanel extends StatelessWidget {
  const DisplayPanel({
    super.key,
    required this.expression,
    required this.preview,
    required this.history,
  });

  final String expression;
  final String preview;
  final List<CalculationEntry> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 22,
            child: ListView(
              reverse: true,
              scrollDirection: Axis.horizontal,
              children: [
                for (final entry in history.reversed)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      entry.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              expression.isEmpty ? '0' : expression,
              maxLines: 1,
              style: theme.textTheme.displayLarge,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            preview,
            style: theme.textTheme.displaySmall,
          ),
        ],
      ),
    );
  }
}
