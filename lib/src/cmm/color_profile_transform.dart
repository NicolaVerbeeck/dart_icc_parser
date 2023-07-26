import 'package:icc_parser/src/cmm/color_profile_pcs.dart';
import 'package:icc_parser/src/cmm/color_profile_transform_3d.dart';
import 'package:icc_parser/src/cmm/color_profile_transform_4d.dart';
import 'package:icc_parser/src/cmm/enums.dart';
import 'package:icc_parser/src/color_profile.dart';
import 'package:icc_parser/src/types/color_profile_profile_header.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag.dart';
import 'package:icc_parser/src/types/tag/color_profile_tags.dart';
import 'package:icc_parser/src/types/tag/lut/color_profile_mbb.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag_type.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ColorProfileTransform {
  final ColorProfile profile;

  final bool doAdjustPCS;
  final bool isInput;
  final bool srcPCSConversion;
  final bool dstPCSConversion;
  final List<double>? pcsScale;
  final List<double>? pcsOffset;

  const ColorProfileTransform({
    required this.profile,
    required this.doAdjustPCS,
    required this.isInput,
    required this.srcPCSConversion,
    required this.dstPCSConversion,
    required this.pcsScale,
    required this.pcsOffset,
  });

  List<double> apply(List<double> source);

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

  List<double> checkSourceAbsolute(List<double> source) {
    if (doAdjustPCS && !isInput && srcPCSConversion) {
      return adjustPCS(source);
    }
    return source;
  }

  List<double> checkDestinationAbsolute(List<double> source) {
    if (doAdjustPCS && isInput && dstPCSConversion) {
      return adjustPCS(source);
    }
    return source;
  }

  List<double> adjustPCS(List<double> source) {
    assert(source.length == 3);
    assert(pcsScale != null);
    assert(pcsOffset != null);

    final space = intToColorSpaceSignature(profile.header.pcs);

    final dest = List.filled(3, 0.0);
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

  bool get useLegacyPCS => false;

  static ColorProfileTransform _createTransformFromTypeAndTag({
    required ColorProfileTransformType type,
    required ColorProfileTag tag,
    required ColorProfile profile,
    required bool doAdjustPCS,
    required bool isInput,
    required bool srcPCSConversion,
    required bool dstPCSConversion,
    required List<double>? pcsScale,
    required List<double>? pcsOffset,
    required ColorProfileInterpolation interpolation,
  }) {
    switch (type) {
      case ColorProfileTransformType.transform3D:
        return ColorProfileTransform3DLut.fromTag(
          tag: tag as ColorProfileMBB,
          profile: profile,
          doAdjustPCS: doAdjustPCS,
          isInput: isInput,
          srcPCSConversion: false,
          dstPCSConversion: false,
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
          srcPCSConversion: false,
          dstPCSConversion: false,
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
        if (tag == null) {
          tag = profile.findTag(ICCColorProfileTag.icSigAToB3Tag);
          if (tag != null) {
            throw Exception(
                'Rendering anything but perceptual is not supported');
          }
        }
      }
      if (tag?.type == ColorProfileTagType.icSigMultiProcessElementType) {
        throw Exception('Multi processing elements are not supported');
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
    if (tag == null) {
      throw Exception('Could not find tag for rendering intent');
    }
    switch (intToColorSpaceSignature(profile.header.pcs)) {
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
    List<double>? pcsScale,
    List<double>? pcsOffset,
  }) _begin({
    required ColorProfileRenderingIntent intent,
    required ColorProfile profile,
    required bool hasPerceptualHandling,
    required bool isInput,
  }) {
    var adjustPCS = false;
    List<double>? pcsScale;
    List<double>? pcsOffset;
    if (intent == ColorProfileRenderingIntent.perceptual &&
        (profile.isVersion2 || !hasPerceptualHandling)) {
      final space = intToColorSpaceSignature(profile.header.pcs);
      if (_isSpacePCS(space) &&
          profile.header.resolvedDeviceClass != DeviceClass.abstract) {
        adjustPCS = true;
        pcsScale = [
          1 - _icPerceptualRefBlackX / _icPerceptualRefWhiteX,
          1 - _icPerceptualRefBlackY / _icPerceptualRefWhiteY,
          1 - _icPerceptualRefBlackZ / _icPerceptualRefWhiteZ,
        ];
        pcsOffset = [
          _icPerceptualRefBlackX * 32768.0 / 65535.0,
          _icPerceptualRefBlackY * 32768.0 / 65535.0,
          _icPerceptualRefBlackZ * 32768.0 / 65535.0,
        ];
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
}

bool _isSpacePCS(ColorSpaceSignature signature) {
  return _isSpaceColorimetricPCS(signature);
}

bool _isSpaceColorimetricPCS(ColorSpaceSignature signature) {
  return signature == ColorSpaceSignature.icSigXYZData ||
      signature == ColorSpaceSignature.icSigLabData;
}
