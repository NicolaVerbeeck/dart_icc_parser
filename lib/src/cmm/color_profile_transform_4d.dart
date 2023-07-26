import 'package:icc_parser/src/cmm/color_profile_cmm.dart';
import 'package:icc_parser/src/cmm/color_profile_transform.dart';
import 'package:icc_parser/src/color_profile.dart';
import 'package:icc_parser/src/types/color_profile_matrix.dart';
import 'package:icc_parser/src/types/tag/curve/color_profile_curve.dart';
import 'package:icc_parser/src/types/tag/lut/color_profile_mbb.dart';
import 'package:meta/meta.dart';

@immutable
final class ColorProfileTransform4DLut extends ColorProfileTransform {
  final ColorProfileMBB tag;
  final List<ColorProfileCurve>? aCurves;
  final List<ColorProfileCurve>? bCurves;
  final List<ColorProfileCurve>? mCurves;
  final ColorProfileMatrix? matrix;

  const ColorProfileTransform4DLut({
    required this.aCurves,
    required this.bCurves,
    required this.mCurves,
    required this.matrix,
    required this.tag,
    required super.profile,
    required super.doAdjustPCS,
    required super.isInput,
    required super.pcsScale,
    required super.pcsOffset,
  });

  factory ColorProfileTransform4DLut.fromTag({
    required ColorProfileMBB tag,
    required ColorProfile profile,
    required bool doAdjustPCS,
    required bool isInput,
    required List<double>? pcsScale,
    required List<double>? pcsOffset,
  }) {
    final params = _begin(tag);
    return ColorProfileTransform4DLut(
      aCurves: params.aCurves,
      bCurves: params.bCurves,
      mCurves: params.mCurves,
      matrix: params.matrix,
      tag: tag,
      profile: profile,
      doAdjustPCS: doAdjustPCS,
      isInput: isInput,
      pcsScale: pcsScale,
      pcsOffset: pcsOffset,
    );
  }

  @override
  List<double> apply(List<double> source, ColorProfileTransformationStep step) {
    final sourcePixel = checkSourceAbsolute(source, step);
    final pixel = [...sourcePixel];
    if (tag.isInputMatrix) {
      if (bCurves != null) {
        pixel[0] = bCurves![0].apply(pixel[0]);
        pixel[1] = bCurves![1].apply(pixel[1]);
        pixel[2] = bCurves![2].apply(pixel[2]);
        pixel[3] = bCurves![3].apply(pixel[3]);
      }
      if (tag.clut != null) {
        final res = tag.clut!.interpolate4d(pixel);
        pixel[0] = res[0];
        pixel[1] = res[1];
        pixel[2] = res[2];
      }
      if (aCurves != null) {
        for (var i = 0; i < tag.outputChannelCount; i++) {
          pixel[i] = aCurves![i].apply(pixel[i]);
        }
      }
    } else {
      if (aCurves != null) {
        pixel[0] = aCurves![0].apply(pixel[0]);
        pixel[1] = aCurves![1].apply(pixel[1]);
        pixel[2] = aCurves![2].apply(pixel[2]);
        pixel[3] = aCurves![3].apply(pixel[3]);
      }
      if (tag.clut != null) {
        final res = tag.clut!.interpolate4d(pixel);
        pixel[0] = res[0];
        pixel[1] = res[1];
        pixel[2] = res[2];
        pixel[3] = res[3];
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

    return checkDestinationAbsolute(pixel, step)
        .sublist(0, tag.outputChannelCount);
  }

  @override
  bool get useLegacyPCS => tag.useLegacyPCS;

  static ({
    List<ColorProfileCurve>? aCurves,
    List<ColorProfileCurve>? bCurves,
    List<ColorProfileCurve>? mCurves,
    ColorProfileMatrix? matrix,
  }) _begin(ColorProfileMBB tag) {
    assert(tag.inputChannelCount == 4);

    List<ColorProfileCurve>? usedACurves;
    List<ColorProfileCurve>? usedBCurves;
    List<ColorProfileCurve>? usedMCurves;
    final aCurves = tag.aCurves;
    final bCurves = tag.bCurves;
    final mCurves = tag.mCurves;
    if (tag.isInputMatrix) {
      if (bCurves != null) {
        for (final curve in bCurves) {
          if (!curve.isIdentity) {
            usedBCurves = bCurves;
            break;
          }
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
      // !isInputMatrix
      if (aCurves != null) {
        for (final curve in aCurves) {
          if (!curve.isIdentity) {
            usedACurves = aCurves;
            break;
          }
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
