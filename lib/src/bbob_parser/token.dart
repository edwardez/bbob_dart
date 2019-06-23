import 'package:bbob_dart/src/bbob_plugin_helper/char.dart';

enum TokenType {
  Word,
  Tag,
  AttributeName,
  AttributeValue,
  Space,
  NewLine,
}

/// A token representation during parsing.
class Token {
  final TokenType type;
  final String value;
  final int linePosition;
  final int columnPosition;

  const Token(
    TokenType type,
    String value, [
    int line = 0,
    int column = 0,
  ])  : this.type = type,
        value = value,
        linePosition = line,
        columnPosition = column;

  bool get isText =>
      type == TokenType.Space ||
      type == TokenType.NewLine ||
      type == TokenType.Word;

  bool get isTag => type == TokenType.Tag;

  bool get isAttributeName => type == TokenType.AttributeName;

  bool get isAttributeValue => type == TokenType.AttributeValue;

  bool get isStart => !isEnd;

  bool get isEnd => value[0] == slash;

  String get name => isEnd ? value.substring(1) : value;

  @override
  toString() {
    return '$openSquareBracket$value$closeSquareBracket';
  }
}
