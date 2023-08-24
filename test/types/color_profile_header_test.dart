import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:fixnum/fixnum.dart';
import 'package:icc_parser/src/types/color_profile_header.dart';
import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:test/test.dart';

void main() {
  group('ColorProfileHeader tests', () {
    test('Test read', () {
      final header = ColorProfileHeader.fromBytes(
          _dataStreamOf(hex.decode(_profileHeader)));

      final expected = _createWithDefaults();
      expect(header, expected);
      expect(header.hashCode, expected.hashCode);
      expect(header == _createWithDefaults(size: const Unsigned32Number(1)),
          false);
      expect(
          header.hashCode ==
              _createWithDefaults(size: const Unsigned32Number(1)).hashCode,
          false);
    });
    test('Test write', () {
      final header = ColorProfileHeader.fromBytes(
          _dataStreamOf(hex.decode(_profileHeader)));
      final bytes = ByteData(100);
      header.toBytes(bytes, 0);
      expect(
          hex.encode(bytes.buffer.asUint8List()).toUpperCase(), _profileHeader);
    });
    test('Test resolve device class', () {
      expect(_createWithDefaults().resolvedDeviceClass, DeviceClass.display);
      expect(resolveDeviceClass(const Unsigned32Number(0x73636E72)),
          DeviceClass.input);
      expect(resolveDeviceClass(const Unsigned32Number(0x6D6E7472)),
          DeviceClass.display);
      expect(resolveDeviceClass(const Unsigned32Number(0x70727472)),
          DeviceClass.output);
      expect(resolveDeviceClass(const Unsigned32Number(0x6C696E6B)),
          DeviceClass.link);
      expect(resolveDeviceClass(const Unsigned32Number(0x73706163)),
          DeviceClass.colorSpace);
      expect(resolveDeviceClass(const Unsigned32Number(0x61627374)),
          DeviceClass.abstract);
      expect(resolveDeviceClass(const Unsigned32Number(0x6E6D636C)),
          DeviceClass.namedColor);
      expect(resolveDeviceClass(const Unsigned32Number(3123)),
          DeviceClass.unknown);
    });
    test('Test resolve color space signature', () {
      expect(_createWithDefaults().resolvedColorSpace,
          ColorSpaceSignature.icSigRgbData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x58595A20)),
          ColorSpaceSignature.icSigXYZData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x4C616220)),
          ColorSpaceSignature.icSigLabData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x4C757620)),
          ColorSpaceSignature.icSigLuvData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x59436272)),
          ColorSpaceSignature.icSigYCbCrData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x59787920)),
          ColorSpaceSignature.icSigYxyData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x52474220)),
          ColorSpaceSignature.icSigRgbData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x47524159)),
          ColorSpaceSignature.icSigGrayData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x48535620)),
          ColorSpaceSignature.icSigHsvData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x484C5320)),
          ColorSpaceSignature.icSigHlsData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x434D594B)),
          ColorSpaceSignature.icSigCmykData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x434D5920)),
          ColorSpaceSignature.icSigCmyData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x31434C52)),
          ColorSpaceSignature.icSig1colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x32434C52)),
          ColorSpaceSignature.icSig2colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x33434C52)),
          ColorSpaceSignature.icSig3colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x34434C52)),
          ColorSpaceSignature.icSig4colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x35434C52)),
          ColorSpaceSignature.icSig5colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x36434C52)),
          ColorSpaceSignature.icSig6colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x37434C52)),
          ColorSpaceSignature.icSig7colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x38434C52)),
          ColorSpaceSignature.icSig8colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x39434C52)),
          ColorSpaceSignature.icSig9colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x41434C52)),
          ColorSpaceSignature.icSig10colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x42434C52)),
          ColorSpaceSignature.icSig11colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x43434C52)),
          ColorSpaceSignature.icSig12colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x44434C52)),
          ColorSpaceSignature.icSig13colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x45434C52)),
          ColorSpaceSignature.icSig14colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x46434C52)),
          ColorSpaceSignature.icSig15colorData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x6e6d636c)),
          ColorSpaceSignature.icSigNamedData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x6e630000)),
          ColorSpaceSignature.icSigNChannelData);
      expect(resolveColorSpaceSignature(const Unsigned32Number(0x6d630000)),
          ColorSpaceSignature.icSigSrcMCSChannelData);
    });

    test('Test resolve platform', () {
      expect(
        _createWithDefaults().resolvedPlatform,
        PlatformSignature.microsoft,
      );
      expect(resolvePlatform(const Unsigned32Number(0x4150504C)),
          PlatformSignature.apple);
      expect(resolvePlatform(const Unsigned32Number(0x4D534654)),
          PlatformSignature.microsoft);
      expect(resolvePlatform(const Unsigned32Number(0x53474920)),
          PlatformSignature.siliconGraphics);
      expect(resolvePlatform(const Unsigned32Number(0x53554E57)),
          PlatformSignature.sunMicrosystems);
      expect(resolvePlatform(const Unsigned32Number(0)),
          PlatformSignature.undefined);
      expect(resolvePlatform(const Unsigned32Number(331)),
          PlatformSignature.unknown);
    });
  });
}

