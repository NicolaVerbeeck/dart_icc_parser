import 'package:icc_parser/src/error.dart';
import 'package:icc_parser/src/types/tag/curve/color_profile_tag_parametric_curve.dart';
import 'package:test/test.dart';

import '../../../utils/data_stream_test.dart';

void main() {
  group('ColorProfileTagParametricCurve', () {
    test('Test invalid signature throws', () {
      expect(
          () => ColorProfileTagParametricCurve.fromBytes(
                dataStreamOf([0, 0, 0, 0, 0, 0, 0, 0]),
                size: 8,
              ),
          throwsA(isA<InvalidSignatureException>()));
    });
  });
}
