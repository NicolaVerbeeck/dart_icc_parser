import 'dart:typed_data';

import 'package:icc_parser/src/cmm/color_profile_cmm.dart';
import 'package:icc_parser/src/cmm/color_profile_transform.dart';
import 'package:icc_parser/src/color_profile.dart';
import 'package:icc_parser/src/types/color_profile_header.dart';
import 'package:icc_parser/src/types/matrix3x3.dart';
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
  final Matrix3x3 matrix;

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
    final matrix = Matrix3x3();
    final curves = <ColorProfileCurve>[];

    var xyz = _getColumn(profile, ICCColorProfileTag.icSigRedMatrixColumnTag);
    if (xyz == null) {
      throw Exception('Missing required tag: icSigRedMatrixColumnTag');
    }
    matrix.m00 = xyz.xyz[0].x.value;
    matrix.m10 = xyz.xyz[0].y.value;
    matrix.m20 = xyz.xyz[0].z.value;

    xyz = _getColumn(profile, ICCColorProfileTag.icSigGreenMatrixColumnTag);
    if (xyz == null) {
      throw Exception('Missing required tag: icSigRedMatrixColumnTag');
    }
    matrix.m01 = xyz.xyz[0].x.value;
    matrix.m11 = xyz.xyz[0].y.value;
    matrix.m21 = xyz.xyz[0].z.value;

    xyz = _getColumn(profile, ICCColorProfileTag.icSigBlueMatrixColumnTag);
    if (xyz == null) {
      throw Exception('Missing required tag: icSigRedMatrixColumnTag');
    }
    matrix.m02 = xyz.xyz[0].x.value;
    matrix.m12 = xyz.xyz[0].y.value;
    matrix.m22 = xyz.xyz[0].z.value;

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

      matrix.invert();
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
          xyzScale(matrix.m00 * linR + matrix.m01 * linG + matrix.m02 * linB);
      pixel[1] =
          xyzScale(matrix.m10 * linR + matrix.m11 * linG + matrix.m12 * linB);
      pixel[2] =
          xyzScale(matrix.m20 * linR + matrix.m21 * linG + matrix.m22 * linB);
    } else {
      final x = xyzDescale(pixel[0]);
      final y = xyzDescale(pixel[1]);
      final z = xyzDescale(pixel[2]);

      final applyCurve = curves;
      if (applyCurve != null) {
        pixel[0] = rgbClip(
            matrix.m00 * x + matrix.m01 * y + matrix.m02 * z, applyCurve[0]);
        pixel[1] = rgbClip(
            matrix.m10 * x + matrix.m11 * y + matrix.m12 * z, applyCurve[1]);
        pixel[2] = rgbClip(
            matrix.m20 * x + matrix.m21 * y + matrix.m22 * z, applyCurve[2]);
      } else {
        pixel[0] = matrix.m00 * x + matrix.m01 * y + matrix.m02 * z;
        pixel[1] = matrix.m10 * x + matrix.m11 * y + matrix.m12 * z;
        pixel[2] = matrix.m20 * x + matrix.m21 * y + matrix.m22 * z;
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
}