ColorProfileHeader _createWithDefaults({
  Unsigned32Number size = const Unsigned32Number(3144),
  List<int> cmmType = const <int>[76, 105, 110, 111],
  Unsigned32Number version = const Unsigned32Number(34603008),
  Unsigned32Number deviceClass = const Unsigned32Number(1835955314),
  Unsigned32Number colorSpace = const Unsigned32Number(1380401696),
  Unsigned32Number pcs = const Unsigned32Number(1482250784),
  DateTimeNumber dateTime = const DateTimeNumber(
      year: 1998, month: 2, day: 9, hour: 6, minute: 49, second: 0),
  Unsigned32Number signature = const Unsigned32Number(1633907568),
  Unsigned32Number platform = const Unsigned32Number(1297303124),
  Unsigned32Number flags = const Unsigned32Number(0),
  Unsigned32Number manufacturer = const Unsigned32Number(1229275936),
  Unsigned32Number model = const Unsigned32Number(1934772034),
  int attributes = 0,
  Unsigned32Number renderingIntent = const Unsigned32Number(0),
  XYZNumber illuminant = const XYZNumber(
    x: Signed15Fixed16Number(integerPart: 0, fractionalPart: 63190),
    y: Signed15Fixed16Number(integerPart: 1, fractionalPart: 0),
    z: Signed15Fixed16Number(integerPart: 0, fractionalPart: 54061),
  ),
  Unsigned32Number creator = const Unsigned32Number(1213210656),
  List<int> profileID = const [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    160
  ],
}) {
  return ColorProfileHeader(
    size: size,
    cmmType: Uint8List.fromList(cmmType),
    version: version,
    deviceClass: deviceClass,
    colorSpace: colorSpace,
    pcs: pcs,
    dateTime: dateTime,
    signature: signature,
    platform: platform,
    flags: flags,
    manufacturer: manufacturer,
    model: model,
    attributes: Unsigned64Number(Int64(attributes)),
    renderingIntent: renderingIntent,
    illuminant: illuminant,
    creator: creator,
    profileID: Uint8List.fromList(profileID),
  );
}

DataStream _dataStreamOf(List<int> bytes) {
  final buffer = Uint8List.fromList(bytes).buffer;
  final data = ByteData.view(buffer);
  return DataStream(
    data: data,
    length: bytes.length,
    offset: 0,
  );
}

const _profileHeader =
    '00000C484C696E6F021000006D6E74725247422058595A2007CE00020009000600310000'
    '616373704D5346540000000049454320735247420000000000000000000000000000F6D6'
    '000100000000D32D48502020000000000000000000000000000000A0';
