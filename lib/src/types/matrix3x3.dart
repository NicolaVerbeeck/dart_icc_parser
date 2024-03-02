import 'dart:typed_data';

import 'package:icc_parser/src/error.dart';

extension type Matrix3x3._(Float64List matrix) {
  Matrix3x3() : matrix = Float64List(9);

  double get m00 => matrix[0];

  double get m01 => matrix[1];

  double get m02 => matrix[2];

  double get m10 => matrix[3];

  double get m11 => matrix[4];

  double get m12 => matrix[5];

  double get m20 => matrix[6];

  double get m21 => matrix[7];

  double get m22 => matrix[8];

  set m00(double value) => matrix[0] = value;

  set m01(double value) => matrix[1] = value;

  set m02(double value) => matrix[2] = value;

  set m10(double value) => matrix[3] = value;

  set m11(double value) => matrix[4] = value;

  set m12(double value) => matrix[5] = value;

  set m20(double value) => matrix[6] = value;

  set m21(double value) => matrix[7] = value;

  set m22(double value) => matrix[8] = value;

  void invert() {
    const epsilon = 1e-8;

    final m48 = matrix[4] * matrix[8];
    final m75 = matrix[7] * matrix[5];
    final m38 = matrix[3] * matrix[8];
    final m65 = matrix[6] * matrix[5];
    final m37 = matrix[3] * matrix[7];
    final m64 = matrix[6] * matrix[4];

    final det = matrix[0] * (m48 - m75) -
        matrix[1] * (m38 - m65) +
        matrix[2] * (m37 - m64);

    if (det > -epsilon && det < epsilon) {
      throw MatrixCannotBeInvertedException(this);
    }

    final co = Float64List(9);

    co[0] = m48 - m75;
    co[1] = -(m38 - m65);
    co[2] = m37 - m64;

    co[3] = -(matrix[1] * matrix[8] - matrix[7] * matrix[2]);
    co[4] = matrix[0] * matrix[8] - matrix[6] * matrix[2];
    co[5] = -(matrix[0] * matrix[7] - matrix[6] * matrix[1]);

    co[6] = matrix[1] * matrix[5] - matrix[4] * matrix[2];
    co[7] = -(matrix[0] * matrix[5] - matrix[3] * matrix[2]);
    co[8] = matrix[0] * matrix[4] - matrix[3] * matrix[1];

    matrix[0] = co[0] / det;
    matrix[1] = co[3] / det;
    matrix[2] = co[6] / det;

    matrix[3] = co[1] / det;
    matrix[4] = co[4] / det;
    matrix[5] = co[7] / det;

    matrix[6] = co[2] / det;
    matrix[7] = co[5] / det;
    matrix[8] = co[8] / det;
  }

  String asString() {
    return '[[${matrix[0]}, ${matrix[1]}, ${matrix[2]}],'
        ' [${matrix[3]}, ${matrix[4]}, ${matrix[5]}],'
        ' [${matrix[6]}, ${matrix[7]}, ${matrix[8]}]]';
  }
}
