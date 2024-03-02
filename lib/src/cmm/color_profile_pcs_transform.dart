import 'dart:typed_data';

import 'package:icc_parser/src/cmm/color_profile_cmm.dart';
import 'package:icc_parser/src/cmm/color_profile_pcs.dart';
import 'package:icc_parser/src/cmm/color_profile_transform.dart';
import 'package:icc_parser/src/color_profile.dart';
import 'package:icc_parser/src/types/color_profile_header.dart';
import 'package:icc_parser/src/utils/list_utils.dart';
import 'package:meta/meta.dart';

@immutable
class ColorProfilePCSTransform extends ColorProfileTransform {
  final List<ColorProfilePcsStep> _steps;

  @visibleForTesting
  List<ColorProfilePcsStep> get steps => _steps;

  const ColorProfilePCSTransform({
    required super.profile,
    required List<ColorProfilePcsStep> steps,
  })  : _steps = steps,
        super(
            pcsOffset: null,
            pcsScale: null,
            doAdjustPCS: false,
            isInput: false);

  static ColorProfilePCSTransform? connect(
    ColorProfileTransform source,
    ColorProfileTransform destination,
  ) {
    if (!source.isInput || (destination.isInput && !destination.isAbstract)) {
      throw Exception('Bad space link');
    }

    final sourceSpace = source.getDestinationColorSpace();

    var steps = <ColorProfilePcsStep>[];
    switch (sourceSpace) {
      case ColorSpaceSignature.icSigLabData:
        steps = _createStepsForSourceLabSpace(source, destination);
        break;
      case ColorSpaceSignature.icSigXYZData:
        steps = _createStepsForSourceXYZSpace(source, destination);
        break;
      // ignore: no_default_cases
      default:
        break;
    }
    if (steps.isEmpty) return null;
    return ColorProfilePCSTransform(
      profile: source.profile,
      steps: steps,
    );
  }

  static List<ColorProfilePcsStep> _createStepsForSourceLabSpace(
    ColorProfileTransform source,
    ColorProfileTransform destination,
  ) {
    final steps = <ColorProfilePcsStep>[];

    final destSpace = destination.getSourceColorSpace();

    switch (destSpace) {
      case ColorSpaceSignature.icSigLabData:
        if (source.useLegacyPCS) {
          steps.add(ColorProfileLab2ToXyz.create(source.profile));
        } else {
          steps.add(ColorProfileLabToXyz.create(source.profile));
        }
        if (source.doAdjustPCS) {
          steps.add(ColorProfileScale3.create(
            source.pcsScale![0],
            source.pcsScale![1],
            source.pcsScale![2],
          ));
          steps.add(ColorProfileOffset3.create(
            source.pcsOffset![0],
            source.pcsOffset![1],
            source.pcsOffset![2],
          ));
        }
        final xyzConvertStep = ColorProfileXYZConvertStep.create(
          source,
          destination,
        );
        if (xyzConvertStep != null) {
          steps.add(xyzConvertStep);
        }
        if (destination.doAdjustPCS) {
          steps.add(ColorProfileOffset3.create(
            destination.pcsOffset![0] / destination.pcsScale![0],
            destination.pcsOffset![1] / destination.pcsScale![1],
            destination.pcsOffset![2] / destination.pcsScale![2],
          ));
          steps.add(ColorProfileScale3.create(
            destination.pcsScale![0],
            destination.pcsScale![1],
            destination.pcsScale![2],
          ));
        }
        if (destination.useLegacyPCS) {
          steps.add(ColorProfileXyzToLab2.create(destination.profile));
        } else {
          steps.add(ColorProfileXyzToLab.create(destination.profile));
        }
        break;
      case ColorSpaceSignature.icSigXYZData:
        if (source.useLegacyPCS) {
          steps.add(ColorProfileLab2ToXyz.create(source.profile));
        } else {
          steps.add(ColorProfileLabToXyz.create(source.profile));
        }
        if (source.doAdjustPCS) {
          steps.add(ColorProfileScale3.create(
            source.pcsScale![0],
            source.pcsScale![1],
            source.pcsScale![2],
          ));
          steps.add(ColorProfileOffset3.create(
            source.pcsOffset![0],
            source.pcsOffset![1],
            source.pcsOffset![2],
          ));
        }
        final xyzConvertStep = ColorProfileXYZConvertStep.create(
          source,
          destination,
        );
        if (xyzConvertStep != null) {
          steps.add(xyzConvertStep);
        }
        if (destination.doAdjustPCS) {
          steps.add(ColorProfileOffset3.create(
            destination.pcsOffset![0] / destination.pcsScale![0],
            destination.pcsOffset![1] / destination.pcsScale![1],
            destination.pcsOffset![2] / destination.pcsScale![2],
          ));
          steps.add(ColorProfileScale3.create(
            destination.pcsScale![0],
            destination.pcsScale![1],
            destination.pcsScale![2],
          ));
        }
        const scale = 32768 / 65535;
        steps.add(ColorProfileScale3.create(scale, scale, scale));
        break;
      // ignore: no_default_cases
      default:
        break;
    }
    return steps;
  }

