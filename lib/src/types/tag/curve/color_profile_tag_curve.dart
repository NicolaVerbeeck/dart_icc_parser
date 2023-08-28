import 'dart:math';
import 'dart:typed_data';

import 'package:icc_parser/src/types/tag/color_profile_tag_type.dart';
import 'package:icc_parser/src/types/tag/curve/color_profile_curve.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:icc_parser/src/utils/list_utils.dart';
import 'package:icc_parser/src/utils/num_utils.dart';
import 'package:meta/meta.dart';

@immutable
final class ColorProfileTagCurve extends ColorProfileCurve {
  final Float64List curve;

  int get _maxIndex => curve.length - 1;

  @override
  ColorProfileTagType get type => ColorProfileTagType.icSigCurveType;

  const ColorProfileTagCurve(this.curve);

  factory ColorProfileTagCurve.fromBytes(
    DataStream data, {
    required int entrySize,
  }) {
    final signature = data.readUnsigned32Number().value;
    assert(signature == ColorProfileTagType.icSigCurveType.code);

    data.skip(4);

    final numEntries = data.readUnsigned32Number().value;

    return ColorProfileTagCurve.fromBytesWithSize(
      data,
      numEntries,
      entrySize: entrySize,
    );
  }

  factory ColorProfileTagCurve.fromBytesWithSize(
    DataStream data,
    int numEntries, {
    required int entrySize,
  }) {
    final curveData = generateFloat64List(
      numEntries,
      (_) => entrySize == 1
          ? (data.readUnsigned8Number().value / 255)
          : (data.readUnsigned16Number().value / 65535),
    );
    return ColorProfileTagCurve(curveData);
  }

  @override
  bool get isIdentity {
    if (curve.isEmpty) {
      return true;
    } else if (curve.length == 1 && isUnity(curve[0] * 65535.0 / 256.0)) {
      return true;
    } else {
      final max = _maxIndex;
      for (var i = 0; i < curve.length; ++i) {
        if ((curve[i] - (i / max)).abs() > verySmallNumber) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  double apply(double value) {
    var v = value;
    if (v < 0.0) {
      v = 0;
    } else if (v > 1.0) {
      v = 1;
    }
    if (curve.isEmpty) {
      return v;
    } else if (curve.length == 1) {
      //Convert 0.0 to 1.0 float to 16bit and then convert from u8Fixed8Number
      final dGamma = curve[0] * 65535.0 / 256.0;
      return pow(v, dGamma).toDouble();
    }

    final index = (v * _maxIndex).toInt();
    if (index == _maxIndex) {
      return curve[index];
    }
    final dif = v * _maxIndex - index;
    final p0 = curve[index];
    var rv = p0 + (curve[index + 1] - p0) * dif;
    if (rv > 1) rv = 1;
    return rv;
  }
}
