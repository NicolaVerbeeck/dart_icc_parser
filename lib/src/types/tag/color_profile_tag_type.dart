import 'package:icc_parser/src/types/color_profile_primitives.dart';

/// ALl defined tag types in ICC spec 4.4 (see chapter 10)
enum ColorProfileTagType {
  /// 'chrm'
  icSigChromaticityType(0x6368726D),

  /// 'clro'
  icSigColorantOrderType(0x636C726F),

  /// 'clrt'
  icSigColorantTableType(0x636C7274),

  /// 'curv'
  icSigCurveType(0x63757276),

  /// 'data'
  icSigDataType(0x64617461),

  /// 'dtim'
  icSigDateTimeType(0x6474696D),

  /// 'mft2'
  icSigLut16Type(0x6d667432),

  /// 'mft1'
  icSigLut8Type(0x6d667431),

  /// 'mAB '
  icSigLutAtoBType(0x6d414220),

  /// 'mBA '
  icSigLutBtoAType(0x6d424120),

  /// 'meas'
  icSigMeasurementType(0x6D656173),

  /// 'mluc'
  icSigMultiLocalizedUnicodeType(0x6D6C7563),

  /// 'mpet'
  icSigMultiProcessElementType(0x6D706574),

  /// 'ncl2' use v2-v4
  icSigNamedColor2Type(0x6E636C32),

  /// 'para'
  icSigParametricCurveType(0x70617261),

  /// 'pseq'
  icSigProfileSequenceDescType(0x70736571),

  /// 'psid'
  icSigProfileSequceIdType(0x70736964),

  /// 'rcs2'
  icSigResponseCurveSet16Type(0x72637332),

  /// 'sf32'
  icSigS15Fixed16ArrayType(0x73663332),

  /// 'curf'
  icSigSegmentedCurveType(0x63757266),

  /// 'sig '
  icSigSignatureType(0x73696720),

  /// 'text'
  icSigTextType(0x74657874),

  /// 'uf32'
  icSigU16Fixed16ArrayType(0x75663332),

  /// 'ui16'
  icSigUInt16ArrayType(0x75693136),

  /// 'ui32'
  icSigUInt32ArrayType(0x75693332),

  /// 'ui64'
  icSigUInt64ArrayType(0x75693634),

  /// 'ui08'
  icSigUInt8ArrayType(0x75693038),

  /// 'view'
  icSigViewingConditionsType(0x76696577),

  /// 'XYZ '
  icSigXYZType(0x58595A20),

  /// 'XYZ '
  icSigXYZArrayType(0x58595A20),
  ;

  final int code;

  const ColorProfileTagType(this.code);
}

/// Returns the [ColorProfileTagType] from the given [value] or null if not found
ColorProfileTagType? tagTypeFromInt(Unsigned32Number value) {
  final rawValue = value.value;
  final index = ColorProfileTagType.values
      .indexWhere((element) => element.code == rawValue);
  if (index < 0) return null;
  return ColorProfileTagType.values[index];
}
