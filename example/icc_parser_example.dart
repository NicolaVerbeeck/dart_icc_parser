import 'dart:io';
import 'dart:typed_data';

import 'package:icc_parser/icc_parser.dart';
import 'package:icc_parser/src/tag/lut/icc_tag_lut16.dart';

void main(final List<String> args) {
  final list = File(args[0]).readAsBytesSync();
  final bytes = ByteData.view(list.buffer);
  final awesome = ICCProfile.fromBytes(bytes);

  final tag = awesome.tagTable
      .firstWhere((element) => element.knownTag == KnownTag.AToB0Tag);
  final reading = IccTagLut16();
  reading.read(bytes, offset: tag.offset.value);

  final res = reading.clut.interpolate4d([1.0, 0.0, 0.0, 0.0]);
  print(res);
}

// icccmm:2111 to connect profile 1 lab space to profile 2 lab space
