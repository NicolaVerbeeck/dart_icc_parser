import 'package:icc_parser/src/types/matrix3x3.dart';
import 'package:icc_parser/src/types/tag/color_profile_tags.dart';

class MatrixCannotBeInvertedException implements Exception {
  final Matrix3x3 matrix;

  MatrixCannotBeInvertedException(this.matrix);

  @override
  String toString() {
    return "Matrix can't be inverted: $matrix";
  }
}

class MissingTagException implements Exception {
  final ICCColorProfileTag tag;

  MissingTagException(this.tag);

  @override
  String toString() {
    return "Missing required tag: $tag";
  }
}

class BadSpaceLinkException implements Exception {
  const BadSpaceLinkException();

  @override
  String toString() {
    return "Bad space link";
  }
}

class InvalidSignatureException implements Exception {
  final int expected;
  final int got;

  const InvalidSignatureException({required this.expected, required this.got});

  @override
  String toString() {
    return "Invalid signature: expected $expected, got $got";
  }
}
