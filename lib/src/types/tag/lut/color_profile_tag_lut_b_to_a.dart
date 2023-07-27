import 'package:icc_parser/src/types/tag/color_profile_tag_type.dart';
import 'package:icc_parser/src/types/tag/lut/color_profile_tag_lut_a_to_b.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

@immutable
class ColorProfileTagLutBToA extends ColorProfileTagLutAToB {
  static const _isInputMatrix = true;

  @override
  ColorProfileTagType get type => ColorProfileTagType.icSigLutBtoAType;

  const ColorProfileTagLutBToA({
    required super.inputChannelCount,
    required super.outputChannelCount,
    required super.aCurves,
    required super.clut,
    required super.matrix,
    required super.bCurves,
    required super.mCurves,
    bool isInputMatrix = _isInputMatrix,
  }) : super(
          isInputMatrix: isInputMatrix,
        );

  factory ColorProfileTagLutBToA.fromBytes(
    DataStream data, {
    required int size,
  }) {
    final parent = ColorProfileTagLutAToB.readFromBytes(
      data,
      size: size,
      isInputMatrix: _isInputMatrix,
      type: ColorProfileTagType.icSigLutBtoAType,
    );
    return ColorProfileTagLutBToA(
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
