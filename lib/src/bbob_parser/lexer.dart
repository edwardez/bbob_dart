// for cases <!-- -->
import 'package:bbob_dart/src/bbob_parser/token.dart';
import 'package:bbob_dart/src/bbob_parser/utils.dart';
import 'package:bbob_dart/src/bbob_plugin_helper/char.dart';
import 'package:meta/meta.dart';

/// A lexer implementation that parses input into a list of [Token].
///
/// Known issue: [_linePosition] and [_columnPosition] might not be correctly
/// calculated. This is the same behavior as the original library.
class Lexer {
  static const _em = '!';

  static const _whiteSpaces = [space, tab];
  static const _spacialChars = [equal, space, tab];

  static const _defaultReservedChars = [
    doubleQuote,
    backslash,
    space,
    tab,
    equal,
    newLine,
    _em,
  ];

  static const _defaultNotCharTokens = {
    space,
    tab,
    newLine,
  };

  /// The input String.
  final String _buffer;

  /// Open tag of the bbcode, default to [openSquareBracket] (the typical bbcode open tag)
  final String _openTag;

  /// Open tag of the bbcode, default to [closeSquareBracket] (the typical bbcode open tag)
  final String _closeTag;

  /// Whether tags can be escaped,
  final bool _enableEscapeTags;

  /// A list of parsed tokens.
  final List<Token> _tokens;

  /// A [Set] of reserved characters.
  final Set<String> _reservedChars;

  final Set<String> _nonCharTokens;

  final Function(Token token) onToken;

  /// Current line position number.
  int _linePosition = 0;

  /// Current column position number.
  int _columnPosition = 0;

  /// Current token index in [_tokens].
  int _tokenIndex = -1;

  CharGrabber _bufferGrabber;

  onSkipBufferGrabber() {
    _columnPosition++;
  }

  Lexer._(
    this._buffer, {
    this.onToken,
    String openTag = openSquareBracket,
    String closeTag = closeSquareBracket,
    bool enableEscapeTags = false,
  })  : _tokens = List()..length = _buffer.length.floor(),
        _openTag = openTag,
        _closeTag = closeTag,
        _enableEscapeTags = enableEscapeTags,
        _reservedChars = Set.of([..._defaultReservedChars, openTag, closeTag]),
        _nonCharTokens = Set.of([
          ..._defaultNotCharTokens,
          openTag,
          ...(enableEscapeTags ? [backslash] : [])
        ]);

  /// Creates a new [Lexer].
  factory Lexer.create(
    String buffer, {
    Function onToken,
    String openTag = openSquareBracket,
    String closeTag = closeSquareBracket,
    bool enableEscapeTags = false,
  }) {
    final lexer = Lexer._(
      buffer,
      onToken: onToken,
      openTag: openTag,
      closeTag: closeTag,
      enableEscapeTags: enableEscapeTags,
    );

    lexer._bufferGrabber = CharGrabber(buffer, onSkip: () {
      lexer._columnPosition++;
    });

    assert(buffer != null);
    assert(openTag != null);
    assert(closeTag != null);
    assert(enableEscapeTags != null);

    return lexer;
  }

  bool _isReservedChar(String char) => _reservedChars.contains(char);

  bool _isWhiteSpace(String char) => _whiteSpaces.contains(char);

  bool _isTokenChar(String char) => !_nonCharTokens.contains(char);

  bool _isSpecialChar(String char) => _spacialChars.contains(char);

  /// Emits newly created token to subscriber
  void _emitToken(Token token) {
    if (onToken != null) {
      onToken(token);
    }

    _tokenIndex++;

    _tokens[_tokenIndex] = token;
  }

