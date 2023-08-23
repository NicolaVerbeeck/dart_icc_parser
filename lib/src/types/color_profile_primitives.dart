import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';

/// IEEE 754 32-bit floating point number
/// See ICC.1:2010 [4.3]
@immutable
final class Float32Number {
  /// The value of the number
  final double value;

  /// Creates a new [Float32Number] with the given [value]
  const Float32Number(this.value);

  /// Creates a new [Float32Number] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 4 bytes starting at [offset].
  factory Float32Number.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 4);
    final value = bytes.getFloat32(offset);
    return Float32Number(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Float32Number &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'Float32Number{value: $value}';
  }
// coverage:ignore-end
}

/// Date time representation, in UTC
/// /// See ICC.1:2010 [4.2]
@immutable
final class DateTimeNumber {
  /// Year, actual year, not offset
  final int year;

  /// Month, 1-12
  final int month;

  /// Day, 1-31
  final int day;

  /// Hour, 0-23;
  final int hour;

  /// Minute, 0-59
  final int minute;

  /// Second, 0-59
  final int second;

  /// The date time as a dart [DateTime]
  DateTime get value => DateTime.utc(year, month, day, hour, minute, second);

  /// Creates a new [DateTimeNumber] with the given [year], [month], [day], [hour], [minute] and [second]
  const DateTimeNumber({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
  });

  /// Creates a new [DateTimeNumber] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 12 bytes starting at [offset].
  factory DateTimeNumber.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 12);
    return DateTimeNumber(
      year: bytes.getUint16(offset),
      month: bytes.getUint16(offset + 2),
      day: bytes.getUint16(offset + 4),
      hour: bytes.getUint16(offset + 6),
      minute: bytes.getUint16(offset + 8),
      second: bytes.getUint16(offset + 10),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateTimeNumber &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          day == other.day &&
          hour == other.hour &&
          minute == other.minute &&
          second == other.second;

  @override
  int get hashCode =>
      year.hashCode ^
      month.hashCode ^
      day.hashCode ^
      hour.hashCode ^
      minute.hashCode ^
      second.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'DateTimeNumber{year: $year, month: $month, day: $day, hour: $hour, minute: $minute, second: $second}';
  }

// coverage:ignore-end

  /// Writes the [DateTimeNumber] to the given [data] starting at [offset].
  /// [data] must hold at least 12 bytes starting at [offset].
  void toBytes(ByteData data, int offset) {
    data.setUint16(offset, year);
    data.setUint16(offset + 2, month);
    data.setUint16(offset + 4, day);
    data.setUint16(offset + 6, hour);
    data.setUint16(offset + 8, minute);
    data.setUint16(offset + 10, second);
  }
}

/// Represents an offset and size of an entry in the structure
/// ICC.1:2010 [4.4]
@immutable
final class PositionNumber {
  /// Offset of the entry in the structure, in bytes
  final int offset;

  /// Size of the entry in the structure, in bytes
  final int size;

  /// Creates a new [PositionNumber] with the given [offset] and [size]
  const PositionNumber({
    required this.offset,
    required this.size,
  });

  /// Creates a new [PositionNumber] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 8 bytes starting at [offset].
  factory PositionNumber.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 8);
    return PositionNumber(
      offset: bytes.getUint32(offset),
      size: bytes.getUint32(offset + 4),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionNumber &&
          runtimeType == other.runtimeType &&
          offset == other.offset &&
          size == other.size;

  @override
  int get hashCode => offset.hashCode ^ size.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'PositionNumber{offset: $offset, size: $size}';
  }
// coverage:ignore-end
}

/// An 8-byte value, used to associate a normalized device code with a measurement
/// ICC.1:2010 [4.5]
@immutable
final class Response16Number {
  /// 16 bit number in the interval [DeviceMin to DeviceMax] (0x0000 to 0xFFFF)
  final int number;

  /// Measurement value
  final Signed15Fixed16Number measurementValue;

  /// Creates a new [Response16Number] with the given [number] and [measurementValue]
  const Response16Number({
    required this.number,
    required this.measurementValue,
  });

  /// Creates a new [Response16Number] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 8 bytes starting at [offset].
  factory Response16Number.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 8);
    return Response16Number(
      number: bytes.getUint16(offset),
      measurementValue:
          Signed15Fixed16Number.fromBytes(bytes, offset: offset + 4),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Response16Number &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          measurementValue == other.measurementValue;

  @override
  int get hashCode => number.hashCode ^ measurementValue.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'Response16Number{number: $number, measurementValue: $measurementValue}';
  }
// coverage:ignore-end
}

/// Fixed 4 byte quantity which has 16 fractional bits and 15 integer bits, preceded by a sign bit
@immutable
final class Signed15Fixed16Number {
  /// Signed integer part
  final int integerPart;

  /// Unsigned fractional part, max value is 65535
  final int fractionalPart;

