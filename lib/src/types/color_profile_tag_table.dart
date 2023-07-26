import 'dart:collection';

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
  int get hashCode => tags.hashCode;

  @override
  String toString() {
    return 'ICCTagTable{tags: $tags}';
  }
}
