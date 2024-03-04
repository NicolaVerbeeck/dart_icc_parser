import 'dart:typed_data';

import 'package:icc_parser/src/error.dart';

class Matrix3x3 {
  final Float64List _matrix;

  Matrix3x3() : _matrix = Float64List(9);

  double get m00 => _matrix[0];

  double get m01 => _matrix[1];

  double get m02 => _matrix[2];

  double get m10 => _matrix[3];

  double get m11 => _matrix[4];

  double get m12 => _matrix[5];

  double get m20 => _matrix[6];

  double get m21 => _matrix[7];

  double get m22 => _matrix[8];

  set m00(double value) => _matrix[0] = value;

  set m01(double value) => _matrix[1] = value;

  set m02(double value) => _matrix[2] = value;

  set m10(double value) => _matrix[3] = value;

  set m11(double value) => _matrix[4] = value;

  set m12(double value) => _matrix[5] = value;

  set m20(double value) => _matrix[6] = value;

  set m21(double value) => _matrix[7] = value;

  set m22(double value) => _matrix[8] = value;

  void invert() {
    const epsilon = 1e-8;

    final m48 = _matrix[4] * _matrix[8];
    final m75 = _matrix[7] * _matrix[5];
    final m38 = _matrix[3] * _matrix[8];
    final m65 = _matrix[6] * _matrix[5];
    final m37 = _matrix[3] * _matrix[7];
    final m64 = _matrix[6] * _matrix[4];

    final det = _matrix[0] * (m48 - m75) -
        _matrix[1] * (m38 - m65) +
        _matrix[2] * (m37 - m64);

    if (det > -epsilon && det < epsilon) {
      throw MatrixCannotBeInvertedException(this);
    }

    final co = Float64List(9);

    co[0] = m48 - m75;
    co[1] = -(m38 - m65);
    co[2] = m37 - m64;

    co[3] = -(_matrix[1] * _matrix[8] - _matrix[7] * _matrix[2]);
    co[4] = _matrix[0] * _matrix[8] - _matrix[6] * _matrix[2];
    co[5] = -(_matrix[0] * _matrix[7] - _matrix[6] * _matrix[1]);

    co[6] = _matrix[1] * _matrix[5] - _matrix[4] * _matrix[2];
    co[7] = -(_matrix[0] * _matrix[5] - _matrix[3] * _matrix[2]);
    co[8] = _matrix[0] * _matrix[4] - _matrix[3] * _matrix[1];

    _matrix[0] = co[0] / det;
    _matrix[1] = co[3] / det;
    _matrix[2] = co[6] / det;

    _matrix[3] = co[1] / det;
    _matrix[4] = co[4] / det;
    _matrix[5] = co[7] / det;

    _matrix[6] = co[2] / det;
    _matrix[7] = co[5] / det;
    _matrix[8] = co[8] / det;
  }

  @override
  String toString() {
    return '[[${_matrix[0]}, ${_matrix[1]}, ${_matrix[2]}],'
        ' [${_matrix[3]}, ${_matrix[4]}, ${_matrix[5]}],'
        ' [${_matrix[6]}, ${_matrix[7]}, ${_matrix[8]}]]';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Matrix3x3 &&
          _matrix[0] == other._matrix[0] &&
          _matrix[1] == other._matrix[1] &&
          _matrix[2] == other._matrix[2] &&
          _matrix[3] == other._matrix[3] &&
          _matrix[4] == other._matrix[4] &&
          _matrix[5] == other._matrix[5] &&
          _matrix[6] == other._matrix[6] &&
          _matrix[7] == other._matrix[7] &&
          _matrix[8] == other._matrix[8];

  @override
  int get hashCode =>
      _matrix[0].hashCode ^
      _matrix[1].hashCode ^
      _matrix[2].hashCode ^
      _matrix[3].hashCode ^
      _matrix[4].hashCode ^
      _matrix[5].hashCode ^
      _matrix[6].hashCode ^
      _matrix[7].hashCode ^
      _matrix[8].hashCode;
}