  /// [double] representation of the number
  double get value => integerPart + (fractionalPart / 65536);

  /// Creates a new [Signed15Fixed16Number] with the given [integerPart] and [fractionalPart]
  const Signed15Fixed16Number({
    required this.integerPart,
    required this.fractionalPart,
  });

  /// Creates a new [Signed15Fixed16Number] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 4 bytes starting at [offset].
  factory Signed15Fixed16Number.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 4);
    return Signed15Fixed16Number(
      integerPart: bytes.getInt16(offset),
      fractionalPart: bytes.getUint16(offset + 2),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Signed15Fixed16Number &&
          runtimeType == other.runtimeType &&
          integerPart == other.integerPart &&
          fractionalPart == other.fractionalPart;

  @override
  int get hashCode => integerPart.hashCode ^ fractionalPart.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'Signed15Fixed16Number{integerPart: $integerPart, '
        'fractionalPart: $fractionalPart, value: $value}';
  }
// coverage:ignore-end

  /// Writes the [Signed15Fixed16Number] to the given [data] starting at [offset].
  /// [data] must hold at least 4 bytes starting at [offset].
  void toBytes(ByteData data, int offset) {
    data.setInt16(offset, integerPart);
    data.setUint16(offset + 2, fractionalPart);
  }
}

/// Fixed 4 byte quantity which has 16 fractional bits and 16 integer bits (unsigned)
@immutable
final class Unsigned16Fixed16Number {
  /// Unsigned integer part
  final int integerPart;

  /// Unsigned fractional part, max value is 65535
  final int fractionalPart;

  /// [double] representation of the number
  double get value => integerPart + (fractionalPart / 65536);

  /// Creates a new [Unsigned16Fixed16Number] with the given [integerPart] and [fractionalPart]
  const Unsigned16Fixed16Number({
    required this.integerPart,
    required this.fractionalPart,
  });

  /// Creates a new [Unsigned16Fixed16Number] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 4 bytes starting at [offset].
  factory Unsigned16Fixed16Number.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 4);
    return Unsigned16Fixed16Number(
      integerPart: bytes.getUint16(offset),
      fractionalPart: bytes.getUint16(offset + 2),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unsigned16Fixed16Number &&
          runtimeType == other.runtimeType &&
          integerPart == other.integerPart &&
          fractionalPart == other.fractionalPart;

  @override
  int get hashCode => integerPart.hashCode ^ fractionalPart.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'Unsigned16Fixed16Number{integerPart: $integerPart, fractionalPart: $fractionalPart}';
  }
// coverage:ignore-end
}

/// Fixed 2 byte quantity which has 15 fractional bits and 1 integer bit (unsigned)
@immutable
final class Unsigned1Fixed15Number {
  /// Unsigned integer part (1 or 0)
  final int integerPart;

  /// Unsigned fractional part, max value is 32767
  final int fractionalPart;

  /// [double] representation of the number
  double get value => integerPart + (fractionalPart / 32768);

  /// Creates a new [Unsigned1Fixed15Number] with the given [integerPart] and [fractionalPart]
  const Unsigned1Fixed15Number({
    required this.integerPart,
    required this.fractionalPart,
  });

  /// Creates a new [Unsigned1Fixed15Number] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 2 bytes starting at [offset].
  factory Unsigned1Fixed15Number.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 2);
    final raw = bytes.getUint16(offset);

    return Unsigned1Fixed15Number(
      integerPart: (raw & 0x8000) >> 15,
      fractionalPart: raw & 0x7FFF,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unsigned1Fixed15Number &&
          runtimeType == other.runtimeType &&
          integerPart == other.integerPart &&
          fractionalPart == other.fractionalPart;

  @override
  int get hashCode => integerPart.hashCode ^ fractionalPart.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'Unsigned1Fixed15Number{integerPart: $integerPart, fractionalPart: $fractionalPart}';
  }
// coverage:ignore-end
}

/// Fixed 2 byte quantity which has 8 fractional bits and 8 integer bits (unsigned)
@immutable
final class Unsigned8Fixed8Number {
  /// Unsigned integer part
  final int integerPart;

  /// Unsigned fractional part, max value is 255
  final int fractionalPart;

  /// [double] representation of the number
  double get value => integerPart + (fractionalPart / 256);

  /// Creates a new [Unsigned8Fixed8Number] with the given [integerPart] and [fractionalPart]
  const Unsigned8Fixed8Number({
    required this.integerPart,
    required this.fractionalPart,
  });

