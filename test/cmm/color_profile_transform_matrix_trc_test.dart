import 'package:icc_parser/src/cmm/color_profile_transform_matrix_trc.dart';
import 'package:icc_parser/src/error.dart';
import 'package:icc_parser/src/types/color_profile_header.dart';
import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:icc_parser/src/types/matrix3x3.dart';
import 'package:icc_parser/src/types/tag/color_profile_tags.dart';
import 'package:icc_parser/src/types/tag/curve/color_profile_curve.dart';
import 'package:icc_parser/src/types/tag/xyz/color_profile_xyz_tag.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'color_profile_pcs_transform_test.dart';

class MockColorProfileXYZTag extends Mock implements ColorProfileXYZTag {}

class MockColorProfileCurve extends Mock implements ColorProfileCurve {}

// ignore: avoid_implementing_value_types
class MockColorProfileHeader extends Mock implements ColorProfileHeader {}

void main() {
  group('ColorProfileTransformMatrixTRC', () {
    final mockProfile = MockColorProfile();

    group('it builds the matrix', () {
      late MockColorProfileXYZTag mockRed;
      late MockColorProfileXYZTag mockGreen;
      late MockColorProfileXYZTag mockBlue;
      late MockColorProfileCurve mockRedCurve;
      late MockColorProfileCurve mockGreenCurve;
      late MockColorProfileCurve mockBlueCurve;
      late MockColorProfileHeader mockHeader;

      setUp(() {
        mockRed = MockColorProfileXYZTag();
        mockGreen = MockColorProfileXYZTag();
        mockBlue = MockColorProfileXYZTag();
        mockRedCurve = MockColorProfileCurve();
        mockGreenCurve = MockColorProfileCurve();
        mockBlueCurve = MockColorProfileCurve();
        mockHeader = MockColorProfileHeader();

        when(() => mockProfile.header).thenReturn(mockHeader);
        when(() => mockHeader.pcs).thenReturn(
          Unsigned32Number(ColorSpaceSignature.icSigXYZData.code),
        );

        when(() => mockRed.xyz).thenReturn([
          const XYZNumber(
            x: Signed15Fixed16Number(integerPart: 18, fractionalPart: 2),
            y: Signed15Fixed16Number(integerPart: 3, fractionalPart: 4),
            z: Signed15Fixed16Number(integerPart: 5, fractionalPart: 6),
          )
        ]);
        when(() => mockGreen.xyz).thenReturn([
          const XYZNumber(
            x: Signed15Fixed16Number(integerPart: 76, fractionalPart: 8),
            y: Signed15Fixed16Number(integerPart: 9, fractionalPart: 10),
            z: Signed15Fixed16Number(integerPart: 11, fractionalPart: 12),
          )
        ]);
        when(() => mockBlue.xyz).thenReturn([
          const XYZNumber(
            x: Signed15Fixed16Number(integerPart: 123, fractionalPart: 14),
            y: Signed15Fixed16Number(integerPart: 15, fractionalPart: 16),
            z: Signed15Fixed16Number(integerPart: 17, fractionalPart: 18),
          )
        ]);

        when(() =>
                mockProfile.findTag(ICCColorProfileTag.icSigRedMatrixColumnTag))
            .thenReturn(mockRed);
        when(() => mockProfile
                .findTag(ICCColorProfileTag.icSigGreenMatrixColumnTag))
            .thenReturn(mockGreen);
        when(() => mockProfile.findTag(
            ICCColorProfileTag.icSigBlueMatrixColumnTag)).thenReturn(mockBlue);
        when(() => mockProfile.findTag(ICCColorProfileTag.icSigRedTRCTag))
            .thenReturn(mockRedCurve);
        when(() => mockProfile.findTag(ICCColorProfileTag.icSigGreenTRCTag))
            .thenReturn(mockGreenCurve);
        when(() => mockProfile.findTag(ICCColorProfileTag.icSigBlueTRCTag))
            .thenReturn(mockBlueCurve);
        when(() => mockRedCurve.isIdentity).thenReturn(false);
        when(() => mockGreenCurve.isIdentity).thenReturn(false);
        when(() => mockBlueCurve.isIdentity).thenReturn(false);

        when(() => mockRedCurve.find(any())).thenReturn(0);
        when(() => mockGreenCurve.find(any())).thenReturn(0);
        when(() => mockBlueCurve.find(any())).thenReturn(0);
      });

      test('throws if red matrix column is missing', () {
        when(() =>
                mockProfile.findTag(ICCColorProfileTag.icSigRedMatrixColumnTag))
            .thenReturn(null);

        expect(
          () => ColorProfileTransformMatrixTRC.create(
              profile: mockProfile,
              doAdjustPCS: true,
              isInput: true,
              pcsScale: null,
              pcsOffset: null),
          throwsA(isA<MissingTagException>()),
        );
      });
      test('throws if green matrix column is missing', () {
        when(() => mockProfile.findTag(
            ICCColorProfileTag.icSigGreenMatrixColumnTag)).thenReturn(null);

        expect(
          () => ColorProfileTransformMatrixTRC.create(
              profile: mockProfile,
              doAdjustPCS: true,
              isInput: true,
              pcsScale: null,
              pcsOffset: null),
          throwsA(isA<MissingTagException>()),
        );
      });
      test('throws if blue matrix column is missing', () {
        when(() => mockProfile.findTag(
            ICCColorProfileTag.icSigBlueMatrixColumnTag)).thenReturn(null);

        expect(
          () => ColorProfileTransformMatrixTRC.create(
              profile: mockProfile,
              doAdjustPCS: true,
              isInput: true,
              pcsScale: null,
              pcsOffset: null),
          throwsA(isA<MissingTagException>()),
        );
      });
      test('it builds the matrix in input mode', () {
        final res = ColorProfileTransformMatrixTRC.create(
            profile: mockProfile,
            doAdjustPCS: true,
            isInput: true,
            pcsScale: null,
            pcsOffset: null);
        expect(res.matrix.m00, 18 + 2 / 65536);
        expect(res.matrix.m10, 3 + 4 / 65536);
        expect(res.matrix.m20, 5 + 6 / 65536);
        expect(res.matrix.m01, 76 + 8 / 65536);
        expect(res.matrix.m11, 9 + 10 / 65536);
        expect(res.matrix.m21, 11 + 12 / 65536);
        expect(res.matrix.m02, 123 + 14 / 65536);
        expect(res.matrix.m12, 15 + 16 / 65536);
        expect(res.matrix.m22, 17 + 18 / 65536);
        expect(res.curves![0], mockRedCurve);
        expect(res.curves![1], mockGreenCurve);
        expect(res.curves![2], mockBlueCurve);
      });
      test('it throws if pcs is not XYZ in output mode', () {
        when(() => mockHeader.pcs).thenReturn(
          Unsigned32Number(ColorSpaceSignature.icSigLabData.code),
        );
        expect(
          () => ColorProfileTransformMatrixTRC.create(
              profile: mockProfile,
              doAdjustPCS: true,
              isInput: false,
              pcsScale: null,
              pcsOffset: null),
          throwsA(isA<BadSpaceLinkException>()),
        );
      });
      test('it inverts the matrix not in input mode', () {
        final res = ColorProfileTransformMatrixTRC.create(
            profile: mockProfile,
            doAdjustPCS: true,
            isInput: false,
            pcsScale: null,
            pcsOffset: null);
        final originalMatrix = Matrix3x3();
        originalMatrix.m00 = 18 + 2 / 65536;
        originalMatrix.m10 = 3 + 4 / 65536;
        originalMatrix.m20 = 5 + 6 / 65536;
        originalMatrix.m01 = 76 + 8 / 65536;
        originalMatrix.m11 = 9 + 10 / 65536;
        originalMatrix.m21 = 11 + 12 / 65536;
        originalMatrix.m02 = 123 + 14 / 65536;
        originalMatrix.m12 = 15 + 16 / 65536;
        originalMatrix.m22 = 17 + 18 / 65536;
        originalMatrix.invert();
        expect(res.matrix, originalMatrix);

        verify(() => mockRedCurve.find(any())).called(2048);
        verify(() => mockGreenCurve.find(any())).called(2048);
        verify(() => mockBlueCurve.find(any())).called(2048);
      });
      group('if curves are identity they are omitted', () {
        test('red curve is identity', () {
          when(() => mockRedCurve.isIdentity).thenReturn(true);
          final res = ColorProfileTransformMatrixTRC.create(
              profile: mockProfile,
              doAdjustPCS: true,
              isInput: true,
              pcsScale: null,
              pcsOffset: null);
          expect(res.curves![0], mockRedCurve);
          expect(res.curves![1], mockGreenCurve);
          expect(res.curves![2], mockBlueCurve);
        });
        test('blue curve is identity', () {
          when(() => mockBlueCurve.isIdentity).thenReturn(true);
          final res = ColorProfileTransformMatrixTRC.create(
              profile: mockProfile,
              doAdjustPCS: true,
              isInput: true,
              pcsScale: null,
              pcsOffset: null);
          expect(res.curves![0], mockRedCurve);
          expect(res.curves![1], mockGreenCurve);
          expect(res.curves![2], mockBlueCurve);
        });
        test('green curve is identity', () {
          when(() => mockGreenCurve.isIdentity).thenReturn(true);
          final res = ColorProfileTransformMatrixTRC.create(
              profile: mockProfile,
              doAdjustPCS: true,
              isInput: true,
              pcsScale: null,
              pcsOffset: null);
          expect(res.curves![0], mockRedCurve);
          expect(res.curves![1], mockGreenCurve);
          expect(res.curves![2], mockBlueCurve);
        });
        test('red and green curve are identity', () {
          when(() => mockRedCurve.isIdentity).thenReturn(true);
          when(() => mockGreenCurve.isIdentity).thenReturn(true);
          final res = ColorProfileTransformMatrixTRC.create(
              profile: mockProfile,
              doAdjustPCS: true,
              isInput: true,
              pcsScale: null,
              pcsOffset: null);
          expect(res.curves![0], mockRedCurve);
          expect(res.curves![1], mockGreenCurve);
          expect(res.curves![2], mockBlueCurve);
        });
        test('red and blue curve are identity', () {
          when(() => mockRedCurve.isIdentity).thenReturn(true);
          when(() => mockBlueCurve.isIdentity).thenReturn(true);
          final res = ColorProfileTransformMatrixTRC.create(
              profile: mockProfile,
              doAdjustPCS: true,
              isInput: true,
              pcsScale: null,
              pcsOffset: null);
          expect(res.curves![0], mockRedCurve);
          expect(res.curves![1], mockGreenCurve);
          expect(res.curves![2], mockBlueCurve);
        });
        test('green and blue curve are identity', () {
          when(() => mockGreenCurve.isIdentity).thenReturn(true);
          when(() => mockBlueCurve.isIdentity).thenReturn(true);
          final res = ColorProfileTransformMatrixTRC.create(
              profile: mockProfile,
              doAdjustPCS: true,
              isInput: true,
              pcsScale: null,
              pcsOffset: null);
          expect(res.curves![0], mockRedCurve);
          expect(res.curves![1], mockGreenCurve);
          expect(res.curves![2], mockBlueCurve);
        });
        test('red, green and blue curve are identity', () {
          when(() => mockRedCurve.isIdentity).thenReturn(true);
          when(() => mockGreenCurve.isIdentity).thenReturn(true);
          when(() => mockBlueCurve.isIdentity).thenReturn(true);
          final res = ColorProfileTransformMatrixTRC.create(
              profile: mockProfile,
              doAdjustPCS: true,
              isInput: true,
              pcsScale: null,
              pcsOffset: null);
          expect(res.curves, isNull);
        });
      });
    });
  });
}
