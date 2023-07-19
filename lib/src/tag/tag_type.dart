import 'package:icc_parser/src/types/built_in.dart';

enum TagType {
  chromaticityType,
  colorantOrderType,
  colorantTableType,
  curveType,
  dataType,
  dateTimeType,
  lut16Type,
  lut8Type,
  lutAToBType,
  lutBToAType,
  measurementType,
  multiLocalizedUnicodeType,
  multiProcessElementsType,
  matrixElementType,
  clutElementType,
  bacsType,
  eacsType,
  namedColor2Type,
  parametricCurveType,
  profileSequenceDescType,
  profileSequenceIdentifierType,
  responseCurveSet16Type,
  s15Fixed16ArrayType,
  signatureType,
  textType,
  u16Fixed16ArrayType,
  uInt16ArrayType,
  uInt32ArrayType,
  uInt64ArrayType,
  uInt8ArrayType,
  viewingConditionsType,
  xyzType,
}

TagType? tagTypeFromInt(final Unsigned32Number value) {
  switch (value.value) {
    case 0x6368726D:
      return TagType.chromaticityType;
    case 0x636c726f:
      return TagType.colorantOrderType;
    case 0x636c7274:
      return TagType.colorantTableType;
    case 0x63757276:
      return TagType.curveType;
    case 0x64617461:
      return TagType.dataType;
    case 0x6474696D:
      return TagType.dateTimeType;
    case 0x6D667432:
      return TagType.lut16Type;
    case 0x6D667431:
      return TagType.lut8Type;
    case 0x6D414220:
      return TagType.lutAToBType;
    case 0x6D424120:
      return TagType.lutBToAType;
    case 0x6D656173:
      return TagType.measurementType;
    case 0x6D6C7563:
      return TagType.multiLocalizedUnicodeType;
    case 0x6D706574:
      return TagType.multiProcessElementsType;
    case 0x6D617466:
      return TagType.matrixElementType;
    case 0x636C7574:
      return TagType.clutElementType;
    case 0x62414353:
      return TagType.bacsType;
    case 0x65414353:
      return TagType.eacsType;
    case 0x6E636C32:
      return TagType.namedColor2Type;
    case 0x70617261:
      return TagType.parametricCurveType;
    case 0x70736571:
      return TagType.profileSequenceDescType;
    case 0x70736964:
      return TagType.profileSequenceIdentifierType;
    case 0x72637332:
      return TagType.responseCurveSet16Type;
    case 0x73663332:
      return TagType.s15Fixed16ArrayType;
    case 0x73696720:
      return TagType.signatureType;
    case 0x74657874:
      return TagType.textType;
    case 0x75663332:
      return TagType.u16Fixed16ArrayType;
    case 0x75693136:
      return TagType.uInt16ArrayType;
    case 0x75693332:
      return TagType.uInt32ArrayType;
    case 0x75693634:
      return TagType.uInt64ArrayType;
    case 0x75693038:
      return TagType.uInt8ArrayType;
    case 0x76696577:
      return TagType.viewingConditionsType;
    case 0x58595A20:
      return TagType.xyzType;
    default:
      return null;
  }
}
