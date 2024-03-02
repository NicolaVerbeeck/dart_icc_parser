import 'package:icc_parser/src/types/matrix3x3.dart';

class MatrixCannotBeInvertedException implements Exception {
  final Matrix3x3 matrix;

  MatrixCannotBeInvertedException(this.matrix);

  @override
  String toString() {
    return "Matrix can't be inverted: ${matrix.asString()}";
  }
}
