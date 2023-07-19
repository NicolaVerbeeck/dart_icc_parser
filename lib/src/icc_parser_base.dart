import 'dart:typed_data';

import 'package:icc_parser/src/types/icc_profile_header.dart';
import 'package:icc_parser/src/types/icc_tag_table.dart';
import 'package:meta/meta.dart';

@immutable
final class ICCProfile {
  final ICCProfileHeader header;
  final ICCTagTable tagTable;

  const ICCProfile(this.header, this.tagTable);

  factory ICCProfile.fromBytes(final ByteData bytes, {final int offset = 0}) {
    return ICCProfile(
      ICCProfileHeader.fromBytes(bytes, offset: offset),
      ICCTagTable.fromBytes(bytes, offset: offset + 128),
    );
  }

  @override
  String toString() {
    return 'ICCProfile{header: $header, tagTable: $tagTable}';
  }
}
