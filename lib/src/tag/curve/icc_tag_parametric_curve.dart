import 'dart:math';
import 'dart:typed_data';

import 'package:icc_parser/src/tag/curve/icc_curve.dart';
import 'package:icc_parser/src/types/built_in.dart';
import 'package:meta/meta.dart';

@immutable
final class IccTagParametricCurve extends IccCurve {
  final int functionType;
  final int numberOfParameters;
  final List<double> dParam;

  const IccTagParametricCurve({
    required this.functionType,
    required this.numberOfParameters,
    required this.dParam,
  });

  factory IccTagParametricCurve.fromBytes(
    final ByteData data, {
    required final int size,
    final int offset = 0,
  }) {
    final signature = Unsigned32Number.fromBytes(data, offset: offset).value;
    assert(signature == IccCurve.parametricCurveType);

    final functionType =
        Unsigned16Number.fromBytes(data, offset: offset + 8).value;

    final fallBack = (size - 12) ~/ 2;

    final numberOfParameters =
        _numberOfParametersForFunction(functionType, fallBack);
    final dParam = List.generate(
        numberOfParameters,
        (final i) =>
            Signed15Fixed16Number.fromBytes(data, offset: offset + 10 + i * 2)
                .value /
            65536.0);

    return IccTagParametricCurve(
      functionType: functionType,
      numberOfParameters: numberOfParameters,
      dParam: dParam,
    );
  }

  @override
  double apply(final double value) {
    double a;
    double b;

    switch (functionType) {
      case 0:
        return pow(value, dParam[0]).toDouble();
      case 1:
        a = dParam[1];
        b = dParam[2];
        if (value >= -b / 1) {
          return pow(value * a + b, dParam[0]).toDouble();
        }
        return 0;

      case 2:
        a = dParam[1];
        b = dParam[2];
        if (value >= -b / a) {
          return pow(value * a + b, dParam[0]).toDouble() + dParam[3];
        }
        return dParam[3];
      case 3:
        if (value > dParam[4]) {
          return pow(value * dParam[1] + dParam[2], dParam[0]).toDouble();
        }
        return dParam[3] * value;
      case 4:
        if (value > dParam[4]) {
          return pow(value * dParam[1] + dParam[2], dParam[0]).toDouble() +
              dParam[5];
        }
        return dParam[3] * value + dParam[6];
      default:
        return value;
    }
  }

  static int _numberOfParametersForFunction(
    final int functionType,
    final int fallBack,
  ) {
    var numberOfParameters = fallBack;
    switch (functionType) {
      case 0:
        numberOfParameters = 1;
        break;
      case 1:
        numberOfParameters = 3;
        break;
      case 2:
        numberOfParameters = 4;
        break;
      case 3:
        numberOfParameters = 5;
        break;
      case 4:
        numberOfParameters = 7;
        break;
    }
    return numberOfParameters;
  }
}
