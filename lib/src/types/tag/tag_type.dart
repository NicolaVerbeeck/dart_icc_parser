import 'package:icc_parser/src/types/primitive.dart';

enum KnownTagType {
/* 'chrm' */
  icSigChromaticityType(0x6368726D),
  /* 'clro' */
  icSigColorantOrderType(0x636C726F),
  /* 'clrt' */
  icSigColorantTableType(0x636C7274),
  /* 'crdi' Removed in V4 */
  icSigCrdInfoType(0x63726469),
  /* 'curv' */
  icSigCurveType(0x63757276),
  /* 'data' */
  icSigDataType(0x64617461),
  /* 'dict' */
  icSigDictType(0x64696374),
  /* 'dtim' */
  icSigDateTimeType(0x6474696D),
  /* 'devs' Removed in V4 */
  icSigDeviceSettingsType(0x64657673),
  /* 'ehim' */
  icSigEmbeddedHeightImageType(0x6568696D),
  /* 'enim' */
  icSigEmbeddedNormalImageType(0x656e696d),
  /* 'fl16' */
  icSigFloat16ArrayType(0x666c3136),
  /* 'fl32' */
  icSigFloat32ArrayType(0x666c3332),
  /* 'fl64' */
  icSigFloat64ArrayType(0x666c3634),
  /* 'gbd ' */
  icSigGamutBoundaryDescType(0x67626420),
  /* 'mft2' */
  icSigLut16Type(0x6d667432),
  /* 'mft1' */
  icSigLut8Type(0x6d667431),
  /* 'mAB ' */
  icSigLutAtoBType(0x6d414220),
  /* 'mBA ' */
  icSigLutBtoAType(0x6d424120),
  /* 'meas' */
  icSigMeasurementType(0x6D656173),
  /* 'mluc' */
  icSigMultiLocalizedUnicodeType(0x6D6C7563),
  /* 'mpet' */
  icSigMultiProcessElementType(0x6D706574),
  /* 'ncl2' use v2-v4*/
  icSigNamedColor2Type(0x6E636C32),
  /* 'para' */
  icSigParametricCurveType(0x70617261),
  /* 'pseq' */
  icSigProfileSequenceDescType(0x70736571),
  /* 'psid' */
  icSigProfileSequceIdType(0x70736964),
  /* 'rcs2' */
  icSigResponseCurveSet16Type(0x72637332),
  /* 'sf32' */
  icSigS15Fixed16ArrayType(0x73663332),
  /* 'scrn' Removed in V4 */
  icSigScreeningType(0x7363726E),
  /* 'curf' */
  icSigSegmentedCurveType(0x63757266),
  /* 'sig ' */
  icSigSignatureType(0x73696720),
  /* 'smat' */
  icSigSparseMatrixArrayType(0x736D6174),
  /* 'svcn' */
  icSigSpectralViewingConditionsType(0x7376636e),
  /* 'sdin' */
  icSigSpectralDataInfoType(0x7364696e),
  /* 'tary' */
  icSigTagArrayType(0x74617279),
  /* 'tstr' */
  icSigTagStructType(0x74737472),
  /* 'text' */
  icSigTextType(0x74657874),
  /* 'desc' Removed in V4 */
  icSigTextDescriptionType(0x64657363),
  /* 'uf32' */
  icSigU16Fixed16ArrayType(0x75663332),
  /* 'bfd ' Removed in V4 */
  icSigUcrBgType(0x62666420),
  /* 'ui16' */
  icSigUInt16ArrayType(0x75693136),
  /* 'ui32' */
  icSigUInt32ArrayType(0x75693332),
  /* 'ui64' */
  icSigUInt64ArrayType(0x75693634),
  /* 'ui08' */
  icSigUInt8ArrayType(0x75693038),
  /* 'view' */
  icSigViewingConditionsType(0x76696577),
  /* 'utf8' */
  icSigUtf8TextType(0x75746638),
  /* 'ut16' */
  icSigUtf16TextType(0x75743136),
  /* 'XYZ ' */
  icSigXYZType(0x58595A20),
  /* 'XYZ ' */
  icSigXYZArrayType(0x58595A20),
  /* 'zut8' */
  icSigZipUtf8TextType(0x7a757438),
  /* 'ZXML' */
  icSigZipXmlType(0x5a584d4c),
  ;

  final int code;

  const KnownTagType(this.code);
}

KnownTagType? tagTypeFromInt(Unsigned32Number value) {
  final rawValue = value.value;
  final index =
      KnownTagType.values.indexWhere((element) => element.code == rawValue);
  if (index < 0) return null;
  return KnownTagType.values[index];
}
