import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icc_parser/icc_parser.dart';
import 'package:icc_parser/src/types/color_profile_tag_entry.dart';
import 'package:icc_parser/src/types/color_profile_tag_table.dart';
import 'package:icc_parser/src/types/tag/color_profile_tags.dart';

void main(List<String> args) {
  if (args.length < 3) {
    print('Usage: icc_shrinker <input> <output> <tag1> <tag2> ...');
    exit(1);
  }
  final input = File(args[0]).readAsBytesSync();

  final stream = DataStream(
    data: ByteData.view(input.buffer),
    length: input.length,
    offset: 0,
  );
  final profile = ColorProfile.fromBytes(stream);

  final output = File(args[1]);
  final tagsToKeep = args
      .sublist(2)
      .map((e) =>
          ICCColorProfileTag.values.firstWhere((element) => element.name == e))
      .toSet();

  final tagTable = profile.tagTable;
  final tagDataTable = <ColorProfileTagEntry, Uint8List>{};
  for (final tag in tagsToKeep) {
    final entry = tagTable.tags
        .firstWhereOrNull((element) => element.signature.value == tag.code);
    if (entry == null) {
      continue;
    }
    stream.seek(entry.offset.value);
    final data = stream.readBytes(entry.elementSize.value);
    tagDataTable[entry] = data;
  }

  // Create new profile
  final newProfile = ColorProfile(
    stream,
    profile.header,
    ColorProfileTagTable(
      tagDataTable.keys.toList(),
    ),
  );
  final data = newProfile.write();
  output.writeAsBytesSync(data);
}
