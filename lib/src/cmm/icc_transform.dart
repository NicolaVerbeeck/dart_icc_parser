import 'package:icc_parser/src/cmm/icc_pcs.dart';
import 'package:icc_parser/src/cmm/transform_3d.dart';
import 'package:icc_parser/src/cmm/transform_4d.dart';
import 'package:icc_parser/src/icc_parser_base.dart';
import 'package:icc_parser/src/types/icc_profile_header.dart';
import 'package:icc_parser/src/types/tag/icc_tag.dart';
import 'package:icc_parser/src/types/tag/known_tags.dart';
import 'package:icc_parser/src/types/tag/lut/icc_mbb.dart';
import 'package:icc_parser/src/types/tag/tag_type.dart';
import 'package:meta/meta.dart';

@immutable
abstract class IccTransform {
  final IccProfile profile;

  final bool doAdjustPCS;
  final bool isInput;
  final bool srcPCSConversion;
  final bool dstPCSConversion;
  final List<double>? pcsScale;
  final List<double>? pcsOffset;

  const IccTransform({
    required this.profile,
    required this.doAdjustPCS,
    required this.isInput,
    required this.srcPCSConversion,
    required this.dstPCSConversion,
    required this.pcsScale,
    required this.pcsOffset,
  });

  List<double> apply(List<double> source);

  factory IccTransform.create({
    required IccProfile profile,
    required bool isInput,
    required IccRenderingIntent intent,
    required IccInterpolation interpolation,
    required IccTransformLutType lutType,
    required bool useD2BTags,
  }) {
    var renderIntent = intent;

    if (profile.header.resolvedDeviceClass == DeviceClass.link) {
      renderIntent = IccRenderingIntent.perceptual;
    }
    switch (lutType) {
      case IccTransformLutType.color:
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
        IccPCS.lab2ToXyz(source: source, dest: dest, noClip: true);
      } else {
        IccPCS.labToXyz(source: source, dest: dest, noClip: true);
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
        IccPCS.xyzToLab2(source: dest, dest: dest, noClip: true);
      } else {
        IccPCS.xyzToLab(source: dest, dest: dest, noClip: true);
      }
    } else {
      dest[0] = dest[0].clamp(0, double.maxFinite);
      dest[1] = dest[1].clamp(0, double.maxFinite);
      dest[2] = dest[2].clamp(0, double.maxFinite);
    }
    return dest;
  }

  bool get useLegacyPCS => false;

  static IccTransform _createTransformFromTypeAndTag({
    required TransformType type,
    required IccTag tag,
    required IccProfile profile,
    required bool doAdjustPCS,
    required bool isInput,
    required bool srcPCSConversion,
    required bool dstPCSConversion,
    required List<double>? pcsScale,
    required List<double>? pcsOffset,
    required IccInterpolation interpolation,
  }) {
    switch (type) {
      case TransformType.transform3D:
        return IccTransform3DLut.fromTag(
          tag: tag as IccMBB,
          profile: profile,
          doAdjustPCS: doAdjustPCS,
          isInput: isInput,
          srcPCSConversion: false,
          dstPCSConversion: false,
          pcsOffset: pcsOffset,
          pcsScale: pcsScale,
          interpolation: interpolation,
        );
      case TransformType.transform4D:
        return IccTransform4DLut.fromTag(
          tag: tag as IccMBB,
          profile: profile,
          doAdjustPCS: doAdjustPCS,
          isInput: isInput,
          srcPCSConversion: false,
          dstPCSConversion: false,
          pcsOffset: pcsOffset,
          pcsScale: pcsScale,
        );
      case TransformType.transformMPE:
        throw ArgumentError('Unsupported transform type: $type');
    }
  }

  static IccTransform _createLutColorTransform({
    required IccProfile profile,
    required bool isInput,
    required IccRenderingIntent intent,
    required IccInterpolation interpolation,
    required bool useD2BTags,
  }) {
    const useColorimetricTags = true;
    IccTag? tag;

    if (isInput) {
      if (useD2BTags) {
        tag = profile.findTag(KnownTag.icSigDToB0Tag.offsetWithIntent(intent));
      }
      if (useColorimetricTags && tag == null) {
        tag = profile.findTag(KnownTag.icSigAToB0Tag.offsetWithIntent(intent));
        tag ??= profile.findTag(KnownTag.icSigAToB0Tag);
        tag ??= profile.findTag(KnownTag.icSigAToB1Tag);
        if (tag == null) {
          tag = profile.findTag(KnownTag.icSigAToB3Tag);
          if (tag != null) {
            throw Exception(
                'Rendering anything but perceptual is not supported');
          }
        }
      }
      if (tag?.type == KnownTagType.icSigMultiProcessElementType) {
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
          TransformType.transform3D,
        ColorSpaceSignature.icSig4colorData ||
        ColorSpaceSignature.icSigCmykData =>
          TransformType.transform4D,
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
      tag = profile.findTag(KnownTag.icSigBToD0Tag.offsetWithIntent(intent));
    }
    if (useColorimetricTags) {
      tag ??= profile.findTag(KnownTag.icSigBToA0Tag.offsetWithIntent(intent));
      tag ??= profile.findTag(KnownTag.icSigBToA0Tag);
    }
    if (tag?.type == KnownTagType.icSigMultiProcessElementType) {
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
          type: TransformType.transform3D,
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
    required IccRenderingIntent intent,
    required IccProfile profile,
    required bool hasPerceptualHandling,
    required bool isInput,
  }) {
    var adjustPCS = false;
    List<double>? pcsScale;
    List<double>? pcsOffset;
    if (intent == IccRenderingIntent.perceptual &&
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

enum TransformType {
  transform3D,
  transform4D,
  transformMPE,
}

enum IccRenderingIntent {
  perceptual(0), // Only one for now
  ;

  final int value;

  const IccRenderingIntent(this.value);
}

enum IccInterpolation {
  linear,
  tetrahedral,
}

enum IccTransformLutType {
  color, // Only one for now
}
