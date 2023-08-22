import 'dart:typed_data';

import 'package:icc_parser/src/utils/data_stream.dart';
import 'package:test/test.dart';

void main() {
  const _dateTimeData = [
    0x07,
    0xCE,
    0x00,
    0x02,
    0x00,
    0x09,
    0x00,
    0x06,
    0x00,
    0x31,
    0x00,
    0x00
  ];

  group('DataStream tests', () {
    test('Test seek', () {
      final stream = DataStream(
        data: ByteData(10),
        length: 10,
        offset: 0,
      );
      expect(stream.position, 0);
      stream.seek(5);
      expect(stream.position, 5);
    });
    test('Test readDataTime', () {
      final stream = _dataStreamOf(_dateTimeData);
      final value = stream.readDateTime();
      expect(value.year, 1998);
      expect(value.month, 2);
      expect(value.day, 9);
      expect(value.hour, 6);
      expect(value.minute, 49);
      expect(value.second, 0);
      expect(stream.position, 12);
    });
    test('Test read bytes', () {
      final stream = _dataStreamOf([0x01, 0x02, 0x03, 0x04, 0x05]);
      stream.seek(1);
      final value = stream.readBytes(3);
      expect(value, [0x02, 0x03, 0x04]);
      expect(stream.position, 4);
    });
    test('Test read uint64', () {
      final stream = _dataStreamOf(_dateTimeData);
      final value = stream.readUnsigned64Number();
      // ignore: avoid_js_rounded_ints
      expect(value.value.toInt(), 562387012058415110);
      expect(stream.position, 8);
    });
    test('Test read uint32', () {
      final stream = _dataStreamOf(_dateTimeData);
      stream.seek(1);
      final value = stream.readUnsigned32Number();
      expect(value.value, 3456107008);
      expect(stream.position, 5);
    });
    test('Test read uint16', () {
      final stream = _dataStreamOf(_dateTimeData);
      stream.seek(1);
      final value = stream.readUnsigned16Number();
      expect(value.value, 52736);
      expect(stream.position, 3);
    });
    test('Test read uint8', () {
      final stream = _dataStreamOf(_dateTimeData);
      stream.seek(1);
      final value = stream.readUnsigned8Number();
      expect(value.value, 206);
      expect(stream.position, 2);
    });
    test('Test read signed 15 fixed 16', () {
      final stream = _dataStreamOf([0x00, 0x01, 0xF6, 0xD6]);
      final value = stream.readSigned15Fixed16Number();
      expect(value.value, 1 + (63190 / 65536));
      expect(stream.position, 4);
    });
    test('Test read xyz number', () {
      final stream = _dataStreamOf([
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0xF6,
        0xD6,
        0x00,
        0x01,
        0x00,
        0x00,
      ]);
      final value = stream.readXYZNumber();
      expect(value.x.value, 0);
      expect(value.y.value, 63190 / 65536);
      expect(value.z.value, 1);
      expect(stream.position, 12);
    });
    test('Test skip', () {
      final stream = DataStream(
        data: ByteData(10),
        length: 10,
        offset: 0,
      );
      expect(stream.position, 0);
      stream.seek(5);
      expect(stream.position, 5);
      stream.skip(3);
      expect(stream.position, 8);
    });
    test('Test sync32', () {
      final stream = DataStream(
        data: ByteData(10),
        length: 10,
        offset: 0,
      );
      stream.seek(3);
      stream.sync32(5);
      // No idea what this is supposed to do
      expect(stream.position, 5);
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
