import 'dart:typed_data';

import 'package:icc_parser/src/tag/curve/icc_curve.dart';
import 'package:icc_parser/src/tag/lut/icc_clut.dart';
import 'package:icc_parser/src/tag/lut/icc_mbb.dart';
import 'package:icc_parser/src/types/built_in.dart';
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
  }) : super(
          isInputMatrix: _isInputMatrix,
        );

  factory IccTagLutAToB.fromBytes(
    final ByteData data, {
    final int offset = 0,
  }) {
    final signature = Unsigned32Number.fromBytes(data, offset: offset);
    assert(signature.value == 0x6D414220);

    // 4 reserved bytes
    final inputChannelCount =
        Unsigned8Number.fromBytes(data, offset: offset + 8);
    final outputChannelCount =
        Unsigned8Number.fromBytes(data, offset: offset + 9);

    final offsetToFirstBCurve =
        Unsigned32Number.fromBytes(data, offset: offset + 12);
    final offsetToMatrix =
        Unsigned32Number.fromBytes(data, offset: offset + 16);
    final offsetToFirstMCurve =
        Unsigned32Number.fromBytes(data, offset: offset + 20);
    final offsetToCLUT = Unsigned32Number.fromBytes(data, offset: offset + 24);
    final offsetToFirstACurve =
        Unsigned32Number.fromBytes(data, offset: offset + 28);

    List<IccCurve>? bCurves;

    if (offsetToFirstBCurve.value != 0) {
      bCurves = _readBCurves(
        data,
        offset: offset + offsetToFirstBCurve.value,
        channelCount: outputChannelCount.value,
      );
    }
    if (offsetToMatrix.value != 0) {
      // Load matrix
    }
    if (offsetToFirstMCurve.value != 0) {
      // Load m curves
    }
    if (offsetToCLUT.value != 0) {
      // Line 3910
      IccCLUT.fromBytesWithHeader(
        data,
        offset: offset + offsetToCLUT.value,
        inputChannelCount: inputChannelCount.value,
        outputChannelCount: outputChannelCount.value,
      );
    }
    if (offsetToFirstACurve.value != 0) {
      // Load a curves
    }

    return IccTagLutAToB();
  }

  static List<IccCurve>? _readBCurves(
    final ByteData data, {
    required final int offset,
    required final int channelCount,
  }) {
    final bCurves = <IccCurve>[];

    var subOffset = 0;
    for (var i = 0; i < channelCount; ++i) {
      final offsetToCurve = Unsigned32Number.fromBytes(
        data,
        offset: offset + subOffset,
      );


      if (offsetToCurve.value != 0) {
        bCurves.add(
          IccCurve.fromBytes(
            data,
            offset: offset + offsetToCurve.value,
          ),
        );
      }
    }

    return bCurves.isEmpty ? null : bCurves;
  }
}
