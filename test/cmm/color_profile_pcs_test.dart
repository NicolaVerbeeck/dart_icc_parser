import 'dart:typed_data';

import 'package:icc_parser/src/cmm/color_profile_pcs.dart';
import 'package:icc_parser/src/utils/list_utils.dart';
import 'package:test/test.dart';

void main() {
  group('ColorProfilePCSUtils', () {
    test('lab2ToXyz without clip', () {
      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);

      ColorProfilePCSUtils.lab2ToXyz(source: source, dest: dest, noClip: true);

      final check = Float64List(3);
      ColorProfilePCSUtils.lab2ToLab4(
          source: source, dest: check, noClip: true);
      ColorProfilePCSUtils.labToXyz(source: check, dest: check, noClip: true);

      expect(dest, check);
    });
    test('lab2ToXyz with clip', () {
      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);

      ColorProfilePCSUtils.lab2ToXyz(source: source, dest: dest, noClip: false);

      final check = Float64List(3);
      ColorProfilePCSUtils.lab2ToLab4(
          source: source, dest: check, noClip: false);
      ColorProfilePCSUtils.labToXyz(source: check, dest: check, noClip: false);

      expect(dest, check);
    });
    test('lab2ToLab4 without clip', () {
      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);

      ColorProfilePCSUtils.lab2ToLab4(source: source, dest: dest, noClip: true);

      final step1 = threeDoubles(
        source[0] * 65535.0 / 65280.0,
        source[1] * 65535.0 / 65280.0,
        source[2] * 65535.0 / 65280.0,
      );

      expect(dest, step1);
    });
    test('lab2ToLab4 with clip', () {
      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);

      ColorProfilePCSUtils.lab2ToLab4(
          source: source, dest: dest, noClip: false);

      final step1 = threeDoubles(
        (source[0] * 65535.0 / 65280.0).clamp(0, 1),
        (source[1] * 65535.0 / 65280.0).clamp(0, 1),
        (source[2] * 65535.0 / 65280.0).clamp(0, 1),
      );

      step1[0] = step1[0].clamp(0, 1);
      step1[1] = step1[1].clamp(0, 1);
      step1[2] = step1[2].clamp(0, 1);

      expect(dest, step1);
    });
    test('xyzToLab2 without clip', () {
      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);

      ColorProfilePCSUtils.xyzToLab2(source: source, dest: dest, noClip: true);

      final check = Float64List(3);
      ColorProfilePCSUtils.xyzToLab(source: source, dest: check, noClip: true);
      ColorProfilePCSUtils.lab4ToLab2(source: check, dest: check);

      expect(dest, check);
    });
    test('xyzToLab2 with clip', () {
      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);

      ColorProfilePCSUtils.xyzToLab2(source: source, dest: dest, noClip: false);

      final check = Float64List(3);
      ColorProfilePCSUtils.xyzToLab(source: source, dest: check, noClip: false);
      ColorProfilePCSUtils.lab4ToLab2(source: check, dest: check);

      expect(dest, check);
    });
    test('labToXyz without clip', () {
      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);

      ColorProfilePCSUtils.labToXyz(source: source, dest: dest, noClip: true);

      final check = Float64List(3);
      final lab = source.copy();
      ColorProfilePCSUtils.icLabFromPcs(lab);
      ColorProfilePCSUtils.icLabToXYZ(lab);
      ColorProfilePCSUtils.icXyzToPcs(lab);
      check.copyFrom(lab);

      expect(dest, check);
    });
    test('labToXyz with clip', () {
      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);

      ColorProfilePCSUtils.labToXyz(source: source, dest: dest, noClip: false);

      final check = Float64List(3);
      final lab = source.copy();
      ColorProfilePCSUtils.icLabFromPcs(lab);
      ColorProfilePCSUtils.icLabToXYZ(lab);
      ColorProfilePCSUtils.icXyzToPcs(lab);
      check[0] = lab[0].clamp(0, 1);
      check[1] = lab[1].clamp(0, 1);
      check[2] = lab[2].clamp(0, 1);

      expect(dest, check);
    });
    test('icLabFromPcs', () {
      final pixel = threeDoubles(1, 2, 3);
      final check = pixel.copy();
      check[0] *= 100;
      check[1] = (check[1] * 255.0) - 128.0;
      check[2] = (check[2] * 255.0) - 128.0;

      ColorProfilePCSUtils.icLabFromPcs(pixel);

      expect(pixel, check);
    });
    test('icLabToXYZ with whiteXYZ', () {
      final pixel = threeDoubles(1, 2, 3);
      final white = threeDoubles(4, 5, 6);
      final lab = threeDoubles(7, 8, 9);

      ColorProfilePCSUtils.icLabToXYZ(pixel, lab: lab, whiteXYZ: white);

      final check = Float64List(3);
      final fy = (lab[0] + 16.0) / 116.0;
      check[0] = ColorProfilePCSUtils.icICubeth(lab[1] / 500.0 + fy) * white[0];
      check[1] = ColorProfilePCSUtils.icICubeth(fy) * white[1];
      check[2] = ColorProfilePCSUtils.icICubeth(fy - lab[2] / 200.0) * white[2];

      expect(pixel, check);
    });
    test('icLabToXYZ without whiteXYZ', () {
      final pixel = threeDoubles(1, 2, 3);
      final lab = threeDoubles(7, 8, 9);

      ColorProfilePCSUtils.icLabToXYZ(pixel, lab: lab, whiteXYZ: null);

      final icD50XYZ = threeDoubles(0.9642, 1.0000, 0.8249);
      final check = Float64List(3);
      final fy = (lab[0] + 16.0) / 116.0;
      check[0] =
          ColorProfilePCSUtils.icICubeth(lab[1] / 500.0 + fy) * icD50XYZ[0];
      check[1] = ColorProfilePCSUtils.icICubeth(fy) * icD50XYZ[1];
      check[2] =
          ColorProfilePCSUtils.icICubeth(fy - lab[2] / 200.0) * icD50XYZ[2];

      expect(pixel, check);
    });
    test('icLabToXYZ without white and lab', () {
      final pixel = threeDoubles(1, 2, 3);
      final pixelCopy = pixel.copy();

      ColorProfilePCSUtils.icLabToXYZ(pixel, lab: null, whiteXYZ: null);

      final icD50XYZ = threeDoubles(0.9642, 1.0000, 0.8249);
      final check = Float64List(3);
      final fy = (pixelCopy[0] + 16.0) / 116.0;
      check[0] = ColorProfilePCSUtils.icICubeth(pixelCopy[1] / 500.0 + fy) *
          icD50XYZ[0];
      check[1] = ColorProfilePCSUtils.icICubeth(fy) * icD50XYZ[1];
      check[2] = ColorProfilePCSUtils.icICubeth(fy - pixelCopy[2] / 200.0) *
          icD50XYZ[2];

      expect(pixel, check);
    });
    test('xyzToLab without clip', () {
      final pixel = threeDoubles(1, 2, 3);
      final dest = Float64List(3);

      ColorProfilePCSUtils.xyzToLab(source: pixel, dest: dest, noClip: true);

      final check = pixel.copy();

      ColorProfilePCSUtils.icXyzFromPcs(check);
      ColorProfilePCSUtils.icXYZtoLab(check);
      ColorProfilePCSUtils.icLabToPcs(check);

      expect(dest, check);
    });
    test('xyzToLab with clip', () {
      final pixel = threeDoubles(1, 2, 3);
      final dest = Float64List(3);

      ColorProfilePCSUtils.xyzToLab(source: pixel, dest: dest, noClip: false);

      final check = Float64List(3);
      check[0] = pixel[0].clamp(0, 1);
      check[1] = pixel[1].clamp(0, 1);
      check[2] = pixel[2].clamp(0, 1);

      ColorProfilePCSUtils.icXyzFromPcs(check);
      ColorProfilePCSUtils.icXYZtoLab(check);
      ColorProfilePCSUtils.icLabToPcs(check);

      check[0] = check[0].clamp(0, 1);
      check[1] = check[1].clamp(0, 1);
      check[2] = check[2].clamp(0, 1);

      expect(dest, check);
    });
    test('icCubeth', () {
      expect(ColorProfilePCSUtils.icCubeth(27), 3);
      expect(ColorProfilePCSUtils.icCubeth(0.007856),
          7.787037037037037037037037037037 * 0.007856 + 16.0 / 116.0);
    });
    test('icICubeth', () {
      expect(ColorProfilePCSUtils.icICubeth(3), 27);
      expect(ColorProfilePCSUtils.icICubeth(0.1479310345),
          (0.1479310345 - 16.0 / 116.0) / 7.787037037037037037037037037037);
      expect(ColorProfilePCSUtils.icICubeth(0.12), 0);
    });
    test('icXyzToPcs', () {
      final pixel = threeDoubles(1, 2, 3);
      final pixelCopy = pixel.copy();
      ColorProfilePCSUtils.icXyzToPcs(pixel);

      const factor = 32768.0 / 65535.0;
      pixelCopy[0] *= factor;
      pixelCopy[1] *= factor;
      pixelCopy[2] *= factor;

      expect(pixel, pixelCopy);
    });
    test('icXyzFromPcs', () {
      final pixel = threeDoubles(1, 2, 3);
      final pixelCopy = pixel.copy();
      ColorProfilePCSUtils.icXyzFromPcs(pixel);

      const factor = 65535.0 / 32768.0;
      pixelCopy[0] *= factor;
      pixelCopy[1] *= factor;
      pixelCopy[2] *= factor;

      expect(pixel, pixelCopy);
    });
    test('icXYZtoLab with whiteXYZ', () {
      final pixel = threeDoubles(1, 2, 3);
      final white = threeDoubles(4, 5, 6);
      final xyz = threeDoubles(7, 8, 9);

      ColorProfilePCSUtils.icXYZtoLab(pixel, xyz: xyz, whiteXYZ: white);

      final xN = ColorProfilePCSUtils.icCubeth(xyz[0] / white[0]);
      final yN = ColorProfilePCSUtils.icCubeth(xyz[1] / white[1]);
      final zN = ColorProfilePCSUtils.icCubeth(xyz[2] / white[2]);

      final check = Float64List(3);
      check[0] = 116.0 * yN - 16.0;
      check[1] = 500.0 * (xN - yN);
      check[2] = 200.0 * (yN - zN);

      expect(pixel, check);
    });
    test('icXYZtoLab without white', () {
      final pixel = threeDoubles(1, 2, 3);
      final xyz = threeDoubles(7, 8, 9);

      ColorProfilePCSUtils.icXYZtoLab(pixel, xyz: xyz, whiteXYZ: null);

      final icD50XYZ = threeDoubles(0.9642, 1.0000, 0.8249);

      final xN = ColorProfilePCSUtils.icCubeth(xyz[0] / icD50XYZ[0]);
      final yN = ColorProfilePCSUtils.icCubeth(xyz[1] / icD50XYZ[1]);
      final zN = ColorProfilePCSUtils.icCubeth(xyz[2] / icD50XYZ[2]);

      final check = Float64List(3);
      check[0] = 116.0 * yN - 16.0;
      check[1] = 500.0 * (xN - yN);
      check[2] = 200.0 * (yN - zN);

      expect(pixel, check);
    });
    test('icXYZtoLab without white and xyz', () {
      final pixel = threeDoubles(1, 2, 3);
      final pixelCopy = pixel.copy();

      ColorProfilePCSUtils.icXYZtoLab(pixel, xyz: null, whiteXYZ: null);

      final icD50XYZ = threeDoubles(0.9642, 1.0000, 0.8249);

      final xN = ColorProfilePCSUtils.icCubeth(pixelCopy[0] / icD50XYZ[0]);
      final yN = ColorProfilePCSUtils.icCubeth(pixelCopy[1] / icD50XYZ[1]);
      final zN = ColorProfilePCSUtils.icCubeth(pixelCopy[2] / icD50XYZ[2]);

      final check = Float64List(3);
      check[0] = 116.0 * yN - 16.0;
      check[1] = 500.0 * (xN - yN);
      check[2] = 200.0 * (yN - zN);

      expect(pixel, check);
    });
    test('icLabToPcs', () {
      final pixel = threeDoubles(1, 2, 3);
      final pixelCopy = pixel.copy();
      ColorProfilePCSUtils.icLabToPcs(pixel);

      pixelCopy[0] /= 100;
      pixelCopy[1] = (pixelCopy[1] + 128.0) / 255.0;
      pixelCopy[2] = (pixelCopy[2] + 128.0) / 255.0;

      expect(pixel, pixelCopy);
    });
    test('lab4ToLab2', () {
      final source = threeDoubles(1, 2, 3);
      final dest = Float64List(3);
      ColorProfilePCSUtils.lab4ToLab2(source: source, dest: dest);

      const factor = 65280.0 / 65535.0;
      final check = threeDoubles(
        source[0] * factor,
        source[1] * factor,
        source[2] * factor,
      );

      expect(dest, check);
    });
  });
}
