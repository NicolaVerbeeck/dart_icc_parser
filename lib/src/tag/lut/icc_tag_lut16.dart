import 'dart:typed_data';

import 'package:icc_parser/src/tag/lut/icc_clut.dart';
import 'package:icc_parser/src/types/built_in.dart';

class IccTagLut16 {
  late final IccCLUT clut;

  void read(final ByteData data, {final int offset = 0}) {
    final signature = Unsigned32Number.fromBytes(data, offset: offset);
    assert(signature.value == 0x6D667432);
    // 4 reserved bytes
    final inputChannelCount =
        Unsigned8Number.fromBytes(data, offset: offset + 8);
    final outputChannelCount =
        Unsigned8Number.fromBytes(data, offset: offset + 9);
    final clutPoints = Unsigned8Number.fromBytes(data, offset: offset + 10);

    final xyzMatrix = <Signed15Fixed16Number>[
      Signed15Fixed16Number.fromBytes(data, offset: offset + 12),
      Signed15Fixed16Number.fromBytes(data, offset: offset + 16),
      Signed15Fixed16Number.fromBytes(data, offset: offset + 20),
      Signed15Fixed16Number.fromBytes(data, offset: offset + 24),
      Signed15Fixed16Number.fromBytes(data, offset: offset + 28),
      Signed15Fixed16Number.fromBytes(data, offset: offset + 32),
      Signed15Fixed16Number.fromBytes(data, offset: offset + 36),
      Signed15Fixed16Number.fromBytes(data, offset: offset + 40),
      Signed15Fixed16Number.fromBytes(data, offset: offset + 44),
    ];

    final inputTableEntriesCount =
        Unsigned16Number.fromBytes(data, offset: offset + 48);
    final outputTableEntriesCount =
        Unsigned16Number.fromBytes(data, offset: offset + 50);

    final inputCurves = <IccCurve>[
      for (var i = 0; i < inputChannelCount.value; ++i)
        IccCurve.fromBytes(
          data,
          count: inputTableEntriesCount.value,
          offset: offset + 52 + (i * 2 * inputTableEntriesCount.value),
        )
    ];
    clut = IccCLUT.fromBytes(
      data,
      offset: offset +
          52 +
          inputChannelCount.value * 2 * inputTableEntriesCount.value,
      numGridPoints: clutPoints.value,
      inputChannelCount: inputChannelCount.value,
      outputChannelCount: outputChannelCount.value,
      precision: 2,
    );

    final outputCurves = <IccCurve>[
      for (var i = 0; i < outputChannelCount.value; ++i)
        IccCurve.fromBytes(
          data,
          count: outputTableEntriesCount.value,
          offset: offset +
              52 +
              inputChannelCount.value * 2 * inputTableEntriesCount.value +
              i * 2 * outputTableEntriesCount.value,
        )
    ];

    // Then resets the color space matrix to identity... ICCProfile:1205
    print('');
  }
}

class IccCurve {
  final List<double> values;

  IccCurve(this.values);

  factory IccCurve.fromBytes(
    final ByteData data, {
    required final int count,
    final int offset = 0,
  }) {
    final values = <double>[];
    for (var i = 0; i < count; i++) {
      final raw = Unsigned16Number.fromBytes(data, offset: offset + (i * 2));
      values.add(raw.value / 65535);
    }
    return IccCurve(values);
  }
}
