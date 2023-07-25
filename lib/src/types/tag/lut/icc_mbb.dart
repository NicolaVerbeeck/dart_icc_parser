import 'package:icc_parser/src/types/icc_matrix.dart';
import 'package:icc_parser/src/types/tag/clut/icc_clut.dart';
import 'package:icc_parser/src/types/tag/curve/icc_curve.dart';
import 'package:icc_parser/src/types/tag/icc_tag.dart';
import 'package:meta/meta.dart';

/// Multi-dimensional Black Box (MBB) base class for lut8, lut16,
/// lutA2B and lutB2A tag types.
@immutable
abstract class IccMBB implements IccTag {
  const IccMBB({
    required this.inputChannelCount,
    required this.outputChannelCount,
    required this.isInputMatrix,
    required this.aCurves,
    required this.clut,
    required this.matrix,
    required this.bCurves,
    required this.mCurves,
  });

  final int inputChannelCount;
  final int outputChannelCount;
  final bool isInputMatrix;

  bool get isInputB => isInputMatrix;

  bool get useLegacyPCS => false;

  final List<IccCurve>? aCurves;
  final IccCLUT? clut;
  final IccMatrix? matrix;
  final List<IccCurve>? bCurves;
  final List<IccCurve>? mCurves;
}
