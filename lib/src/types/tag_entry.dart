import 'dart:typed_data';

import 'package:icc_parser/icc_parser.dart';
import 'package:icc_parser/src/types/tag/icc_tag.dart';
import 'package:icc_parser/src/types/tag/tag_type.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

/// ICC tag entry in the [IccTagTable]
@immutable
final class IccTagEntry {
  /// Tag signature
  final Unsigned32Number signature;

  /// Offset from the beginning of the profile to the first byte of the tag data
  final Unsigned32Number offset;

  /// Size of the tag data element in bytes
  final Unsigned32Number elementSize;

  KnownTag? get knownTag => tagFromInt(signature);

  KnownTagType? tagType(ByteData bytes, {int offset = 0}) {
    return tagTypeFromInt(
      Unsigned32Number.fromBytes(bytes, offset: offset + this.offset.value),
    );
  }

  /// Creates ICC tag with the given [signature], [offset] and [elementSize].
  const IccTagEntry({
    required this.signature,
    required this.offset,
    required this.elementSize,
  });

  /// Creates a new [IccTagEntry] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 12 bytes starting at [offset].
  factory IccTagEntry.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 12);
    return IccTagEntry(
      signature: Unsigned32Number.fromBytes(bytes, offset: offset),
      offset: Unsigned32Number.fromBytes(bytes, offset: offset + 4),
      elementSize: Unsigned32Number.fromBytes(bytes, offset: offset + 8),
    );
  }

  IccTag read(DataStream data) {
    data.seek(offset.value);
    return IccTag.fromBytes(data, size: elementSize.value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IccTagEntry &&
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
