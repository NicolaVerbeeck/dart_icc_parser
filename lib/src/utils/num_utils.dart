import 'package:icc_parser/src/types/tag/curve/color_profile_curve.dart';

const verySmallNumber = 0.0000001;

bool isUnity(double num) {
  return num > (1.0 - verySmallNumber) && num < (1.0 + verySmallNumber);
}

double xyzScale(double v) {
  return v * 32768.0 / 65535.0;
}

double xyzDescale(double v) {
  return v * 65535.0 / 32768.0;
}

/// Apply the [curve] to the [value] which is clamped to the range 0.0 to 1.0.
double rgbClip(double value, ColorProfileCurve curve) {
  return curve.apply(value.clamp(0.0, 1.0));
}
