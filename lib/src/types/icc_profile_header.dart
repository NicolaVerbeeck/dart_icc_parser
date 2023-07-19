import 'dart:typed_data';

import 'package:icc_parser/src/types/built_in.dart';
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

  ColorSpaceSignature get resolvedColorSpace => _resolveColorSpace(colorSpace);

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

  factory ICCProfileHeader.fromBytes(final ByteData bytes, {final int offset = 0}) {
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

DeviceClass _resolveDeviceClass(final Unsigned32Number deviceClass) {
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

ColorSpaceSignature _resolveColorSpace(final Unsigned32Number colorSpace) {
  switch (colorSpace.value) {
    case 0x58595A20:
      return ColorSpaceSignature.xyz;
    case 0x4C616220:
      return ColorSpaceSignature.lab;
    case 0x4C757620:
      return ColorSpaceSignature.luv;
    case 0x59436272:
      return ColorSpaceSignature.ycbr;
    case 0x59787920:
      return ColorSpaceSignature.yxy;
    case 0x52474220:
      return ColorSpaceSignature.rgb;
    case 0x47524159:
      return ColorSpaceSignature.gray;
    case 0x48535620:
      return ColorSpaceSignature.hsv;
    case 0x484C5320:
      return ColorSpaceSignature.hls;
    case 0x434D594B:
      return ColorSpaceSignature.cmyk;
    case 0x434D5920:
      return ColorSpaceSignature.cmy;
    case 0x32434C52:
      return ColorSpaceSignature.clr_2;
    case 0x33434C52:
      return ColorSpaceSignature.clr_3;
    case 0x34434C52:
      return ColorSpaceSignature.clr_4;
    case 0x35434C52:
      return ColorSpaceSignature.clr_5;
    case 0x36434C52:
      return ColorSpaceSignature.clr_6;
    case 0x37434C52:
      return ColorSpaceSignature.clr_7;
    case 0x38434C52:
      return ColorSpaceSignature.clr_8;
    case 0x39434C52:
      return ColorSpaceSignature.clr_9;
    case 0x41434C52:
      return ColorSpaceSignature.clr_10;
    case 0x42434C52:
      return ColorSpaceSignature.clr_11;
    case 0x43434C52:
      return ColorSpaceSignature.clr_12;
    case 0x44434C52:
      return ColorSpaceSignature.clr_13;
    case 0x45434C52:
      return ColorSpaceSignature.clr_14;
    case 0x46434C52:
      return ColorSpaceSignature.clr_15;
    default:
      throw Exception('Unknown color space');
  }
}

PlatformSignature _resolvePlatform(final Unsigned32Number platform) {
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
  xyz,
  lab,
  luv,
  ycbr,
  yxy,
  rgb,
  gray,
  hsv,
  hls,
  cmyk,
  cmy,
  clr_2,
  clr_3,
  clr_4,
  clr_5,
  clr_6,
  clr_7,
  clr_8,
  clr_9,
  clr_10,
  clr_11,
  clr_12,
  clr_13,
  clr_14,
  clr_15,
}

enum PlatformSignature {
  apple,
  microsoft,
  siliconGraphics,
  sunMicrosystems,
  undefined,
  unknown,
}
