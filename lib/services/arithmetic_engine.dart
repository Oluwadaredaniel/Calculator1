import 'dart:math' as math;

/// Evaluates infix arithmetic expressions using the shunting-yard algorithm
/// to build a postfix (RPN) queue, then folds that queue to a value.
///
/// Supported tokens: numbers (with decimals), + - * / , unary minus,
/// parentheses, % (as "divide-by-100"), and ^ for exponentiation.
class ArithmeticEngine {
  const ArithmeticEngine();

  static const Map<String, int> _precedence = {
    '+': 1,
    '-': 1,
    '*': 2,
    '/': 2,
    '^': 3,
  };

  /// Parses and evaluates [input]. Throws [FormatException] on malformed text
  /// and [UnsupportedError] on division by zero so callers can show a tidy
  /// message instead of crashing.
  double evaluate(String input) {
    final tokens = _tokenize(input);
    final rpn = _toPostfix(tokens);
    return _foldPostfix(rpn);
  }

  List<String> _tokenize(String input) {
    final tokens = <String>[];
    final buffer = StringBuffer();

    void flushNumber() {
      if (buffer.isNotEmpty) {
        tokens.add(buffer.toString());
        buffer.clear();
      }
    }

    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      if (ch == ' ') continue;

      final isDigitOrDot = RegExp(r'[0-9.]').hasMatch(ch);
      if (isDigitOrDot) {
        buffer.write(ch);
        continue;
      }

      flushNumber();

      // Distinguish a unary minus from binary subtraction by looking at the
      // previous meaningful token.
      final prev = tokens.isEmpty ? null : tokens.last;
      final unaryContext =
          prev == null || prev == '(' || _precedence.containsKey(prev);
      if (ch == '-' && unaryContext) {
        tokens.add('u-');
      } else if (ch == '%') {
        // Treat trailing percent as multiply by 0.01.
        tokens
          ..add('*')
          ..add('0.01');
      } else {
        tokens.add(ch);
      }
    }
    flushNumber();
    return tokens;
  }

  List<String> _toPostfix(List<String> tokens) {
    final output = <String>[];
    final operators = <String>[];

    bool isOperator(String t) => _precedence.containsKey(t) || t == 'u-';

    for (final token in tokens) {
      if (double.tryParse(token) != null) {
        output.add(token);
      } else if (token == 'u-') {
        operators.add(token);
      } else if (isOperator(token)) {
        while (operators.isNotEmpty &&
            operators.last != '(' &&
            _rank(operators.last) >= _rank(token) &&
            token != '^') {
          output.add(operators.removeLast());
        }
        operators.add(token);
      } else if (token == '(') {
        operators.add(token);
      } else if (token == ')') {
        while (operators.isNotEmpty && operators.last != '(') {
          output.add(operators.removeLast());
        }
        if (operators.isEmpty) {
          throw const FormatException('Mismatched parentheses');
        }
        operators.removeLast();
      } else {
        throw FormatException('Unexpected token "$token"');
      }
    }

    while (operators.isNotEmpty) {
      final op = operators.removeLast();
      if (op == '(') throw const FormatException('Mismatched parentheses');
      output.add(op);
    }
    return output;
  }

  int _rank(String op) => op == 'u-' ? 4 : _precedence[op]!;

  double _foldPostfix(List<String> rpn) {
    final stack = <double>[];

    for (final token in rpn) {
      final number = double.tryParse(token);
      if (number != null) {
        stack.add(number);
        continue;
      }

      if (token == 'u-') {
        if (stack.isEmpty) throw const FormatException('Dangling negation');
        stack.add(-stack.removeLast());
        continue;
      }

      if (stack.length < 2) {
        throw const FormatException('Incomplete expression');
      }
      final b = stack.removeLast();
      final a = stack.removeLast();
      stack.add(_apply(token, a, b));
    }

    if (stack.length != 1) {
      throw const FormatException('Incomplete expression');
    }
    return stack.single;
  }

  double _apply(String op, double a, double b) {
    return switch (op) {
      '+' => a + b,
      '-' => a - b,
      '*' => a * b,
      '/' => b == 0
          ? throw UnsupportedError('Cannot divide by zero')
          : a / b,
      '^' => math.pow(a, b).toDouble(),
      _ => throw FormatException('Unknown operator "$op"'),
    };
  }
}
