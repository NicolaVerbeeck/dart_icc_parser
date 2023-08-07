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

  const iterations = 8000*8000;
  final sw = Stopwatch()..start();
  for (var i = 0; i < iterations; ++i) {
    cmm.apply(finalTransformations, convert([0, 0, 0, 0]));
  }
  final el = sw.elapsedMilliseconds;
  print('Elapsed: $el ms, ${el / iterations} ms per iteration');
  sw.stop();
}

// icccmm:2111 to connect profile 1 lab space to profile 2 lab space

void printColor(List<double> color) {
  print(color.map((e) => (e * 255).toInt()).toList());
}

Float64List convert(List<double> e) {
  return Float64List.fromList([
    e[0] / 255,
    e[1] / 255,
    e[2] / 255,
    e[3] / 255,
  ]);
}
