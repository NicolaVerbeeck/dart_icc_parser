import 'dart:typed_data';

import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:icc_parser/src/types/color_profile_tag_entry.dart';
import 'package:icc_parser/src/types/tag/color_profile_tag_type.dart';
import 'package:icc_parser/src/types/tag/color_profile_tags.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:test/test.dart';

void main() {
  group('ColorProfileTagEntry tests', () {
    test('Test read', () {
      final tag = ColorProfileTagEntry.fromBytes(_dataStreamOf(const [
        0x01, 0x02, 0x03, 0x04, // signature
        0x05, 0x06, 0x07, 0x08, // offset
        0x09, 0x0A, 0x0B, 0x0C, // elementSize
      ]));
      expect(tag.signature.value, 0x01020304);
      expect(tag.offset.value, 0x05060708);
      expect(tag.elementSize.value, 0x090A0B0C);
      expect(
          tag,
          const ColorProfileTagEntry(
            signature: Unsigned32Number(0x01020304),
            offset: Unsigned32Number(0x05060708),
            elementSize: Unsigned32Number(0x090A0B0C),
          ));
      expect(
          tag.hashCode,
          const ColorProfileTagEntry(
            signature: Unsigned32Number(0x01020304),
            offset: Unsigned32Number(0x05060708),
            elementSize: Unsigned32Number(0x090A0B0C),
          ).hashCode);
      expect(
          tag ==
              const ColorProfileTagEntry(
                signature: Unsigned32Number(0x01020304),
                offset: Unsigned32Number(0x05060708),
                elementSize: Unsigned32Number(0x090A0B0D),
              ),
          false);
      expect(
          tag.hashCode ==
              const ColorProfileTagEntry(
                signature: Unsigned32Number(0x01020304),
                offset: Unsigned32Number(0x05060708),
                elementSize: Unsigned32Number(0x090A0B0D),
              ).hashCode,
          false);
    });
    test('Test parseICCColorProfileTag', () {
      final tag = ColorProfileTagEntry.fromBytes(_dataStreamOf(const [
        0x41, 0x32, 0x42, 0x31, // signature
        0x05, 0x06, 0x07, 0x08, // offset
        0x09, 0x0A, 0x0B, 0x0C, // elementSize
      ]));
      expect(tag.knownTag, ICCColorProfileTag.icSigAToB1Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x41324230)),
          ICCColorProfileTag.icSigAToB0Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x41324231)),
          ICCColorProfileTag.icSigAToB1Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x41324232)),
          ICCColorProfileTag.icSigAToB2Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x6258595A)),
          ICCColorProfileTag.icSigBlueMatrixColumnTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x62545243)),
          ICCColorProfileTag.icSigBlueTRCTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x42324130)),
          ICCColorProfileTag.icSigBToA0Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x42324131)),
          ICCColorProfileTag.icSigBToA1Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x42324132)),
          ICCColorProfileTag.icSigBToA2Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x63616C74)),
          ICCColorProfileTag.icSigCalibrationDateTimeTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x74617267)),
          ICCColorProfileTag.icSigCharTargetTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x63686164)),
          ICCColorProfileTag.icSigChromaticAdaptationTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x6368726D)),
          ICCColorProfileTag.icSigChromaticityTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x636C726F)),
          ICCColorProfileTag.icSigColorantOrderTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x636C7274)),
          ICCColorProfileTag.icSigColorantTableTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x636C6F74)),
          ICCColorProfileTag.icSigColorantTableOutTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x63696973)),
          ICCColorProfileTag.icSigColorimetricIntentImageStateTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x63707274)),
          ICCColorProfileTag.icSigCopyrightTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x646D6E64)),
          ICCColorProfileTag.icSigDeviceMfgDescTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x646D6464)),
          ICCColorProfileTag.icSigDeviceModelDescTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x44324230)),
          ICCColorProfileTag.icSigDToB0Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x44324231)),
          ICCColorProfileTag.icSigDToB1Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x44324232)),
          ICCColorProfileTag.icSigDToB2Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x44324233)),
          ICCColorProfileTag.icSigDToB3Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x42324430)),
          ICCColorProfileTag.icSigBToD0Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x42324431)),
          ICCColorProfileTag.icSigBToD1Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x42324432)),
          ICCColorProfileTag.icSigBToD2Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x42324433)),
          ICCColorProfileTag.icSigBToD3Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x67616D74)),
          ICCColorProfileTag.icSigGamutTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x6b545243)),
          ICCColorProfileTag.icSigGrayTRCTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x6758595A)),
          ICCColorProfileTag.icSigGreenColorantTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x67545243)),
          ICCColorProfileTag.icSigGreenTRCTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x6C756d69)),
          ICCColorProfileTag.icSigLuminanceTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x6D656173)),
          ICCColorProfileTag.icSigMeasurementTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x77747074)),
          ICCColorProfileTag.icSigMediaWhitePointTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x6D657461)),
          ICCColorProfileTag.icSigMetaDataTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x6E636C32)),
          ICCColorProfileTag.icSigNamedColor2Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x72657370)),
          ICCColorProfileTag.icSigOutputResponseTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x72696730)),
          ICCColorProfileTag.icSigPerceptualRenderingIntentGamutTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x70726530)),
          ICCColorProfileTag.icSigPreview0Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x70726531)),
          ICCColorProfileTag.icSigPreview1Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x70726532)),
          ICCColorProfileTag.icSigPreview2Tag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x64657363)),
          ICCColorProfileTag.icSigProfileDescriptionTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x70736571)),
          ICCColorProfileTag.icSigProfileSequenceDescTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x70736964)),
          ICCColorProfileTag.icSigProfileSequceIdTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x7258595A)),
          ICCColorProfileTag.icSigRedMatrixColumnTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x72545243)),
          ICCColorProfileTag.icSigRedTRCTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x72696732)),
          ICCColorProfileTag.icSigSaturationRenderingIntentGamutTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x74656368)),
          ICCColorProfileTag.icSigTechnologyTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x76756564)),
          ICCColorProfileTag.icSigViewingCondDescTag);
      expect(parseICCColorProfileTag(const Unsigned32Number(0x76696577)),
          ICCColorProfileTag.icSigViewingConditionsTag);
    });
    test('Test read tag type', () {
      final tag = ColorProfileTagEntry.fromBytes(_dataStreamOf(const [
        0x01, 0x02, 0x03, 0x04, // signature
        0x00, 0x00, 0x00, 0x01, // offset
        0x09, 0x0A, 0x0B, 0x0C, // elementSize
      ]));
      final bd = ByteData.view(
          Uint8List.fromList([0x00, 0x00, 0x00, 0x58, 0x59, 0x5A, 0x20])
              .buffer);
      expect(tag.tagType(bd, offset: 2), ColorProfileTagType.icSigXYZType);
    });
    test('Test read unknown tag type', () {
      final tag = ColorProfileTagEntry.fromBytes(_dataStreamOf(const [
        0x01, 0x02, 0x03, 0x04, // signature
        0x00, 0x00, 0x00, 0x01, // offset
        0x09, 0x0A, 0x0B, 0x0C, // elementSize
      ]));
      final bd = ByteData.view(
          Uint8List.fromList([0x00, 0x00, 0x00, 0x00, 0x09, 0x5A, 0x20])
              .buffer);
      expect(
          () => tag
              .read(DataStream(data: bd, length: bd.lengthInBytes, offset: 0)),
          throwsA(isA<Exception>()));
    });
  });
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
