import 'dart:collection';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icc_parser/src/tag/tag.dart';
import 'package:icc_parser/src/types/built_in.dart';
import 'package:meta/meta.dart';

/// ICC tag table
@immutable
final class ICCTagTable with ListMixin<ICCTag> implements List<ICCTag> {
  /// List of tags in the table
  final List<ICCTag> tags;

  @override
  int get length => tags.length;

  /// Creates ICC tag table with the given [tags].
  const ICCTagTable(this.tags);

  /// Creates a new [ICCTagTable] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 4 bytes starting at [offset].
  factory ICCTagTable.fromBytes(final ByteData bytes, {final int offset = 0}) {
    final tagCount = Unsigned32Number.fromBytes(bytes, offset: offset);
    final tagTable = <ICCTag>[];
    for (var i = 0; i < tagCount.value; ++i) {
      final tagOffset = offset + 4 + (i * 12);
      tagTable.add(ICCTag.fromBytes(bytes, offset: tagOffset));
    }
    return ICCTagTable(tagTable);
  }

  @override
  ICCTag operator [](final int index) => tags[index];

  @override
  void operator []=(final int index, final ICCTag value) =>
      throw ArgumentError('ICCTagTable is immutable');

  @override
  set length(final int newLength) =>
      throw ArgumentError('ICCTagTable is immutable');

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is ICCTagTable &&
          runtimeType == other.runtimeType &&
          const DeepCollectionEquality().equals(tags, other.tags);

  @override
  int get hashCode => tags.hashCode;

  @override
  String toString() {
    return 'ICCTagTable{tags: $tags}';
  }
}
