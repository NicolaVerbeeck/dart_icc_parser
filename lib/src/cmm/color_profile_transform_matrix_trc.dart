import 'dart:typed_data';

import 'package:icc_parser/src/cmm/color_profile_cmm.dart';
import 'package:icc_parser/src/cmm/color_profile_transform.dart';
import 'package:icc_parser/src/color_profile.dart';
import 'package:icc_parser/src/types/color_profile_header.dart';
import 'package:icc_parser/src/types/tag/color_profile_tags.dart';
import 'package:icc_parser/src/types/tag/curve/color_profile_curve.dart';
import 'package:icc_parser/src/types/tag/curve/color_profile_tag_curve.dart';
import 'package:icc_parser/src/types/tag/xyz/color_profile_xyz_tag.dart';
import 'package:icc_parser/src/utils/list_utils.dart';
import 'package:icc_parser/src/utils/num_utils.dart';
import 'package:meta/meta.dart';

@immutable
final class ColorProfileTransformMatrixTRC extends ColorProfileTransform {
  final List<ColorProfileCurve>? curves;
  final Float64List matrix;

  const ColorProfileTransformMatrixTRC({
    required super.profile,
    required super.doAdjustPCS,
    required super.isInput,
    required super.pcsScale,
    required super.pcsOffset,
    required this.curves,
    required this.matrix,
  });

  factory ColorProfileTransformMatrixTRC.create({
    required ColorProfile profile,
    required bool doAdjustPCS,
    required bool isInput,
    required Float64List? pcsScale,
    required Float64List? pcsOffset,
  }) {
    final matrix = Float64List(9);
    final curves = <ColorProfileCurve>[];

    var xyz = _getColumn(profile, ICCColorProfileTag.icSigRedMatrixColumnTag);
    if (xyz == null) {
      throw Exception('Missing required tag: icSigRedMatrixColumnTag');
    }
    matrix[0] = xyz.xyz[0].x.value;
    matrix[3] = xyz.xyz[0].y.value;
    matrix[6] = xyz.xyz[0].z.value;

    xyz = _getColumn(profile, ICCColorProfileTag.icSigGreenMatrixColumnTag);
    if (xyz == null) {
      throw Exception('Missing required tag: icSigRedMatrixColumnTag');
    }
    matrix[1] = xyz.xyz[0].x.value;
    matrix[4] = xyz.xyz[0].y.value;
    matrix[7] = xyz.xyz[0].z.value;

    xyz = _getColumn(profile, ICCColorProfileTag.icSigBlueMatrixColumnTag);
    if (xyz == null) {
      throw Exception('Missing required tag: icSigRedMatrixColumnTag');
    }
    matrix[2] = xyz.xyz[0].x.value;
    matrix[5] = xyz.xyz[0].y.value;
    matrix[8] = xyz.xyz[0].z.value;

    if (isInput) {
      curves.add(_getCurve(profile, ICCColorProfileTag.icSigRedTRCTag));
      curves.add(_getCurve(profile, ICCColorProfileTag.icSigGreenTRCTag));
      curves.add(_getCurve(profile, ICCColorProfileTag.icSigBlueTRCTag));
    } else {
      if (profile.header.pcs.value != ColorSpaceSignature.icSigXYZData.code) {
        throw Exception('Bad space link');
      }
      curves.add(_getInvCurve(profile, ICCColorProfileTag.icSigRedTRCTag));
      curves.add(_getInvCurve(profile, ICCColorProfileTag.icSigGreenTRCTag));
      curves.add(_getInvCurve(profile, ICCColorProfileTag.icSigBlueTRCTag));

      _invertMatrix(matrix);
    }
    return ColorProfileTransformMatrixTRC(
      profile: profile,
      doAdjustPCS: doAdjustPCS,
      isInput: isInput,
      pcsScale: pcsScale,
      pcsOffset: pcsOffset,
      curves:
          (curves[0].isIdentity && curves[1].isIdentity && curves[2].isIdentity)
              ? null
              : curves,
      matrix: matrix,
    );
  }

