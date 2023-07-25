import 'package:icc_parser/src/types/tag/lut/icc_tag_lut_a_to_b.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

@immutable
class IccTagLutBToA extends IccTagLutAToB {
  static const _isInputMatrix = true;

  const IccTagLutBToA({
    required super.inputChannelCount,
    required super.outputChannelCount,
    required super.aCurves,
    required super.clut,
    required super.matrix,
    required super.bCurves,
    required super.mCurves,
    final bool isInputMatrix = _isInputMatrix,
  }) : super(
          isInputMatrix: isInputMatrix,
        );

  factory IccTagLutBToA.fromBytes(
    final DataStream data, {
    required final int size,
  }) {
    final parent = IccTagLutAToB.readFromBytes(
      data,
      size: size,
      isInputMatrix: _isInputMatrix,
    );
    return IccTagLutBToA(
      inputChannelCount: parent.inputChannelCount,
      outputChannelCount: parent.outputChannelCount,
      aCurves: parent.aCurves,
      clut: parent.clut,
      matrix: parent.matrix,
      bCurves: parent.bCurves,
      mCurves: parent.mCurves,
    );
  }
}
