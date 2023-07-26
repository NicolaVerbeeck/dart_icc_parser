import 'package:icc_parser/src/cmm/icc_transform.dart';
import 'package:icc_parser/src/types/primitive.dart';

enum KnownTag {
/* 'A2B0' */
  icSigAToB0Tag(0x41324230),
  /* 'A2B1' */
  icSigAToB1Tag(0x41324231),
  /* 'A2B2' */
  icSigAToB2Tag(0x41324232),
  /* 'A2B3' */
  icSigAToB3Tag(0x41324233),
  /* 'A2M0' */
  icSigAToM0Tag(0x41324d30),
  /* 'bXYZ' */
  icSigBlueColorantTag(0x6258595A),
  /* 'bXYZ' */
  icSigBlueMatrixColumnTag(0x6258595A),
  /* 'bTRC' */
  icSigBlueTRCTag(0x62545243),
  /* 'bcp0' */
  icSigBrdfColorimetricParameter0Tag(0x62637030),
  /* 'bcp1' */
  icSigBrdfColorimetricParameter1Tag(0x62637031),
  /* 'bcp2' */
  icSigBrdfColorimetricParameter2Tag(0x62637032),
  /* 'bcp3' */
  icSigBrdfColorimetricParameter3Tag(0x62637033),
  /* 'bsp0' */
  icSigBrdfSpectralParameter0Tag(0x62737030),
  /* 'bsp1' */
  icSigBrdfSpectralParameter1Tag(0x62737031),
  /* 'bsp2' */
  icSigBrdfSpectralParameter2Tag(0x62737032),
  /* 'bsp3' */
  icSigBrdfSpectralParameter3Tag(0x62737033),
  /* 'bAB0' */
  icSigBRDFAToB0Tag(0x62414230),
  /* 'bAB1' */
  icSigBRDFAToB1Tag(0x62414231),
  /* 'bAB2' */
  icSigBRDFAToB2Tag(0x62414232),
  /* 'bAB3' */
  icSigBRDFAToB3Tag(0x62414233),
  /* 'bDB0' */
  icSigBRDFDToB0Tag(0x62444230),
  /* 'bDB1' */
  icSigBRDFDToB1Tag(0x62444231),
  /* 'bDB2' */
  icSigBRDFDToB2Tag(0x62444232),
  /* 'bDB3' */
  icSigBRDFDToB3Tag(0x62444233),
  /* 'bMB0' */
  icSigBRDFMToB0Tag(0x624D4230),
  /* 'bMB1' */
  icSigBRDFMToB1Tag(0x624D4231),
  /* 'bMB2' */
  icSigBRDFMToB2Tag(0x624D4232),
  /* 'bMB3' */
  icSigBRDFMToB3Tag(0x624D4233),
  /* 'bMS0' */
  icSigBRDFMToS0Tag(0x624D5330),
  /* 'bMS1' */
  icSigBRDFMToS1Tag(0x624D5331),
  /* 'bMS2' */
  icSigBRDFMToS2Tag(0x624D5332),
  /* 'bMS3' */
  icSigBRDFMToS3Tag(0x624D5333),
  /* 'B2A0' */
  icSigBToA0Tag(0x42324130),
  /* 'B2A1' */
  icSigBToA1Tag(0x42324131),
  /* 'B2A2' */
  icSigBToA2Tag(0x42324132),
  /* 'B2A3' */
  icSigBToA3Tag(0x42324133),
  /* 'calt' */
  icSigCalibrationDateTimeTag(0x63616C74),
  /* 'targ' */
  icSigCharTargetTag(0x74617267),
  /* 'chad' */
  icSigChromaticAdaptationTag(0x63686164),
  /* 'chrm' */
  icSigChromaticityTag(0x6368726D),
  /* 'cept' */
  icSigColorEncodingParamsTag(0x63657074),
  /* 'csnm' */
  icSigColorSpaceNameTag(0x63736e6d),
  /* 'clin' */
  icSigColorantInfoTag(0x636c696e),
  /* 'clio' */
  icSigColorantInfoOutTag(0x636c696f),
  /* 'clro' */
  icSigColorantOrderTag(0x636C726F),
  /* 'cloo' */
  icSigColorantOrderOutTag(0x636c6f6f),
  /* 'clrt' */
  icSigColorantTableTag(0x636C7274),
  /* 'clot' */
  icSigColorantTableOutTag(0x636C6F74),
  /* 'ciis' */
  icSigColorimetricIntentImageStateTag(0x63696973),
  /* 'cprt' */
  icSigCopyrightTag(0x63707274),
  /* 'crdi' Removed in V4 */
  icSigCrdInfoTag(0x63726469),
  /* 'c2sp' */
  icSigCustomToStandardPccTag(0x63327370),
  /* 'CxF ' */
  icSigCxFTag(0x43784620),
  /* 'data' Removed in V4 */
  icSigDataTag(0x64617461),
  /* 'dtim' Removed in V4 */
  icSigDateTimeTag(0x6474696D),
  /* 'dmwp' */
  icSigDeviceMediaWhitePointTag(0x646d7770),
  /* 'dmnd' */
  icSigDeviceMfgDescTag(0x646D6E64),
  /* 'dmdd' */
  icSigDeviceModelDescTag(0x646D6464),
  /* 'devs' Removed in V4 */
  icSigDeviceSettingsTag(0x64657673),
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
  /* 'gbd0' */
  icSigGamutBoundaryDescription0Tag(0x67626430),
  /* 'gbd1' */
  icSigGamutBoundaryDescription1Tag(0x67626431),
  /* 'gbd2' */
  icSigGamutBoundaryDescription2Tag(0x67626432),
  /* 'gbd3' */
  icSigGamutBoundaryDescription3Tag(0x67626433),
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
  /* 'mdv ' */
  icSigMaterialDefaultValuesTag(0x6D647620),
  /* 'mcta' */
  icSigMaterialTypeArrayTag(0x6d637461),
  /* 'M2A0' */
  icSigMToA0Tag(0x4d324130),
  /* 'M2B0' */
  icSigMToB0Tag(0x4d324230),
  /* 'M2B1' */
  icSigMToB1Tag(0x4d324231),
  /* 'M2B2' */
  icSigMToB2Tag(0x4d324232),
  /* 'M2B3' */
  icSigMToB3Tag(0x4d324233),
  /* 'M2S0' */
  icSigMToS0Tag(0x4d325330),
  /* 'M2S1' */
  icSigMToS1Tag(0x4d325331),
  /* 'M2S2' */
  icSigMToS2Tag(0x4d325332),
  /* 'M2S3' */
  icSigMToS3Tag(0x4d325333),
  /* 'meas' */
  icSigMeasurementTag(0x6D656173),
  /* 'bkpt' */
  icSigMediaBlackPointTag(0x626B7074),
  /* 'wtpt' */
  icSigMediaWhitePointTag(0x77747074),
  /* 'meta' */
  icSigMetaDataTag(0x6D657461),
  /* 'nmcl' use for V5 */
  icSigNamedColorTag(0x6e6d636C),
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
  /* 'ptcn' */
  icSigPrintConditionTag(0x7074636e),
  /* 'desc' */
  icSigProfileDescriptionTag(0x64657363),
  /* 'pseq' */
  icSigProfileSequenceDescTag(0x70736571),
  /* 'psid' */
  icSigProfileSequceIdTag(0x70736964),
  /* 'psd0' Removed in V4 */
  icSigPs2CRD0Tag(0x70736430),
  /* 'psd1' Removed in V4 */
  icSigPs2CRD1Tag(0x70736431),
  /* 'psd2' Removed in V4 */
  icSigPs2CRD2Tag(0x70736432),
  /* 'psd3' Removed in V4 */
  icSigPs2CRD3Tag(0x70736433),
  /* 'ps2s' Removed in V4 */
  icSigPs2CSATag(0x70733273),
  /* 'ps2i' Removed in V4 */
  icSigPs2RenderingIntentTag(0x70733269),
  /* 'rXYZ' */
  icSigRedColorantTag(0x7258595A),
  /* 'rXYZ' */
  icSigRedMatrixColumnTag(0x7258595A),
  /* 'rTRC' */
  icSigRedTRCTag(0x72545243),
  /* 'rfnm' */
  icSigReferenceNameTag(0x72666e6d),
  /* 'rig2' */
  icSigSaturationRenderingIntentGamutTag(0x72696732),
  /* 'scrd' Removed in V4 */
  icSigScreeningDescTag(0x73637264),
  /* 'scrn' Removed in V4 */
  icSigScreeningTag(0x7363726E),
  /* 'sdin' */
  icSigSpectralDataInfoTag(0x7364696e),
  /* 'swpt' */
  icSigSpectralWhitePointTag(0x73777074),
  /* 'svcn' */
  icSigSpectralViewingConditionsTag(0x7376636e),
  /* 's2cp' */
  icSigStandardToCustomPccTag(0x73326370),
  /* 'smap' */
  icSigSurfaceMapTag(0x736D6170),
  /* 'tech' */
  icSigTechnologyTag(0x74656368),
  /* 'bfd ' Removed in V4 */
  icSigUcrBgTag(0x62666420),
  /* 'vued' */
  icSigViewingCondDescTag(0x76756564),
  /* 'view' */
  icSigViewingConditionsTag(0x76696577),
  /* 'ICC5' */
  icSigEmbeddedV5ProfileTag(0x49434335),
  ;

  final int code;

  const KnownTag(this.code);

  KnownTag offsetWithIntent(IccRenderingIntent intent) {
    final tagCode = code + intent.value;
    return KnownTag.values.firstWhere((element) => element.code == tagCode, orElse: () {
      throw Exception('Unknown tag code with offset: $this -> $intent');
    });
  }
}

KnownTag? tagFromInt(Unsigned32Number value) {
  final rawValue = value.value;
  final index =
      KnownTag.values.indexWhere((element) => element.code == rawValue);
  if (index < 0) return null;
  return KnownTag.values[index];
}
