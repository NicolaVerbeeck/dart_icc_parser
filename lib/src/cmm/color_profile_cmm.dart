import 'dart:typed_data';

import 'package:icc_parser/src/cmm/color_profile_pcs_transform.dart';
import 'package:icc_parser/src/cmm/color_profile_transform.dart';
import 'package:icc_parser/src/utils/list_utils.dart';
import 'package:meta/meta.dart';

class ColorProfileCmm {

  Float64List apply(List<ColorProfileTransformationStep> steps, Float64List source) {
    var pixel = source.copy();
    for (final step in steps) {
      pixel = step.transform.apply(pixel, step);
    }
    return pixel;
  }

  List<ColorProfileTransformationStep> buildTransformations(
    List<ColorProfileTransform> transformations, {
    bool usePCSConversions = false,
  }) {
    assert(transformations.isNotEmpty);

    if (transformations.length == 1) {
      return [
        ColorProfileTransformationStep(
          transform: transformations.first,
          useDestinationPCSConversion: true,
          useSourcePCSConversion: true,
        )
      ];
    }

    final holders = transformations
        .map((e) => _TransformationStepHolder(transform: e))
        .toList();

    final outputHolders = <_TransformationStepHolder>[
      holders.first,
    ];

    for (var i = 1; i < transformations.length; ++i) {
      final last = holders[i - 1];
      final next = holders[i];

      if (!usePCSConversions &&
          (isSpaceColorimetricPCS(last.transform.getDestinationColorSpace()) ||
              isSpaceColorimetricPCS(next.transform.getSourceColorSpace()))) {
        last.useDestinationPCSConversion = false;
        next.useSourcePCSConversion = false;

        final pcsTransform =
            ColorProfilePCSTransform.connect(last.transform, next.transform);
        if (pcsTransform != null) {
          outputHolders.add(_TransformationStepHolder(transform: pcsTransform));
        }
      }
      outputHolders.add(next);
    }

    return outputHolders
        .map((e) => ColorProfileTransformationStep(
              transform: e.transform,
              useDestinationPCSConversion: e.useDestinationPCSConversion,
              useSourcePCSConversion: e.useSourcePCSConversion,
            ))
        .toList();
  }
}

class _TransformationStepHolder {
  final ColorProfileTransform transform;
  bool useDestinationPCSConversion = true;
  bool useSourcePCSConversion = true;

  _TransformationStepHolder({
    required this.transform,
  });
}

@immutable
final class ColorProfileTransformationStep {
  final ColorProfileTransform transform;
  final bool useDestinationPCSConversion;
  final bool useSourcePCSConversion;

  const ColorProfileTransformationStep({
    required this.transform,
    required this.useDestinationPCSConversion,
    required this.useSourcePCSConversion,
  });
}
