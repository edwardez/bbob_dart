
class ParseErrorMessage {
  final String message;
  final String tagName;
  final int lineNumber;
  final int column;

  ParseErrorMessage({
    required this.message,
    required this.tagName,
    required this.lineNumber,
    required this.column,
  });

  @override
  String toString() {
    return 'ParseErrorMessage{message: $message, tagName: $tagName, '
        'lineNumber: $lineNumber, column: $column}';
  }
}
