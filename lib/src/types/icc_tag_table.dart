import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:icc_parser/src/types/tag_entry.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
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

  /// Creates a new [IccTagTable] from the given [bytes].
  /// [bytes] must hold at least 4 bytes.
  factory IccTagTable.fromBytes(DataStream bytes) {
    final tagCount = bytes.readUnsigned32Number();
    final tagTable = List<IccTagEntry>.generate(
      tagCount.value,
      (_) => IccTagEntry.fromBytes(bytes),
    );
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
