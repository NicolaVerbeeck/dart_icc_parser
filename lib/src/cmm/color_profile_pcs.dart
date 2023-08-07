import 'dart:math';
import 'dart:typed_data';

import 'package:icc_parser/src/utils/list_utils.dart';

/// Utility class for converting between Lab and XYZ color spaces from various
/// versions
abstract class ColorProfilePCSUtils {
  /// Utility classes should not be constructed
  ColorProfilePCSUtils._();

  /// The D50 XYZ values used in the ICC PCS
  static const _icD50XYZ = [0.9642, 1.0000, 0.8249];

  static void lab2ToXyz({
    required Float64List source,
    required Float64List dest,
    required bool noClip,
  }) {
    lab2ToLab4(source: source, dest: dest, noClip: noClip);
    labToXyz(source: dest, dest: dest, noClip: noClip);
  }

  static void lab2ToLab4({
    required Float64List source,
    required Float64List dest,
    required bool noClip,
  }) {
    const factor = 65535.0 / 65280.0;
    if (noClip) {
      dest[0] = source[0] * factor;
      dest[1] = source[1] * factor;
      dest[2] = source[2] * factor;
    } else {
      dest[0] = (source[0] * factor).clamp(0, 1);
      dest[1] = (source[1] * factor).clamp(0, 1);
      dest[2] = (source[2] * factor).clamp(0, 1);
    }
  }

  static void xyzToLab2({
    required Float64List source,
    required Float64List dest,
    required bool noClip,
  }) {
    xyzToLab(source: source, dest: dest, noClip: noClip);
    lab4ToLab2(source: dest, dest: dest);
  }

  static void labToXyz({
    required Float64List source,
    required Float64List dest,
    required bool noClip,
  }) {
    final lab = source.copy();
    icLabFromPcs(lab);
    icLabToXYZ(lab);
    icXyzToPcs(lab);

    if (!noClip) {
      dest[0] = lab[0].clamp(0, 1);
      dest[1] = lab[1].clamp(0, 1);
      dest[2] = lab[2].clamp(0, 1);
    } else {
      dest[0] = lab[0];
      dest[1] = lab[1];
      dest[2] = lab[2];
    }
  }

  static void icLabFromPcs(Float64List pixel) {
    pixel[0] *= 100;
    pixel[1] = (pixel[1] * 255.0) - 128.0;
    pixel[2] = (pixel[2] * 255.0) - 128.0;
  }

  static void icLabToXYZ(
    Float64List pixel, {
    Float64List? lab,
    Float64List? whiteXYZ,
  }) {
    final useLab = lab ?? pixel;
    final whitePoint = whiteXYZ ?? _icD50XYZ;

    final fy = (useLab[0] + 16.0) / 116.0;
    pixel[0] = icICubeth(useLab[1] / 500.0 + fy) * whitePoint[0];
    pixel[1] = icICubeth(fy) * whitePoint[1];
    pixel[2] = icICubeth(fy - useLab[2] / 200.0) * whitePoint[2];
  }

  static void xyzToLab({
    required Float64List source,
    required Float64List dest,
    required bool noClip,
  }) {
    final xyz = Float64List(3);
    if (!noClip) {
      xyz[0] = source[0].clamp(0.0, 1.0);
      xyz[1] = source[1].clamp(0.0, 1.0);
      xyz[2] = source[2].clamp(0.0, 1.0);
    } else {
      xyz[0] = source[0];
      xyz[1] = source[1];
      xyz[2] = source[2];
    }

    icXyzFromPcs(xyz);
    icXYZtoLab(xyz);
    icLabToPcs(xyz);

    if (!noClip) {
      dest[0] = xyz[0].clamp(0.0, 1.0);
      dest[1] = xyz[1].clamp(0.0, 1.0);
      dest[2] = xyz[2].clamp(0.0, 1.0);
    } else {
      dest[0] = xyz[0];
      dest[1] = xyz[1];
      dest[2] = xyz[2];
    }
  }

  static double icCubeth(double v) {
    if (v > 0.008856) {
      return pow(v, 1.0 / 3.0).toDouble();
    } else {
      return 7.787037037037037037037037037037 * v + 16.0 / 116.0;
    }
  }

  static double icICubeth(double v) {
    if (v > 0.20689303448275862068965517241379) {
      return v * v * v;
    } else if (v > 16.0 / 116.0) {
      return (v - 16.0 / 116.0) / 7.787037037037037037037037037037;
    } else {
      return 0;
    }
  }

  static void icXyzToPcs(Float64List pixel) {
    const factor = 32768.0 / 65535.0;
    pixel[0] *= factor;
    pixel[1] *= factor;
    pixel[2] *= factor;
  }

  static void icXyzFromPcs(Float64List xyz) {
    const factor = 65535.0 / 32768.0;
    xyz[0] *= factor;
    xyz[1] *= factor;
    xyz[2] *= factor;
  }

  static void icXYZtoLab(
    Float64List lab, {
    Float64List? xyz,
    Float64List? whiteXYZ,
  }) {
    final whitePoint = whiteXYZ ?? _icD50XYZ;
    final useXyz = xyz ?? lab;

    final xn = icCubeth(useXyz[0] / whitePoint[0]);
    final yn = icCubeth(useXyz[1] / whitePoint[1]);
    final zn = icCubeth(useXyz[2] / whitePoint[2]);

    lab[0] = 116.0 * yn - 16.0;
    lab[1] = 500.0 * (xn - yn);
    lab[2] = 200.0 * (yn - zn);
  }

  static void icLabToPcs(Float64List lab) {
    lab[0] /= 100.0;
    lab[1] = (lab[1] + 128.0) / 255.0;
    lab[2] = (lab[2] + 128.0) / 255.0;
  }

  static void lab4ToLab2({
    required Float64List source,
    required Float64List dest,
  }) {
    const factor = 65280.0 / 65535.0;
    dest[0] = source[0] * factor;
    dest[1] = source[1] * factor;
    dest[2] = source[2] * factor;
  }
}
