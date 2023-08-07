import 'dart:typed_data';

import 'package:icc_parser/src/types/tag/clut/color_profile_clut.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag_type.dart';
import 'package:icc_parser/src/types/tag/curve/color_profile_curve.dart';
import 'package:icc_parser/src/types/tag/curve/color_profile_tag_curve.dart';
import 'package:icc_parser/src/types/tag/lut/color_profile_mbb.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:icc_parser/src/utils/list_utils.dart';
import 'package:meta/meta.dart';

@immutable
final class ColorProfileTagLut16 extends ColorProfileMBB {
  final Float64List xyzMatrix;

  @override
  ColorProfileCLUT get clut => super.clut!;

  @override
  bool get useLegacyPCS => true;

  @override
  ColorProfileTagType get type => ColorProfileTagType.icSigLut16Type;

  const ColorProfileTagLut16({
    required super.inputChannelCount,
    required super.outputChannelCount,
    required super.aCurves,
    required super.bCurves,
    required super.clut,
    required this.xyzMatrix,
  }) : super(
          isInputMatrix: true,
          mCurves: null,
          matrix: null,
        );

  factory ColorProfileTagLut16.fromBytes(DataStream data) {
    final signature = data.readUnsigned32Number();
    assert(signature.value == 0x6D667432);
    // 4 reserved bytes
    data.skip(4);
    final inputChannelCount = data.readUnsigned8Number();
    final outputChannelCount = data.readUnsigned8Number();
    final clutPoints = data.readUnsigned8Number();
    // 1 reserved byte
    data.skip(1);

    final xyzMatrix = generateFloat64List(
      9,
      (_) => data.readSigned15Fixed16Number().value,
    );

    final inputTableEntriesCount = data.readUnsigned16Number();
    final outputTableEntriesCount = data.readUnsigned16Number();

    final bCurves = List<ColorProfileCurve>.generate(
      inputChannelCount.value,
      (_) => ColorProfileTagCurve.fromBytesWithSize(
          data, inputTableEntriesCount.value),
    );

    final clut = ColorProfileCLUT.fromBytes(
      data,
      numGridPoints: clutPoints.value,
      inputChannelCount: inputChannelCount.value,
      outputChannelCount: outputChannelCount.value,
      precision: 2,
    );

    final aCurves = List<ColorProfileCurve>.generate(
        outputChannelCount.value,
        (_) => ColorProfileTagCurve.fromBytesWithSize(
            data, outputTableEntriesCount.value));

    return ColorProfileTagLut16(
      inputChannelCount: inputChannelCount.value,
      outputChannelCount: outputChannelCount.value,
      aCurves: aCurves,
      bCurves: bCurves,
      clut: clut,
      xyzMatrix: xyzMatrix,
    );
  }
}
