import 'package:icc_parser/src/error.dart';
import 'package:icc_parser/src/types/tag/lut/color_profile_tag_lut_b_to_a.dart';
import 'package:test/test.dart';

import '../../../utils/data_stream_test.dart';

void main() {
  group('ColorProfileTagLutBToA', () {
    test('Test invalid signature throws', () {
      expect(
          () => ColorProfileTagLutBToA.fromBytes(
                dataStreamOf([0, 0, 0, 0, 0, 0, 0, 0]),
                size: 8,
              ),
          throwsA(isA<InvalidSignatureException>()));
    });
  });
}
