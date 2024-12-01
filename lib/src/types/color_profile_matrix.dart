import 'dart:typed_data';

import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:icc_parser/src/utils/list_utils.dart';
import 'package:icc_parser/src/utils/num_utils.dart';
import 'package:meta/meta.dart';

/// Matrix implementation for color profile operations
@immutable
final class ColorProfileMatrix {
  final Float64List _matrix;

  @visibleForTesting
  Float64List get values => _matrix;

  /// Create a new color profile matrix. Must have 12 elements.
  const ColorProfileMatrix(this._matrix) : assert(_matrix.length == 12);

  /// Parse a color profile matrix from a byte stream.
  /// Reading 12 15.16 fixed point numbers.
  factory ColorProfileMatrix.fromBytes(DataStream stream) {
    final matrix = generateFloat64List(
      12,
      (_) => stream.readSigned15Fixed16Number().value,
    );
    return ColorProfileMatrix(matrix);
  }

  /// Checks if the matrix is the identity matrix
  bool get isIdentity {
    if (_matrix[9].abs() > 0 ||
        _matrix[10].abs() > 0 ||
        _matrix[11].abs() > 0) {
      return false;
    }
    if (!isUnity(_matrix[0]) || !isUnity(_matrix[4]) || !isUnity(_matrix[8])) {
      return false;
    }

    if (_matrix[1].abs() > 0 ||
        _matrix[2].abs() > 0 ||
        _matrix[3].abs() > 0 ||
        _matrix[5].abs() > 0 ||
        _matrix[6].abs() > 0 ||
        _matrix[7].abs() > 0) {
      return false;
    }
    return true;
  }

  /// Transform a pixel using the matrix. The pixel is modified in place.
  void apply(Float64List pixel) {
    final a = pixel[0];
    final b = pixel[1];
    final c = pixel[2];

    pixel[0] = a * _matrix[0] + b * _matrix[1] + c * _matrix[2] + _matrix[9];
    pixel[1] = a * _matrix[3] + b * _matrix[4] + c * _matrix[5] + _matrix[10];
    pixel[2] = a * _matrix[6] + b * _matrix[7] + c * _matrix[8] + _matrix[11];
  }
}
