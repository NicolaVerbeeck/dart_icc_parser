import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:icc_parser/src/utils/list_utils.dart';
import 'package:meta/meta.dart';

@immutable
final class ColorProfileCLUT {
  final int inputChannelCount;
  final int outputChannelCount;
  final int numGridPoints;
  final Uint8List gridPoints;
  final Uint32List dimensionSize;
  final Uint8List _data;
  final Uint8List maxGridPoints;
  final Uint32List _offsets;
  final int precision;

  const ColorProfileCLUT({
    required this.inputChannelCount,
    required this.outputChannelCount,
    required this.numGridPoints,
    required this.gridPoints,
    required this.dimensionSize,
    required Uint8List data,
    required this.maxGridPoints,
    required Uint32List offsets,
    required this.precision,
  })  : _data = data,
        _offsets = offsets;

  factory ColorProfileCLUT.fromBytesWithHeader(
    DataStream data, {
    required int inputChannelCount,
    required int outputChannelCount,
  }) {
    // Skip 16-inputChannelCount bytes as we will never need them
    final gridPoints = data.readBytes(inputChannelCount);
    data.skip(16 - inputChannelCount);

    final precision = data.readUnsigned8Number().value;
    // 3 reserved bytes
    data.skip(3);

    return ColorProfileCLUT._internalFromBytes(
      data,
      inputChannelCount: inputChannelCount,
      outputChannelCount: outputChannelCount,
      precision: precision,
      gridPoints: gridPoints,
    );
  }

  factory ColorProfileCLUT.fromBytes(
    DataStream data, {
    required int numGridPoints,
    required int inputChannelCount,
    required int outputChannelCount,
    required int precision,
  }) {
    final gridPoints = filledUint8List(inputChannelCount, numGridPoints);
    return ColorProfileCLUT._internalFromBytes(
      data,
      inputChannelCount: inputChannelCount,
      outputChannelCount: outputChannelCount,
      precision: precision,
      gridPoints: gridPoints,
    );
  }

  factory ColorProfileCLUT._internalFromBytes(
    DataStream data, {
    required int inputChannelCount,
    required int outputChannelCount,
    required int precision,
    required Uint8List gridPoints,
  }) {
    // Init lists
    final dimensionSize = Uint32List(inputChannelCount);
    final maxGridPoints = Uint8List(inputChannelCount);

    var i = inputChannelCount - 1;
    dimensionSize[i] = outputChannelCount;
    var numPoints = Int64(gridPoints[i]);
    for (i--; i >= 0; i--) {
      dimensionSize[i] = dimensionSize[i + 1] * gridPoints[i + 1];
      numPoints *= Int64(gridPoints[i]);
    }
    final totalNumGridPoints = numPoints.toInt32().toInt();
    final size = totalNumGridPoints * outputChannelCount;

    final dataPoints = data.readBytes(size * precision);

    for (var i = 0; i < inputChannelCount; ++i) {
      maxGridPoints[i] = gridPoints[i] - 1;
    }
    final offsets = Uint32List(1 << inputChannelCount);

    _buildOffsetTable(
      offsets: offsets,
      inputChannelCount: inputChannelCount,
      dimensionSize: dimensionSize,
    );
    return ColorProfileCLUT(
      inputChannelCount: inputChannelCount,
      outputChannelCount: outputChannelCount,
      numGridPoints: totalNumGridPoints,
      gridPoints: gridPoints,
      dimensionSize: dimensionSize,
      data: dataPoints,
      maxGridPoints: maxGridPoints,
      offsets: offsets,
      precision: precision,
    );
  }

