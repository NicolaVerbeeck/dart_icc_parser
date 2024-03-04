import 'package:icc_parser/src/error.dart';
import 'package:icc_parser/src/types/tag/xyz/color_profile_xyz_tag.dart';
import 'package:test/test.dart';

import '../../../utils/data_stream_test.dart';

void main() {
  group('ColorProfileXYZTag', () {
    test('Test invalid signature throws', () {
      expect(
          () => ColorProfileXYZTag.fromBytes(
                dataStreamOf([0, 0, 0, 0, 0, 0, 0, 0]),
                size: 8,
              ),
          throwsA(isA<InvalidSignatureException>()));
    });
  });
}
