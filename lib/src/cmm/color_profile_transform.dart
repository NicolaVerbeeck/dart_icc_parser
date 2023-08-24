import 'dart:typed_data';

import 'package:icc_parser/src/cmm/color_profile_cmm.dart';
import 'package:icc_parser/src/cmm/color_profile_pcs.dart';
import 'package:icc_parser/src/cmm/color_profile_transform_3d.dart';
import 'package:icc_parser/src/cmm/color_profile_transform_4d.dart';
import 'package:icc_parser/src/cmm/color_profile_transform_matrix_trc.dart';
import 'package:icc_parser/src/cmm/enums.dart';
import 'package:icc_parser/src/color_profile.dart';
import 'package:icc_parser/src/types/color_profile_header.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag_type.dart';
import 'package:icc_parser/src/types/tag/color_profile_tags.dart';
import 'package:icc_parser/src/types/tag/lut/color_profile_mbb.dart';
import 'package:meta/meta.dart';

/// A color space transformation holder based on a [ColorProfile].
@immutable
abstract class ColorProfileTransform {
  /// The [ColorProfile] that is used as source for the transformation
  final ColorProfile profile;

  /// Whether to adjust the PCS (Profile Connection Space) or not.
  final bool doAdjustPCS;

  /// Whether the transformation is an input or output transformation.
  final bool isInput;

  /// The optional PCS scale.
  final Float64List? pcsScale;

  /// The optional PCS offset.
  final Float64List? pcsOffset;

  /// Create a new [ColorProfileTransform].
  const ColorProfileTransform({
    required this.profile,
    required this.doAdjustPCS,
    required this.isInput,
    required this.pcsScale,
    required this.pcsOffset,
  });

  /// Apply the transformation to the [source] using extra information from [step]
  /// [source] must hold at least the number of channels defined for this
  /// transform in [ColorProfile] (depending on input or output)
  Float64List apply(Float64List source, ColorProfileTransformationStep step);

  /// Create a new [ColorProfileTransform] from a [ColorProfile] definition
  /// Note that not all transformations are supported at this time, an
  /// exception will be thrown if an unsupported transformation is found.
  factory ColorProfileTransform.create({
    required ColorProfile profile,
    required bool isInput,
    required ColorProfileRenderingIntent intent,
    required ColorProfileInterpolation interpolation,
    required ColorProfileTransformLutType lutType,
    required bool useD2BTags,
  }) {
    var renderIntent = intent;

    if (profile.header.resolvedDeviceClass == DeviceClass.link) {
      renderIntent = ColorProfileRenderingIntent.perceptual;
    }
    switch (lutType) {
      case ColorProfileTransformLutType.color:
        return _createLutColorTransform(
          profile: profile,
          isInput: isInput,
          intent: renderIntent,
          interpolation: interpolation,
          useD2BTags: useD2BTags,
        );
      // ignore: no_default_cases
      default:
        throw ArgumentError('Unsupported lut type: $lutType');
    }
  }

  @protected
  Float64List checkSourceAbsolute(
    Float64List source,
    ColorProfileTransformationStep step,
  ) {
    if (doAdjustPCS && !isInput && step.useSourcePCSConversion) {
      return adjustPCS(source);
    }
    return source;
  }

  @protected
  Float64List checkDestinationAbsolute(
    Float64List source,
    ColorProfileTransformationStep step,
  ) {
    if (doAdjustPCS && isInput && step.useDestinationPCSConversion) {
      return adjustPCS(source);
    }
    return source;
  }

  @protected
  Float64List adjustPCS(Float64List source) {
    assert(source.length == 3);
    assert(pcsScale != null);
    assert(pcsOffset != null);

    final space = resolveColorSpaceSignature(profile.header.pcs);

    final dest = Float64List(3);
    if (space == ColorSpaceSignature.icSigLabData) {
      if (useLegacyPCS) {
        ColorProfilePCSUtils.lab2ToXyz(
            source: source, dest: dest, noClip: true);
      } else {
        ColorProfilePCSUtils.labToXyz(source: source, dest: dest, noClip: true);
      }
    } else {
      dest[0] = source[0];
      dest[1] = source[1];
      dest[2] = source[2];
    }

    dest[0] = dest[0] * pcsScale![0] + pcsOffset![0];
    dest[1] = dest[1] * pcsScale![1] + pcsOffset![1];
    dest[2] = dest[2] * pcsScale![2] + pcsOffset![2];

    if (space == ColorSpaceSignature.icSigLabData) {
      if (useLegacyPCS) {
        ColorProfilePCSUtils.xyzToLab2(source: dest, dest: dest, noClip: true);
      } else {
        ColorProfilePCSUtils.xyzToLab(source: dest, dest: dest, noClip: true);
      }
    } else {
      dest[0] = dest[0].clamp(0, double.maxFinite);
      dest[1] = dest[1].clamp(0, double.maxFinite);
      dest[2] = dest[2].clamp(0, double.maxFinite);
    }
    return dest;
  }

