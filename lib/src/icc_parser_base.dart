// ignore_for_file: avoid_final_parameters

import 'package:collection/collection.dart';
import 'package:icc_parser/src/types/icc_profile_header.dart';
import 'package:icc_parser/src/types/icc_tag_table.dart';
import 'package:icc_parser/src/types/primitive.dart';
import 'package:icc_parser/src/types/tag/icc_tag.dart';
import 'package:icc_parser/src/types/tag/known_tags.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

@immutable
final class IccProfile {
  final DataStream stream;

  final ICCProfileHeader header;
  final IccTagTable tagTable;

  const IccProfile(this.stream, this.header, this.tagTable);

  factory IccProfile.fromBytes(final DataStream stream) {
    final header = ICCProfileHeader.fromBytes(stream);
    stream.seek(128); // Total header size is 128 bytes
    final tagTable = IccTagTable.fromBytes(stream);

    return IccProfile(stream, header, tagTable);
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

  IccTag? findTag(KnownTag tag) {
    final entry = tagTable.tags
        .firstWhereOrNull((element) => element.signature.value == tag.code);
    if (entry == null) return null;

    return entry.read(stream);
  }

  bool get isVersion2 => header.version.value == 0x04000000;
}
