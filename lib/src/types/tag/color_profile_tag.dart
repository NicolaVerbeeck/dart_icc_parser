import 'package:icc_parser/src/types/tag/curve/color_profile_curve.dart';
import 'package:icc_parser/src/types/tag/lut/color_profile_tag_lut16.dart';
import 'package:icc_parser/src/types/tag/lut/color_profile_tag_lut8.dart';
import 'package:icc_parser/src/types/tag/lut/color_profile_tag_lut_a_to_b.dart';
import 'package:icc_parser/src/types/tag/lut/color_profile_tag_lut_b_to_a.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag_type.dart';
import 'package:icc_parser/src/utils/data_stream.dart';

abstract interface class ColorProfileTag {
  ColorProfileTagType get type;

  factory ColorProfileTag.fromBytes(
    DataStream stream, {
    required int size,
  }) {
    final pos = stream.position;
    final signature = stream.readUnsigned32Number();
    stream.seek(pos);

    switch (tagTypeFromInt(signature)) {
      case ColorProfileTagType.icSigCurveType:
      case ColorProfileTagType.icSigParametricCurveType:
        return ColorProfileCurve.fromBytes(stream, size: size);
      case ColorProfileTagType.icSigLut8Type:
        return ColorProfileTagLut8.fromBytes(stream);
      case ColorProfileTagType.icSigLut16Type:
        return ColorProfileTagLut16.fromBytes(stream);
      case ColorProfileTagType.icSigLutAtoBType:
        return ColorProfileTagLutAToB.fromBytes(stream, size: size);
      case ColorProfileTagType.icSigLutBtoAType:
        return ColorProfileTagLutBToA.fromBytes(stream, size: size);
      //ignore: no_default_cases
      default:
        throw Exception('Unsupported tag type: $signature');
    }
  }
}
