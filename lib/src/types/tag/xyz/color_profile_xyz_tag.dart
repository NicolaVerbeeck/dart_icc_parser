import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag_type.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

@immutable
class ColorProfileXYZTag implements ColorProfileTag {
  final List<XYZNumber> xyz;

  @override
  ColorProfileTagType get type => ColorProfileTagType.icSigXYZType;

  const ColorProfileXYZTag(this.xyz);

  factory ColorProfileXYZTag.fromBytes(
    DataStream bytes, {
    required int size,
  }) {
    final xyz = <XYZNumber>[];

    assert(bytes.readUnsigned32Number().value ==
        ColorProfileTagType.icSigXYZType.code);
    bytes.skip(4); // reserved

    final num = (size - 2 * 4) ~/ 12;

    for (var i = 0; i < num; ++i) {
      xyz.add(bytes.readXYZNumber());
    }
    return ColorProfileXYZTag(xyz);
  }
}