  Float64List interpolate4d(Float64List source) {
    final dest = Float64List(outputChannelCount);
    final mw = maxGridPoints[0];
    final mx = maxGridPoints[1];
    final my = maxGridPoints[2];
    final mz = maxGridPoints[3];

    final w = source[0].clampDouble(0, 1.0) * mw;
    final x = source[1].clampDouble(0, 1.0) * mx;
    final y = source[2].clampDouble(0, 1.0) * my;
    final z = source[3].clampDouble(0, 1.0) * mz;

    var iw = w.toInt();
    var ix = x.toInt();
    var iy = y.toInt();
    var iz = z.toInt();

    var v = w - iw;
    var u = x - ix;
    var t = y - iy;
    var s = z - iz;

    if (iw == mw) {
      --iw;
      v = 1.0;
    }
    if (ix == mx) {
      --ix;
      u = 1.0;
    }
    if (iy == my) {
      --iy;
      t = 1.0;
    }
    if (iz == mz) {
      --iz;
      s = 1.0;
    }

    final ns = 1.0 - s;
    final nt = 1.0 - t;
    final nu = 1.0 - u;
    final nv = 1.0 - v;

    final dF = Float64List(16);
    dF[0] = ns * nt * nu * nv;
    dF[1] = ns * nt * nu * v;
    dF[2] = ns * nt * u * nv;
    dF[3] = ns * nt * u * v;
    dF[4] = ns * t * nu * nv;
    dF[5] = ns * t * nu * v;
    dF[6] = ns * t * u * nv;
    dF[7] = ns * t * u * v;
    dF[8] = s * nt * nu * nv;
    dF[9] = s * nt * nu * v;
    dF[10] = s * nt * u * nv;
    dF[11] = s * nt * u * v;
    dF[12] = s * t * nu * nv;
    dF[13] = s * t * nu * v;
    dF[14] = s * t * u * nv;
    dF[15] = s * t * u * v;

    var p = iw * dimensionSize[0] +
        ix * dimensionSize[1] +
        iy * dimensionSize[2] +
        iz * dimensionSize[3];

    for (var i = 0; i < outputChannelCount; ++i) {
      var value = 0.0;
      for (var j = 0; j < 16; ++j) {
        value += _getValue(p + _offsets[j]) * dF[j];
      }
      dest[i] = value;
      ++p;
    }

    return dest;
  }

  Float64List interpolate3d(Float64List source) {
    final dest = Float64List(outputChannelCount);

    final mx = maxGridPoints[0];
    final my = maxGridPoints[1];
    final mz = maxGridPoints[2];

    final x = source[0].clampDouble(0, 1.0) * mx;
    final y = source[1].clampDouble(0, 1.0) * my;
    final z = source[2].clampDouble(0, 1.0) * mz;

    var ix = x.toInt();
    var iy = y.toInt();
    var iz = z.toInt();

    var u = x - ix;
    var t = y - iy;
    var s = z - iz;

    if (ix == mx) {
      --ix;
      u = 1.0;
    }
    if (iy == my) {
      --iy;
      t = 1.0;
    }
    if (iz == mz) {
      --iz;
      s = 1.0;
    }

    final ns = 1.0 - s;
    final nt = 1.0 - t;
    final nu = 1.0 - u;

    var offset = ix * _offsets[1] + iy * _offsets[2] + iz * _offsets[4];

    final dF0 = ns * nt * nu;
    final dF1 = ns * nt * u;
    final dF2 = ns * t * nu;
    final dF3 = ns * t * u;
    final dF4 = s * nt * nu;
    final dF5 = s * nt * u;
    final dF6 = s * t * nu;
    final dF7 = s * t * u;

    var pv = 0.0;

    for (var i = 0; i < outputChannelCount; i++) {
      pv = _getValue(offset) * dF0 +
          _getValue(offset + _offsets[1]) * dF1 +
          _getValue(offset + _offsets[2]) * dF2 +
          _getValue(offset + _offsets[3]) * dF3 +
          _getValue(offset + _offsets[4]) * dF4 +
          _getValue(offset + _offsets[5]) * dF5 +
          _getValue(offset + _offsets[6]) * dF6 +
          _getValue(offset + _offsets[7]) * dF7;

      dest[i] = pv;
      ++offset;
    }
    return dest;
  }

