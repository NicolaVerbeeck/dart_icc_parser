import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:meta/meta.dart';

/// Header of a color profile file
@immutable
class ColorProfileHeader {
  /// Size of the header
  final Unsigned32Number size;

  /// Raw CMM type
  final Uint8List cmmType;

  /// Version of the profile
  final Unsigned32Number version;

  /// Raw device class
  final Unsigned32Number deviceClass;

  /// Raw color space
  final Unsigned32Number colorSpace;

  /// Raw PCS
  final Unsigned32Number pcs;

  /// Date and time of profile creation
  final DateTimeNumber dateTime;

  /// Signature of the profile
  final Unsigned32Number signature;

  /// Raw platform
  final Unsigned32Number platform;

  /// Flags
  final Unsigned32Number flags;

  /// Manufacturer
  final Unsigned32Number manufacturer;

  /// Model
  final Unsigned32Number model;

  /// Attributes
  final Unsigned64Number attributes;

  /// Rendering intent
  final Unsigned32Number renderingIntent;

  /// Illuminant
  final XYZNumber illuminant;

  /// Creator
  final Unsigned32Number creator;

  /// Profile ID
  final Uint8List profileID;

  /// Resolved device class
  DeviceClass get resolvedDeviceClass => resolveDeviceClass(deviceClass);

  /// Resolved color space
  ColorSpaceSignature get resolvedColorSpace =>
      resolveColorSpaceSignature(colorSpace);

  /// Resolved platform
  PlatformSignature get resolvedPlatform => resolvePlatform(platform);

