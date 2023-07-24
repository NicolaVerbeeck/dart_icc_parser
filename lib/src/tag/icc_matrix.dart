abstract class IccMatrix {
  final List<double> matrix;

  bool get isIdentity;

  IccMatrix(this.matrix);

  void apply(final List<double> pixel);
}
