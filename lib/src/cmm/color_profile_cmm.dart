import 'dart:typed_data';

import 'package:icc_parser/src/cmm/color_profile_pcs_transform.dart';
import 'package:icc_parser/src/cmm/color_profile_transform.dart';
import 'package:icc_parser/src/utils/list_utils.dart';
import 'package:meta/meta.dart';

/// Simple color management system based on ICC profiles.
class ColorProfileCmm {
  /// Apply the given transformations to the given pixel. The pixel should have
  /// at least the number of components as the first transformation's source
  ///
  /// Create [steps] by using [buildTransformations] method.
  Float64List apply(
    List<ColorProfileTransformationStep> steps,
    Float64List source,
  ) {
    var pixel = source.copy();
    for (final step in steps) {
      pixel = step.transform.apply(pixel, step);
    }
    return pixel;
  }

  /// Build a list of transformation steps from the given list of transforms.
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

/// A single step in the color profile transformation.
@immutable
class ColorProfileTransformationStep {
  /// The transformation to apply.
  final ColorProfileTransform transform;

  /// Whether to convert the destination to the PCS color space.
  final bool useDestinationPCSConversion;

  /// Whether to convert the source to the PCS color space.
  final bool useSourcePCSConversion;

  /// Creates a new transformation step.
  const ColorProfileTransformationStep({
    required this.transform,
    required this.useDestinationPCSConversion,
    required this.useSourcePCSConversion,
  });
}
