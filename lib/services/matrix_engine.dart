/// Square-matrix arithmetic for sizes 2x2 through 4x4. Matrices are stored as
/// `List<List<double>>` in row-major order. Operations validate dimensions and
/// throw [ArgumentError] when they disagree.
class MatrixEngine {
  const MatrixEngine();

  void _requireSameShape(List<List<double>> a, List<List<double>> b) {
    if (a.length != b.length || a.first.length != b.first.length) {
      throw ArgumentError('Matrices must share the same dimensions');
    }
  }

  List<List<double>> add(List<List<double>> a, List<List<double>> b) {
    _requireSameShape(a, b);
    return [
      for (var r = 0; r < a.length; r++)
        [for (var c = 0; c < a[r].length; c++) a[r][c] + b[r][c]],
    ];
  }

  List<List<double>> subtract(List<List<double>> a, List<List<double>> b) {
    _requireSameShape(a, b);
    return [
      for (var r = 0; r < a.length; r++)
        [for (var c = 0; c < a[r].length; c++) a[r][c] - b[r][c]],
    ];
  }

  List<List<double>> multiply(List<List<double>> a, List<List<double>> b) {
    if (a.first.length != b.length) {
      throw ArgumentError('Columns of A must equal rows of B');
    }
    final rows = a.length;
    final cols = b.first.length;
    final inner = b.length;
    return [
      for (var r = 0; r < rows; r++)
        [
          for (var c = 0; c < cols; c++)
            List.generate(inner, (k) => a[r][k] * b[k][c])
                .fold<double>(0, (sum, v) => sum + v),
        ],
    ];
  }

  List<List<double>> transpose(List<List<double>> m) {
    final rows = m.length;
    final cols = m.first.length;
    return [
      for (var c = 0; c < cols; c++) [for (var r = 0; r < rows; r++) m[r][c]],
    ];
  }

  /// Determinant via Laplace (cofactor) expansion along the first row.
  /// Recursion terminates at the trivial 1x1 case.
  double determinant(List<List<double>> m) {
    final n = m.length;
    if (n != m.first.length) {
      throw ArgumentError('Determinant requires a square matrix');
    }
    if (n == 1) return m[0][0];
    if (n == 2) return m[0][0] * m[1][1] - m[0][1] * m[1][0];

    var det = 0.0;
    for (var col = 0; col < n; col++) {
      final sign = col.isEven ? 1 : -1;
      det += sign * m[0][col] * determinant(_minor(m, 0, col));
    }
    return det;
  }

  List<List<double>> _minor(List<List<double>> m, int skipRow, int skipCol) {
    return [
      for (var r = 0; r < m.length; r++)
        if (r != skipRow)
          [
            for (var c = 0; c < m.length; c++)
              if (c != skipCol) m[r][c],
          ],
    ];
  }
}
