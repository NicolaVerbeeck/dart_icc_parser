import 'package:icc_parser/src/types/tag/color_profile_tag.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag_type.dart';
import 'package:icc_parser/src/types/tag/curve/color_profile_tag_curve.dart';
import 'package:icc_parser/src/types/tag/curve/color_profile_tag_parametric_curve.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

abstract class ColorProfileCurve implements ColorProfileTag {
  bool get isIdentity;

  const ColorProfileCurve();

  factory ColorProfileCurve.fromBytes(
    DataStream data, {
    required int size,
  }) {
    final pos = data.position;
    final signature = data.readUnsigned32Number().value;
    data.seek(pos);

    if (signature == ColorProfileTagType.icSigCurveType.code) {
      return ColorProfileTagCurve.fromBytes(data, entrySize: 2);
    } else if (signature == ColorProfileTagType.icSigParametricCurveType.code) {
      return ColorProfileTagParametricCurve.fromBytes(
        data,
        size: size,
      );
    }
    throw Exception('Unsupported curve type: $signature');
  }

  double apply(double value);

  double find(double value) => findValue(
        value: value,
        p0: 0,
        v0: apply(0),
        p1: 1,
        v1: apply(1),
      );

  @protected
  double findValue({
    required double value,
    required double p0,
    required double v0,
    required double p1,
    required double v1,
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
