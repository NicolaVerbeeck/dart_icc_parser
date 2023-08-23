import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:icc_parser/src/types/color_profile_primitives.dart';
import 'package:test/test.dart';

void main() {
  group('Color Profile Primitives tests', () {
    group('Float32Number tests', () {
      test('Test read float32', () {
        final number =
            Float32Number.fromBytes(_byteDataOf([0x42, 0xAA, 0x40, 0x00]));
        expect(number.value, 85.125);
        expect(number, const Float32Number(85.125));
        expect(number == const Float32Number(85.12), false);
        expect(number.hashCode, const Float32Number(85.125).hashCode);
        expect(number.hashCode == const Float32Number(85.12).hashCode, false);
      });
    });
    group('DateTimeNumber tests', () {
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
      test('Test read', () {
        final date = DateTimeNumber.fromBytes(_byteDataOf(_dateTimeData));
        expect(date.year, 1998);
        expect(date.month, 2);
        expect(date.day, 9);
        expect(date.hour, 6);
        expect(date.minute, 49);
        expect(date.second, 0);
        expect(
            date,
            const DateTimeNumber(
              year: 1998,
              month: 2,
              day: 9,
              hour: 6,
              minute: 49,
              second: 0,
            ));
        expect(
            date.hashCode,
            const DateTimeNumber(
              year: 1998,
              month: 2,
              day: 9,
              hour: 6,
              minute: 49,
              second: 0,
            ).hashCode);
        expect(
            date ==
                const DateTimeNumber(
                  year: 1996,
                  month: 2,
                  day: 9,
                  hour: 6,
                  minute: 49,
                  second: 0,
                ),
            false);
        expect(
            date.hashCode ==
                const DateTimeNumber(
                  year: 1996,
                  month: 2,
                  day: 9,
                  hour: 6,
                  minute: 49,
                  second: 0,
                ).hashCode,
            false);
      });
      test('Test write', () {
        final data = ByteData(12);
        const DateTimeNumber(
          year: 1998,
          month: 2,
          day: 9,
          hour: 6,
          minute: 49,
          second: 0,
        ).toBytes(data, 0);
        expect(data.buffer.asUint8List(), _dateTimeData);
      });
      test('Test to dart type', () {
        final asDart = const DateTimeNumber(
          year: 1998,
          month: 2,
          day: 9,
          hour: 6,
          minute: 49,
          second: 0,
        ).value;
        expect(asDart.year, 1998);
        expect(asDart.month, 2);
        expect(asDart.day, 9);
        expect(asDart.hour, 6);
        expect(asDart.minute, 49);
        expect(asDart.second, 0);
      });
    });
    group('PositionNumber tests', () {
      test('Test read', () {
        final value = PositionNumber.fromBytes(_byteDataOf([
          0x10,
          0x01,
          0x2A,
          0xA9,
          0xA9,
          0x2A,
          0x01,
          0x10,
        ]));
        expect(value.offset, 0x10012AA9);
        expect(value.size, 0xA92A0110);
        expect(
          value,
          const PositionNumber(offset: 0x10012AA9, size: 0xA92A0110),
        );
        expect(
          value.hashCode,
          const PositionNumber(offset: 0x10012AA9, size: 0xA92A0110).hashCode,
        );
        expect(
          value == const PositionNumber(offset: 0x10012AA9, size: 0xA92A0111),
          false,
        );
        expect(
          value.hashCode ==
              const PositionNumber(offset: 0x10012AA9, size: 0xA92A0111)
                  .hashCode,
          false,
        );
      });
    });
    group('Response16Number tests', () {
      test('Test read', () {
        final value = Response16Number.fromBytes(_byteDataOf([
          0x19,
          0x13,
          0x00,
          0x00,
          0x00,
          0x01,
          0xF6,
          0xD6,
        ]));
        expect(value.number, 0x1913);
        expect(value.measurementValue.value, 1 + (63190 / 65536));
        expect(
          value,
          const Response16Number(
              number: 0x1913,
              measurementValue:
                  Signed15Fixed16Number(integerPart: 1, fractionalPart: 63190)),
        );
        expect(
          value.hashCode,
          const Response16Number(
                  number: 0x1913,
                  measurementValue: Signed15Fixed16Number(
                      integerPart: 1, fractionalPart: 63190))
              .hashCode,
        );
      });
    });
    group('Signed15Fixed16Number tests', () {
      test('Test read', () {
        final value = Signed15Fixed16Number.fromBytes(
            _byteDataOf([0x80, 0x01, 0xF6, 0xD6]));
        expect(value.integerPart, -32767);
        expect(value.fractionalPart, 63190);
        expect(value.value, -32767 + (63190 / 65536));
        expect(
            value,
            const Signed15Fixed16Number(
                integerPart: -32767, fractionalPart: 63190));
        expect(
            value.hashCode,
            const Signed15Fixed16Number(
                    integerPart: -32767, fractionalPart: 63190)
                .hashCode);
        expect(
            value ==
                const Signed15Fixed16Number(
                    integerPart: -32767, fractionalPart: 63191),
            false);
        expect(
            value.hashCode ==
                const Signed15Fixed16Number(
                        integerPart: -32767, fractionalPart: 63191)
                    .hashCode,
            false);
      });
      test('Test write', () {
        final value = Signed15Fixed16Number.fromBytes(
            _byteDataOf([0x80, 0x01, 0xF6, 0xD6]));
        final data = ByteData(4);
        value.toBytes(data, 0);
        expect(data.buffer.asUint8List(), [0x80, 0x01, 0xF6, 0xD6]);
      });
    });
    group('Unsigned16Fixed16Number tests', () {
      test('Test read', () {
        final value = Unsigned16Fixed16Number.fromBytes(
            _byteDataOf([0x80, 0x01, 0xF6, 0xD6]));
        expect(value.integerPart, 32769);
        expect(value.fractionalPart, 63190);
        expect(value.value, 32769 + (63190 / 65536));
        expect(
            value,
            const Unsigned16Fixed16Number(
                integerPart: 32769, fractionalPart: 63190));
        expect(
            value.hashCode,
            const Unsigned16Fixed16Number(
                    integerPart: 32769, fractionalPart: 63190)
                .hashCode);
        expect(
            value ==
                const Unsigned16Fixed16Number(
                    integerPart: 32769, fractionalPart: 63191),
            false);
        expect(
            value.hashCode ==
                const Unsigned16Fixed16Number(
                        integerPart: 32769, fractionalPart: 63191)
                    .hashCode,
            false);
      });
    });
    group('Unsigned1Fixed15Number tests', () {
      test('Test read', () {
        final value =
            Unsigned1Fixed15Number.fromBytes(_byteDataOf([0x84, 0x31]));
        expect(value.integerPart, 1);
        expect(value.fractionalPart, 1073);
        expect(value.value, 1 + (1073 / 32768));
        expect(value,
            const Unsigned1Fixed15Number(integerPart: 1, fractionalPart: 1073));
        expect(
            value.hashCode,
            const Unsigned1Fixed15Number(integerPart: 1, fractionalPart: 1073)
                .hashCode);
        expect(
            value ==
                const Unsigned1Fixed15Number(
                    integerPart: 1, fractionalPart: 1074),
            false);
        expect(
            value.hashCode ==
                const Unsigned1Fixed15Number(
                        integerPart: 1, fractionalPart: 1074)
                    .hashCode,
            false);
      });
    });
    group('Unsigned8Fixed8Number tests', () {
      test('Test read', () {
        final value =
            Unsigned8Fixed8Number.fromBytes(_byteDataOf([0x84, 0x31]));
        expect(value.integerPart, 0x84);
        expect(value.fractionalPart, 0x31);
        expect(value.value, 0x84 + (0x31 / 256));
        expect(
            value,
            const Unsigned8Fixed8Number(
                integerPart: 0x84, fractionalPart: 0x31));
        expect(
            value.hashCode,
            const Unsigned8Fixed8Number(integerPart: 0x84, fractionalPart: 0x31)
                .hashCode);
        expect(
            value ==
                const Unsigned8Fixed8Number(
                    integerPart: 0x84, fractionalPart: 0x32),
            false);
        expect(
            value.hashCode ==
                const Unsigned8Fixed8Number(
                        integerPart: 0x84, fractionalPart: 0x32)
                    .hashCode,
            false);
      });
    });
    group('Unsigned16Number tests', () {
      test('Test read', () {
        final value = Unsigned16Number.fromBytes(_byteDataOf([0x84, 0x31]));
        expect(value.value, 0x8431);
        expect(value, const Unsigned16Number(0x8431));
        expect(value.hashCode, const Unsigned16Number(0x8431).hashCode);
        expect(value == const Unsigned16Number(0x8432), false);
        expect(
            value.hashCode == const Unsigned16Number(0x8432).hashCode, false);
      });
    });
    group('Unsigned32Number tests', () {
      test('Test read', () {
        final value =
            Unsigned32Number.fromBytes(_byteDataOf([0x84, 0x31, 0x11, 0xFF]));
        expect(value.value, 0x843111FF);
        expect(value, const Unsigned32Number(0x843111FF));
        expect(value.hashCode, const Unsigned32Number(0x843111FF).hashCode);
        expect(value == const Unsigned32Number(0x843111FB), false);
        expect(value.hashCode == const Unsigned32Number(0x843111FB).hashCode,
            false);
      });
    });
    group('Unsigned64Number tests', () {
      test('Test read', () {
        final value = Unsigned64Number.fromBytes(
            _byteDataOf([0x84, 0x31, 0x11, 0xFF, 0x42, 0x44, 0x11, 0xFF]));
        // ignore: avoid_js_rounded_ints
        expect(value.value, Int64(0x843111FF424411FF));
        // ignore: avoid_js_rounded_ints
        expect(value, Unsigned64Number(Int64(0x843111FF424411FF)));
        expect(
            value.hashCode,
            // ignore: avoid_js_rounded_ints
            Unsigned64Number(Int64(0x843111FF424411FF)).hashCode);
        // ignore: avoid_js_rounded_ints
        expect(value == Unsigned64Number(Int64(0x843111FF424411FB)), false);
        expect(
            value.hashCode ==
                // ignore: avoid_js_rounded_ints
                Unsigned64Number(Int64(0x843111FF424411FB)).hashCode,
            false);
      });
      test('Test write', () {
        final value = Unsigned64Number.fromBytes(
            _byteDataOf([0x84, 0x31, 0x11, 0xFF, 0x42, 0x44, 0x11, 0xFF]));
        final data = ByteData(8);
        value.toBytes(data, 0);
        expect(data.buffer.asUint8List(),
            [0x84, 0x31, 0x11, 0xFF, 0x42, 0x44, 0x11, 0xFF]);
      });
    });
    group('Unsigned8Number tests', () {
      test('Test read', () {
        final value =
            Unsigned8Number.fromBytes(_byteDataOf([0x84, 0x31, 0x11, 0xFF]));
        expect(value.value, 0x84);
        expect(value, const Unsigned8Number(0x84));
        expect(value.hashCode, const Unsigned8Number(0x84).hashCode);
        expect(value == const Unsigned8Number(0x85), false);
        expect(value.hashCode == const Unsigned8Number(0x85).hashCode, false);
      });
    });
    group('XYZNumber tests', () {
      test('Test read', () {
        final stream = _byteDataOf([
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
        final value = XYZNumber.fromBytes(stream);
        expect(value.x.value, 0);
        expect(value.y.value, 63190 / 65536);
        expect(value.z.value, 1);
        expect(value, XYZNumber.fromValues([value.x, value.y, value.z]));
        expect(value.hashCode,
            XYZNumber.fromValues([value.x, value.y, value.z]).hashCode);
      });
      test('Test write', () {
        final stream = _byteDataOf([
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
        final value = XYZNumber.fromBytes(stream);
        final data = ByteData(12);
        value.toBytes(data, 0);
        expect(data.buffer.asUint8List(), [
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
      });
    });
  });
}

ByteData _byteDataOf(List<int> data) =>
    ByteData.view(Uint8List.fromList(data).buffer);
