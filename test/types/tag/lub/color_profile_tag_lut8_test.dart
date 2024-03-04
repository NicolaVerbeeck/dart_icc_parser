import 'package:icc_parser/src/error.dart';
import 'package:icc_parser/src/types/tag/lut/color_profile_tag_lut8.dart';
import 'package:test/test.dart';

import '../../../utils/data_stream_test.dart';

void main() {
  group('ColorProfileTagLut8', () {
    test('Test invalid signature throws', () {
      expect(
          () => ColorProfileTagLut8.fromBytes(
                dataStreamOf([0, 0, 0, 0, 0, 0, 0, 0]),
              ),
          throwsA(isA<InvalidSignatureException>()));
    });
  });
}