  /// Creates a new color profile header
  const ColorProfileHeader({
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

  /// Creates a new color profile header by parsing it from the given [bytes].
  factory ColorProfileHeader.fromBytes(DataStream bytes) {
    return ColorProfileHeader(
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorProfileHeader &&
          runtimeType == other.runtimeType &&
          size == other.size &&
          const DeepCollectionEquality().equals(cmmType, other.cmmType) &&
          version == other.version &&
          deviceClass == other.deviceClass &&
          colorSpace == other.colorSpace &&
          pcs == other.pcs &&
          dateTime == other.dateTime &&
          signature == other.signature &&
          platform == other.platform &&
          flags == other.flags &&
          manufacturer == other.manufacturer &&
          model == other.model &&
          attributes == other.attributes &&
          renderingIntent == other.renderingIntent &&
          illuminant == other.illuminant &&
          creator == other.creator &&
          const DeepCollectionEquality().equals(profileID, other.profileID);

  @override
  int get hashCode =>
      size.hashCode ^
      const DeepCollectionEquality().hash(cmmType) ^
      version.hashCode ^
      deviceClass.hashCode ^
      colorSpace.hashCode ^
      pcs.hashCode ^
      dateTime.hashCode ^
      signature.hashCode ^
      platform.hashCode ^
      flags.hashCode ^
      manufacturer.hashCode ^
      model.hashCode ^
      attributes.hashCode ^
      renderingIntent.hashCode ^
      illuminant.hashCode ^
      creator.hashCode ^
      const DeepCollectionEquality().hash(profileID);

  // coverage:ignore-start
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

  // coverage:ignore-end

  /// Write the header to the provided [data] starting at the given [offset].
  /// The [data] must be at least 128 bytes long after [offset].
  void toBytes(ByteData data, int offset) {
    data.setUint32(offset, size.value);
    for (var i = 0; i < 4; ++i) {
      data.setUint8(offset + 4 + i, cmmType[i]);
    }
    data.setUint32(offset + 8, version.value);
    data.setUint32(offset + 12, deviceClass.value);
    data.setUint32(offset + 16, colorSpace.value);
    data.setUint32(offset + 20, pcs.value);
    dateTime.toBytes(data, offset + 24);
    data.setUint32(offset + 36, signature.value);
    data.setUint32(offset + 40, platform.value);
    data.setUint32(offset + 44, flags.value);
    data.setUint32(offset + 48, manufacturer.value);
    data.setUint32(offset + 52, model.value);
    attributes.toBytes(data, offset + 56);
    data.setUint32(offset + 64, renderingIntent.value);
    illuminant.toBytes(data, offset + 68);
    data.setUint32(offset + 80, creator.value);
    for (var i = 0; i < 16; ++i) {
      data.setUint8(offset + 84 + i, profileID[i]);
    }
  }
}

/// Resolves the device class from the raw [deviceClass] value.
DeviceClass resolveDeviceClass(Unsigned32Number deviceClass) {
  final rawValue = deviceClass.value;
  return DeviceClass.values.firstWhere(
    (element) => element.code == rawValue,
    orElse: () => DeviceClass.unknown,
  );
}

/// Resolves the color space from the raw [colorSpace] value.
ColorSpaceSignature resolveColorSpaceSignature(
  Unsigned32Number colorSpace,
) {
  final rawValue = colorSpace.value;
  return ColorSpaceSignature.values.firstWhere(
    (element) => element.code == rawValue,
  );
}

/// Resolves the platform from the raw [platform] value.
PlatformSignature resolvePlatform(Unsigned32Number platform) {
  final rawValue = platform.value;
  return PlatformSignature.values.firstWhere(
    (element) => element.code == rawValue,
    orElse: () => PlatformSignature.unknown,
  );
}

/// Device class of a color profile
enum DeviceClass {
  input(0x73636E72),
  display(0x6D6E7472),
  output(0x70727472),
  link(0x6C696E6B),
  colorSpace(0x73706163),
  abstract(0x61627374),
  namedColor(0x6E6D636C),
  unknown(0),
  ;

  final int code;

  const DeviceClass(this.code);
}

/// Color space signature of a color profile
enum ColorSpaceSignature {
  /// 'XYZ '
  icSigXYZData(0x58595A20, 3),

  /// 'Lab '
  icSigLabData(0x4C616220, 3),

  /// 'Luv '
  icSigLuvData(0x4C757620, 3),

  /// 'YCbr'
  icSigYCbCrData(0x59436272, 3),

  /// 'Yxy '
  icSigYxyData(0x59787920, 3),

  /// 'RGB '
  icSigRgbData(0x52474220, 3),

  /// 'GRAY'
  icSigGrayData(0x47524159, 1),

  /// 'HSV '
  icSigHsvData(0x48535620, 3),

  /// 'HLS '
  icSigHlsData(0x484C5320, 3),

  /// 'CMYK'
  icSigCmykData(0x434D594B, 4),

  /// 'CMY '
  icSigCmyData(0x434D5920, 3),

  /// '1CLR'
  icSig1colorData(0x31434C52, 1),

  /// '2CLR'
  icSig2colorData(0x32434C52, 2),

  /// '3CLR'
  icSig3colorData(0x33434C52, 3),

  /// '4CLR'
  icSig4colorData(0x34434C52, 4),

  /// '5CLR'
  icSig5colorData(0x35434C52, 5),

  /// '6CLR'
  icSig6colorData(0x36434C52, 6),

  /// '7CLR'
  icSig7colorData(0x37434C52, 7),

  /// '8CLR'
  icSig8colorData(0x38434C52, 8),

  /// '9CLR'
  icSig9colorData(0x39434C52, 9),

  /// 'ACLR'
  icSig10colorData(0x41434C52, 10),

  /// 'BCLR'
  icSig11colorData(0x42434C52, 11),

  /// 'CCLR'
  icSig12colorData(0x43434C52, 12),

  /// 'DCLR'
  icSig13colorData(0x44434C52, 13),

  /// 'ECLR'
  icSig14colorData(0x45434C52, 14),

  /// 'FCLR'
  icSig15colorData(0x46434C52, 15),

  /// 'nmcl'
  icSigNamedData(0x6e6d636c, -1),

  /// "nc0000"
  icSigNChannelData(0x6e630000, -1),

  /// "mc0000"
  icSigSrcMCSChannelData(0x6d630000, -1),
  ;

  /// The raw spec identifier
  final int code;

  /// Number of samples in the color space
  final int numSamples;

  /// Creates a new color space signature
  const ColorSpaceSignature(this.code, this.numSamples);
}

/// Platform signature of a color profile
enum PlatformSignature {
  /// 'APPL'
  apple(0x4150504C),

  /// 'MSFT'
  microsoft(0x4D534654),

  /// 'SGI '
  siliconGraphics(0x53474920),

  /// 'SUNW'
  sunMicrosystems(0x53554E57),

  /// Undefined
  undefined(0),

  /// Not found
  unknown(-1),
  ;

  /// The raw spec identifier
  final int code;

  const PlatformSignature(this.code);
}
