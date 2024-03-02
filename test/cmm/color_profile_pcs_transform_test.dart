import 'package:icc_parser/icc_parser.dart';
import 'package:icc_parser/src/cmm/color_profile_pcs_transform.dart';
import 'package:icc_parser/src/types/color_profile_header.dart';
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
  });
}
