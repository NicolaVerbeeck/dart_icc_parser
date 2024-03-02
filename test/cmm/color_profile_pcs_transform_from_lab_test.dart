import 'dart:typed_data';

import 'package:icc_parser/icc_parser.dart';
import 'package:icc_parser/src/cmm/color_profile_pcs_transform.dart';
import 'package:icc_parser/src/types/color_profile_header.dart';
import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'color_profile_pcs_transform_test.dart';

void main() {
  group('ColorProfilePcsTransform', () {
    _testTargetLab();
    _testTargetXYZ();
  });
}

void _testTargetLab() {
  group('Source lab', () {
    final source = MockColorProfileTransform();
    final destination = MockColorProfileTransform();
    final mockSource = MockColorProfile();
    final mockDestination = MockColorProfile();

    setUp(() {
      when(() => source.isInput).thenReturn(true);
      when(() => destination.isInput).thenReturn(false);
      when(() => source.getDestinationColorSpace())
          .thenReturn(ColorSpaceSignature.icSigLabData);
      when(() => source.profile).thenReturn(mockSource);
      when(() => destination.profile).thenReturn(mockDestination);
      when(() => mockSource.getNormIlluminantXYZ()).thenReturn([
        const Signed15Fixed16Number(integerPart: 1, fractionalPart: 2),
        const Signed15Fixed16Number(integerPart: 3, fractionalPart: 4),
        const Signed15Fixed16Number(integerPart: 5, fractionalPart: 6),
      ]);
      when(() => mockDestination.getNormIlluminantXYZ()).thenReturn([
        const Signed15Fixed16Number(integerPart: 7, fractionalPart: 8),
        const Signed15Fixed16Number(integerPart: 9, fractionalPart: 9),
        const Signed15Fixed16Number(integerPart: 10, fractionalPart: 11),
      ]);
      when(() => mockSource.illuminant)
          .thenReturn(ColorProfileIlluminant.illuminantD50);
      when(() => mockDestination.illuminant)
          .thenReturn(ColorProfileIlluminant.illuminantD50);
      when(() => mockSource.pccObserver).thenReturn(
          ColorProfileStandardObserver.standardObserver1931TwoDegrees);
      when(() => mockDestination.pccObserver).thenReturn(
          ColorProfileStandardObserver.standardObserver1931TwoDegrees);

      when(() => source.useLegacyPCS).thenReturn(true);
      when(() => source.doAdjustPCS).thenReturn(true);
      when(() => source.pcsScale).thenReturn(Float64List.fromList([1, 2, 3]));
      when(() => source.pcsOffset).thenReturn(Float64List.fromList([4, 5, 6]));
    });

    group('Destination lab', () {
      setUp(() {
        when(() => destination.getSourceColorSpace())
            .thenReturn(ColorSpaceSignature.icSigLabData);
        when(() => destination.doAdjustPCS).thenReturn(true);
        when(() => destination.pcsScale)
            .thenReturn(Float64List.fromList([7, 8, 9]));
        when(() => destination.pcsOffset)
            .thenReturn(Float64List.fromList([10, 11, 12]));
        when(() => destination.useLegacyPCS).thenReturn(true);
      });
      test('if source uses legacy pcs, it adds lab2XYZ', () {
        when(() => source.useLegacyPCS).thenReturn(true);

        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps[0];
        expect(first, isA<ColorProfileLab2ToXyz>());
        first as ColorProfileLab2ToXyz;
        expect(first.xyzWhite,
            equals([1 + 2 / 65536, 3 + 4 / 65536, 5 + 6 / 65536]));
      });
      test('if source does not use legacy pcs, it adds labXYZ', () {
        when(() => source.useLegacyPCS).thenReturn(false);

        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps[0];
        expect(first, isA<ColorProfileLabToXyz>());
        first as ColorProfileLabToXyz;
        expect(first.xyzWhite,
            equals([1 + 2 / 65536, 3 + 4 / 65536, 5 + 6 / 65536]));
      });
      test('if source needs to adjust pcs, it adds scale and offset', () {
        when(() => source.doAdjustPCS).thenReturn(true);

        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps[1];
        final second = result.steps[2];
        first as ColorProfileScale3;
        second as ColorProfileOffset3;
        expect(first.scale, equals([1, 2, 3]));
        expect(
            second.offset,
            equals([
              4 * 65535.0 / 32768.0,
              5 * 65535.0 / 32768.0,
              6 * 65535.0 / 32768.0,
            ]));
      });
      test(
          'if source does not need to adjust pcs, it does not add scale and offset',
          () {
        when(() => source.doAdjustPCS).thenReturn(false);
        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps[1];
        expect(first, isNot(isA<ColorProfileScale3>()));
      });
      test('if target needs to adjust pcs, it adds scale and offset', () {
        when(() => destination.doAdjustPCS).thenReturn(true);

        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps[3];
        final second = result.steps[4];
        first as ColorProfileOffset3;
        second as ColorProfileScale3;
        expect(
            first.offset,
            equals([
              (10 / 7) * 65535.0 / 32768.0,
              (11 / 8) * 65535.0 / 32768.0,
              (12 / 9) * 65535.0 / 32768.0,
            ]));
        expect(second.scale, equals([7, 8, 9]));
      });
      test(
          'if destination does not need to adjust pcs, it does not add scale and offset',
          () {
        when(() => destination.doAdjustPCS).thenReturn(false);
        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps[3];
        expect(first, isNot(isA<ColorProfileScale3>()));
      });
      test('if destination uses legacy PCS, it adds XYZToLab2', () {
        when(() => destination.useLegacyPCS).thenReturn(true);

        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps.last;
        expect(first, isA<ColorProfileXyzToLab2>());
        first as ColorProfileXyzToLab2;
        expect(first.xyzWhite,
            equals([7 + 8 / 65536, 9 + 9 / 65536, 10 + 11 / 65536]));
      });
      test('if destination does not use legacy PCS, it adds XYZToLab', () {
        when(() => destination.useLegacyPCS).thenReturn(false);

        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps.last;
        expect(first, isA<ColorProfileXyzToLab>());
        first as ColorProfileXyzToLab;
        expect(first.xyzWhite,
            equals([7 + 8 / 65536, 9 + 9 / 65536, 10 + 11 / 65536]));
      });
    });
  });
}

