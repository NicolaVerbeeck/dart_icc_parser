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
    print('Loading from $e');
    return ColorProfileTransform.create(
      profile: profile,
      isInput: index == 0,
      intent: ColorProfileRenderingIntent.icRelativeColorimetric,
      interpolation: ColorProfileInterpolation.tetrahedral,
      lutType: ColorProfileTransformLutType.color,
      useD2BTags: true,
    );
  }).toList();
  final reverseTransformations = args.reversed.mapIndexed((index, e) {
    final bytes = ByteData.view(File(e).readAsBytesSync().buffer);
    final stream =
        DataStream(data: bytes, offset: 0, length: bytes.lengthInBytes);
    final profile = ColorProfile.fromBytes(stream);
    return ColorProfileTransform.create(
      profile: profile,
      isInput: index == 0,
      intent: ColorProfileRenderingIntent.icRelativeColorimetric,
      interpolation: ColorProfileInterpolation.tetrahedral,
      lutType: ColorProfileTransformLutType.color,
      useD2BTags: true,
    );
  }).toList();

  final cmm = ColorProfileCmm();
  final reverseCMM = ColorProfileCmm();

  final finalTransformations = cmm.buildTransformations(transformations);
  final finalReverseTransformations =
      reverseCMM.buildTransformations(reverseTransformations);
  print("Got transformations: $finalTransformations");
  print("Got reverse transformations: $finalReverseTransformations");

  final input1CMYK = Float64List.fromList([0.16, 0.32, 1, 0.61]);
  final input2CMYK = Float64List.fromList([0.2, 0.63, 0.45, 0.06]);
  final input3CMYK = Float64List.fromList([0, 0, 0, 1]);

  final col1 = cmm.apply(finalTransformations, input1CMYK);
  final col2 = cmm.apply(finalTransformations, input2CMYK);
  final col3 = cmm.apply(finalTransformations, input3CMYK);

  printColor(col1);
  printColor(col2);
  printColor(col3);

  printColor(cmm.apply(finalTransformations.sublist(1),
      Float64List.fromList([0.72, 0.4784, 0.30196])));

  print('Control ->');
  printFloatColor(input1CMYK);
  printFloatColor(input2CMYK);
  printFloatColor(input3CMYK);

  print('Reverse ->');

  printFloatColor(reverseCMM.apply(finalReverseTransformations, col1));
  printFloatColor(reverseCMM.apply(finalReverseTransformations, col2));
  printFloatColor(reverseCMM.apply(finalReverseTransformations, col3));
}

void printColor(List<double> color) {
  print(color.map((e) => (e * 255).round().clamp(0, 255)).toList());
}

void printFloatColor(List<double> color) {
  print(color);
}
