import 'dart:typed_data';

import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:icc_parser/src/types/color_profile_tag_entry.dart';
import 'package:icc_parser/src/types/color_profile_tag_table.dart';
import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:test/test.dart';

void main() {
  group('ColorProfileTagTable tests', () {
    test('Test read', () {
      final table = ColorProfileTagTable.fromBytes(_dataStreamOf([
        0x00, 0x00, 0x00, 0x02, // tagCount
        0x01, 0x02, 0x03, 0x04, // signature
        0x05, 0x06, 0x07, 0x08, // offset
        0x09, 0x0A, 0x0B, 0x0C, // elementSize
        0x01, 0x02, 0x03, 0x04, // signature
        0x05, 0x06, 0x07, 0x08, // offset
        0x09, 0x0A, 0x0B, 0x0C, // elementSize
      ]));
      expect(table.length, 2);
      expect(
          table[0],
          const ColorProfileTagEntry(
            signature: Unsigned32Number(0x01020304),
            offset: Unsigned32Number(0x05060708),
            elementSize: Unsigned32Number(0x090A0B0C),
          ));
      expect(
          table[1],
          const ColorProfileTagEntry(
            signature: Unsigned32Number(0x01020304),
            offset: Unsigned32Number(0x05060708),
            elementSize: Unsigned32Number(0x090A0B0C),
          ));
    });
    test('Test write is not allowed', () {
      const table = ColorProfileTagTable([
        ColorProfileTagEntry(
          signature: Unsigned32Number(0x01020304),
          offset: Unsigned32Number(0x05060708),
          elementSize: Unsigned32Number(0x090A0B0C),
        )
      ]);
      expect(() {
        table[0] = const ColorProfileTagEntry(
          signature: Unsigned32Number(0x01020304),
          offset: Unsigned32Number(0x05060708),
          elementSize: Unsigned32Number(0x090A0B0C),
        );
      }, throwsArgumentError);
      expect(() => table.length = 2, throwsArgumentError);
    });
    test('Test equality', () {
      final table = ColorProfileTagTable.fromBytes(_dataStreamOf([
        0x00, 0x00, 0x00, 0x02, // tagCount
        0x01, 0x02, 0x03, 0x04, // signature
        0x05, 0x06, 0x07, 0x08, // offset
        0x09, 0x0A, 0x0B, 0x0C, // elementSize
        0x01, 0x02, 0x03, 0x04, // signature
        0x05, 0x06, 0x07, 0x08, // offset
        0x09, 0x0A, 0x0B, 0x0C, // elementSize
      ]));
      const secondTable = ColorProfileTagTable([
        ColorProfileTagEntry(
            signature: Unsigned32Number(0x01020304),
            offset: Unsigned32Number(0x05060708),
            elementSize: Unsigned32Number(0x090A0B0C)),
        ColorProfileTagEntry(
          signature: Unsigned32Number(0x01020304),
          offset: Unsigned32Number(0x05060708),
          elementSize: Unsigned32Number(0x090A0B0C),
        )
      ]);
      const thirdTable = ColorProfileTagTable([
        ColorProfileTagEntry(
            signature: Unsigned32Number(0x01020304),
            offset: Unsigned32Number(0x05060708),
            elementSize: Unsigned32Number(0x090A0B0C)),
        ColorProfileTagEntry(
          signature: Unsigned32Number(0x01020303),
          offset: Unsigned32Number(0x05060708),
          elementSize: Unsigned32Number(0x090A0B0C),
        )
      ]);
      expect(table, secondTable);
      expect(table.hashCode, secondTable.hashCode);
      expect(table.hashCode == thirdTable.hashCode, false);
      expect(table == thirdTable, false);
    });
    test('Test write', () {
      const table = ColorProfileTagTable([
        ColorProfileTagEntry(
            signature: Unsigned32Number(0x01020304),
            offset: Unsigned32Number(0x05060708),
            elementSize: Unsigned32Number(0x090A0B0C)),
        ColorProfileTagEntry(
          signature: Unsigned32Number(0x01020304),
          offset: Unsigned32Number(0x05060708),
          elementSize: Unsigned32Number(0x090A0B0C),
        )
      ]);
      final data = ByteData(4 + 2 * 12);
      table.toBytes(data, 0);
      expect(data.buffer.asUint8List(), [
        0x00, 0x00, 0x00, 0x02, // tagCount
        0x01, 0x02, 0x03, 0x04, // signature
        0x00, 0x00, 0x00, 0x1C, // new offset
        0x09, 0x0A, 0x0B, 0x0C, // elementSize
        0x01, 0x02, 0x03, 0x04, // signature
        0x09, 0x0A, 0x0B, 0x28, // offset
        0x09, 0x0A, 0x0B, 0x0C, // elementSize
      ]);
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
