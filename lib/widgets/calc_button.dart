import 'package:flutter/material.dart';

/// Visual weighting for a key, mapped onto the Material 3 colour roles so the
/// keypad reads as a hierarchy rather than a wall of identical buttons.
enum KeyTone { neutral, accent, operator, danger }

class CalcButton extends StatelessWidget {
  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.tone = KeyTone.neutral,
    this.flex = 1,
  });

  final String label;
  final VoidCallback onTap;
  final KeyTone tone;
  final int flex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (Color bg, Color fg) = switch (tone) {
      KeyTone.neutral => (scheme.surfaceContainerHighest, scheme.onSurface),
      KeyTone.accent => (scheme.primaryContainer, scheme.onPrimaryContainer),
      KeyTone.operator => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      KeyTone.danger => (scheme.errorContainer, scheme.onErrorContainer),
    };

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 64,
              alignment: Alignment.center,
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: fg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
