import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

@immutable
class IccCLUT {
  final int inputChannelCount;
  final int outputChannelCount;
  final int numGridPoints;
  final List<int> gridPoints;
  final List<int> dimensionSize;
  final List<double> data;
  final List<int> maxGridPoints;
  final List<int> _offsets;

  const IccCLUT({
    required this.inputChannelCount,
    required this.outputChannelCount,
    required this.numGridPoints,
    required this.gridPoints,
    required this.dimensionSize,
    required this.data,
    required this.maxGridPoints,
    required final List<int> offsets,
  }) : _offsets = offsets;

  factory IccCLUT.fromBytesWithHeader(
    final DataStream data, {
    required final int inputChannelCount,
    required final int outputChannelCount,
  }) {
    // Skip 16-inputChannelCount bytes as we will never need them
    final gridPoints = List.generate(
      inputChannelCount,
      (final i) => data.readUnsigned8Number().value,
    );
    data.skip(16 - inputChannelCount);

    final precision = data.readUnsigned8Number().value;
    // 3 reserved bytes
    data.skip(3);

    return IccCLUT._internalFromBytes(
      data,
      inputChannelCount: inputChannelCount,
      outputChannelCount: outputChannelCount,
      precision: precision,
      gridPoints: gridPoints,
    );
  }

  factory IccCLUT.fromBytes(
    final DataStream data, {
    required final int numGridPoints,
    required final int inputChannelCount,
    required final int outputChannelCount,
    required final int precision,
  }) {
    final gridPoints = List.filled(inputChannelCount, 0);
    for (var i = 0; i < inputChannelCount; i++) {
      gridPoints[i] = numGridPoints;
    }
    return IccCLUT._internalFromBytes(
      data,
      inputChannelCount: inputChannelCount,
      outputChannelCount: outputChannelCount,
      precision: precision,
      gridPoints: gridPoints,
    );
  }

  factory IccCLUT._internalFromBytes(
    final DataStream data, {
    required final int inputChannelCount,
    required final int outputChannelCount,
    required final int precision,
    required final List<int> gridPoints,
  }) {
    // Init lists
    final dimensionSize = List.filled(inputChannelCount, 0);
    final maxGridPoints = List.filled(inputChannelCount, 0);

    var i = inputChannelCount - 1;
    dimensionSize[i] = outputChannelCount;
    var numPoints = Int64(gridPoints[i]);
    for (i--; i >= 0; i--) {
      dimensionSize[i] = dimensionSize[i + 1] * gridPoints[i + 1];
      numPoints *= Int64(gridPoints[i]);
    }
    final totalNumGridPoints = numPoints.toInt32().toInt();
    final size = totalNumGridPoints * outputChannelCount;
    final dataPoints = List.filled(size, 0.0);

    final num = totalNumGridPoints * outputChannelCount;

    // Read raw data
    final divisor = precision == 1 ? 255.0 : 65535.0;
    for (var i = 0; i < num; i++) {
      final raw = precision == 1
          ? data.readUnsigned8Number().value
          : data.readUnsigned16Number().value;
      dataPoints[i] = raw / divisor;
    }

    for (var i = 0; i < inputChannelCount; i++) {
      maxGridPoints[i] = gridPoints[i] - 1;
    }
    final offsets = List.filled(1 << inputChannelCount, 0);

    _buildOffsetTable(
      offsets: offsets,
      inputChannelCount: inputChannelCount,
      dimensionSize: dimensionSize,
    );
    return IccCLUT(
      inputChannelCount: inputChannelCount,
      outputChannelCount: outputChannelCount,
      numGridPoints: totalNumGridPoints,
      gridPoints: gridPoints,
      dimensionSize: UnmodifiableListView(dimensionSize),
      data: UnmodifiableListView(dataPoints),
      maxGridPoints: UnmodifiableListView(maxGridPoints),
      offsets: UnmodifiableListView(offsets),
    );
  }

  List<double> interpolate4d(final List<double> source) {
    final dest = List.filled(outputChannelCount, 0.0);
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

    final dF = List.filled(16, 0.0);
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
        value += data[p + _offsets[j]] * dF[j];
      }
      dest[i] = value;
      ++p;
    }

    return dest;
  }

  List<double> interpolate3d(final List<double> source) {
    final dest = List.filled(outputChannelCount, 0.0);

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
      pv = data[offset] * dF0 +
          data[offset + _offsets[1]] * dF1 +
          data[offset + _offsets[2]] * dF2 +
          data[offset + _offsets[3]] * dF3 +
          data[offset + _offsets[4]] * dF4 +
          data[offset + _offsets[5]] * dF5 +
          data[offset + _offsets[6]] * dF6 +
          data[offset + _offsets[7]] * dF7;

      dest[i] = pv;
      ++offset;
    }
    return dest;
  }

  List<double> interpolate3dTetra(final List<double> source) {
    final dest = List.filled(outputChannelCount, 0.0);
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
          dest[i] = data[offset] +
              t * (data[offset + _offsets[6]] - data[offset + _offsets[2]]) +
              u * (data[offset + _offsets[2]] - data[offset]) +
              v * (data[offset + _offsets[7]] - data[offset + _offsets[6]]);
        } else if (u < v) {
          dest[i] = data[offset] +
              t * (data[offset + _offsets[7]] - data[offset + _offsets[3]]) +
              u * (data[offset + _offsets[3]] - data[offset + _offsets[1]]) +
              v * (data[offset + _offsets[1]] - data[offset]);
        } else {
          dest[i] = data[offset] +
              t * (data[offset + _offsets[7]] - data[offset + _offsets[3]]) +
              u * (data[offset + _offsets[2]] - data[offset]) +
              v * (data[offset + _offsets[3]] - data[offset + _offsets[2]]);
        }
      } else {
        if (t < v) {
          dest[i] = data[offset] +
              t * (data[offset + _offsets[5]] - data[offset + _offsets[1]]) +
              u * (data[offset + _offsets[7]] - data[offset + _offsets[5]]) +
              v * (data[offset + _offsets[1]] - data[offset]);
        } else if (u < v) {
          dest[i] = data[offset] +
              t * (data[offset + _offsets[4]] - data[offset]) +
              u * (data[offset + _offsets[7]] - data[offset + _offsets[5]]) +
              v * (data[offset + _offsets[5]] - data[offset + _offsets[4]]);
        } else {
          dest[i] = data[offset] +
              t * (data[offset + _offsets[4]] - data[offset]) +
              u * (data[offset + _offsets[6]] - data[offset + _offsets[4]]) +
              v * (data[offset + _offsets[7]] - data[offset + _offsets[6]]);
        }
      }
      ++offset;
    }
    return dest;
  }

  static void _buildOffsetTable({
    required final List<int> offsets,
    required final int inputChannelCount,
    required final List<int> dimensionSize,
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
  double clampDouble(final double min, final double max) {
    return clamp(min, max).toDouble();
  }
}
