import 'package:flutter/material.dart';

import 'screens/calculator_screen.dart';
import 'theme/app_theme.dart';

/// Root widget. Theme mode is held here and toggled from the calculator
/// screen via a callback, keeping the rest of the tree free of inherited
/// theme plumbing.
class AuroraCalculatorApp extends StatefulWidget {
  const AuroraCalculatorApp({super.key});

  @override
  State<AuroraCalculatorApp> createState() => _AuroraCalculatorAppState();
}

class _AuroraCalculatorAppState extends State<AuroraCalculatorApp> {
  ThemeMode _mode = ThemeMode.system;

  void _cycleThemeMode() {
    setState(() {
      _mode = switch (_mode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _mode,
      home: CalculatorScreen(
        themeMode: _mode,
        onToggleTheme: _cycleThemeMode,
      ),
    );
  }
}
