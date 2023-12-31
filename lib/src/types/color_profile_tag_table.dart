import 'dart:collection';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icc_parser/src/types/color_profile_tag_entry.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

/// ICC tag table
@immutable
final class ColorProfileTagTable
    with ListMixin<ColorProfileTagEntry>
    implements List<ColorProfileTagEntry> {
  /// List of tags in the table
  final List<ColorProfileTagEntry> tags;

  @override
  int get length => tags.length;

  /// Creates ICC tag table with the given [tags].
  const ColorProfileTagTable(this.tags);

  /// Creates a new [ColorProfileTagTable] from the given [bytes].
  /// [bytes] must hold at least 4 bytes.
  factory ColorProfileTagTable.fromBytes(DataStream bytes) {
    final tagCount = bytes.readUnsigned32Number();
    final tagTable = List<ColorProfileTagEntry>.generate(
      tagCount.value,
      (_) => ColorProfileTagEntry.fromBytes(bytes),
    );
    return ColorProfileTagTable(tagTable);
  }

  @override
  ColorProfileTagEntry operator [](int index) => tags[index];

  @override
  void operator []=(int index, ColorProfileTagEntry value) =>
      throw ArgumentError('ICCTagTable is immutable');

  @override
  set length(int newLength) => throw ArgumentError('ICCTagTable is immutable');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorProfileTagTable &&
          runtimeType == other.runtimeType &&
          const DeepCollectionEquality().equals(tags, other.tags);

  @override
  int get hashCode => const DeepCollectionEquality().hash(tags);

  // coverage:ignore-start
  @override
  String toString() {
    return 'ICCTagTable{tags: $tags}';
  }
  // coverage:ignore-end

  void toBytes(ByteData data, int offset) {
    data.setUint32(offset, tags.length);
    var tagOffset = offset + 4 + tags.length * 12;
    for (var i = 0; i < tags.length; ++i) {
      final tag = tags[i];

      final tagWriteOffset = offset + 4 + i * 12;

      data.setUint32(tagWriteOffset, tag.signature.value);
      data.setUint32(tagWriteOffset + 4, tagOffset);
      data.setUint32(tagWriteOffset + 8, tag.elementSize.value);
      tagOffset += tag.elementSize.value;
    }
  }
}
