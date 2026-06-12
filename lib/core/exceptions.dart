/// Custom exceptions for Journal Trend Analyzer.
library;

class OpenAlexException implements Exception {
  const OpenAlexException(this.message);
  final String message;

  @override
  String toString() => 'OpenAlexException: $message';
}

class NetworkException implements Exception {
  const NetworkException(this.message);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class ParseException implements Exception {
  const ParseException(this.message);
  final String message;

  @override
  String toString() => 'ParseException: $message';
}
