import 'package:icc_parser/src/cmm/enums.dart';
import 'package:icc_parser/src/types/color_profile_primitives.dart';

/// All defined ICC color profile tags in V 4.4.
enum ICCColorProfileTag {
  /* 'A2B0' */
  icSigAToB0Tag(0x41324230),
  /* 'A2B1' */
  icSigAToB1Tag(0x41324231),
  /* 'A2B2' */
  icSigAToB2Tag(0x41324232),
  /* 'bXYZ' */
  icSigBlueMatrixColumnTag(0x6258595A),
  /* 'bTRC' */
  icSigBlueTRCTag(0x62545243),
  /* 'B2A0' */
  icSigBToA0Tag(0x42324130),
  /* 'B2A1' */
  icSigBToA1Tag(0x42324131),
  /* 'B2A2' */
  icSigBToA2Tag(0x42324132),
  /* 'calt' */
  icSigCalibrationDateTimeTag(0x63616C74),
  /* 'targ' */
  icSigCharTargetTag(0x74617267),
  /* 'chad' */
  icSigChromaticAdaptationTag(0x63686164),
  /* 'chrm' */
  icSigChromaticityTag(0x6368726D),
  /* 'clro' */
  icSigColorantOrderTag(0x636C726F),
  /* 'clrt' */
  icSigColorantTableTag(0x636C7274),
  /* 'clot' */
  icSigColorantTableOutTag(0x636C6F74),
  /* 'ciis' */
  icSigColorimetricIntentImageStateTag(0x63696973),
  /* 'cprt' */
  icSigCopyrightTag(0x63707274),
  /* 'dmnd' */
  icSigDeviceMfgDescTag(0x646D6E64),
  /* 'dmdd' */
  icSigDeviceModelDescTag(0x646D6464),
  /* 'D2B0' */
  icSigDToB0Tag(0x44324230),
  /* 'D2B1' */
  icSigDToB1Tag(0x44324231),
  /* 'D2B2' */
  icSigDToB2Tag(0x44324232),
  /* 'D2B3' */
  icSigDToB3Tag(0x44324233),
  /* 'B2D0' */
  icSigBToD0Tag(0x42324430),
  /* 'B2D1' */
  icSigBToD1Tag(0x42324431),
  /* 'B2D2' */
  icSigBToD2Tag(0x42324432),
  /* 'B2D3' */
  icSigBToD3Tag(0x42324433),
  /* 'gamt' */
  icSigGamutTag(0x67616D74),
  /* 'kTRC' */
  icSigGrayTRCTag(0x6b545243),
  /* 'gXYZ' */
  icSigGreenColorantTag(0x6758595A),
  /* 'gXYZ' */
  icSigGreenMatrixColumnTag(0x6758595A),
  /* 'gTRC' */
  icSigGreenTRCTag(0x67545243),
  /* 'lumi' */
  icSigLuminanceTag(0x6C756d69),
  /* 'meas' */
  icSigMeasurementTag(0x6D656173),
  /* 'wtpt' */
  icSigMediaWhitePointTag(0x77747074),
  /* 'meta' */
  icSigMetaDataTag(0x6D657461),
  /* 'ncl2' */
  icSigNamedColor2Tag(0x6E636C32),
  /* 'resp' */
  icSigOutputResponseTag(0x72657370),
  /* 'rig0' */
  icSigPerceptualRenderingIntentGamutTag(0x72696730),
  /* 'pre0' */
  icSigPreview0Tag(0x70726530),
  /* 'pre1' */
  icSigPreview1Tag(0x70726531),
  /* 'pre2' */
  icSigPreview2Tag(0x70726532),
  /* 'desc' */
  icSigProfileDescriptionTag(0x64657363),
  /* 'pseq' */
  icSigProfileSequenceDescTag(0x70736571),
  /* 'psid' */
  icSigProfileSequceIdTag(0x70736964),
  /* 'rXYZ' */
  icSigRedMatrixColumnTag(0x7258595A),
  /* 'rTRC' */
  icSigRedTRCTag(0x72545243),
  /* 'rig2' */
  icSigSaturationRenderingIntentGamutTag(0x72696732),
  /* 'tech' */
  icSigTechnologyTag(0x74656368),
  /* 'vued' */
  icSigViewingCondDescTag(0x76756564),
  /* 'view' */
  icSigViewingConditionsTag(0x76696577),
  ;

  final int code;

  const ICCColorProfileTag(this.code);

  /// Offsets the tag code with the given [intent], throws an exception if the
  /// offset combination is not valid.
  ICCColorProfileTag offsetWithIntent(ColorProfileRenderingIntent intent) {
    final tagCode = code + intent.offset;
    return ICCColorProfileTag.values
        .firstWhere((element) => element.code == tagCode, orElse: () {
      throw Exception('Unknown tag code with offset: $this -> $intent');
    });
  }
}

/// Resolve the [ICCColorProfileTag] from the given [value], returns null if
/// the value is not a valid tag code.
ICCColorProfileTag? parseICCColorProfileTag(Unsigned32Number value) {
  final rawValue = value.value;
  final index = ICCColorProfileTag.values
      .indexWhere((element) => element.code == rawValue);
  if (index < 0) return null;
  return ICCColorProfileTag.values[index];
}
