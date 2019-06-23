import 'package:bbob_dart/src/bbob_parser/error_message.dart';
import 'package:bbob_dart/src/bbob_parser/parser.dart';
import 'package:bbob_dart/src/bbob_plugin_helper/ast.dart';
import 'package:bbob_dart/src/bbob_plugin_helper/char.dart';

/// Parses the input raw bbcode.
/// See constructor of [Parser] for explanations of each field.
List<Node> parse(
  String input, {
  Function(ParseErrorMessage message) onError,
  String openTag = openSquareBracket,
  String closeTag = closeSquareBracket,
  bool enableEscapeTags = false,
  Set<String> validTags,
}) {
  final parser = Parser(
    onError: onError,
    validTags: validTags,
    openTag: openTag,
    closeTag: closeTag,
    enableEscapeTags: enableEscapeTags,
  );

  return parser.parse(input);
}
