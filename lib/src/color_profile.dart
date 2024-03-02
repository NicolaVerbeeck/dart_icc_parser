import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icc_parser/src/cmm/enums.dart';
import 'package:icc_parser/src/types/color_profile_header.dart';
import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:icc_parser/src/types/color_profile_tag_table.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag.dart';
import 'package:icc_parser/src/types/tag/color_profile_tags.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

/// A color profile.
///
/// Note: Color profiles hold on the the [stream] that was used to create them
/// to support lazy loading the right data when creating transformations
@immutable
class ColorProfile {
  /// The stream that was used to create this color profile.
  final DataStream stream;

  /// The header of the color profile.
  final ColorProfileHeader header;

  /// The tag table of the color profile
  final ColorProfileTagTable tagTable;

  /// Creates a new color profile.
  const ColorProfile(this.stream, this.header, this.tagTable);

  /// Creates a new color profile by parsing it from the given [stream].
  ///
  /// Note: [stream] is retained by the created color profile.
  factory ColorProfile.fromBytes(DataStream stream) {
    final header = ColorProfileHeader.fromBytes(stream);
    stream.seek(128); // Total header size is 128 bytes
    final tagTable = ColorProfileTagTable.fromBytes(stream);

    return ColorProfile(stream, header, tagTable);
  }

  /// Gets the XYZ values of the profile's illuminant.
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

  /// Gets and parses the tag with the given [tag] code.
  ///
  /// If the tag is not found in the file, `null` is returned.
  ///
  /// Note that not all tags are supported yet and will throw an exception of
  /// it cannot be parsed
  ColorProfileTag? findTag(ICCColorProfileTag tag) {
    final entry = tagTable.tags
        .firstWhereOrNull((element) => element.signature.value == tag.code);
    if (entry == null) return null;

    return entry.read(stream);
  }

  /// Returns if this profile is version 2 or not.
  bool get isVersion2 => header.version.value < 0x04000000;

  /// Returns the illuminant of this profile.
  ColorProfileIlluminant get illuminant => ColorProfileIlluminant.illuminantD50;

  /// Returns the observer of this profile.
  ColorProfileStandardObserver get pccObserver =>
      ColorProfileStandardObserver.standardObserver1931TwoDegrees;

  /// Writes the profile to a byte array.
  Uint8List write() {
    var size = 128 + 4 + tagTable.length * 12;
    for (final tag in tagTable.tags) {
      size += tag.elementSize.value;
    }
    final data = ByteData(size);
    header.toBytes(data, 0);

    tagTable.toBytes(data, 128);
    var offset = 128 + 4 + tagTable.length * 12;
    for (final tag in tagTable.tags) {
      stream.seek(tag.offset.value);
      final list = stream.readBytes(tag.elementSize.value);
      data.buffer.asUint8List(offset, tag.elementSize.value).setAll(0, list);
      offset += tag.elementSize.value;
    }
    data.setUint32(0, offset); // Update total size

    return Uint8List.view(data.buffer);
  }
}