  @protected
  bool get useLegacyPCS => false;

  @protected
  bool get isAbstract =>
      profile.header.resolvedDeviceClass == DeviceClass.abstract;

  static ColorProfileTransform _createTransformFromTypeAndTag({
    required ColorProfileTransformType type,
    required ColorProfileTag tag,
    required ColorProfile profile,
    required bool doAdjustPCS,
    required bool isInput,
    required bool srcPCSConversion,
    required bool dstPCSConversion,
    required Float64List? pcsScale,
    required Float64List? pcsOffset,
    required ColorProfileInterpolation interpolation,
  }) {
    switch (type) {
      case ColorProfileTransformType.transform3D:
        return ColorProfileTransform3DLut.fromTag(
          tag: tag as ColorProfileMBB,
          profile: profile,
          doAdjustPCS: doAdjustPCS,
          isInput: isInput,
          pcsOffset: pcsOffset,
          pcsScale: pcsScale,
          interpolation: interpolation,
        );
      case ColorProfileTransformType.transform4D:
        return ColorProfileTransform4DLut.fromTag(
          tag: tag as ColorProfileMBB,
          profile: profile,
          doAdjustPCS: doAdjustPCS,
          isInput: isInput,
          pcsOffset: pcsOffset,
          pcsScale: pcsScale,
        );
    }
  }

  static ColorProfileTransform _createLutColorTransform({
    required ColorProfile profile,
    required bool isInput,
    required ColorProfileRenderingIntent intent,
    required ColorProfileInterpolation interpolation,
    required bool useD2BTags,
  }) {
    const useColorimetricTags = true;
    ColorProfileTag? tag;

    if (isInput) {
      if (useD2BTags) {
        tag = profile
            .findTag(ICCColorProfileTag.icSigDToB0Tag.offsetWithIntent(intent));
      }
      if (useColorimetricTags && tag == null) {
        tag = profile
            .findTag(ICCColorProfileTag.icSigAToB0Tag.offsetWithIntent(intent));
        tag ??= profile.findTag(ICCColorProfileTag.icSigAToB0Tag);
        tag ??= profile.findTag(ICCColorProfileTag.icSigAToB1Tag);
      }
      if (tag?.type == ColorProfileTagType.icSigMultiProcessElementType) {
        throw Exception('Multi processing elements are not supported');
      }
      if (tag == null && profile.header.version.value < 0x05000000) {
        if (profile.header.resolvedColorSpace ==
            ColorSpaceSignature.icSigRgbData) {
          final params = _begin(
            intent: intent,
            profile: profile,
            hasPerceptualHandling: true,
            isInput: isInput,
          );
          return ColorProfileTransformMatrixTRC.create(
            profile: profile,
            doAdjustPCS: params.adjustPCS,
            isInput: isInput,
            pcsScale: params.pcsScale,
            pcsOffset: params.pcsOffset,
          );
        } else if (profile.header.resolvedColorSpace ==
            ColorSpaceSignature.icSigGrayData) {
          // TODO Implement
        }
      }
      if (tag == null) {
        throw Exception('Could not find tag for rendering intent');
      }
      final params = _begin(
        intent: intent,
        profile: profile,
        hasPerceptualHandling: true,
        isInput: isInput,
      );
      final transformType = switch (profile.header.resolvedColorSpace) {
        ColorSpaceSignature.icSigXYZData ||
        ColorSpaceSignature.icSigLabData ||
        ColorSpaceSignature.icSigLuvData ||
        ColorSpaceSignature.icSigYCbCrData ||
        ColorSpaceSignature.icSigYxyData ||
        ColorSpaceSignature.icSigRgbData ||
        ColorSpaceSignature.icSigHsvData ||
        ColorSpaceSignature.icSigHlsData ||
        ColorSpaceSignature.icSigCmyData ||
        ColorSpaceSignature.icSig3colorData =>
          ColorProfileTransformType.transform3D,
        ColorSpaceSignature.icSig4colorData ||
        ColorSpaceSignature.icSigCmykData =>
          ColorProfileTransformType.transform4D,
        _ => throw Exception(
            'Unsupported color space ${profile.header.resolvedColorSpace}'),
      };
      return _createTransformFromTypeAndTag(
        type: transformType,
        tag: tag,
        profile: profile,
        doAdjustPCS: params.adjustPCS,
        isInput: isInput,
        // TODO these change based on connection
        srcPCSConversion: true,
        dstPCSConversion: true,
        pcsScale: params.pcsScale,
        pcsOffset: params.pcsOffset,
        interpolation: interpolation,
      );
    }
    // Not input
    if (useD2BTags) {
      tag = profile
          .findTag(ICCColorProfileTag.icSigBToD0Tag.offsetWithIntent(intent));
    }
    if (useColorimetricTags) {
      tag ??= profile
          .findTag(ICCColorProfileTag.icSigBToA0Tag.offsetWithIntent(intent));
      tag ??= profile.findTag(ICCColorProfileTag.icSigBToA0Tag);
    }
    if (tag?.type == ColorProfileTagType.icSigMultiProcessElementType) {
      throw Exception('Multi processing elements are not supported');
    }
    if (tag == null && profile.header.version.value < 0x05000000) {
      if (profile.header.resolvedColorSpace ==
          ColorSpaceSignature.icSigRgbData) {
        final params = _begin(
          intent: intent,
          profile: profile,
          hasPerceptualHandling: true,
          isInput: isInput,
        );
        return ColorProfileTransformMatrixTRC.create(
          profile: profile,
          doAdjustPCS: params.adjustPCS,
          isInput: isInput,
          pcsScale: params.pcsScale,
          pcsOffset: params.pcsOffset,
        );
      } else if (profile.header.resolvedColorSpace ==
          ColorSpaceSignature.icSigGrayData) {
        // TODO Implement
      }
    }
    if (tag == null) {
      throw Exception('Could not find tag for rendering intent');
    }
    switch (resolveColorSpaceSignature(profile.header.pcs)) {
      case ColorSpaceSignature.icSigXYZData:
      case ColorSpaceSignature.icSigLabData:
        final params = _begin(
          intent: intent,
          profile: profile,
          hasPerceptualHandling: true,
          isInput: isInput,
        );
        return _createTransformFromTypeAndTag(
          type: ColorProfileTransformType.transform3D,
          tag: tag,
          profile: profile,
          doAdjustPCS: params.adjustPCS,
          isInput: isInput,
          // TODO resolve
          srcPCSConversion: true,
          dstPCSConversion: true,
          pcsScale: params.pcsScale,
          pcsOffset: params.pcsOffset,
          interpolation: interpolation,
        );
      // ignore: no_default_cases
      default:
        throw Exception('Unsupported color space ${profile.header.pcs}');
    }
  }

