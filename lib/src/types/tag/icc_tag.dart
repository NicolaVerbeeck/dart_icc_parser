import 'package:icc_parser/src/types/tag/curve/icc_curve.dart';
import 'package:icc_parser/src/types/tag/lut/icc_tag_lut16.dart';
import 'package:icc_parser/src/types/tag/lut/icc_tag_lut8.dart';
import 'package:icc_parser/src/types/tag/lut/icc_tag_lut_a_to_b.dart';
import 'package:icc_parser/src/types/tag/lut/icc_tag_lut_b_to_a.dart';
import 'package:icc_parser/src/types/tag/tag_type.dart';
import 'package:icc_parser/src/utils/data_stream.dart';

abstract interface class IccTag {
  factory IccTag.fromBytes(
    DataStream stream, {
    required int size,
  }) {
    final pos = stream.position;
    final signature = stream.readUnsigned32Number();
    stream.seek(pos);

    switch (tagTypeFromInt(signature)) {
      case KnownTagType.icSigCurveType:
      case KnownTagType.icSigParametricCurveType:
        return IccCurve.fromBytes(stream, size: size);
      case KnownTagType.icSigLut8Type:
        return IccTagLut8.fromBytes(stream);
      case KnownTagType.icSigLut16Type:
        return IccTagLut16.fromBytes(stream);
      case KnownTagType.icSigLutAtoBType:
        return IccTagLutAToB.fromBytes(stream, size: size);
      case KnownTagType.icSigLutBtoAType:
        return IccTagLutBToA.fromBytes(stream, size: size);
      //ignore: no_default_cases
      default:
        throw Exception('Unsupported tag type: $signature');
    }
  }
}
