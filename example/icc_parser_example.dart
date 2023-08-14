import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icc_parser/icc_parser.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print("Usage: dart icc_parser_example.dart <cmyk_icc_file> [icc_file ...]");
    exit(1);
  }
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

  printColor(
      cmm.apply(finalTransformations, Float64List.fromList([0, 0, 0, 0])));
  printColor(cmm.apply(
      finalTransformations, Float64List.fromList([0.2, 0.63, 0.45, 0.06])));
  printColor(
      cmm.apply(finalTransformations, Float64List.fromList([0, 0, 0, 1])));
}

void printColor(List<double> color) {
  print(color.map((e) => (e * 255).round().clamp(0, 255)).toList());
}
