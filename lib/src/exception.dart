part of dartist;

class DartistException implements Exception {
  const DartistException([String this.message = ""]);
  String toString() => "$runtimeType: $message";
  final String message;
}