import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icc_parser/src/cmm/color_profile_cmm.dart';
import 'package:icc_parser/src/cmm/color_profile_transform.dart';
import 'package:icc_parser/src/cmm/enums.dart';
import 'package:icc_parser/src/color_profile.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:test/test.dart';

void main() {
  group('ColorProfileCmm tests', () {
    test('Test convert cmyk to rgb', () {
      final files = [
        'test/resources/JapanColor2011Coated.icc',
        'test/resources/sRGB_v4_ICC_preference.icc'
      ];
      final transformations = files.mapIndexed((index, e) {
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
      var col = cmm.apply(
          finalTransformations, Float64List.fromList([0.0, 0.0, 0, 0]));
      expect(_toRGBByte(col), [255, 255, 255]);
      col = cmm.apply(finalTransformations,
          Float64List.fromList([0.0, 7 / 255, 246 / 255, 159 / 255]));
      expect(_toRGBByte(col), [147, 147, 30]);
      col = cmm.apply(
          finalTransformations, Float64List.fromList([255 / 255, 0, 0, 0]));
      expect(_toRGBByte(col), [18, 208, 254]);
    });
  });
}

List<int> _toRGBByte(Float64List list) {
  return list.map((e) => (e * 255).round().clamp(0, 255)).toList();
}