  Float64List interpolate3dTetra(Float64List source) {
    final dest = Float64List(outputChannelCount);
    final mx = maxGridPoints[0];
    final my = maxGridPoints[1];
    final mz = maxGridPoints[2];

    final x = source[0].clampDouble(0, 1.0) * mx;
    final y = source[1].clampDouble(0, 1.0) * my;
    final z = source[2].clampDouble(0, 1.0) * mz;

    var ix = x.toInt();
    var iy = y.toInt();
    var iz = z.toInt();

    var v = x - ix;
    var u = y - iy;
    var t = z - iz;

    if (ix == mx) {
      --ix;
      v = 1.0;
    }
    if (iy == my) {
      --iy;
      u = 1.0;
    }
    if (iz == mz) {
      --iz;
      t = 1.0;
    }

    var offset = ix * _offsets[1] + iy * _offsets[2] + iz * _offsets[4];
    for (var i = 0; i < outputChannelCount; ++i) {
      if (t < u) {
        if (t > v) {
          dest[i] = _getValue(offset) +
              t *
                  (_getValue(offset + _offsets[6]) -
                      _getValue(offset + _offsets[2])) +
              u * (_getValue(offset + _offsets[2]) - _getValue(offset)) +
              v *
                  (_getValue(offset + _offsets[7]) -
                      _getValue(offset + _offsets[6]));
        } else if (u < v) {
          dest[i] = _getValue(offset) +
              t *
                  (_getValue(offset + _offsets[7]) -
                      _getValue(offset + _offsets[3])) +
              u *
                  (_getValue(offset + _offsets[3]) -
                      _getValue(offset + _offsets[1])) +
              v * (_getValue(offset + _offsets[1]) - _getValue(offset));
        } else {
          dest[i] = _getValue(offset) +
              t *
                  (_getValue(offset + _offsets[7]) -
                      _getValue(offset + _offsets[3])) +
              u * (_getValue(offset + _offsets[2]) - _getValue(offset)) +
              v *
                  (_getValue(offset + _offsets[3]) -
                      _getValue(offset + _offsets[2]));
        }
      } else {
        if (t < v) {
          dest[i] = _getValue(offset) +
              t *
                  (_getValue(offset + _offsets[5]) -
                      _getValue(offset + _offsets[1])) +
              u *
                  (_getValue(offset + _offsets[7]) -
                      _getValue(offset + _offsets[5])) +
              v * (_getValue(offset + _offsets[1]) - _getValue(offset));
        } else if (u < v) {
          dest[i] = _getValue(offset) +
              t * (_getValue(offset + _offsets[4]) - _getValue(offset)) +
              u *
                  (_getValue(offset + _offsets[7]) -
                      _getValue(offset + _offsets[5])) +
              v *
                  (_getValue(offset + _offsets[5]) -
                      _getValue(offset + _offsets[4]));
        } else {
          dest[i] = _getValue(offset) +
              t * (_getValue(offset + _offsets[4]) - _getValue(offset)) +
              u *
                  (_getValue(offset + _offsets[6]) -
                      _getValue(offset + _offsets[4])) +
              v *
                  (_getValue(offset + _offsets[7]) -
                      _getValue(offset + _offsets[6]));
        }
      }
      ++offset;
    }
    return dest;
  }

  double _getValue(int offset) {
    if (precision == 1) {
      return _data[offset] / 255.0;
    } else {
      final high = _data[offset * 2];
      final low = _data[offset * 2 + 1];
      return (high << 8 | low) / 65535.0;
    }
  }

  static void _buildOffsetTable({
    required Uint32List offsets,
    required int inputChannelCount,
    required Uint32List dimensionSize,
  }) {
    // Helper fields for interpolation
    final int _n001;
    final int _n010;
    final int _n100;
    final int _n110;

    if (inputChannelCount == 1) {
      offsets[1] = _n001 = dimensionSize[0];
    } else if (inputChannelCount == 2) {
      offsets[1] = _n001 = dimensionSize[0];
      offsets[2] = _n010 = dimensionSize[1];
      offsets[3] = _n001 + _n010;
    } else if (inputChannelCount == 3) {
      offsets[1] = _n001 = dimensionSize[0];
      offsets[2] = _n010 = dimensionSize[1];
      offsets[3] = _n001 + _n010;
      offsets[4] = _n100 = dimensionSize[2];
      offsets[5] = _n100 + _n001;
      offsets[6] = _n110 = _n100 + _n010;
      offsets[7] = _n110 + _n001;
    } else if (inputChannelCount == 4) {
      offsets[1] = dimensionSize[0];
      offsets[2] = dimensionSize[1];
      offsets[3] = offsets[2] + offsets[1];
      offsets[4] = dimensionSize[2];
      offsets[5] = offsets[4] + offsets[1];
      offsets[6] = offsets[4] + offsets[2];
      offsets[7] = offsets[4] + offsets[3];
      offsets[8] = dimensionSize[3];
      offsets[9] = offsets[8] + offsets[1];
      offsets[10] = offsets[8] + offsets[2];
      offsets[11] = offsets[8] + offsets[3];
      offsets[12] = offsets[8] + offsets[4];
      offsets[13] = offsets[8] + offsets[5];
      offsets[14] = offsets[8] + offsets[6];
      offsets[15] = offsets[8] + offsets[7];
    }
  }
}

extension _NumExt on num {
  double clampDouble(double min, double max) {
    return clamp(min, max).toDouble();
  }
}