  /// Parses params inside [myTag---params goes here---]content[/myTag]
  Attribute _parseAttrs(str) {
    String tagName;
    bool skipSpecialChars = false;

    final attrTokens = <Token>[];
    final attrCharGrabber = CharGrabber(str);

    validAttr(char) {
      final isEqual = char == equal;
      final isWhiteSpace = _isWhiteSpace(char);
      final nextChar = attrCharGrabber.next;
      final isPreviousCharSlash = attrCharGrabber.previous == backslash;

      if (tagName == null) {
        return (isEqual || isWhiteSpace || attrCharGrabber.isLast) == false;
      }

      if (skipSpecialChars && _isSpecialChar(char)) {
        return true;
      }

      if (char == doubleQuote && !isPreviousCharSlash) {
        skipSpecialChars = !skipSpecialChars;

        if (!skipSpecialChars &&
            !(nextChar == equal || _isWhiteSpace(nextChar))) {
          return false;
        }
      }

      return !isEqual && !isWhiteSpace;
    }

    _nextAttr() {
      final attrStr = attrCharGrabber.grabWhile(validAttr);
      final currChar = attrCharGrabber.current;

      // first string before space is a tag name [tagName params...]
      if (tagName == null) {
        tagName = attrStr;
      } else if (_isWhiteSpace(currChar) ||
          currChar == doubleQuote ||
          !attrCharGrabber.hasNext) {
        final escaped = unquote(trimChar(attrStr, doubleQuote));
        attrTokens.add(Token(
            TokenType.AttributeValue, escaped, _linePosition, _columnPosition));
      } else {
        attrTokens.add(Token(
            TokenType.AttributeName, attrStr, _linePosition, _columnPosition));
      }

      attrCharGrabber.skip();
    }

    while (attrCharGrabber.hasNext) {
      _nextAttr();
    }

    return Attribute(
      tag: tagName,
      attrs: attrTokens,
    );
  }

  void _next() {
    final currChar = _bufferGrabber.current;
    final nextChar = _bufferGrabber.next;
    if (currChar == newLine) {
      _bufferGrabber.skip();
      _columnPosition = 0;

      _emitToken(
          Token(TokenType.NewLine, currChar, _linePosition, _columnPosition));

      // Original bbob increase [linePosition] before [_emitToken]. It seems wrong
      // since new line is at the end of last line.
      _linePosition++;
    } else if (_isWhiteSpace(currChar)) {
      final str = _bufferGrabber.grabWhile(_isWhiteSpace);
      _emitToken(Token(TokenType.Space, str, _linePosition, _columnPosition));
    } else if (_enableEscapeTags &&
        currChar == backslash &&
        (nextChar == _openTag || nextChar == _closeTag)) {
      _bufferGrabber.skip(); // skip the \ without emitting anything
      _bufferGrabber.skip(); // skip past the [ or ] as well
      _emitToken(
          Token(TokenType.Word, nextChar, _linePosition, _columnPosition));
    } else if (_enableEscapeTags &&
        currChar == backslash &&
        nextChar == backslash) {
      _bufferGrabber.skip(); // skip the first \ without emitting anything
      _bufferGrabber.skip(); // skip past the second \ and emit it
      _emitToken(
          Token(TokenType.Word, nextChar, _linePosition, _columnPosition));
    } else if (currChar == _openTag) {
      _bufferGrabber.skip(); // skip openTag

      // detect case where we have '[My word [tag][/tag]' or we have '[My last line word'
      final substr = _bufferGrabber.substringUntil(_closeTag);
      final hasInvalidChars = substr.isEmpty || substr.contains(_openTag);

      if (_isReservedChar(nextChar) ||
          hasInvalidChars ||
          _bufferGrabber.isLast) {
        _emitToken(
            Token(TokenType.Word, currChar, _linePosition, _columnPosition));
      } else {
        final str = _bufferGrabber.grabWhile((val) => val != _closeTag);

        _bufferGrabber.skip(); // skip closeTag
        // [myTag   ]
        final isNoAttrsInTag = !str.contains(equal);
        // [/myTag]
        final isClosingTag = str.startsWith(slash);

        if (isNoAttrsInTag || isClosingTag) {
          _emitToken(Token(TokenType.Tag, str, _linePosition, _columnPosition));
        } else {
          final parsed = _parseAttrs(str);

          _emitToken(
              Token(TokenType.Tag, parsed.tag, _linePosition, _columnPosition));

          parsed.attrs.forEach(_emitToken);
        }
      }
    } else if (currChar == _closeTag) {
      _bufferGrabber.skip(); // skip closeTag

      _emitToken(
          Token(TokenType.Word, currChar, _linePosition, _columnPosition));
    } else if (_isTokenChar(currChar)) {
      final str = _bufferGrabber.grabWhile(_isTokenChar);
      _emitToken(Token(TokenType.Word, str, _linePosition, _columnPosition));
    }
    // TODO: check if a final else condition is needed.
  }

  List<Token> tokenize() {
    while (_bufferGrabber.hasNext) {
      _next();
    }

    _tokens.length = _tokenIndex + 1;

    return _tokens;
  }

  bool isTokenNested(Token token) {
    final value = _openTag + slash + token.value;
    // potential bottleneck
    return _buffer.contains(value);
  }
}

class Attribute {
  final String tag;
  final List<Token> attrs;

  const Attribute({@required this.tag, @required this.attrs});
}
