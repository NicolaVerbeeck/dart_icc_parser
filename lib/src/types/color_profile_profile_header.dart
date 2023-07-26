import 'dart:typed_data';

import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

@immutable
final class ColorProfileProfileHeader {
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

  const ColorProfileProfileHeader({
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

  factory ColorProfileProfileHeader.fromBytes(DataStream bytes) {
    return ColorProfileProfileHeader(
      size: bytes.readUnsigned32Number(),
      cmmType: bytes.readBytes(4),
      version: bytes.readUnsigned32Number(),
      deviceClass: bytes.readUnsigned32Number(),
      colorSpace: bytes.readUnsigned32Number(),
      pcs: bytes.readUnsigned32Number(),
      dateTime: bytes.readDateTime(),
      signature: bytes.readUnsigned32Number(),
      platform: bytes.readUnsigned32Number(),
      flags: bytes.readUnsigned32Number(),
      manufacturer: bytes.readUnsigned32Number(),
      model: bytes.readUnsigned32Number(),
      attributes: bytes.readUnsigned64Number(),
      renderingIntent: bytes.readUnsigned32Number(),
      illuminant: bytes.readXYZNumber(),
      creator: bytes.readUnsigned32Number(),
      profileID: bytes.readBytes(16),
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
  icSigXYZData(0x58595A20, 3),
  /* 'Lab ' */
  icSigLabData(0x4C616220, 3),
  /* 'Luv ' */
  icSigLuvData(0x4C757620, 3),
  /* 'YCbr' */
  icSigYCbCrData(0x59436272, 3),
  /* 'Yxy ' */
  icSigYxyData(0x59787920, 3),
  /* 'RGB ' */
  icSigRgbData(0x52474220, 3),
  /* 'GRAY' */
  icSigGrayData(0x47524159, 1),
  /* 'HSV ' */
  icSigHsvData(0x48535620, 3),
  /* 'HLS ' */
  icSigHlsData(0x484C5320, 3),
  /* 'CMYK' */
  icSigCmykData(0x434D594B, 4),
  /* 'CMY ' */
  icSigCmyData(0x434D5920, 3),
  /* '1CLR' */
  icSig1colorData(0x31434C52, 1),
  /* '2CLR' */
  icSig2colorData(0x32434C52, 2),
  /* '3CLR' */
  icSig3colorData(0x33434C52, 3),
  /* '4CLR' */
  icSig4colorData(0x34434C52, 4),
  /* '5CLR' */
  icSig5colorData(0x35434C52, 5),
  /* '6CLR' */
  icSig6colorData(0x36434C52, 6),
  /* '7CLR' */
  icSig7colorData(0x37434C52, 7),
  /* '8CLR' */
  icSig8colorData(0x38434C52, 8),
  /* '9CLR' */
  icSig9colorData(0x39434C52, 9),
  /* 'ACLR' */
  icSig10colorData(0x41434C52, 10),
  /* 'BCLR' */
  icSig11colorData(0x42434C52, 11),
  /* 'CCLR' */
  icSig12colorData(0x43434C52, 12),
  /* 'DCLR' */
  icSig13colorData(0x44434C52, 13),
  /* 'ECLR' */
  icSig14colorData(0x45434C52, 14),
  /* 'FCLR' */
  icSig15colorData(0x46434C52, 15),
  /* 'nmcl' */
  icSigNamedData(0x6e6d636c, -1),
  /* '1CLR' */
  icSigMCH1Data(0x31434C52, 1),
  /* '2CLR' */
  icSigMCH2Data(0x32434C52, 2),
  /* '3CLR' */
  icSigMCH3Data(0x33434C52, 3),
  /* '4CLR' */
  icSigMCH4Data(0x34434C52, 4),
  /* '5CLR' */
  icSigMCH5Data(0x35434C52, 5),
  /* '6CLR' */
  icSigMCH6Data(0x36434C52, 6),
  /* '7CLR' */
  icSigMCH7Data(0x37434C52, 7),
  /* '8CLR' */
  icSigMCH8Data(0x38434C52, 8),
  /* '9CLR' */
  icSigMCH9Data(0x39434C52, 9),
  /* 'ACLR' */
  icSigMCHAData(0x41434C52, 10),
  /* 'BCLR' */
  icSigMCHBData(0x42434C52, 11),
  /* 'CCLR' */
  icSigMCHCData(0x43434C52, 12),
  /* 'DCLR' */
  icSigMCHDData(0x44434C52, 13),
  /* 'ECLR' */
  icSigMCHEData(0x45434C52, 14),
  /* 'FCLR' */
  icSigMCHFData(0x46434C52, 15),
  /* "nc0000" */
  icSigNChannelData(0x6e630000, -1),
  /* "mc0000" */
  icSigSrcMCSChannelData(0x6d630000, -1),
  ;

  final int code;
  final int numSamples;

  const ColorSpaceSignature(this.code, this.numSamples);
}

enum PlatformSignature {
  apple,
  microsoft,
  siliconGraphics,
  sunMicrosystems,
  undefined,
  unknown,
}
