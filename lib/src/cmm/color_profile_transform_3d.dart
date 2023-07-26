import 'package:icc_parser/src/cmm/color_profile_transform.dart';
import 'package:icc_parser/src/cmm/enums.dart';
import 'package:icc_parser/src/color_profile.dart';
import 'package:icc_parser/src/types/color_profile_matrix.dart';
import 'package:icc_parser/src/types/tag/curve/color_profile_curve.dart';
import 'package:icc_parser/src/types/tag/lut/color_profile_mbb.dart';
import 'package:meta/meta.dart';

@immutable
final class ColorProfileTransform3DLut extends ColorProfileTransform {
  final ColorProfileMBB tag;
  final List<ColorProfileCurve>? aCurves;
  final List<ColorProfileCurve>? bCurves;
  final List<ColorProfileCurve>? mCurves;
  final ColorProfileMatrix? matrix;
  // TODO move to transform parameters
  final ColorProfileInterpolation interpolation;

  const ColorProfileTransform3DLut({
    required this.aCurves,
    required this.bCurves,
    required this.mCurves,
    required this.matrix,
    required this.tag,
    required super.profile,
    required super.doAdjustPCS,
    required super.isInput,
    required super.srcPCSConversion,
    required super.pcsScale,
    required super.pcsOffset,
    required super.dstPCSConversion,
    required this.interpolation,
  });

  factory ColorProfileTransform3DLut.fromTag({
    required ColorProfileMBB tag,
    required ColorProfile profile,
    required bool doAdjustPCS,
    required bool isInput,
    required bool srcPCSConversion,
    required bool dstPCSConversion,
    required List<double>? pcsScale,
    required List<double>? pcsOffset,
    required ColorProfileInterpolation interpolation,
  }) {
    final params = _begin(tag);
    return ColorProfileTransform3DLut(
      aCurves: params.aCurves,
      bCurves: params.bCurves,
      mCurves: params.mCurves,
      matrix: params.matrix,
      tag: tag,
      profile: profile,
      doAdjustPCS: doAdjustPCS,
      isInput: isInput,
      srcPCSConversion: srcPCSConversion,
      pcsScale: pcsScale,
      pcsOffset: pcsOffset,
      dstPCSConversion: dstPCSConversion,
      interpolation: interpolation,
    );
  }

  @override
  List<double> apply(List<double> source) {
    final sourcePixel = checkSourceAbsolute(source);
    final pixel = [...sourcePixel];
    if (tag.isInputMatrix) {
      if (bCurves != null) {
        pixel[0] = bCurves![0].apply(pixel[0]);
        pixel[1] = bCurves![1].apply(pixel[1]);
        pixel[2] = bCurves![2].apply(pixel[2]);
      }
      if (matrix != null) {
        matrix!.apply(pixel);
      }
      if (mCurves != null) {
        pixel[0] = mCurves![0].apply(pixel[0]);
        pixel[1] = mCurves![1].apply(pixel[1]);
        pixel[2] = mCurves![2].apply(pixel[2]);
      }
      if (tag.clut != null) {
        final res = switch (interpolation) {
          ColorProfileInterpolation.linear => tag.clut!.interpolate3d(pixel),
          ColorProfileInterpolation.tetrahedral =>
            tag.clut!.interpolate3dTetra(pixel),
        };
        pixel[0] = res[0];
        pixel[1] = res[1];
        pixel[2] = res[2];
      }
      if (aCurves != null) {
        pixel[0] = aCurves![0].apply(pixel[0]);
        pixel[1] = aCurves![1].apply(pixel[1]);
        pixel[2] = aCurves![2].apply(pixel[2]);
      }
    } else {
      if (aCurves != null) {
        pixel[0] = aCurves![0].apply(pixel[0]);
        pixel[1] = aCurves![1].apply(pixel[1]);
        pixel[2] = aCurves![2].apply(pixel[2]);
      }
      if (tag.clut != null) {
        final res = switch (interpolation) {
          ColorProfileInterpolation.linear => tag.clut!.interpolate3d(pixel),
          ColorProfileInterpolation.tetrahedral =>
            tag.clut!.interpolate3dTetra(pixel),
        };
        pixel[0] = res[0];
        pixel[1] = res[1];
        pixel[2] = res[2];
      }
      if (mCurves != null) {
        for (var i = 0; i < tag.outputChannelCount; i++) {
          pixel[i] = mCurves![i].apply(pixel[i]);
        }
      }
      if (matrix != null) {
        matrix!.apply(pixel);
      }
      if (bCurves != null) {
        for (var i = 0; i < tag.outputChannelCount; i++) {
          pixel[i] = bCurves![i].apply(pixel[i]);
        }
      }
    }

    return checkDestinationAbsolute(pixel);
  }

  @override
  bool get useLegacyPCS => tag.useLegacyPCS;

  static ({
    List<ColorProfileCurve>? aCurves,
    List<ColorProfileCurve>? bCurves,
    List<ColorProfileCurve>? mCurves,
    ColorProfileMatrix? matrix,
  }) _begin(ColorProfileMBB tag) {
    assert(tag.inputChannelCount == 3);

    List<ColorProfileCurve>? usedACurves;
    List<ColorProfileCurve>? usedBCurves;
    List<ColorProfileCurve>? usedMCurves;
    final aCurves = tag.aCurves;
    final bCurves = tag.bCurves;
    final mCurves = tag.mCurves;
    if (tag.isInputMatrix) {
      if (bCurves != null) {
        if (!bCurves[0].isIdentity ||
            !bCurves[1].isIdentity ||
            !bCurves[2].isIdentity) {
          usedBCurves = bCurves;
        }
      }
      if (mCurves != null) {
        if (!mCurves[0].isIdentity ||
            !mCurves[1].isIdentity ||
            !mCurves[2].isIdentity) {
          usedMCurves = mCurves;
        }
      }
      if (aCurves != null) {
        for (final curve in aCurves) {
          if (!curve.isIdentity) {
            usedACurves = aCurves;
            break;
          }
        }
      }
    } else {
      // isInputMatrix
      if (aCurves != null) {
        if (!aCurves[0].isIdentity ||
            !aCurves[1].isIdentity ||
            !aCurves[2].isIdentity) {
          usedACurves = aCurves;
        }
      }
      if (bCurves != null) {
        for (final curve in bCurves) {
          if (!curve.isIdentity) {
            usedBCurves = bCurves;
            break;
          }
        }
      }
      if (mCurves != null) {
        for (final curve in mCurves) {
          if (!curve.isIdentity) {
            usedMCurves = mCurves;
            break;
          }
        }
      }
    }

    ColorProfileMatrix? usedMatrix;
    final matrix = tag.matrix;
    if (matrix != null) {
      if (!matrix.isIdentity()) {
        usedMatrix = matrix;
      }
    }

    return (
      mCurves: usedMCurves,
      aCurves: usedACurves,
      bCurves: usedBCurves,
      matrix: usedMatrix,
    );
  }
}
