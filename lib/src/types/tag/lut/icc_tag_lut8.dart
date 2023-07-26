import 'package:icc_parser/src/types/primitive.dart';
import 'package:icc_parser/src/types/tag/clut/icc_clut.dart';
import 'package:icc_parser/src/types/tag/curve/icc_curve.dart';
import 'package:icc_parser/src/types/tag/curve/icc_tag_curve.dart';
import 'package:icc_parser/src/types/tag/lut/icc_mbb.dart';
import 'package:icc_parser/src/types/tag/tag_type.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

@immutable
final class ColorProfileTagLut8 extends ColorProfileMBB {
  final List<Signed15Fixed16Number> xyzMatrix;

  @override
  ColorProfileCLUT get clut => super.clut!;

  @override
  ColorProfileTagType get type => ColorProfileTagType.icSigLut8Type;

  const ColorProfileTagLut8({
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

  factory ColorProfileTagLut8.fromBytes(DataStream data) {
    final signature = data.readUnsigned32Number();
    assert(signature.value == 0x6D667431);
    // 4 reserved bytes
    data.skip(4);
    final inputChannelCount = data.readUnsigned8Number();
    final outputChannelCount = data.readUnsigned8Number();
    final clutPoints = data.readUnsigned8Number();
    // 1 reserved byte
    data.skip(1);

    final xyzMatrix = List.generate(9, (_) => data.readSigned15Fixed16Number());

    const inputTableEntriesCount = 256;
    const outputTableEntriesCount = 256;

    final bCurves = List<ColorProfileCurve>.generate(
      inputChannelCount.value,
      (_) => ColorProfileTagCurve.fromBytesWithSize(data, inputTableEntriesCount),
    );

    final clut = ColorProfileCLUT.fromBytes(
      data,
      numGridPoints: clutPoints.value,
      inputChannelCount: inputChannelCount.value,
      outputChannelCount: outputChannelCount.value,
      precision: 1,
    );

    final aCurves = List<ColorProfileCurve>.generate(outputChannelCount.value,
        (_) => ColorProfileTagCurve.fromBytesWithSize(data, outputTableEntriesCount));

    return ColorProfileTagLut8(
      inputChannelCount: inputChannelCount.value,
      outputChannelCount: outputChannelCount.value,
      aCurves: aCurves,
      bCurves: bCurves,
      clut: clut,
      xyzMatrix: xyzMatrix,
    );
  }
}
