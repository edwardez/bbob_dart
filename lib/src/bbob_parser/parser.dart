import 'package:bbob_dart/src/bbob_parser/error_message.dart';
import 'package:bbob_dart/src/bbob_parser/lexer.dart';
import 'package:bbob_dart/src/bbob_parser/token.dart';
import 'package:bbob_dart/src/bbob_parser/utils.dart';
import 'package:bbob_dart/src/bbob_plugin_helper/ast.dart';
import 'package:bbob_dart/src/bbob_plugin_helper/char.dart';

/// A parser that parses raw bbcode input.
///
/// To use [Parser], initialize it then call [Parser.parse].
class Parser {
  /// Result AST of nodes.
  final _nodes = List<Node>();

  // If a new cache/buffer field is added, [_resetCache] needs to be updated.

  /// Temporary buffer of nodes that's nested to another node.
  final _nestedElements = List<Element>();

  /// Temporary buffer of nodes [tag..]...[/tag].
  final _tagNodeElements = List<Element>();

  /// Temporary buffer of tag attributes.
  final _ElementsAttrName = List<String>();

  /// Cache for nested tags checks.
  final _nestedTagsMap = {};

  /// Function that'll be called if there is an error.
  final Function(ParseErrorMessage message) onError;

  /// Tags that will be treated as valid during parsing. If [validTags] is not
  /// null and input contains a tag that's not in this list, that tag will be
  /// ignored.
  ///
  /// Default to null, a null [validTags] indicates that all tags will be treated
  /// as valid.
  final Set<String> validTags;

  /// Open tag of the bbcode, default to [openSquareBracket] (the typical
  /// bbcode open tag).
  final String openTag;

  /// Open tag of the bbcode, default to [closeSquareBracket] (the typical
  /// bbcode open tag).
  final String closeTag;

  /// Whether tags can be escaped. See [Lexer._enableEscapeTags] for a detailed
  /// explanation.
  final bool enableEscapeTags;

  /// Underlying tokenizer that'll be initialized each time [Parser.parse] is
  /// called.
  Lexer tokenizer;

  Parser({
    this.onError,
    this.openTag = openSquareBracket,
    this.closeTag = closeSquareBracket,
    this.enableEscapeTags = false,
    Set<String> validTags,
  }) : validTags = validTags?.toSet();

  bool isTagNested(String tagName) => _nestedTagsMap.containsKey(tagName);

  bool isTokenNested(Map nestedTagsMap, Token token) {
    if (!nestedTagsMap.containsKey(token.value)) {
      nestedTagsMap[token.value] = tokenizer.isTokenNested(token);
    }

    return nestedTagsMap[token.value];
  }

  /// Flushes temp tag nodes and its attributes buffers
  void _flushTagNodeElements() {
    if (removePossibleLast(_tagNodeElements) != null) {
      removePossibleLast(_ElementsAttrName);
    }
  }

  _appendNodes(Node node) {
    final lastNestedNode = lastOrNull(_nestedElements);
    if (lastNestedNode != null) {
      lastNestedNode.children.add(node);
    } else {
      _nodes.add(node);
    }
  }

  void _handleTagStart(Token token) {
    _flushTagNodeElements();

    final element = Element(token.value);
    final isNested = isTokenNested(_nestedTagsMap, token);

    _tagNodeElements.add(element);

    if (isNested) {
      _nestedElements.add(element);
    } else {
      _appendNodes(element);
    }
  }

  void _handleTagEnd(Token token) {
    _flushTagNodeElements();

    final lastNestedNode = removePossibleLast(_nestedElements);

    if (lastNestedNode != null) {
      _appendNodes(lastNestedNode);
    } else if (onError != null) {
      final tag = token.value;
      final row = token.linePosition;
      final column = token.columnPosition;

      onError(ParseErrorMessage(
        lineNumber: row,
        tagName: tag,
        message:
            'Inconsistent tag "${tag}" on line ${row} and column ${column}',
        column: column,
      ));
    }
  }

  void _handleTag(Token token) {
    // [tag]
    if (token.isStart) {
      _handleTagStart(token);
    }

    // [/tag]
    if (token.isEnd) {
      _handleTagEnd(token);
    }
  }

  void _handleNode(Token token) {
    final lastElement = lastOrNull(_tagNodeElements);
    final tokenValue = token.value;
    final isNested = isTagNested(token.toString());

    if (lastElement != null) {
      if (token.isAttributeName) {
        _ElementsAttrName.add(tokenValue);
        lastElement.updateAttributes(lastOrNull(_ElementsAttrName), '');
      } else if (token.isAttributeValue) {
        final attrName = lastOrNull(_ElementsAttrName);

        if (attrName != null) {
          lastElement.updateAttributes(attrName, tokenValue);
          removePossibleLast(_ElementsAttrName);
        } else {
          lastElement.updateAttributes(tokenValue, tokenValue);
        }
      } else if (token.isText) {
        if (isNested) {
          lastElement.appendChild(Text(tokenValue));
        } else {
          _appendNodes(Text(tokenValue));
        }
      } else if (token.isTag) {
        // if tag is not allowed, just past it as is
        _appendNodes(Text(token.toString()));
      }
    } else if (token.isText) {
      _appendNodes(Text(tokenValue));
    } else if (token.isTag) {
      // if tag is not allowed, just past it as is
      _appendNodes(Text(token.toString()));
    }
  }

  /// Resets cached data.
  _resetCache() {
    _nodes.clear();
    _nestedElements.clear();
    _tagNodeElements.clear();
    _ElementsAttrName.clear();
    _nestedTagsMap.clear();
  }

  /// Parses the [input] string and returns the result ast in a list of [Node].
  List<Node> parse(String input) {
    _resetCache();

    tokenizer = Lexer.create(
      input,
      onToken: (Token token) {
        bool isAllowedTag = validTags?.contains(token.name) ?? true;

        if (token.isTag && isAllowedTag) {
          _handleTag(token);
        } else {
          _handleNode(token);
        }
      },
      openTag: openTag,
      closeTag: closeTag,
      enableEscapeTags: enableEscapeTags,
    );
    tokenizer.tokenize();

    return _nodes;
  }
}
