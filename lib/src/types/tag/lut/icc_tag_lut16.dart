import 'package:icc_parser/src/types/primitive.dart';
import 'package:icc_parser/src/types/tag/clut/icc_clut.dart';
import 'package:icc_parser/src/types/tag/curve/icc_curve.dart';
import 'package:icc_parser/src/types/tag/curve/icc_tag_curve.dart';
import 'package:icc_parser/src/types/tag/lut/icc_mbb.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

@immutable
final class IccTagLut16 extends IccMBB {
  final List<Signed15Fixed16Number> xyzMatrix;

  @override
  IccCLUT get clut => super.clut!;

  @override
  bool get useLegacyPCS => true;

  const IccTagLut16({
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

  factory IccTagLut16.fromBytes(DataStream data) {
    final signature = data.readUnsigned32Number();
    assert(signature.value == 0x6D667432);
    // 4 reserved bytes
    data.skip(4);
    final inputChannelCount = data.readUnsigned8Number();
    final outputChannelCount = data.readUnsigned8Number();
    final clutPoints = data.readUnsigned8Number();
    // 1 reserved byte
    data.skip(1);

    final xyzMatrix = List.generate(9, (_) => data.readSigned15Fixed16Number());

    final inputTableEntriesCount = data.readUnsigned16Number();
    final outputTableEntriesCount = data.readUnsigned16Number();

    final bCurves = List<IccCurve>.generate(
      inputChannelCount.value,
      (_) => IccTagCurve.fromBytesWithSize(data, inputTableEntriesCount.value),
    );

    final clut = IccCLUT.fromBytes(
      data,
      numGridPoints: clutPoints.value,
      inputChannelCount: inputChannelCount.value,
      outputChannelCount: outputChannelCount.value,
      precision: 2,
    );

    final aCurves = List<IccCurve>.generate(
        outputChannelCount.value,
        (_) =>
            IccTagCurve.fromBytesWithSize(data, outputTableEntriesCount.value));

    return IccTagLut16(
      inputChannelCount: inputChannelCount.value,
      outputChannelCount: outputChannelCount.value,
      aCurves: aCurves,
      bCurves: bCurves,
      clut: clut,
      xyzMatrix: xyzMatrix,
    );
  }
}
