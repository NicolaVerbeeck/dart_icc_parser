import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icc_parser/icc_parser.dart';
import 'package:icc_parser/src/cmm/icc_transform.dart';
import 'package:icc_parser/src/types/tag/lut/icc_tag_lut16.dart';
import 'package:icc_parser/src/utils/data_stream.dart';

void main(List<String> args) {
  final firstProfileBytes =
      ByteData.view(File(args[0]).readAsBytesSync().buffer);
  final secondProfileBytes =
      ByteData.view(File(args[1]).readAsBytesSync().buffer);

  final firstProfileStream = DataStream(
      data: firstProfileBytes,
      offset: 0,
      length: firstProfileBytes.lengthInBytes);
  final secondProfileStream = DataStream(
      data: secondProfileBytes,
      offset: 0,
      length: secondProfileBytes.lengthInBytes);

  final firstProfile = IccProfile.fromBytes(firstProfileStream);
  final secondProfile = IccProfile.fromBytes(secondProfileStream);

  print('Creating output transform');
  final outputTransform = IccTransform.create(
    profile: secondProfile,
    isInput: false,
    intent: IccRenderingIntent.perceptual,
    interpolation: IccInterpolation.tetrahedral,
    lutType: IccTransformLutType.color,
    useD2BTags: true,
  );
  print('Creating input transform');
  final inputTransform = IccTransform.create(
    profile: firstProfile,
    isInput: true,
    intent: IccRenderingIntent.perceptual,
    interpolation: IccInterpolation.tetrahedral,
    lutType: IccTransformLutType.color,
    useD2BTags: true,
  );


  final aToB0Entry = firstProfile.tagTable.firstWhereOrNull(
    (element) => element.knownTag == KnownTag.icSigAToB0Tag,
  );
  final aToB0TagData = aToB0Entry?.read(firstProfileStream);
  print(
      'Found a to b0 entry? ${aToB0Entry != null}. Read as: ${aToB0TagData?.runtimeType}');

  if (aToB0TagData is IccTagLut16) {
    final res = aToB0TagData.clut.interpolate4d([1.0, 0.0, 0.0, 0.0]);
    print(res);
  }
}

// icccmm:2111 to connect profile 1 lab space to profile 2 lab space
