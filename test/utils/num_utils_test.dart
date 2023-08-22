import 'dart:typed_data';

import 'package:icc_parser/src/types/tag/curve/color_profile_tag_parametric_curve.dart';
import 'package:icc_parser/src/utils/num_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Num utils tests', () {
    test('isUnity', () {
      expect(isUnity(1.0), true);
      expect(isUnity(1.00000001), true);
      expect(isUnity(0.99999999), true);
      expect(isUnity(0.9999999), false);
      expect(isUnity(1.0000001), false);
    });
    test('xyzScale', () {
      expect(xyzScale(0.0), 0.0);
      expect(xyzScale(1.0), 32768.0 / 65535.0);
      expect(xyzScale(0.5), 0.5 * 32768.0 / 65535.0);
    });
    test('xyzDescale', () {
      expect(xyzDescale(0.0), 0.0);
      expect(xyzDescale(32768.0 / 65535.0), 1.0);
      expect(xyzDescale(0.5 * 32768.0 / 65535.0), 0.5);
    });
    test('Scaling idempotent', () {
      expect(xyzDescale(xyzScale(0.0)), 0.0);
      expect(xyzDescale(xyzScale(1.0)), 1.0);
      expect(xyzDescale(xyzScale(0.5)), 0.5);
    });
    test('Test rgbClip', () {
      final curve = ColorProfileTagParametricCurve(
        functionType: 0,
        numberOfParameters: 1,
        dParam: Float64List.fromList([13.4]),
      );
      expect(rgbClip(0.0, curve), 0.0);
      expect(curve.apply(2.0), 10809.408805051553);
      expect(rgbClip(2.0, curve), 1.0);
    });
  });
}