  static List<ColorProfilePcsStep> _createStepsForSourceXYZSpace(
    ColorProfileTransform source,
    ColorProfileTransform destination,
  ) {
    final steps = <ColorProfilePcsStep>[];

    final destSpace = destination.getSourceColorSpace();
    switch (destSpace) {
      case ColorSpaceSignature.icSigLabData:
        const scale = 65535 / 32768;
        steps.add(ColorProfileScale3.create(scale, scale, scale));
        if (source.doAdjustPCS) {
          steps.add(ColorProfileScale3.create(
            source.pcsScale![0],
            source.pcsScale![1],
            source.pcsScale![2],
          ));
          steps.add(ColorProfileOffset3.create(
            source.pcsOffset![0],
            source.pcsOffset![1],
            source.pcsOffset![2],
          ));
        }
        final xyzConvertStep = ColorProfileXYZConvertStep.create(
          source,
          destination,
        );
        if (xyzConvertStep != null) {
          steps.add(xyzConvertStep);
        }
        if (destination.doAdjustPCS) {
          steps.add(ColorProfileOffset3.create(
            destination.pcsOffset![0] / destination.pcsScale![0],
            destination.pcsOffset![1] / destination.pcsScale![1],
            destination.pcsOffset![2] / destination.pcsScale![2],
          ));
          steps.add(ColorProfileScale3.create(
            destination.pcsScale![0],
            destination.pcsScale![1],
            destination.pcsScale![2],
          ));
        }
        if (destination.useLegacyPCS) {
          steps.add(ColorProfileXyzToLab2.create(destination.profile));
        } else {
          steps.add(ColorProfileXyzToLab.create(destination.profile));
        }
        break;
      case ColorSpaceSignature.icSigXYZData:
        const scale = 65535 / 32768;
        steps.add(ColorProfileScale3.create(scale, scale, scale));
        if (source.doAdjustPCS) {
          steps.add(ColorProfileScale3.create(
            source.pcsScale![0],
            source.pcsScale![1],
            source.pcsScale![2],
          ));
          steps.add(ColorProfileOffset3.create(
            source.pcsOffset![0],
            source.pcsOffset![1],
            source.pcsOffset![2],
          ));
        }
        final xyzConvertStep = ColorProfileXYZConvertStep.create(
          source,
          destination,
        );
        if (xyzConvertStep != null) {
          steps.add(xyzConvertStep);
        }
        if (destination.doAdjustPCS) {
          steps.add(ColorProfileOffset3.create(
            destination.pcsOffset![0] / destination.pcsScale![0],
            destination.pcsOffset![1] / destination.pcsScale![1],
            destination.pcsOffset![2] / destination.pcsScale![2],
          ));
          steps.add(ColorProfileScale3.create(
            destination.pcsScale![0],
            destination.pcsScale![1],
            destination.pcsScale![2],
          ));
        }
        const scale2 = 32768 / 65535;
        steps.add(ColorProfileScale3.create(scale2, scale2, scale2));
        break;
      // ignore: no_default_cases
      default:
        break;
    }
    return steps;
  }

  @override
  Float64List apply(Float64List source, ColorProfileTransformationStep step) {
    if (_steps.isEmpty) {
      return source.sublist(0, getSourceColorSpace().numSamples);
    }
    var p1 = Float64List(3);
    var p2 = Float64List(3);
    Float64List temp;
    var varSource = source;
    for (final step in _steps) {
      step.apply(source: varSource, destination: p1);
      varSource = p1;
      temp = p1;
      p1 = p2;
      p2 = temp;
    }
    return varSource;
  }
}

@visibleForTesting
abstract interface class ColorProfilePcsStep {
  void apply({
    required Float64List source,
    required Float64List destination,
  });
}

@visibleForTesting
@immutable
final class ColorProfileLab2ToXyz implements ColorProfilePcsStep {
  final Float64List xyzWhite;

  const ColorProfileLab2ToXyz({
    required this.xyzWhite,
  });

  factory ColorProfileLab2ToXyz.create(
    ColorProfile profile,
  ) {
    final xyzWhite = profile.getNormIlluminantXYZ();
    return ColorProfileLab2ToXyz(
      xyzWhite: Float64List.fromList(xyzWhite.map((e) => e.value).toList()),
    );
  }

  @override
  void apply({
    required Float64List source,
    required Float64List destination,
  }) {
    final lab = threeDoubles(
      source[0] * (65535.0 / 65280.0) * 100.0,
      source[1] * 65535.0 / 65280.0 * 255.0 - 128.0,
      source[2] * 65535.0 / 65280.0 * 255.0 - 128.0,
    );

    ColorProfilePCSUtils.icLabToXYZ(destination, lab: lab, whiteXYZ: xyzWhite);
  }
}

@visibleForTesting
@immutable
final class ColorProfileXyzToLab2 implements ColorProfilePcsStep {
  final Float64List xyzWhite;

  const ColorProfileXyzToLab2({
    required this.xyzWhite,
  });

