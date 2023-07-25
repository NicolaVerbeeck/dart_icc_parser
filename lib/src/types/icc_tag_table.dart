import 'dart:collection';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icc_parser/src/types/primitive.dart';
import 'package:icc_parser/src/types/tag_entry.dart';
import 'package:meta/meta.dart';

/// ICC tag table
@immutable
final class IccTagTable
    with ListMixin<IccTagEntry>
    implements List<IccTagEntry> {
  /// List of tags in the table
  final List<IccTagEntry> tags;

  @override
  int get length => tags.length;

  /// Creates ICC tag table with the given [tags].
  const IccTagTable(this.tags);

  /// Creates a new [IccTagTable] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 4 bytes starting at [offset].
  factory IccTagTable.fromBytes(ByteData bytes, {int offset = 0}) {
    final tagCount = Unsigned32Number.fromBytes(bytes, offset: offset);
    final tagTable = <IccTagEntry>[];
    for (var i = 0; i < tagCount.value; ++i) {
      final tagOffset = offset + 4 + (i * 12);
      tagTable.add(IccTagEntry.fromBytes(bytes, offset: tagOffset));
    }
    return IccTagTable(tagTable);
  }

  @override
  IccTagEntry operator [](int index) => tags[index];

  @override
  void operator []=(int index, IccTagEntry value) =>
      throw ArgumentError('ICCTagTable is immutable');

  @override
  set length(int newLength) => throw ArgumentError('ICCTagTable is immutable');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IccTagTable &&
          runtimeType == other.runtimeType &&
          const DeepCollectionEquality().equals(tags, other.tags);

  @override
  int get hashCode => tags.hashCode;

  @override
  String toString() {
    return 'ICCTagTable{tags: $tags}';
  }
}