  static const _icPerceptualRefBlackX = 0.00336;
  static const _icPerceptualRefBlackY = 0.0034731;
  static const _icPerceptualRefBlackZ = 0.00287;
  static const _icPerceptualRefWhiteX = 0.9642;
  static const _icPerceptualRefWhiteY = 1.0000;
  static const _icPerceptualRefWhiteZ = 0.8249;

  static ({
    bool adjustPCS,
    Float64List? pcsScale,
    Float64List? pcsOffset,
  }) _begin({
    required ColorProfileRenderingIntent intent,
    required ColorProfile profile,
    required bool hasPerceptualHandling,
    required bool isInput,
  }) {
    var adjustPCS = false;
    Float64List? pcsScale;
    Float64List? pcsOffset;
    if (intent == ColorProfileRenderingIntent.perceptual &&
        (profile.isVersion2 || !hasPerceptualHandling)) {
      final space = resolveColorSpaceSignature(profile.header.pcs);
      if (isSpacePCS(space) &&
          profile.header.resolvedDeviceClass != DeviceClass.abstract) {
        adjustPCS = true;
        pcsScale = Float64List.fromList([
          1 - _icPerceptualRefBlackX / _icPerceptualRefWhiteX,
          1 - _icPerceptualRefBlackY / _icPerceptualRefWhiteY,
          1 - _icPerceptualRefBlackZ / _icPerceptualRefWhiteZ,
        ]);
        pcsOffset = Float64List.fromList([
          _icPerceptualRefBlackX * 32768.0 / 65535.0,
          _icPerceptualRefBlackY * 32768.0 / 65535.0,
          _icPerceptualRefBlackZ * 32768.0 / 65535.0,
        ]);
        if (!isInput) {
          pcsScale[0] = 1 / pcsScale[0];
          pcsScale[1] = 1 / pcsScale[1];
          pcsScale[2] = 1 / pcsScale[2];
          pcsOffset[0] *= -pcsScale[0];
          pcsOffset[1] *= -pcsScale[1];
          pcsOffset[2] *= -pcsScale[2];
        }
      }
    }

    return (
      adjustPCS: adjustPCS,
      pcsScale: pcsScale,
      pcsOffset: pcsOffset,
    );
  }

  /// Gets the color space of the transformation's destination.
  ColorSpaceSignature getDestinationColorSpace() {
    if (isInput) {
      return resolveColorSpaceSignature(profile.header.pcs);
    } else {
      return profile.header.resolvedColorSpace;
    }
  }

  /// Gets the color space of the transformation's source.
  ColorSpaceSignature getSourceColorSpace() {
    if (isInput) {
      return profile.header.resolvedColorSpace;
    } else {
      return resolveColorSpaceSignature(profile.header.pcs);
    }
  }
}

bool isSpacePCS(ColorSpaceSignature signature) {
  return isSpaceColorimetricPCS(signature);
}

bool isSpaceColorimetricPCS(ColorSpaceSignature signature) {
  return signature == ColorSpaceSignature.icSigXYZData ||
      signature == ColorSpaceSignature.icSigLabData;
}
