import 'dart:io';
import 'dart:typed_data';

import 'package:icc_parser/icc_parser.dart';
import 'package:icc_parser/src/cmm/color_profile_transform.dart';
import 'package:icc_parser/src/cmm/enums.dart';
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

  final firstProfile = ColorProfile.fromBytes(firstProfileStream);
  final secondProfile = ColorProfile.fromBytes(secondProfileStream);

  print('Creating output transform');
  final outputTransform = ColorProfileTransform.create(
    profile: secondProfile,
    isInput: false,
    intent: ColorProfileRenderingIntent.perceptual,
    interpolation: ColorProfileInterpolation.tetrahedral,
    lutType: ColorProfileTransformLutType.color,
    useD2BTags: true,
  );
  print('Creating input transform');
  final inputTransform = ColorProfileTransform.create(
    profile: firstProfile,
    isInput: true,
    intent: ColorProfileRenderingIntent.perceptual,
    interpolation: ColorProfileInterpolation.tetrahedral,
    lutType: ColorProfileTransformLutType.color,
    useD2BTags: true,
  );

  print('Converting from cmyk to lab');
  final step1Res = inputTransform.apply([255, 0, 0, 0]);
  print(step1Res);
  print('Converting from lab to rgb');
  final hacked = [0.600877166, 0.363889456, 0.339949101];
  final step2Res = outputTransform.apply(hacked);
  print(step2Res);
  print(step2Res.map((e) => (e * 255).toInt()).toList());
}

// icccmm:2111 to connect profile 1 lab space to profile 2 lab space
