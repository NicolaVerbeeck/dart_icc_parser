enum ColorProfileTransformType {
  transform3D,
  transform4D,
}

enum ColorProfileRenderingIntent {
  perceptual(0), // We only support this for now
  ;

  final int offset;

  const ColorProfileRenderingIntent(this.offset);
}

enum ColorProfileInterpolation {
  linear,
  tetrahedral,
}

enum ColorProfileTransformLutType {
  color, // Only one for now
}

enum ColorProfileStandardObserver {
  standardObserver1931TwoDegrees,
}

enum ColorProfileIlluminant {
  illuminantD50,
}