  @override
  Float64List apply(Float64List source, ColorProfileTransformationStep step) {
    final sourcePixel = checkSourceAbsolute(source, step);
    final pixel = sourcePixel.copy();

    if (isInput) {
      final applyCurve = curves;
      final linR = applyCurve == null ? pixel[0] : applyCurve[0].find(pixel[0]);
      final linG = applyCurve == null ? pixel[1] : applyCurve[1].find(pixel[1]);
      final linB = applyCurve == null ? pixel[2] : applyCurve[2].find(pixel[2]);

      pixel[0] =
          xyzScale(matrix[0] * linR + matrix[1] * linG + matrix[2] * linB);
      pixel[1] =
          xyzScale(matrix[3] * linR + matrix[4] * linG + matrix[5] * linB);
      pixel[2] =
          xyzScale(matrix[6] * linR + matrix[7] * linG + matrix[8] * linB);
    } else {
      final x = xyzDescale(pixel[0]);
      final y = xyzDescale(pixel[1]);
      final z = xyzDescale(pixel[2]);

      final applyCurve = curves;
      if (applyCurve != null) {
        pixel[0] = rgbClip(
            matrix[0] * x + matrix[1] * y + matrix[2] * z, applyCurve[0]);
        pixel[1] = rgbClip(
            matrix[3] * x + matrix[4] * y + matrix[5] * z, applyCurve[1]);
        pixel[2] = rgbClip(
            matrix[6] * x + matrix[7] * y + matrix[8] * z, applyCurve[2]);
      } else {
        pixel[0] = matrix[0] * x + matrix[1] * y + matrix[2] * z;
        pixel[1] = matrix[3] * x + matrix[4] * y + matrix[5] * z;
        pixel[2] = matrix[6] * x + matrix[7] * y + matrix[8] * z;
      }
    }

    return checkDestinationAbsolute(pixel, step);
  }

  static ColorProfileXYZTag? _getColumn(
    ColorProfile profile,
    ICCColorProfileTag tag,
  ) {
    final resolved = profile.findTag(tag);
    if (resolved != null && resolved is ColorProfileXYZTag) {
      return resolved;
    }
    return null;
  }

  static ColorProfileCurve _getCurve(
    ColorProfile profile,
    ICCColorProfileTag tag,
  ) {
    final resolved = profile.findTag(tag);
    if (resolved != null && resolved is ColorProfileCurve) {
      return resolved;
    }
    throw Exception('Missing required tag: $tag');
  }

  static ColorProfileCurve _getInvCurve(
    ColorProfile profile,
    ICCColorProfileTag tag,
  ) {
    final curve = _getCurve(profile, tag);

    final lut = Float64List(2048);
    for (var i = 0; i < 2048; ++i) {
      final x = i / 2047;
      lut[i] = curve.find(x);
    }
    return ColorProfileTagCurve(lut);
  }

  static void _invertMatrix(Float64List matrix) {
    const epsilon = 1e-8;

    final m48 = matrix[4] * matrix[8];
    final m75 = matrix[7] * matrix[5];
    final m38 = matrix[3] * matrix[8];
    final m65 = matrix[6] * matrix[5];
    final m37 = matrix[3] * matrix[7];
    final m64 = matrix[6] * matrix[4];

    final det = matrix[0] * (m48 - m75) -
        matrix[1] * (m38 - m65) +
        matrix[2] * (m37 - m64);

    if (det > -epsilon && det < epsilon) {
      throw Exception('Could not invert matrix -> $matrix');
    }

    final co = Float64List(9);

    co[0] = m48 - m75;
    co[1] = -(m38 - m65);
    co[2] = m37 - m64;

    co[3] = -(matrix[1] * matrix[8] - matrix[7] * matrix[2]);
    co[4] = matrix[0] * matrix[8] - matrix[6] * matrix[2];
    co[5] = -(matrix[0] * matrix[7] - matrix[6] * matrix[1]);

    co[6] = matrix[1] * matrix[5] - matrix[4] * matrix[2];
    co[7] = -(matrix[0] * matrix[5] - matrix[3] * matrix[2]);
    co[8] = matrix[0] * matrix[4] - matrix[3] * matrix[1];

    matrix[0] = co[0] / det;
    matrix[1] = co[3] / det;
    matrix[2] = co[6] / det;

    matrix[3] = co[1] / det;
    matrix[4] = co[4] / det;
    matrix[5] = co[7] / det;

    matrix[6] = co[2] / det;
    matrix[7] = co[5] / det;
    matrix[8] = co[8] / det;
  }
}