  /// Creates a new [Unsigned8Fixed8Number] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 2 bytes starting at [offset].
  factory Unsigned8Fixed8Number.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 2);
    return Unsigned8Fixed8Number(
      integerPart: bytes.getUint8(offset),
      fractionalPart: bytes.getUint8(offset + 1),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unsigned8Fixed8Number &&
          runtimeType == other.runtimeType &&
          integerPart == other.integerPart &&
          fractionalPart == other.fractionalPart;

  @override
  int get hashCode => integerPart.hashCode ^ fractionalPart.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'Unsigned8Fixed8Number{integerPart: $integerPart, fractionalPart: $fractionalPart}';
  }
// coverage:ignore-end
}

/// Fixed 2 byte unsigned integer
@immutable
final class Unsigned16Number {
  /// Unsigned integer value
  final int value;

  /// Creates a new [Unsigned16Number] with the given [value]
  const Unsigned16Number(this.value);

  /// Creates a new [Unsigned16Number] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 2 bytes starting at [offset].
  factory Unsigned16Number.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 2);
    return Unsigned16Number(bytes.getUint16(offset));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unsigned16Number &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'Unsigned16Number{value: $value}';
  }
// coverage:ignore-end
}

/// Fixed 4 byte unsigned integer
@immutable
final class Unsigned32Number {
  /// Unsigned integer value
  final int value;

  /// Creates a new [Unsigned32Number] with the given [value]
  const Unsigned32Number(this.value);

  /// Creates a new [Unsigned32Number] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 4 bytes starting at [offset].
  factory Unsigned32Number.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 4);
    return Unsigned32Number(bytes.getUint32(offset));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unsigned32Number &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'Unsigned32Number{value: $value}';
  }
// coverage:ignore-end
}

/// Fixed 8 byte unsigned integer
/// Int64 is used to represent the value to support both VM and web
@immutable
final class Unsigned64Number {
  /// Unsigned integer value
  final Int64 value;

  /// Creates a new [Unsigned64Number] with the given [value]
  const Unsigned64Number(this.value);

  /// Creates a new [Unsigned64Number] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 8 bytes starting at [offset].
  factory Unsigned64Number.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 8);

    final value = Int64.fromBytesBigEndian(bytes.buffer.asUint8List(offset));
    return Unsigned64Number(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unsigned64Number &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'Unsigned64Number{value: $value}';
  }
// coverage:ignore-end

  /// Writes the value to the given [data] starting at [offset].
  /// [data] must hold at least 8 bytes starting at [offset].
  void toBytes(ByteData data, int offset) {
    final bytes = value.toBytes();
    for (var i = 0; i < 8; ++i) {
      data.setUint8(offset + i, bytes[bytes.length - i - 1]);
    }
  }
}

/// Fixed 8 byte unsigned integer
@immutable
final class Unsigned8Number {
  /// Unsigned integer value
  final int value;

  /// Creates a new [Unsigned8Number] with the given [value]
  const Unsigned8Number(this.value);

  /// Creates a new [Unsigned8Number] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 1 byte starting at [offset].
  factory Unsigned8Number.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 1);
    return Unsigned8Number(bytes.getUint8(offset));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unsigned8Number &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'Unsigned8Number{value: $value}';
  }
  // coverage:ignore-end
}

/// A set of 3 [Signed15Fixed16Number]s used to encode CIEXYZ, nCIEXYZ
/// and PCSXYZ values
@immutable
final class XYZNumber {
  /// X value
  final Signed15Fixed16Number x;

  /// Y value
  final Signed15Fixed16Number y;

  /// Z value
  final Signed15Fixed16Number z;

  /// Creates a new [XYZNumber] with the given [x], [y] and [z]
  const XYZNumber({
    required this.x,
    required this.y,
    required this.z,
  });

  /// Creates a new [XYZNumber] from the given [bytes] starting at [offset].
  /// [bytes] must hold at least 12 bytes starting at [offset].
  factory XYZNumber.fromBytes(ByteData bytes, {int offset = 0}) {
    assert(bytes.lengthInBytes >= offset + 12);
    return XYZNumber(
      x: Signed15Fixed16Number.fromBytes(bytes, offset: offset),
      y: Signed15Fixed16Number.fromBytes(bytes, offset: offset + 4),
      z: Signed15Fixed16Number.fromBytes(bytes, offset: offset + 8),
    );
  }

  ///Creates a new [XYZNumber] from the given [xyz] list
  factory XYZNumber.fromValues(List<Signed15Fixed16Number> xyz) {
    assert(xyz.length == 3);
    return XYZNumber(x: xyz[0], y: xyz[1], z: xyz[2]);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XYZNumber &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          z == other.z;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;

  // coverage:ignore-start
  @override
  String toString() {
    return 'XYZNumber{x: $x, y: $y, z: $z}';
  }
// coverage:ignore-end

  /// Writes the value to the given [data] starting at [offset].
  /// [data] must hold at least 12 bytes starting at [offset].
  void toBytes(ByteData data, int offset) {
    x.toBytes(data, offset);
    y.toBytes(data, offset + 4);
    z.toBytes(data, offset + 8);
  }
}
