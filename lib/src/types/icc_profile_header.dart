import 'dart:typed_data';

import 'package:icc_parser/src/types/primitive.dart';
import 'package:meta/meta.dart';

@immutable
final class ICCProfileHeader {
  final Unsigned32Number size;
  final Uint8List cmmType;
  final Unsigned32Number version;
  final Unsigned32Number deviceClass;
  final Unsigned32Number colorSpace;
  final Unsigned32Number pcs;
  final DateTimeNumber dateTime;
  final Unsigned32Number signature;
  final Unsigned32Number platform;
  final Unsigned32Number flags;
  final Unsigned32Number manufacturer;
  final Unsigned32Number model;
  final Unsigned64Number attributes;
  final Unsigned32Number renderingIntent;
  final XYZNumber illuminant;
  final Unsigned32Number creator;
  final Uint8List profileID;

  DeviceClass get resolvedDeviceClass => _resolveDeviceClass(deviceClass);

  ColorSpaceSignature get resolvedColorSpace =>
      intToColorSpaceSignature(colorSpace);

  PlatformSignature get resolvedPlatform => _resolvePlatform(platform);

  const ICCProfileHeader({
    required this.size,
    required this.cmmType,
    required this.version,
    required this.deviceClass,
    required this.colorSpace,
    required this.pcs,
    required this.dateTime,
    required this.signature,
    required this.platform,
    required this.flags,
    required this.manufacturer,
    required this.model,
    required this.attributes,
    required this.renderingIntent,
    required this.illuminant,
    required this.creator,
    required this.profileID,
  });

  factory ICCProfileHeader.fromBytes(ByteData bytes, {int offset = 0}) {
    return ICCProfileHeader(
      size: Unsigned32Number.fromBytes(bytes, offset: offset),
      cmmType: bytes.buffer.asUint8List(offset + 4, 4),
      version: Unsigned32Number.fromBytes(bytes, offset: offset + 8),
      deviceClass: Unsigned32Number.fromBytes(bytes, offset: offset + 12),
      colorSpace: Unsigned32Number.fromBytes(bytes, offset: offset + 16),
      pcs: Unsigned32Number.fromBytes(bytes, offset: offset + 20),
      dateTime: DateTimeNumber.fromBytes(bytes, offset: offset + 24),
      signature: Unsigned32Number.fromBytes(bytes, offset: offset + 36),
      platform: Unsigned32Number.fromBytes(bytes, offset: offset + 40),
      flags: Unsigned32Number.fromBytes(bytes, offset: offset + 44),
      manufacturer: Unsigned32Number.fromBytes(bytes, offset: offset + 48),
      model: Unsigned32Number.fromBytes(bytes, offset: offset + 52),
      attributes: Unsigned64Number.fromBytes(bytes, offset: offset + 56),
      renderingIntent: Unsigned32Number.fromBytes(bytes, offset: offset + 64),
      illuminant: XYZNumber.fromBytes(bytes, offset: offset + 68),
      creator: Unsigned32Number.fromBytes(bytes, offset: offset + 80),
      profileID: bytes.buffer.asUint8List(offset + 84, 16),
    );
  }

  @override
  String toString() {
    return 'ICCProfileHeader{size: $size,'
        ' cmmType: $cmmType, version: $version,'
        ' deviceClass: $deviceClass, colorSpace:'
        ' $colorSpace, pcs: $pcs, dateTime: $dateTime,'
        ' signature: $signature, platform: $platform,'
        ' flags: $flags, manufacturer: $manufacturer,'
        ' model: $model, attributes: $attributes,'
        ' renderingIntent: $renderingIntent,'
        ' illuminant: $illuminant,'
        ' creator: $creator,'
        ' profileID: $profileID,'
        ' resolvedDeviceClass: $resolvedDeviceClass,'
        ' resolvedColorSpace: $resolvedColorSpace,'
        ' resolvedPlatform: $resolvedPlatform}';
  }
}

DeviceClass _resolveDeviceClass(Unsigned32Number deviceClass) {
  switch (deviceClass.value) {
    case 0x73636E72:
      return DeviceClass.input;
    case 0x6D6E7472:
      return DeviceClass.display;
    case 0x70727472:
      return DeviceClass.output;
    case 0x6C696E6B:
      return DeviceClass.link;
    case 0x73706163:
      return DeviceClass.colorSpace;
    case 0x61627374:
      return DeviceClass.abstract;
    case 0x6E6D636C:
      return DeviceClass.namedColor;
    default:
      return DeviceClass.unknown;
  }
}

