import 'package:icc_parser/src/error.dart';
import 'package:icc_parser/src/types/tag/color_profile_tags.dart';
import 'package:test/test.dart';

void main() {
  group('Error tests', () {
    test('Test MissingTagException', () {
      final exception = MissingTagException(ICCColorProfileTag.icSigAToB0Tag);
      expect(exception.toString(),
          "Missing required tag: ${ICCColorProfileTag.icSigAToB0Tag}");
    });

    test('Test BadSpaceLinkException', () {
      const exception = BadSpaceLinkException();
      expect(exception.toString(), "Bad space link");
    });

    test('Test InvalidSignatureException', () {
      const exception = InvalidSignatureException(expected: 1, got: 2);
      expect(exception.toString(), "Invalid signature: expected 1, got 2");
    });
  });
}
