import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icc_parser/icc_parser.dart';
import 'package:icc_parser/src/types/tag/lut/icc_tag_lut16.dart';
import 'package:icc_parser/src/utils/data_stream.dart';

void main(final List<String> args) {
  final list = File(args[0]).readAsBytesSync();
  final bytes = ByteData.view(list.buffer);
  final firstProfile = IccProfile.fromBytes(bytes);

  print(firstProfile.getNormIlluminantXYZ());

  final stream =
      DataStream(data: bytes, offset: 0, length: bytes.lengthInBytes);

  final aToB0Entry = firstProfile.tagTable.firstWhereOrNull(
    (final element) => element.knownTag == KnownTag.icSigAToB0Tag,
  );
  final aToB0TagData = aToB0Entry?.read(stream);
  print(
      'Found a to b0 entry? ${aToB0Entry != null}. Read as: ${aToB0TagData?.runtimeType}');

  if (aToB0TagData is IccTagLut16) {
    final res = aToB0TagData.clut.interpolate4d([1.0, 0.0, 0.0, 0.0]);
    print(res);
  }
}

// icccmm:2111 to connect profile 1 lab space to profile 2 lab space