ColorSpaceSignature intToColorSpaceSignature(
  Unsigned32Number colorSpace,
) {
  final rawValue = colorSpace.value;
  return ColorSpaceSignature.values.firstWhere(
    (element) => element.code == rawValue,
  );
}

PlatformSignature _resolvePlatform(Unsigned32Number platform) {
  switch (platform.value) {
    case 0x4150504C:
      return PlatformSignature.apple;
    case 0x4D534654:
      return PlatformSignature.microsoft;
    case 0x53474920:
      return PlatformSignature.siliconGraphics;
    case 0x53554E57:
      return PlatformSignature.sunMicrosystems;
    case 0:
      return PlatformSignature.undefined;
    default:
      return PlatformSignature.unknown;
  }
}

enum DeviceClass {
  input,
  display,
  output,
  link,
  colorSpace,
  abstract,
  namedColor,
  unknown,
}

enum ColorSpaceSignature {
/* 'XYZ ' */
  icSigXYZData(0x58595A20),
  /* 'Lab ' */
  icSigLabData(0x4C616220),
  /* 'Luv ' */
  icSigLuvData(0x4C757620),
  /* 'YCbr' */
  icSigYCbCrData(0x59436272),
  /* 'Yxy ' */
  icSigYxyData(0x59787920),
  /* 'RGB ' */
  icSigRgbData(0x52474220),
  /* 'GRAY' */
  icSigGrayData(0x47524159),
  /* 'HSV ' */
  icSigHsvData(0x48535620),
  /* 'HLS ' */
  icSigHlsData(0x484C5320),
  /* 'CMYK' */
  icSigCmykData(0x434D594B),
  /* 'CMY ' */
  icSigCmyData(0x434D5920),
  /* '1CLR' */
  icSig1colorData(0x31434C52),
  /* '2CLR' */
  icSig2colorData(0x32434C52),
  /* '3CLR' */
  icSig3colorData(0x33434C52),
  /* '4CLR' */
  icSig4colorData(0x34434C52),
  /* '5CLR' */
  icSig5colorData(0x35434C52),
  /* '6CLR' */
  icSig6colorData(0x36434C52),
  /* '7CLR' */
  icSig7colorData(0x37434C52),
  /* '8CLR' */
  icSig8colorData(0x38434C52),
  /* '9CLR' */
  icSig9colorData(0x39434C52),
  /* 'ACLR' */
  icSig10colorData(0x41434C52),
  /* 'BCLR' */
  icSig11colorData(0x42434C52),
  /* 'CCLR' */
  icSig12colorData(0x43434C52),
  /* 'DCLR' */
  icSig13colorData(0x44434C52),
  /* 'ECLR' */
  icSig14colorData(0x45434C52),
  /* 'FCLR' */
  icSig15colorData(0x46434C52),
  /* 'nmcl' */
  icSigNamedData(0x6e6d636c),
  /* '1CLR' */
  icSigMCH1Data(0x31434C52),
  /* '2CLR' */
  icSigMCH2Data(0x32434C52),
  /* '3CLR' */
  icSigMCH3Data(0x33434C52),
  /* '4CLR' */
  icSigMCH4Data(0x34434C52),
  /* '5CLR' */
  icSigMCH5Data(0x35434C52),
  /* '6CLR' */
  icSigMCH6Data(0x36434C52),
  /* '7CLR' */
  icSigMCH7Data(0x37434C52),
  /* '8CLR' */
  icSigMCH8Data(0x38434C52),
  /* '9CLR' */
  icSigMCH9Data(0x39434C52),
  /* 'ACLR' */
  icSigMCHAData(0x41434C52),
  /* 'BCLR' */
  icSigMCHBData(0x42434C52),
  /* 'CCLR' */
  icSigMCHCData(0x43434C52),
  /* 'DCLR' */
  icSigMCHDData(0x44434C52),
  /* 'ECLR' */
  icSigMCHEData(0x45434C52),
  /* 'FCLR' */
  icSigMCHFData(0x46434C52),
  /* "nc0000" */
  icSigNChannelData(0x6e630000),
  /* "mc0000" */
  icSigSrcMCSChannelData(0x6d630000),
  ;

  final int code;

  const ColorSpaceSignature(this.code);
}

enum PlatformSignature {
  apple,
  microsoft,
  siliconGraphics,
  sunMicrosystems,
  undefined,
  unknown,
}