void _testTargetXYZ() {
  group('Source lab', () {
    final source = MockColorProfileTransform();
    final destination = MockColorProfileTransform();
    final mockSource = MockColorProfile();
    final mockDestination = MockColorProfile();

    setUp(() {
      when(() => source.isInput).thenReturn(true);
      when(() => destination.isInput).thenReturn(false);
      when(() => source.getDestinationColorSpace())
          .thenReturn(ColorSpaceSignature.icSigLabData);
      when(() => source.profile).thenReturn(mockSource);
      when(() => destination.profile).thenReturn(mockDestination);
      when(() => mockSource.getNormIlluminantXYZ()).thenReturn([
        const Signed15Fixed16Number(integerPart: 1, fractionalPart: 2),
        const Signed15Fixed16Number(integerPart: 3, fractionalPart: 4),
        const Signed15Fixed16Number(integerPart: 5, fractionalPart: 6),
      ]);
      when(() => mockDestination.getNormIlluminantXYZ()).thenReturn([
        const Signed15Fixed16Number(integerPart: 7, fractionalPart: 8),
        const Signed15Fixed16Number(integerPart: 9, fractionalPart: 9),
        const Signed15Fixed16Number(integerPart: 10, fractionalPart: 11),
      ]);
      when(() => mockSource.illuminant)
          .thenReturn(ColorProfileIlluminant.illuminantD50);
      when(() => mockDestination.illuminant)
          .thenReturn(ColorProfileIlluminant.illuminantD50);
      when(() => mockSource.pccObserver).thenReturn(
          ColorProfileStandardObserver.standardObserver1931TwoDegrees);
      when(() => mockDestination.pccObserver).thenReturn(
          ColorProfileStandardObserver.standardObserver1931TwoDegrees);

      when(() => source.useLegacyPCS).thenReturn(true);
      when(() => source.doAdjustPCS).thenReturn(true);
      when(() => source.pcsScale).thenReturn(Float64List.fromList([1, 2, 3]));
      when(() => source.pcsOffset).thenReturn(Float64List.fromList([4, 5, 6]));
    });

    group('Destination xyz', () {
      setUp(() {
        when(() => destination.getSourceColorSpace())
            .thenReturn(ColorSpaceSignature.icSigXYZData);
        when(() => destination.doAdjustPCS).thenReturn(true);
        when(() => destination.pcsScale)
            .thenReturn(Float64List.fromList([7, 8, 9]));
        when(() => destination.pcsOffset)
            .thenReturn(Float64List.fromList([10, 11, 12]));
        when(() => destination.useLegacyPCS).thenReturn(true);
      });
      test('if source uses legacy pcs, it adds lab2XYZ', () {
        when(() => source.useLegacyPCS).thenReturn(true);

        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps[0];
        expect(first, isA<ColorProfileLab2ToXyz>());
        first as ColorProfileLab2ToXyz;
        expect(first.xyzWhite,
            equals([1 + 2 / 65536, 3 + 4 / 65536, 5 + 6 / 65536]));
      });
      test('if source does not use legacy pcs, it adds labXYZ', () {
        when(() => source.useLegacyPCS).thenReturn(false);

        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps[0];
        expect(first, isA<ColorProfileLabToXyz>());
        first as ColorProfileLabToXyz;
        expect(first.xyzWhite,
            equals([1 + 2 / 65536, 3 + 4 / 65536, 5 + 6 / 65536]));
      });
      test('if source needs to adjust pcs, it adds scale and offset', () {
        when(() => source.doAdjustPCS).thenReturn(true);

        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps[1];
        final second = result.steps[2];
        first as ColorProfileScale3;
        second as ColorProfileOffset3;
        expect(first.scale, equals([1, 2, 3]));
        expect(
            second.offset,
            equals([
              4 * 65535.0 / 32768.0,
              5 * 65535.0 / 32768.0,
              6 * 65535.0 / 32768.0,
            ]));
      });
      test(
          'if source does not need to adjust pcs, it does not add scale and offset',
          () {
        when(() => source.doAdjustPCS).thenReturn(false);
        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps[1];
        expect(first, isNot(isA<ColorProfileScale3>()));
      });
      test('if target needs to adjust pcs, it adds scale and offset', () {
        when(() => destination.doAdjustPCS).thenReturn(true);

        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps[3];
        final second = result.steps[4];
        first as ColorProfileOffset3;
        second as ColorProfileScale3;
        expect(
            first.offset,
            equals([
              (10 / 7) * 65535.0 / 32768.0,
              (11 / 8) * 65535.0 / 32768.0,
              (12 / 9) * 65535.0 / 32768.0,
            ]));
        expect(second.scale, equals([7, 8, 9]));
      });
      test(
          'if destination does not need to adjust pcs, it does not add scale and offset',
          () {
        when(() => destination.doAdjustPCS).thenReturn(false);
        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps[3];
        expect(first, isNot(isA<ColorProfileOffset3>()));
      });
      test('it adds xyzToXyz', () {
        final result = ColorProfilePCSTransform.connect(source, destination);
        expect(result, isNotNull);
        final first = result!.steps.last;
        expect(first, isA<ColorProfileScale3>());
        first as ColorProfileScale3;
        const scale = 32768 / 65535;
        expect(first.scale, equals([scale, scale, scale]));
      });
    });
  });
}
