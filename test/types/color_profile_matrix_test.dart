import 'dart:typed_data';

import 'package:icc_parser/src/types/color_profile_matrix.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:test/test.dart';

void main() {
  group('Color profile matrix tests', () {
    test('Test read color profile matrix', () {
      final data = _dataStreamOf(List.generate(12 * 4, (index) => index));
      final matrix = ColorProfileMatrix.fromBytes(data);
      data.seek(0);
      expect(matrix.values, [
        data.readSigned15Fixed16Number().value,
        data.readSigned15Fixed16Number().value,
        data.readSigned15Fixed16Number().value,
        data.readSigned15Fixed16Number().value,
        data.readSigned15Fixed16Number().value,
        data.readSigned15Fixed16Number().value,
        data.readSigned15Fixed16Number().value,
        data.readSigned15Fixed16Number().value,
        data.readSigned15Fixed16Number().value,
        data.readSigned15Fixed16Number().value,
        data.readSigned15Fixed16Number().value,
        data.readSigned15Fixed16Number().value,
      ]);
    });
    test('Test isIdentity', () {
      expect(
          ColorProfileMatrix(
                  Float64List.fromList([1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0]))
              .isIdentity,
          true);
      expect(
          ColorProfileMatrix(
                  Float64List.fromList([2, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0]))
              .isIdentity,
          false);
      expect(
          ColorProfileMatrix(
                  Float64List.fromList([1, 0, 0, 0, 1, 2, 0, 0, 1, 0, 0, 0]))
              .isIdentity,
          false);
    });
    test('Test apply', () {
      var matrix = ColorProfileMatrix(
          Float64List.fromList([1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0]));
      var pixel = Float64List.fromList([1, 2, 3]);
      matrix.apply(pixel);
      expect(pixel, [1, 2, 3]);

      matrix = ColorProfileMatrix(
          Float64List.fromList([2, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0]));
      pixel = Float64List.fromList([1, 2, 3]);
      matrix.apply(pixel);
      expect(pixel, [2, 2, 3]);
    });
  });
}

DataStream _dataStreamOf(List<int> bytes) {
  final buffer = Uint8List.fromList(bytes).buffer;
  final data = ByteData.view(buffer);
  return DataStream(
    data: data,
    length: bytes.length,
    offset: 0,
  );
}
