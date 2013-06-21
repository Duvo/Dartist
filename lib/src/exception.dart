part of dartist;

/**
 * Class [DartistException].
 */
class DartistException implements Exception {
  const DartistException([String this.message = ""]);
  String toString() => "$runtimeType: $message";
  final String message;
}