/// Enumerations for the CMM.
enum ColorProfileTransformType {
  transform3D,
  transform4D,
}

/// Which rendering intent to use
enum ColorProfileRenderingIntent {
  perceptual(0), // We only support this for now
  icRelativeColorimetric(1),
  ;

  final int offset;

  const ColorProfileRenderingIntent(this.offset);
}

/// Which type of interpolation to use when using LUTs
enum ColorProfileInterpolation {
  linear,
  tetrahedral,
}

/// Which type of LUT to use
enum ColorProfileTransformLutType {
  color, // Only one for now
}

/// Which type of observer to use
enum ColorProfileStandardObserver {
  standardObserver1931TwoDegrees,
}

/// Which type of illuminant to use
enum ColorProfileIlluminant {
  illuminantD50,
}
