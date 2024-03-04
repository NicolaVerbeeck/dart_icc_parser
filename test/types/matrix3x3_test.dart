import 'package:icc_parser/src/error.dart';
import 'package:icc_parser/src/types/matrix3x3.dart';
import 'package:test/test.dart';

void main() {
  group('ColorProfileTransformMatrixTRC', () {
    group('Matrix3x3', () {
      late Matrix3x3 sut;

      setUp(() {
        sut = Matrix3x3();
      });

      test('setters set the value', () {
        sut.m00 = 1.0;
        sut.m01 = 2.0;
        sut.m02 = 3.0;
        sut.m10 = 4.0;
        sut.m11 = 5.0;
        sut.m12 = 6.0;
        sut.m20 = 7.0;
        sut.m21 = 8.0;
        sut.m22 = 9.0;
        expect(sut.m00, equals(1.0));
        expect(sut.m01, equals(2.0));
        expect(sut.m02, equals(3.0));
        expect(sut.m10, equals(4.0));
        expect(sut.m11, equals(5.0));
        expect(sut.m12, equals(6.0));
        expect(sut.m20, equals(7.0));
        expect(sut.m21, equals(8.0));
        expect(sut.m22, equals(9.0));

        expect(sut.toString(),
            equals('[[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]]'));
      });

      test('throws if it can\'t be inverted', () {
        sut.m00 = 1.0;
        sut.m01 = 2.0;
        sut.m02 = 3.0;
        sut.m10 = 4.0;
        sut.m11 = 5.0;
        sut.m12 = 6.0;
        sut.m20 = 7.0;
        sut.m21 = 8.0;
        sut.m22 = 9.0;

        expect(
          () => sut.invert(),
          throwsA(isA<MatrixCannotBeInvertedException>()),
        );

        try {
          sut.invert();
        } on MatrixCannotBeInvertedException catch (e) {
          expect(e.toString(),
              'Matrix can\'t be inverted: [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]]');
        }
      });
      test('it inverts correctly', () {
        sut.m00 = 1.0;
        sut.m01 = 3.0;
        sut.m02 = 4.0;
        sut.m10 = 8.0;
        sut.m11 = 2.0;
        sut.m12 = 5.0;
        sut.m20 = 9.0;
        sut.m21 = 10.0;
        sut.m22 = 6.0;

        sut.invert();

        expect(sut.m00, -38 / 201);
        expect(sut.m01, 22 / 201);
        expect(sut.m02, 7 / 201);
        expect(sut.m10, -1 / 67);
        expect(sut.m11, -10 / 67);
        expect(sut.m12, 9 / 67);
        expect(sut.m20, 62 / 201);
        expect(sut.m21, 17 / 201);
        expect(sut.m22, -22 / 201);
      });
      test('same values give same hash code and equals', () {
        final matrix1 = Matrix3x3();
        final matrix2 = Matrix3x3();
        matrix1.m00 = 1.0;
        matrix1.m01 = 2.0;
        matrix1.m02 = 3.0;
        matrix1.m10 = 4.0;
        matrix1.m11 = 5.0;
        matrix1.m12 = 6.0;
        matrix1.m20 = 7.0;
        matrix1.m21 = 8.0;
        matrix1.m22 = 9.0;
        matrix2.m00 = 1.0;
        matrix2.m01 = 2.0;
        matrix2.m02 = 3.0;
        matrix2.m10 = 4.0;
        matrix2.m11 = 5.0;
        matrix2.m12 = 6.0;
        matrix2.m20 = 7.0;
        matrix2.m21 = 8.0;
        matrix2.m22 = 9.0;

        expect(matrix1.hashCode, matrix2.hashCode);
        expect(matrix1, matrix2);
      });
      test('different values give same hash code and equals', () {
        final matrix1 = Matrix3x3();
        final matrix2 = Matrix3x3();
        matrix1.m00 = 1.0;
        matrix1.m01 = 2.0;
        matrix1.m02 = 3.0;
        matrix1.m10 = 4.0;
        matrix1.m11 = 5.0;
        matrix1.m12 = 6.0;
        matrix1.m20 = 7.0;
        matrix1.m21 = 8.0;
        matrix1.m22 = 9.0;
        matrix2.m00 = 1.0;
        matrix2.m01 = 2.0;
        matrix2.m02 = 3.0;
        matrix2.m10 = 4.0;
        matrix2.m11 = 5.0;
        matrix2.m12 = 6.0;
        matrix2.m20 = 7.0;
        matrix2.m21 = 8.0;
        matrix2.m22 = 10.0;

        expect(matrix1.hashCode, isNot(matrix2.hashCode));
        expect(matrix1, isNot(matrix2));
      });
    });
  });
}
