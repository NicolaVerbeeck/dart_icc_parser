import 'dart:math';
import 'dart:typed_data';

import 'package:icc_parser/src/error.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag_type.dart';
import 'package:icc_parser/src/types/tag/curve/color_profile_curve.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:icc_parser/src/utils/list_utils.dart';
import 'package:icc_parser/src/utils/num_utils.dart';
import 'package:meta/meta.dart';

@immutable
final class ColorProfileTagParametricCurve extends ColorProfileCurve {
  final int functionType;
  final int numberOfParameters;
  final Float64List dParam;

  @override
  ColorProfileTagType get type => ColorProfileTagType.icSigParametricCurveType;

  const ColorProfileTagParametricCurve({
    required this.functionType,
    required this.numberOfParameters,
    required this.dParam,
  });

  factory ColorProfileTagParametricCurve.fromBytes(
    DataStream data, {
    required int size,
  }) {
    final signature = data.readUnsigned32Number().value;
    if (signature != ColorProfileTagType.icSigParametricCurveType.code) {
      throw InvalidSignatureException(
        expected: ColorProfileTagType.icSigParametricCurveType.code,
        got: signature,
      );
    }

    data.skip(4);
    final functionType = data.readUnsigned16Number().value;
    data.skip(2);

    // 12 is the size of the header, 2 is the size of each parameter
    final fallBack = (size - 12) ~/ 2;

    final numberOfParameters =
        _numberOfParametersForFunction(functionType, fallBack);
    final dParam = generateFloat64List(
      numberOfParameters,
      (_) => data.readSigned15Fixed16Number().value,
    );

    return ColorProfileTagParametricCurve(
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
        if (value >= -b / a) {
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

  @override
  bool get isIdentity {
    switch (functionType) {
      case 0:
        return isUnity(dParam[0]);
      case 1:
      case 2:
      case 3:
      case 4:
        return false;
      default:
        return true;
    }
  }
}