  factory ColorProfileXyzToLab2.create(
    ColorProfile profile,
  ) {
    final xyzWhite = profile.getNormIlluminantXYZ();
    return ColorProfileXyzToLab2(
      xyzWhite: Float64List.fromList(xyzWhite.map((e) => e.value).toList()),
    );
  }

  @override
  void apply({
    required Float64List source,
    required Float64List destination,
  }) {
    final lab = Float64List(3);

    ColorProfilePCSUtils.icXYZtoLab(lab, xyz: source, whiteXYZ: xyzWhite);

    destination[0] = (lab[0] / 100.0) * (65280.0 / 65535.0);
    destination[1] = (lab[1] + 128.0) / 255.0 * (65280.0 / 65535.0);
    destination[2] = (lab[2] + 128.0) / 255.0 * (65280.0 / 65535.0);
  }
}

@visibleForTesting
@immutable
final class ColorProfileLabToXyz implements ColorProfilePcsStep {
  final Float64List xyzWhite;

  const ColorProfileLabToXyz({
    required this.xyzWhite,
  });

  factory ColorProfileLabToXyz.create(
    ColorProfile profile,
  ) {
    final xyzWhite = profile.getNormIlluminantXYZ();
    return ColorProfileLabToXyz(
      xyzWhite: Float64List.fromList(xyzWhite.map((e) => e.value).toList()),
    );
  }

  @override
  void apply({
    required Float64List source,
    required Float64List destination,
  }) {
    final lab = threeDoubles(
      source[0] * 100.0,
      source[1] * 255.0 - 128.0,
      source[2] * 255.0 - 128.0,
    );

    ColorProfilePCSUtils.icLabToXYZ(destination, lab: lab, whiteXYZ: xyzWhite);
  }
}

@visibleForTesting
@immutable
final class ColorProfileXyzToLab implements ColorProfilePcsStep {
  final Float64List xyzWhite;

  const ColorProfileXyzToLab({
    required this.xyzWhite,
  });

  factory ColorProfileXyzToLab.create(
    ColorProfile profile,
  ) {
    final xyzWhite = profile.getNormIlluminantXYZ();
    return ColorProfileXyzToLab(
      xyzWhite: Float64List.fromList(xyzWhite.map((e) => e.value).toList()),
    );
  }

  @override
  void apply({
    required Float64List source,
    required Float64List destination,
  }) {
    final lab = Float64List(3);

    ColorProfilePCSUtils.icXYZtoLab(lab, xyz: source, whiteXYZ: xyzWhite);

    destination[0] = lab[0] / 100.0;
    destination[1] = (lab[1] + 128.0) / 255.0;
    destination[2] = (lab[2] + 128.0) / 255.0;
  }
}

@visibleForTesting
@immutable
final class ColorProfileScale3 implements ColorProfilePcsStep {
  final Float64List scale;

  const ColorProfileScale3({
    required this.scale,
  });

  factory ColorProfileScale3.create(
    double v1,
    double v2,
    double v3,
  ) {
    return ColorProfileScale3(
      scale: threeDoubles(v1, v2, v3),
    );
  }

  @override
  void apply({
    required Float64List source,
    required Float64List destination,
  }) {
    destination[0] = source[0] * scale[0];
    destination[1] = source[1] * scale[1];
    destination[2] = source[2] * scale[2];
  }
}

@visibleForTesting
@immutable
final class ColorProfileOffset3 implements ColorProfilePcsStep {
  final Float64List offset;

  const ColorProfileOffset3({
    required this.offset,
  });

  factory ColorProfileOffset3.create(
    double v1,
    double v2,
    double v3, [
    bool convertIntXyzOffset = true,
  ]) {
    if (convertIntXyzOffset) {
      return ColorProfileOffset3(
        offset: threeDoubles(
          v1 * 65535.0 / 32768.0,
          v2 * 65535.0 / 32768.0,
          v3 * 65535.0 / 32768.0,
        ),
      );
    }
    return ColorProfileOffset3(
      offset: threeDoubles(v1, v2, v3),
    );
  }

  @override
  void apply({
    required Float64List source,
    required Float64List destination,
  }) {
    destination[0] = source[0] + offset[0];
    destination[1] = source[1] + offset[1];
    destination[2] = source[2] + offset[2];
  }
}

@visibleForTesting
@immutable
final class ColorProfileXYZConvertStep implements ColorProfilePcsStep {
  const ColorProfileXYZConvertStep._();

  static ColorProfileXYZConvertStep? create(
    ColorProfileTransform source,
    ColorProfileTransform destination,
  ) {
    if (_isEquivalentPcc(source.profile, destination.profile)) {
      return null;
    }
    return null; // We don't have non-standard PCSs
  }

  @override
  void apply({
    required Float64List source,
    required Float64List destination,
  }) {}
}

bool _isEquivalentPcc(
  ColorProfile source,
  ColorProfile destination,
) {
  final illuminant = source.illuminant;
  final observer = source.pccObserver;

  if (illuminant != destination.illuminant) return false;
  if (observer != destination.pccObserver) return false;

  return true;
}
