import 'package:icc_parser/src/types/icc_matrix.dart';
import 'package:icc_parser/src/types/tag/clut/icc_clut.dart';
import 'package:icc_parser/src/types/tag/curve/icc_curve.dart';
import 'package:icc_parser/src/types/tag/lut/icc_mbb.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

@immutable
class IccTagLutAToB extends IccMBB {
  static const _isInputMatrix = false;

  const IccTagLutAToB({
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

  factory IccTagLutAToB.fromBytes(
    DataStream data, {
    required int size,
  }) {
    return readFromBytes(
      data,
      size: size,
      isInputMatrix: _isInputMatrix,
    );
  }

  @protected
  static IccTagLutAToB readFromBytes(
    DataStream data, {
    required int size,
    required bool isInputMatrix,
  }) {
    final start = data.position;
    final end = start + size;
    final signature = data.readUnsigned32Number();
    assert(signature.value == 0x6D414220);

    // 4 reserved bytes
    data.skip(4);

    final inputChannelCount = data.readUnsigned8Number();
    final outputChannelCount = data.readUnsigned8Number();
    // 2 reserved bytes
    data.skip(2);

    final offsetToFirstBCurve = data.readUnsigned32Number().value;
    final offsetToMatrix = data.readUnsigned32Number().value;
    final offsetToFirstMCurve = data.readUnsigned32Number().value;
    final offsetToCLUT = data.readUnsigned32Number().value;
    final offsetToFirstACurve = data.readUnsigned32Number().value;

    List<IccCurve>? bCurves;
    List<IccCurve>? mCurves;
    List<IccCurve>? aCurves;
    IccMatrix? matrix;
    IccCLUT? clut;

    if (offsetToFirstBCurve != 0) {
      data.seek(start + offsetToFirstBCurve);
      bCurves = _readCurves(
        data,
        end: end,
        nextOffset: offsetToMatrix,
        channelCount:
            isInputMatrix ? inputChannelCount.value : outputChannelCount.value,
      );
    }
    if (offsetToMatrix != 0) {
      // Load matrix
      data.seek(offsetToMatrix);
      matrix = IccMatrix.fromBytes(data);
    }
    if (offsetToFirstMCurve != 0) {
      data.seek(start + offsetToFirstMCurve);
      bCurves = _readCurves(
        data,
        end: end,
        nextOffset: offsetToCLUT,
        channelCount:
            isInputMatrix ? inputChannelCount.value : outputChannelCount.value,
      );
    }
    if (offsetToCLUT != 0) {
      // Line 3910
      data.seek(start + offsetToCLUT);
      clut = IccCLUT.fromBytesWithHeader(
        data,
        inputChannelCount: inputChannelCount.value,
        outputChannelCount: outputChannelCount.value,
      );
    }
    if (offsetToFirstACurve != 0) {
      // Load a curves
      data.seek(start + offsetToFirstACurve);
      aCurves = _readCurves(
        data,
        end: end,
        nextOffset: offsetToFirstACurve,
        channelCount:
            !isInputMatrix ? inputChannelCount.value : outputChannelCount.value,
      );
    }

    return IccTagLutAToB(
      inputChannelCount: inputChannelCount.value,
      outputChannelCount: outputChannelCount.value,
      aCurves: aCurves,
      clut: clut,
      matrix: matrix,
      bCurves: bCurves,
      mCurves: mCurves,
    );
  }

  static List<IccCurve>? _readCurves(
    DataStream data, {
    required int end,
    required int channelCount,
    required int nextOffset,
  }) {
    if (channelCount == 0) return null;

    final bCurves = List<IccCurve>.generate(
      channelCount,
      (_) {
        final curve = IccCurve.fromBytes(data, size: end - data.position);
        data.sync32(nextOffset);
        return curve;
      },
    );

    return bCurves;
  }
}
