import 'dart:typed_data';

Uint8List generateUint8List(int length, int Function(int) generator) {
  final list = Uint8List(length);
  for (var i = 0; i < length; ++i) {
    list[i] = generator(i);
  }
  return list;
}

Uint8List filledUint8List(int length, int value) {
  final list = Uint8List(length);
  for (var i = 0; i < length; ++i) {
    list[i] = value;
  }
  return list;
}

Float64List generateFloat64List(int length, double Function(int) generator) {
  final list = Float64List(length);
  for (var i = 0; i < length; ++i) {
    list[i] = generator(i);
  }
  return list;
}

Float64List threeDoubles(double l, double a, double b) {
  final list = Float64List(3);
  list[0] = l;
  list[1] = a;
  list[2] = b;
  return list;
}

extension Float64ListExtension on Float64List {
  Float64List copy() {
    return Float64List.fromList(this);
  }

  Float64List copyWithSize(int size) {
    if (this.length == size) {
      return Float64List.fromList(this);
    } else if (this.length > size) {
      return Float64List.fromList(this.sublist(0, size));
    }
    final list = Float64List(size);
    for (var i = 0; i < this.length; ++i) {
      list[i] = this[i];
    }
    return list;
  }

  void copyFrom(Float64List other) {
    if (length == other.length) {
      for (var i = 0; i < length; ++i) {
        this[i] = other[i];
      }
    } else if (other.length < length) {
      for (var i = 0; i < other.length; ++i) {
        this[i] = other[i];
      }
    } else {
      for (var i = 0; i < length; ++i) {
        this[i] = other[i];
      }
    }
  }
}
