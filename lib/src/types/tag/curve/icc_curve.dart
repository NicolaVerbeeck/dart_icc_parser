import 'package:icc_parser/src/types/tag/curve/icc_tag_curve.dart';
import 'package:icc_parser/src/types/tag/curve/icc_tag_parametric_curve.dart';
import 'package:icc_parser/src/types/tag/icc_tag.dart';
import 'package:icc_parser/src/types/tag/tag_type.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

abstract class IccCurve implements IccTag {
  bool get isIdentity => false;

  const IccCurve();

  factory IccCurve.fromBytes(
    final DataStream data, {
    required final int size,
  }) {
    final pos = data.position;
    final signature = data.readUnsigned32Number().value;
    data.seek(pos);

    if (signature == KnownTagType.icSigCurveType.code) {
      return IccTagCurve.fromBytes(data);
    } else if (signature == KnownTagType.icSigParametricCurveType.code) {
      return IccTagParametricCurve.fromBytes(
        data,
        size: size,
      );
    }
    throw Exception('Unsupported curve type: $signature');
  }

  double apply(final double value);

  double find(final double value) => findValue(
        value: value,
        p0: 0,
        v0: apply(0),
        p1: 1,
        v1: apply(1),
      );

  @protected
  double findValue({
    required final double value,
    required final double p0,
    required final double v0,
    required final double p1,
    required final double v1,
  }) {
    if (value <= v0) {
      return p0;
    } else if (value >= v1) {
      return p1;
    }

    if (p1 - p0 < 0.00001) {
      final d0 = (value - v0).abs();
      final d1 = (value - v1).abs();
      if (d0 < d1) return p0;
      return p1;
    }
    final np = (p0 + p1) / 2.0;
    final nv = apply(np);
    if (value <= nv) {
      return findValue(value: value, p0: p0, v0: v0, p1: np, v1: nv);
    }
    return findValue(value: value, p0: np, v0: nv, p1: p1, v1: v1);
  }
}
