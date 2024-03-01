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
  final List<_ColorProfilePcsStep> _steps;

  const ColorProfilePCSTransform({
    required super.profile,
    required List<_ColorProfilePcsStep> steps,
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
    final destSpace = destination.getSourceColorSpace();

    final steps = <_ColorProfilePcsStep>[];

    switch (sourceSpace) {
      case ColorSpaceSignature.icSigLabData:
        switch (destSpace) {
          case ColorSpaceSignature.icSigLabData:
            if (source.useLegacyPCS) {
              steps.add(_ColorProfileLab2ToXyz.create(source.profile));
            } else {
              steps.add(_ColorProfileLabToXyz.create(source.profile));
            }
            if (source.doAdjustPCS) {
              steps.add(_ColorProfileScale3.create(
                source.pcsScale![0],
                source.pcsScale![1],
                source.pcsScale![2],
              ));
              steps.add(_ColorProfileOffset3.create(
                source.pcsOffset![0],
                source.pcsOffset![1],
                source.pcsOffset![2],
              ));
            }
            final xyzConvertStep = _ColorProfileXYZConvertStep.create(
              source,
              destination,
            );
            if (xyzConvertStep != null) {
              steps.add(xyzConvertStep);
            }
            if (destination.doAdjustPCS) {
              steps.add(_ColorProfileOffset3.create(
                destination.pcsOffset![0] / destination.pcsScale![0],
                destination.pcsOffset![1] / destination.pcsScale![1],
                destination.pcsOffset![2] / destination.pcsScale![2],
              ));
              steps.add(_ColorProfileScale3.create(
                destination.pcsScale![0],
                destination.pcsScale![1],
                destination.pcsScale![2],
              ));
            }
            if (destination.useLegacyPCS) {
              steps.add(_ColorProfileXyzToLab2.create(destination.profile));
            } else {
              steps.add(_ColorProfileXyzToLab.create(destination.profile));
            }
            break;
          case ColorSpaceSignature.icSigXYZData:
            if (source.useLegacyPCS) {
              steps.add(_ColorProfileLab2ToXyz.create(source.profile));
            } else {
              steps.add(_ColorProfileLabToXyz.create(source.profile));
            }
            if (source.doAdjustPCS) {
              steps.add(_ColorProfileScale3.create(
                source.pcsScale![0],
                source.pcsScale![1],
                source.pcsScale![2],
              ));
              steps.add(_ColorProfileOffset3.create(
                source.pcsOffset![0],
                source.pcsOffset![1],
                source.pcsOffset![2],
              ));
            }
            final xyzConvertStep = _ColorProfileXYZConvertStep.create(
              source,
              destination,
            );
            if (xyzConvertStep != null) {
              steps.add(xyzConvertStep);
            }
            if (destination.doAdjustPCS) {
              steps.add(_ColorProfileOffset3.create(
                destination.pcsOffset![0] / destination.pcsScale![0],
                destination.pcsOffset![1] / destination.pcsScale![1],
                destination.pcsOffset![2] / destination.pcsScale![2],
              ));
              steps.add(_ColorProfileScale3.create(
                destination.pcsScale![0],
                destination.pcsScale![1],
                destination.pcsScale![2],
              ));
            }
            const scale = 32768 / 65535;
            steps.add(_ColorProfileScale3.create(scale, scale, scale));
            break;
          // ignore: no_default_cases
          default:
            break;
        }
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

abstract interface class _ColorProfilePcsStep {
  void apply({
    required Float64List source,
    required Float64List destination,
  });
}

@immutable
final class _ColorProfileLab2ToXyz implements _ColorProfilePcsStep {
  final Float64List xyzWhite;

  const _ColorProfileLab2ToXyz({
    required this.xyzWhite,
  });

  factory _ColorProfileLab2ToXyz.create(
    ColorProfile profile,
  ) {
    final xyzWhite = profile.getNormIlluminantXYZ();
    return _ColorProfileLab2ToXyz(
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

@immutable
final class _ColorProfileXyzToLab2 implements _ColorProfilePcsStep {
  final Float64List xyzWhite;

  const _ColorProfileXyzToLab2({
    required this.xyzWhite,
  });

  factory _ColorProfileXyzToLab2.create(
    ColorProfile profile,
  ) {
    final xyzWhite = profile.getNormIlluminantXYZ();
    return _ColorProfileXyzToLab2(
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

@immutable
final class _ColorProfileLabToXyz implements _ColorProfilePcsStep {
  final Float64List xyzWhite;

  const _ColorProfileLabToXyz({
    required this.xyzWhite,
  });

  factory _ColorProfileLabToXyz.create(
    ColorProfile profile,
  ) {
    final xyzWhite = profile.getNormIlluminantXYZ();
    return _ColorProfileLabToXyz(
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

@immutable
final class _ColorProfileXyzToLab implements _ColorProfilePcsStep {
  final Float64List xyzWhite;

  const _ColorProfileXyzToLab({
    required this.xyzWhite,
  });

  factory _ColorProfileXyzToLab.create(
    ColorProfile profile,
  ) {
    final xyzWhite = profile.getNormIlluminantXYZ();
    return _ColorProfileXyzToLab(
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

@immutable
final class _ColorProfileScale3 implements _ColorProfilePcsStep {
  final Float64List scale;

  const _ColorProfileScale3({
    required this.scale,
  });

  factory _ColorProfileScale3.create(
    double v1,
    double v2,
    double v3,
  ) {
    return _ColorProfileScale3(
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

@immutable
final class _ColorProfileOffset3 implements _ColorProfilePcsStep {
  final Float64List offset;

  const _ColorProfileOffset3({
    required this.offset,
  });

  factory _ColorProfileOffset3.create(
    double v1,
    double v2,
    double v3, [
    bool convertIntXyzOffset = true,
  ]) {
    if (convertIntXyzOffset) {
      return _ColorProfileOffset3(
        offset: threeDoubles(
          v1 * 65535.0 / 32768.0,
          v2 * 65535.0 / 32768.0,
          v3 * 65535.0 / 32768.0,
        ),
      );
    }
    return _ColorProfileOffset3(
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

@immutable
final class _ColorProfileXYZConvertStep implements _ColorProfilePcsStep {
  const _ColorProfileXYZConvertStep._();

  static _ColorProfileXYZConvertStep? create(
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
