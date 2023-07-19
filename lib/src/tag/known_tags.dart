
import 'package:icc_parser/src/types/built_in.dart';

enum KnownTag {
  AToB0Tag,
  AToB1Tag,
  AToB2Tag,
  blueMatrixColumnTag,
  blueTRCTag,
  BToA0Tag,
  BToA1Tag,
  BToA2Tag,
  BToD0Tag,
  BToD1Tag,
  BToD2Tag,
  BToD3Tag,
  calibrationDateTimeTag,
  charTargetTag,
  chromaticAdaptationTag,
  chromaticityTag,
  colorantOrderTag,
  colorantTableTag,
  colorantTableOutTag,
  colorimetricIntentImageStateTag,
  copyrightTag,
  deviceMfgDescTag,
  deviceModelDescTag,
  DToB0Tag,
  DToB1Tag,
  DToB2Tag,
  DToB3Tag,
  gamutTag,
  grayTRCTag,
  greenMatrixColumnTag,
  greenTRCTag,
  luminanceTag,
  measurementTag,
  mediaWhitePointTag,
  namedColor2Tag,
  outputResponseTag,
  perceptualRenderingIntentGamutTag,
  preview0Tag,
  preview1Tag,
  preview2Tag,
  profileDescriptionTag,
  profileSequenceDescTag,
  profileSequenceIdentifierTag,
  redMatrixColumnTag,
  redTRCTag,
  saturationRenderingIntentGamutTag,
  technologyTag,
  viewingCondDescTag,
  viewingConditionsTag,
}

KnownTag? tagFromInt(final Unsigned32Number value) {
  switch (value.value) {
    case 0x41324230:
      return KnownTag.AToB0Tag;
    case 0x41324231:
      return KnownTag.AToB1Tag;
    case 0x41324232:
      return KnownTag.AToB2Tag;
    case 0x6258595A:
      return KnownTag.blueMatrixColumnTag;
    case 0x62545243:
      return KnownTag.blueTRCTag;
    case 0x42324130:
      return KnownTag.BToA0Tag;
    case 0x42324131:
      return KnownTag.BToA1Tag;
    case 0x42324132:
      return KnownTag.BToA2Tag;
    case 0x42324430:
      return KnownTag.BToD0Tag;
    case 0x42324431:
      return KnownTag.BToD1Tag;
    case 0x42324432:
      return KnownTag.BToD2Tag;
    case 0x42324433:
      return KnownTag.BToD3Tag;
    case 0x63616C74:
      return KnownTag.calibrationDateTimeTag;
    case 0x74617267:
      return KnownTag.charTargetTag;
    case 0x63686164:
      return KnownTag.chromaticAdaptationTag;
    case 0x6368726D:
      return KnownTag.chromaticityTag;
    case 0x636C726F:
      return KnownTag.colorantOrderTag;
    case 0x636C7274:
      return KnownTag.colorantTableTag;
    case 0x636C6F74:
      return KnownTag.colorantTableOutTag;
    case 0x63696973:
      return KnownTag.colorimetricIntentImageStateTag;
    case 0x63707274:
      return KnownTag.copyrightTag;
    case 0x646D6E64:
      return KnownTag.deviceMfgDescTag;
    case 0x646D6464:
      return KnownTag.deviceModelDescTag;
    case 0x44324230:
      return KnownTag.DToB0Tag;
    case 0x44324231:
      return KnownTag.DToB1Tag;
    case 0x44324232:
      return KnownTag.DToB2Tag;
    case 0x44324233:
      return KnownTag.DToB3Tag;
    case 0x67616D74:
      return KnownTag.gamutTag;
    case 0x6B545243:
      return KnownTag.grayTRCTag;
    case 0x6758595A:
      return KnownTag.greenMatrixColumnTag;
    case 0x67545243:
      return KnownTag.greenTRCTag;
    case 0x6C756D69:
      return KnownTag.luminanceTag;
    case 0x6D656173:
      return KnownTag.measurementTag;
    case 0x77747074:
      return KnownTag.mediaWhitePointTag;
    case 0x6E636C32:
      return KnownTag.namedColor2Tag;
    case 0x72657370:
      return KnownTag.outputResponseTag;
    case 0x72696730:
      return KnownTag.perceptualRenderingIntentGamutTag;
    case 0x70726530:
      return KnownTag.preview0Tag;
    case 0x70726531:
      return KnownTag.preview1Tag;
    case 0x70726532:
      return KnownTag.preview2Tag;
    case 0x64657363:
      return KnownTag.profileDescriptionTag;
    case 0x70736571:
      return KnownTag.profileSequenceDescTag;
    case 0x70736964:
      return KnownTag.profileSequenceIdentifierTag;
    case 0x7258595A:
      return KnownTag.redMatrixColumnTag;
    case 0x72545243:
      return KnownTag.redTRCTag;
    case 0x72696732:
      return KnownTag.saturationRenderingIntentGamutTag;
    case 0x74656368:
      return KnownTag.technologyTag;
    case 0x76756564:
      return KnownTag.viewingCondDescTag;
    case 0x76696577:
      return KnownTag.viewingConditionsTag;
    default:
      return null;
  }
}