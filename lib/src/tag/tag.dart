import 'dart:typed_data';

import 'package:icc_parser/src/tag/known_tags.dart';
import 'package:icc_parser/src/tag/tag_type.dart';
import 'package:icc_parser/src/types/built_in.dart';
import 'package:meta/meta.dart';

/// ICC tag
@immutable
final class ICCTag {
  /// Tag signature
  final Unsigned32Number signature;

  /// Offset from the beginning of the profile to the first byte of the tag data
  final Unsigned32Number offset;

  /// Size of the tag data element in bytes
  final Unsigned32Number elementSize;

  KnownTag? get knownTag => tagFromInt(signature);

  TagType? tagType(final ByteData bytes, {final int offset = 0}) {
    return tagTypeFromInt(
      Unsigned32Number.fromBytes(bytes, offset: offset + this.offset.value),
    );
  }

  /// Creates ICC tag with the given [signature], [offset] and [elementSize].
  const ICCTag({
    required this.signature,
    required this.offset,
    required this.elementSize,
  });

  /// Creates a new [ICCTag] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 12 bytes starting at [offset].
  factory ICCTag.fromBytes(final ByteData bytes, {final int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 12);
    return ICCTag(
      signature: Unsigned32Number.fromBytes(bytes, offset: offset),
      offset: Unsigned32Number.fromBytes(bytes, offset: offset + 4),
      elementSize: Unsigned32Number.fromBytes(bytes, offset: offset + 8),
    );
  }

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is ICCTag &&
          runtimeType == other.runtimeType &&
          signature == other.signature &&
          offset == other.offset &&
          elementSize == other.elementSize;

  @override
  int get hashCode =>
      signature.hashCode ^ offset.hashCode ^ elementSize.hashCode;

  @override
  String toString() {
    return 'ICCTag{signature: $signature, offset: $offset,'
        ' elementSize: $elementSize, knownTag: $knownTag}';
  }
}
