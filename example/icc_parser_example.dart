import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icc_parser/icc_parser.dart';
import 'package:icc_parser/src/cmm/color_profile_cmm.dart';

void main(List<String> args) {
  final transformations = args.mapIndexed((index, e) {
    final bytes = ByteData.view(File(e).readAsBytesSync().buffer);
    final stream =
        DataStream(data: bytes, offset: 0, length: bytes.lengthInBytes);
    final profile = ColorProfile.fromBytes(stream);
    return ColorProfileTransform.create(
      profile: profile,
      isInput: index == 0,
      intent: ColorProfileRenderingIntent.perceptual,
      interpolation: ColorProfileInterpolation.tetrahedral,
      lutType: ColorProfileTransformLutType.color,
      useD2BTags: true,
    );
  }).toList();
  final cmm = ColorProfileCmm();

  final finalTransformations = cmm.buildTransformations(transformations);
  print("Got transformations: $finalTransformations");
  printColor(cmm.apply(finalTransformations, [255, 0, 0, 0]));
  printColor(cmm.apply(finalTransformations, [0, 255, 0, 0]));
  printColor(cmm.apply(finalTransformations, [0, 0, 255, 0]));
  printColor(cmm.apply(finalTransformations, [0, 0, 0, 255]));
}

// icccmm:2111 to connect profile 1 lab space to profile 2 lab space

void printColor(List<double> color) {
  print(color.map((e) => (e * 255).toInt()).toList());
}