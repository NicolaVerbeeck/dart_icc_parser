abstract class IccPCS {
  static const icD50XYZ = [0.9642, 1.0000, 0.8249];

  static void lab2ToXyz({
    required final List<double> source,
    required final List<double> dest,
    required final bool noClip,
  }) {
    lab2ToLab4(source: source, dest: dest, noClip: noClip);
    labToXyz(source: dest, dest: dest, noClip: noClip);
  }

  static void lab2ToLab4({
    required final List<double> source,
    required final List<double> dest,
    required final bool noClip,
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
    required final List<double> source,
    required final List<double> dest,
    required final bool noClip,
  }) {
    xyzToLab(source: source, dest: dest, noClip: noClip);
    lab4ToLab2(source: dest, dest: dest);
  }

  static void labToXyz({
    required final List<double> source,
    required final List<double> dest,
    required final bool noClip,
  }) {
    final List<double> lab = [...source];
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

  static void icLabFromPcs(final List<double> pixel) {
    pixel[0] *= 100;
    pixel[1] = (pixel[1] * 255.0) - 128.0;
    pixel[2] = (pixel[2] * 255.0) - 128.0;
  }

  static void icLabToXYZ(final List<double> pixel) {
    const whitePoint = icD50XYZ;

    final fy = (pixel[0] + 16.0) / 116.0;
    pixel[0] = icICubeth(pixel[1] / 500.0 + fy) * whitePoint[0];
    pixel[1] = icICubeth(fy) * whitePoint[1];
    pixel[2] = icICubeth(fy - pixel[2] / 200.0) * whitePoint[2];
  }

  static void xyzToLab({
    required final List<double> source,
    required final List<double> dest,
    required final bool noClip,
  }) {
    final xyz = List.filled(3, 0.0);
    if (!noClip) {
      xyz[0] = source[0].clamp(0, 1);
      xyz[1] = source[1].clamp(0, 1);
      xyz[2] = source[2].clamp(0, 1);
    } else {
      xyz[0] = source[0];
      xyz[1] = source[1];
      xyz[2] = source[2];
    }

    icXyzFromPcs(xyz);
    icXYZtoLab(xyz);
    icLabToPcs(xyz);
  }

  static double icICubeth(final double v) {
    if (v > 0.20689303448275862068965517241379) {
      return v * v * v;
    } else if (v > 16.0 / 116.0) {
      return (v - 16.0 / 116.0) / 7.787037037037037037037037037037;
    } else {
      return 0;
    }
  }

  static void icXyzToPcs(final List<double> pixel) {
    const factor = 32768.0 / 65535.0;
    pixel[0] *= factor;
    pixel[1] *= factor;
    pixel[2] *= factor;
  }

  static void icXyzFromPcs(final List<double> xyz) {
    const factor = 65535.0 / 32768.0;
    xyz[0] *= factor;
    xyz[1] *= factor;
    xyz[2] *= factor;
  }

  static void icXYZtoLab(final List<double> lab) {
    const whitePoint = icD50XYZ;

    final xn = icICubeth(lab[0] / whitePoint[0]);
    final yn = icICubeth(lab[1] / whitePoint[1]);
    final zn = icICubeth(lab[2] / whitePoint[2]);

    lab[0] = 116.0 * yn - 16.0;
    lab[1] = 500.0 * (xn - yn);
    lab[2] = 200.0 * (yn - zn);
  }

  static void icLabToPcs(final List<double> lab) {
    lab[0] /= 100.0;
    lab[1] = (lab[1] + 128.0) / 255.0;
    lab[2] = (lab[2] + 128.0) / 255.0;
  }

  static void lab4ToLab2({
    required final List<double> source,
    required final List<double> dest,
  }) {
    const factor = 65280.0 / 65535.0;
    dest[0] = source[0] * factor;
    dest[1] = source[1] * factor;
    dest[2] = source[2] * factor;
  }
}
