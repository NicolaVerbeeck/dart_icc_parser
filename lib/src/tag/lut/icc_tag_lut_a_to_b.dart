import 'dart:typed_data';

import 'package:icc_parser/src/tag/lut/icc_clut.dart';
import 'package:icc_parser/src/types/built_in.dart';

class ICCTagLutAToB {
  ICCTagLutAToB();

  factory ICCTagLutAToB.fromBytes(
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

    if (offsetToFirstBCurve.value != 0) {
      // Load b curves
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

    return ICCTagLutAToB();
  }
}
