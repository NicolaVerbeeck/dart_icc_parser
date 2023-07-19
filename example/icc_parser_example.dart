import 'dart:io';
import 'dart:typed_data';

import 'package:icc_parser/icc_parser.dart';

void main(final List<String> args) {
  final list = File(args[0]).readAsBytesSync();
  final bytes = ByteData.view(list.buffer);
  final awesome = ICCProfile.fromBytes(bytes);

  for (final tag in awesome.tagTable){
    print(tag.knownTag);
    print('\t${tag.tagType(bytes)}');
  }
}
