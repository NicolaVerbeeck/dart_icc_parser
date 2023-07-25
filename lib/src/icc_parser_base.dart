import 'dart:typed_data';

import 'package:icc_parser/src/types/icc_profile_header.dart';
import 'package:icc_parser/src/types/icc_tag_table.dart';
import 'package:icc_parser/src/types/primitive.dart';
import 'package:meta/meta.dart';

@immutable
final class IccProfile {
  final ICCProfileHeader header;
  final IccTagTable tagTable;

  const IccProfile(this.header, this.tagTable);

  factory IccProfile.fromBytes(final ByteData bytes, {final int offset = 0}) {
    return IccProfile(
      ICCProfileHeader.fromBytes(bytes, offset: offset),
      IccTagTable.fromBytes(bytes, offset: offset + 128),
    );
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
}
