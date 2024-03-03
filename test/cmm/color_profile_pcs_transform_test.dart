import 'package:icc_parser/icc_parser.dart';
import 'package:icc_parser/src/cmm/color_profile_pcs_transform.dart';
import 'package:icc_parser/src/types/color_profile_header.dart';
import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:icc_parser/src/utils/list_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'color_profile_transform_matrix_trc_test.dart';

class MockColorProfileTransform extends Mock implements ColorProfileTransform {}

class MockColorProfile extends Mock implements ColorProfile {}

class MockColorProfileTransformationStep extends Mock
    implements ColorProfileTransformationStep {}

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
    test('it throws bad space link when source is not input', () {
      final source = MockColorProfileTransform();
      final destination = MockColorProfileTransform();
      when(() => source.isInput).thenReturn(false);
      expect(() => ColorProfilePCSTransform.connect(source, destination),
          throwsA(isA<BadSpaceLinkException>()));
    });
    test('it throws bad space link when destination is input and not abstract',
        () {
      final source = MockColorProfileTransform();
      final destination = MockColorProfileTransform();
      when(() => source.isInput).thenReturn(true);
      when(() => destination.isInput).thenReturn(true);
      when(() => destination.isAbstract).thenReturn(false);
      expect(() => ColorProfilePCSTransform.connect(source, destination),
          throwsA(isA<BadSpaceLinkException>()));
    });
    test('if no steps are given, it copies the source to destination', () {
      final profile = MockColorProfile();
      final mockHeader = MockColorProfileHeader();
      when(() => profile.header).thenReturn(mockHeader);
      when(() => mockHeader.pcs)
          .thenReturn(Unsigned32Number(ColorSpaceSignature.icSigRgbData.code));

      final sut = ColorProfilePCSTransform(
        profile: profile,
        steps: List.empty(),
      );

      final source = threeDoubles(2, 3, 4);
      final dest = sut.apply(source, MockColorProfileTransformationStep());
      expect(source, dest);
    });
  });
}
