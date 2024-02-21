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
    test('Test Float64List copyWithSize to smaller', () {
      final list = Float64List.fromList([5.0, 2.0, 3.0]);
      final copy = list.copyWithSize(2);
      expect(copy, [5.0, 2.0]);
      expect(copy, isNot(same(list)));
    });
    test('Test Float64List copyWithSize to same', () {
      final list = Float64List.fromList([5.0, 2.0, 3.0]);
      final copy = list.copyWithSize(3);
      expect(copy, [5.0, 2.0, 3.0]);
      expect(copy, isNot(same(list)));
    });
    test('Test Float64List copyWithSize to larger', () {
      final list = Float64List.fromList([5.0, 2.0, 3.0]);
      final copy = list.copyWithSize(5);
      expect(copy, [5.0, 2.0, 3.0, 0.0, 0.0]);
      expect(copy, isNot(same(list)));
    });
    test('test Float64List copyFrom same size', () {
      final list = Float64List.fromList([5.0, 2.0, 3.0]);
      final copy = Float64List.fromList([1.0, 2.0, 3.0]);
      copy.copyFrom(list);
      expect(copy, [5.0, 2.0, 3.0]);
    });
    test('test Float64List copyFrom smaller size', () {
      final list = Float64List.fromList([5.0, 2.0, 3.0]);
      final copy = Float64List.fromList([1.0, 2.0]);
      copy.copyFrom(list);
      expect(copy, [5.0, 2.0]);
    });
    test('test Float64List copyFrom larger size', () {
      final list = Float64List.fromList([5.0, 2.0]);
      final copy = Float64List.fromList([1.0, 2.0, 3.0]);
      copy.copyFrom(list);
      expect(copy, [5.0, 2.0, 3.0]);
    });
  });
}
