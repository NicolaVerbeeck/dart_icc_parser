import 'dart:math';

import 'package:icc_parser/src/types/tag/curve/icc_curve.dart';
import 'package:icc_parser/src/types/tag/tag_type.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

@immutable
final class IccTagParametricCurve extends IccCurve {
  final int functionType;
  final int numberOfParameters;
  final List<double> dParam;

  @override
  KnownTagType get type => KnownTagType.icSigParametricCurveType;

  const IccTagParametricCurve({
    required this.functionType,
    required this.numberOfParameters,
    required this.dParam,
  });

  factory IccTagParametricCurve.fromBytes(
    DataStream data, {
    required int size,
  }) {
    final signature = data.readUnsigned32Number().value;
    assert(signature == KnownTagType.icSigParametricCurveType.code);

    data.skip(4);
    final functionType = data.readUnsigned16Number().value;
    data.skip(2);

    // 12 is the size of the header, 2 is the size of each parameter
    final fallBack = (size - 12) ~/ 2;

    final numberOfParameters =
        _numberOfParametersForFunction(functionType, fallBack);
    final dParam = List.generate(numberOfParameters,
        (_) => data.readSigned15Fixed16Number().value / 65536.0);

    return IccTagParametricCurve(
      functionType: functionType,
      numberOfParameters: numberOfParameters,
      dParam: dParam,
    );
  }

  @override
  double apply(double value) {
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
    int functionType,
    int fallBack,
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
