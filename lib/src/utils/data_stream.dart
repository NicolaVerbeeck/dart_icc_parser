import 'dart:typed_data';

import 'package:icc_parser/src/types/color_profile_primitives.dart';

/// Data provider class that automatically increments its reading position
/// upon reading data.
class DataStream {
  final ByteData _data;
  final int _length;
  final int _offset;
  int _position = 0;

  /// The current reading position in side the data stream. Use [seek] to
  /// directly manipulate this value.
  int get position => _position;

  /// Creates a new data stream from the given [data] with the given [length]
  /// and [offset].
  DataStream({
    required ByteData data,
    required int length,
    required int offset,
  })  : _data = data,
        _length = length,
        _offset = offset;

  /// Seeks to the requested [position] in the data stream. The position must
  /// be greater than or equal to 0 and less than the length of the data stream.
  /// Note: the seek is absolute, not relative to the current position.
  void seek(int position) {
    assert(position >= 0, 'Position must be greater than or equal to 0');
    assert(position < _length, 'Position must be less than $_length');
    _position = position;
  }

  /// Reads a [DateTimeNumber]
  DateTimeNumber readDateTime() {
    final value = DateTimeNumber.fromBytes(_data, offset: _offset + _position);
    _position += 12;
    return value;
  }

  /// Reads [length] bytes into a [Uint8List]
  Uint8List readBytes(int length) {
    final value = _data.buffer.asUint8List(_offset + _position, length);
    _position += length;
    return value;
  }

  /// Reads an [Unsigned64Number]
  Unsigned64Number readUnsigned64Number() {
    final value =
        Unsigned64Number.fromBytes(_data, offset: _offset + _position);
    _position += 8;
    return value;
  }

  /// Reads an [Unsigned32Number]
  Unsigned32Number readUnsigned32Number() {
    final value =
        Unsigned32Number.fromBytes(_data, offset: _offset + _position);
    _position += 4;
    return value;
  }

  /// Reads an [Unsigned16Number]
  Unsigned16Number readUnsigned16Number() {
    final value =
        Unsigned16Number.fromBytes(_data, offset: _offset + _position);
    _position += 2;
    return value;
  }

  /// Reads an [Unsigned8Number]
  Unsigned8Number readUnsigned8Number() {
    final value = Unsigned8Number.fromBytes(_data, offset: _offset + _position);
    _position += 1;
    return value;
  }

  /// Reads a [Signed15Fixed16Number]
  Signed15Fixed16Number readSigned15Fixed16Number() {
    final value =
        Signed15Fixed16Number.fromBytes(_data, offset: _offset + _position);
    _position += 4;
    return value;
  }

  /// Reads an [XYZNumber]
  XYZNumber readXYZNumber() {
    final value = XYZNumber.fromBytes(_data, offset: _offset + _position);
    _position += 12;
    return value;
  }

  /// Skip [numberOfBytes] bytes.
  /// Equivalent to calling [seek] with the current [position]+[numberOfBytes].
  void skip(int numberOfBytes) {
    seek(position + numberOfBytes);
  }

  /// Operation to make sure read position is evenly divisible by 4
  void sync32(int offset) {
    final updatedOffset = offset & 0x3;
    final pos = ((position - updatedOffset + 3) >> 2) << 2;
    seek(pos + updatedOffset);
  }
}
