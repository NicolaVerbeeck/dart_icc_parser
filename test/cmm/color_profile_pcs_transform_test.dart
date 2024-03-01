import 'dart:typed_data';

import 'package:icc_parser/icc_parser.dart';
import 'package:icc_parser/src/cmm/color_profile_pcs_transform.dart';
import 'package:icc_parser/src/types/color_profile_header.dart';
import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockColorProfileTransform extends Mock implements ColorProfileTransform {}

class MockColorProfile extends Mock implements ColorProfile {}

void main() {
  group('ColorProfilePcsTransform', () {
    test('Null transform for unsupported pcs transforms', () {
      final source = MockColorProfileTransform();
      final destination = MockColorProfileTransform();

      when(() => source.isInput).thenReturn(true);
      when(() => destination.isInput).thenReturn(false);
      when(() => source.getDestinationColorSpace())
          .thenReturn(ColorSpaceSignature.icSig10colorData);

      expect(ColorProfilePCSTransform.connect(source, destination), isNull);
    });
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
        when(() => source.pcsOffset)
            .thenReturn(Float64List.fromList([4, 5, 6]));
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
        test('if source uses legacy pcs, it adds labXYZ', () {
          when(() => source.useLegacyPCS).thenReturn(false);

          final result = ColorProfilePCSTransform.connect(source, destination);
          expect(result, isNotNull);
          final first = result!.steps[0];
          expect(first, isA<ColorProfileLabToXyz>());
          first as ColorProfileLabToXyz;
          expect(first.xyzWhite,
              equals([1 + 2 / 65536, 3 + 4 / 65536, 5 + 6 / 65536]));
        });
      });
    });
  });
}
