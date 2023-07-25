import 'package:icc_parser/src/cmm/icc_transform.dart';
import 'package:icc_parser/src/types/icc_matrix.dart';
import 'package:icc_parser/src/types/tag/curve/icc_curve.dart';
import 'package:icc_parser/src/types/tag/lut/icc_mbb.dart';
import 'package:meta/meta.dart';

@immutable
final class IccTransform3DLut extends IccTransform {
  final IccMBB tag;
  final List<IccCurve>? aCurves;
  final List<IccCurve>? bCurves;
  final List<IccCurve>? mCurves;
  final IccMatrix? matrix;

  const IccTransform3DLut({
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
  });

  void begin() {}

  List<double> apply(final List<double> source) {
    final sourcePixel = adjustPCS(source);
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
        // TODO other interpolation methods
        final res = tag.clut!.interpolate3d(pixel);
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
        // TODO other interpolation methods
        final res = tag.clut!.interpolate3d(pixel);
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
    List<IccCurve>? aCurves,
    List<IccCurve>? bCurves,
    List<IccCurve>? mCurves,
    IccMatrix? matrix,
  }) _begin(final IccMBB tag) {
    assert(tag.inputChannelCount == 3);
    // TODO parent begin...

    List<IccCurve>? usedACurves;
    List<IccCurve>? usedBCurves;
    List<IccCurve>? usedMCurves;
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

    IccMatrix? usedMatrix;
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
