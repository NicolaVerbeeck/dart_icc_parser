import 'package:collection/collection.dart';
import 'package:icc_parser/src/types/color_profile_profile_header.dart';
import 'package:icc_parser/src/types/color_profile_tag_table.dart';
import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag.dart';
import 'package:icc_parser/src/types/tag/color_profile_tags.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

@immutable
final class ColorProfile {
  final DataStream stream;

  final ColorProfileProfileHeader header;
  final ColorProfileTagTable tagTable;

  const ColorProfile(this.stream, this.header, this.tagTable);

  factory ColorProfile.fromBytes(DataStream stream) {
    final header = ColorProfileProfileHeader.fromBytes(stream);
    stream.seek(128); // Total header size is 128 bytes
    final tagTable = ColorProfileTagTable.fromBytes(stream);

    return ColorProfile(stream, header, tagTable);
  }

  List<Signed15Fixed16Number> getNormIlluminantXYZ() {
    return [
      header.illuminant.x,
      header.illuminant.y,
      header.illuminant.z,
    ];
  }

  @override
  String toString() {
    return 'ICCProfile{header: $header, tagTable: $tagTable}';
  }

  ColorProfileTag? findTag(ICCColorProfileTag tag) {
    final entry = tagTable.tags
        .firstWhereOrNull((element) => element.signature.value == tag.code);
    if (entry == null) return null;

    return entry.read(stream);
  }

  bool get isVersion2 => header.version.value == 0x04000000;
}
