import 'dart:typed_data';

import 'package:icc_parser/src/cmm/color_profile_pcs.dart';
import 'package:icc_parser/src/cmm/color_profile_pcs_transform.dart';
import 'package:icc_parser/src/utils/list_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Color profile PCS step', () {
    test('ColorProfileLab2ToXyz', () {
      final xyzWhite = threeDoubles(4, 5, 6);
      final step = ColorProfileLab2ToXyz(xyzWhite: xyzWhite);

      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);
      step.apply(source: source, destination: dest);

      final step1X = source[0] * (65535.0 / 65280.0) * 100.0;
      final step1Y = source[1] * 65535.0 / 65280.0 * 255.0 - 128.0;
      final step1Z = source[2] * 65535.0 / 65280.0 * 255.0 - 128.0;

      final fy = (step1X + 16.0) / 116.0;

      final resX =
          ColorProfilePCSUtils.icICubeth(step1Y / 500 + fy) * xyzWhite[0];
      final resY = ColorProfilePCSUtils.icICubeth(fy) * xyzWhite[1];
      final resZ =
          ColorProfilePCSUtils.icICubeth(fy - step1Z / 200) * xyzWhite[2];

      expect(dest[0], resX);
      expect(dest[1], resY);
      expect(dest[2], resZ);
    });

    test('ColorProfileXyzToLab2', () {
      final xyzWhite = threeDoubles(4, 5, 6);
      final step = ColorProfileXyzToLab2(xyzWhite: xyzWhite);

      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);
      step.apply(source: source, destination: dest);

      final step1X = ColorProfilePCSUtils.icCubeth(source[0] / xyzWhite[0]);
      final step1Y = ColorProfilePCSUtils.icCubeth(source[1] / xyzWhite[1]);
      final step1Z = ColorProfilePCSUtils.icCubeth(source[2] / xyzWhite[2]);

      final step2X = 116 * step1Y - 16;
      final step2Y = 500 * (step1X - step1Y);
      final step2Z = 200 * (step1Y - step1Z);

      final resX = (step2X / 100.0) * (65280.0 / 65535.0);
      final resY = ((step2Y + 128.0) / 255.0) * (65280.0 / 65535.0);
      final resZ = ((step2Z + 128.0) / 255.0) * (65280.0 / 65535.0);

      expect(dest, [resX, resY, resZ]);
    });

    test('ColorProfileLabToXyz', () {
      final xyzWhite = threeDoubles(4, 5, 6);
      final step = ColorProfileLabToXyz(xyzWhite: xyzWhite);

      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);
      step.apply(source: source, destination: dest);

      final step1X = source[0] * 100.0;
      final step1Y = source[1] * 255.0 - 128.0;
      final step1Z = source[2] * 255.0 - 128.0;

      final fy = (step1X + 16.0) / 116.0;

      final resX =
          ColorProfilePCSUtils.icICubeth(step1Y / 500 + fy) * xyzWhite[0];
      final resY = ColorProfilePCSUtils.icICubeth(fy) * xyzWhite[1];
      final resZ =
          ColorProfilePCSUtils.icICubeth(fy - step1Z / 200) * xyzWhite[2];

      expect(dest[0], resX);
      expect(dest[1], resY);
      expect(dest[2], resZ);
    });

    test('ColorProfileXyzToLab', () {
      final xyzWhite = threeDoubles(4, 5, 6);
      final step = ColorProfileXyzToLab(xyzWhite: xyzWhite);

      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);
      step.apply(source: source, destination: dest);

      final step1X = ColorProfilePCSUtils.icCubeth(source[0] / xyzWhite[0]);
      final step1Y = ColorProfilePCSUtils.icCubeth(source[1] / xyzWhite[1]);
      final step1Z = ColorProfilePCSUtils.icCubeth(source[2] / xyzWhite[2]);

      final step2X = 116 * step1Y - 16;
      final step2Y = 500 * (step1X - step1Y);
      final step2Z = 200 * (step1Y - step1Z);

      final resX = step2X / 100.0;
      final resY = (step2Y + 128.0) / 255.0;
      final resZ = (step2Z + 128.0) / 255.0;

      expect(dest, [resX, resY, resZ]);
    });

    test('ColorProfileScale3', () {
      final step = ColorProfileScale3(scale: threeDoubles(2, 3, 5));

      final source = threeDoubles(6, 7, 8);
      final dest = Float64List(3);
      step.apply(source: source, destination: dest);

      expect(dest, [12, 21, 40]);
    });

    test('ColorProfileOffset3', () {
      final step = ColorProfileOffset3(offset: threeDoubles(2, 3, 5));

      final source = threeDoubles(6, 7, 8);
      final dest = Float64List(3);
      step.apply(source: source, destination: dest);

      expect(dest, [8, 10, 13]);
    });

    test('ColorProfileXYZConvertStep', () {
      const step = ColorProfileXYZConvertStep();

      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);
      step.apply(source: source, destination: dest);
      expect(source, dest);
    });

    test('ColorProfileOffset3 does not convert when not required', () {
      final step = ColorProfileOffset3.create(1, 2, 3, false);
      expect(step.offset, [1, 2, 3]);
    });

    test('ColorProfileOffset3 does convert when required', () {
      final step = ColorProfileOffset3.create(1, 2, 3, true);
      expect(step.offset, [
        1 * 65535.0 / 32768.0,
        2 * 65535.0 / 32768.0,
        3 * 65535.0 / 32768.0,
      ]);
    });
  });
}
