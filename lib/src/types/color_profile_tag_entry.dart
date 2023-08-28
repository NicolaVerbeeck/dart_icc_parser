import 'dart:typed_data';

import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:icc_parser/src/types/color_profile_tag_table.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag_type.dart';
import 'package:icc_parser/src/types/tag/color_profile_tags.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

/// ICC tag entry in the [ColorProfileTagTable]
@immutable
final class ColorProfileTagEntry {
  /// Tag signature
  final Unsigned32Number signature;

  /// Offset from the beginning of the profile to the first byte of the tag data
  final Unsigned32Number offset;

  /// Size of the tag data element in bytes
  final Unsigned32Number elementSize;

  /// Parse the signature to a known [ICCColorProfileTag] if it is known
  ICCColorProfileTag? get knownTag => parseICCColorProfileTag(signature);

  /// Reads and tries to parse the tag type from the given [bytes] with extra
  /// [offset]. If the tag type is not supported, returns `null`.
  ColorProfileTagType? tagType(ByteData bytes, {int offset = 0}) {
    return tagTypeFromInt(
      Unsigned32Number.fromBytes(bytes, offset: offset + this.offset.value),
    );
  }

  /// Creates ICC tag with the given [signature], [offset] and [elementSize].
  const ColorProfileTagEntry({
    required this.signature,
    required this.offset,
    required this.elementSize,
  });

  /// Creates a new [ColorProfileTagEntry] from the given [bytes].
  /// [bytes] must hold at least 12 bytes.
  factory ColorProfileTagEntry.fromBytes(DataStream bytes) {
    return ColorProfileTagEntry(
      signature: bytes.readUnsigned32Number(),
      offset: bytes.readUnsigned32Number(),
      elementSize: bytes.readUnsigned32Number(),
    );
  }

  /// Read and create a [ColorProfileTag] from the given [data].
  ColorProfileTag read(DataStream data) {
    data.seek(offset.value);
    return ColorProfileTag.fromBytes(data, size: elementSize.value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorProfileTagEntry &&
          runtimeType == other.runtimeType &&
          signature == other.signature &&
          offset == other.offset &&
          elementSize == other.elementSize;

  @override
  int get hashCode =>
      signature.hashCode ^ offset.hashCode ^ elementSize.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'ICCTag{signature: $signature, offset: $offset,'
        ' elementSize: $elementSize, knownTag: $knownTag}';
  }
// coverage:ignore-end
}
