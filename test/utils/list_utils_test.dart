import 'dart:typed_data';

import 'package:icc_parser/src/utils/list_utils.dart';
import 'package:test/test.dart';

void main() {
  group('List utils tests', () {
    test('Test generate Uint8List', () {
      expect(generateUint8List(5, (p0) => p0 * 3), [0, 3, 6, 9, 12]);
    });
    test('Test filled Uint8List', () {
      expect(filledUint8List(5, 3), [3, 3, 3, 3, 3]);
    });
    test('Test generate Float64List', () {
      expect(generateFloat64List(5, (p0) => p0 * 3), [0, 3, 6, 9, 12]);
    });
    test('Test three doubles', () {
      expect(threeDoubles(4.0, 2.0, 3.0), [4.0, 2.0, 3.0]);
    });
    test('Test Float64List copy', () {
      final list = Float64List.fromList([5.0, 2.0, 3.0]);
      final copy = list.copy();
      expect(copy, [5.0, 2.0, 3.0]);
      expect(copy, isNot(same(list)));
    });
  });
}
