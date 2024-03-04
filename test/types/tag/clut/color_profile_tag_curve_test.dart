import 'package:icc_parser/src/error.dart';
import 'package:icc_parser/src/types/tag/curve/color_profile_tag_curve.dart';
import 'package:test/test.dart';

import '../../../utils/data_stream_test.dart';

void main() {
  group('ColorProfileTagCurve', () {
    test('Test invalid signature throws', () {
      expect(
          () => ColorProfileTagCurve.fromBytes(
                dataStreamOf([0, 0, 0, 0, 0, 0, 0, 0]),
                entrySize: 1,
              ),
          throwsA(isA<InvalidSignatureException>()));
    });
  });
}
