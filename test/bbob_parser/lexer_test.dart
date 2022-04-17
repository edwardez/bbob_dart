import 'package:bbob_dart/src/bbob_parser/lexer.dart';
import 'package:bbob_dart/src/bbob_parser/token.dart';
import 'package:quiver/iterables.dart';
import 'package:test/test.dart';

void main() {
  group('Lexer', () {
    tokenEqualityMatcher(
      Token expected, {
      bool skipLinePositionChecking = false,
      bool skipColumnPositionChecking = false,
    }) {
      var matcher = TypeMatcher<Token>()
          .having((t) => t.name, 'name', expected.name)
          .having((t) => t.type, 'type', expected.type)
          .having((t) => t.value, 'value', expected.value)
          .having((t) => t.toString(), 'toString()', expected.toString());
      if (!skipColumnPositionChecking) {
        matcher = matcher.having(
            (t) => t.columnPosition, 'columnPosition', expected.columnPosition);
      }

      if (!skipLinePositionChecking) {
        matcher = matcher.having(
            (t) => t.linePosition, 'linePosition', expected.linePosition);
      }

      return matcher;
    }

    validateTokens(
      List<Token> actual,
      List<Token> expected, {
      bool skipLinePositionChecking = false,
      bool skipColumnPositionChecking = false,
    }) {
      validateToken(Token actual, Token expected) {
        expect(
            actual,
            tokenEqualityMatcher(expected,
                skipLinePositionChecking: skipLinePositionChecking,
                skipColumnPositionChecking: skipColumnPositionChecking));
      }

      expect(actual.length, expected.length);

      for (var pair in zip([actual, expected])) {
        validateToken(pair[0], pair[1]);
      }
    }

    group('bbcode', () {
      List<Token> tokenize(String input,
              {enableEscapeTags = false,
              String openTag = '[',
              String closeTag = ']'}) =>
          Lexer.create(
            input,
            enableEscapeTags: enableEscapeTags,
            openTag: openTag,
            closeTag: closeTag,
          ).tokenize();

      test('single tag', () {
        const tagName = 'SingleTag';
        const input = '[$tagName]';
        final tokens = tokenize(input);
        const output = [Token(TokenType.Tag, '$tagName', 0, input.length)];

        validateTokens(tokens, output);
      });

      test('single tag with params', () {
        const input = '[user=111]';
        final tokens = tokenize(input);
        const output = [
          Token(TokenType.Tag, 'user', 0, 10),
          Token(TokenType.AttributeValue, '111', 0, 10),
        ];

        validateTokens(tokens, output);
      });

      test('single tag with spaces', () {
        const input = '[Single Tag]';
        final tokens = tokenize(input);
        const output = [
          Token(TokenType.Tag, 'Single Tag', 0, 12),
        ];

        validateTokens(tokens, output);
      });

      test('string with quotemarks', () {
        const input = '"Dear brave" by kano';
        final tokens = tokenize(input);
        const output = [
          Token(TokenType.Word, '"Dear', 0, 5),
          Token(TokenType.Space, ' ', 0, 6),
          Token(TokenType.Word, 'brave"', 0, 12),
          Token(TokenType.Space, ' ', 0, 13),
          Token(TokenType.Word, 'by', 0, 15),
          Token(TokenType.Space, ' ', 0, 16),
          Token(TokenType.Word, 'kano', 0, 20),
        ];

        validateTokens(tokens, output);
      });

      test('tags in brackets', () {
        const input = '[ [h1]G[/h1] ]';
        final tokens = tokenize(input);
        const output = [
          Token(TokenType.Word, '[', 0, 1),
          Token(TokenType.Space, ' ', 0, 2),
          Token(TokenType.Tag, 'h1', 0, 6),
          Token(TokenType.Word, 'G', 0, 7),
          Token(TokenType.Tag, '/h1', 0, 12),
          Token(TokenType.Space, ' ', 0, 13),
          Token(TokenType.Word, ']', 0, 14),
        ];

        validateTokens(tokens, output);
      });

      test('tag as param', () {
        const input = '[color="#ff0000"]Text[/color]';
        final tokens = tokenize(input);
        const output = [
          Token(TokenType.Tag, 'color', 0, 17),
          Token(TokenType.AttributeValue, '#ff0000', 0, 17),
          Token(TokenType.Word, 'Text', 0, 21),
          Token(TokenType.Tag, '/color', 0, 29),
        ];

        validateTokens(tokens, output);
      });

      test('tag with escaped quotemark param', () {
        const input = '[url text="Foo \\"Bar"]Text[/url]';
        final tokens = tokenize(input);
        const output = [
          Token(TokenType.Tag, 'url', 0, 22),
          Token(TokenType.AttributeName, 'text', 0, 22),
          Token(TokenType.AttributeValue, 'Foo "Bar', 0, 22),
          Token(TokenType.Word, 'Text', 0, 26),
          Token(TokenType.Tag, '/url', 0, 32),
        ];

        validateTokens(tokens, output);
      });

      test('tag param without quotemarks', () {
        const input = '[style color=#ff0000]Text[/style]';
        final tokens = tokenize(input);
        const output = [
          Token(TokenType.Tag, 'style', 0, 21),
          Token(TokenType.AttributeName, 'color', 0, 21),
          Token(TokenType.AttributeValue, '#ff0000', 0, 21),
          Token(TokenType.Word, 'Text', 0, 25),
          Token(TokenType.Tag, '/style', 0, 33),
        ];

        validateTokens(tokens, output);
      });

      test('list tag with items', () {
        const input = '''[list]
   [*] Item 1.
   [*] Item 2.
   [*] Item 3.
[/list]''';
        final tokens = tokenize(input);
        const output = [
          Token(TokenType.Tag, 'list', 0),
          Token(TokenType.NewLine, '\n', 0),
          Token(TokenType.Space, '   ', 1),
          Token(TokenType.Tag, '*', 1),
          Token(TokenType.Space, ' ', 1),
          Token(TokenType.Word, 'Item', 1),
          Token(TokenType.Space, ' ', 1),
          Token(TokenType.Word, '1.', 1),
          Token(TokenType.NewLine, '\n', 1),
          Token(TokenType.Space, '   ', 2),
          Token(TokenType.Tag, '*', 2),
          Token(TokenType.Space, ' ', 2),
          Token(TokenType.Word, 'Item', 2),
          Token(TokenType.Space, ' ', 2),
          Token(TokenType.Word, '2.', 2),
          Token(TokenType.NewLine, '\n', 2),
          Token(TokenType.Space, '   ', 3),
          Token(TokenType.Tag, '*', 3),
          Token(TokenType.Space, ' ', 3),
          Token(TokenType.Word, 'Item', 3),
          Token(TokenType.Space, ' ', 3),
          Token(TokenType.Word, '3.', 3),
          Token(TokenType.NewLine, '\n', 3),
          Token(TokenType.Tag, '/list', 4),
        ];

        validateTokens(
          tokens,
          output,
          skipColumnPositionChecking: true,
        );
      });

      test('bad tags as texts', () {
        const inputs = [
          '[]',
          '[=]',
          '![](image.jpg)',
          'x html([a. title][, alt][, classes]) x',
          '[/y]',
          '[sc',
          '[sc / [/sc]',
          '[sc arg="val',
        ];

        const outputs = [
          [
            Token(TokenType.Word, '['),
            Token(TokenType.Word, ']'),
          ],
          [
            Token(TokenType.Word, '['),
            Token(TokenType.Word, '=]'),
          ],
          [
            Token(TokenType.Word, '!'),
            Token(TokenType.Word, '['),
            Token(TokenType.Word, ']'),
            Token(TokenType.Word, '(image.jpg)'),
          ],
          [
            Token(TokenType.Word, 'x'),
            Token(TokenType.Space, ' '),
            Token(TokenType.Word, 'html('),
            Token(TokenType.Tag, 'a. title'),
            Token(TokenType.Tag, ', alt'),
            Token(TokenType.Tag, ', classes'),
            Token(TokenType.Word, ')'),
            Token(TokenType.Space, ' '),
            Token(TokenType.Word, 'x'),
          ],
          [
            Token(TokenType.Tag, '/y'),
          ],
          [
            Token(TokenType.Word, '['),
            Token(TokenType.Word, 'sc'),
          ],
          [
            Token(TokenType.Word, '['),
            Token(TokenType.Word, 'sc'),
            Token(TokenType.Space, ' '),
            Token(TokenType.Word, '/'),
            Token(TokenType.Space, ' '),
            Token(TokenType.Tag, '/sc'),
          ],
          [
            Token(TokenType.Word, '['),
            Token(TokenType.Word, 'sc'),
            Token(TokenType.Space, ' '),
            Token(TokenType.Word, 'arg="val'),
          ],
        ];

        for (var i = 0; i < inputs.length; i++) {
          var input = inputs[i];
          var output = outputs[i];

          final tokens = tokenize(input);
          validateTokens(
            tokens,
            output,
            skipColumnPositionChecking: true,
            skipLinePositionChecking: true,
          );
        }
      });

      test('bad unclosed tag', () {
        const input = '[Finger Part A [Finger]';
        final tokens = tokenize(input);
        const output = [
          Token(TokenType.Word, '[', 0, 1),
          Token(TokenType.Word, 'Finger', 0, 7),
          Token(TokenType.Space, ' ', 0, 8),
          Token(TokenType.Word, 'Part', 0, 12),
          Token(TokenType.Space, ' ', 0, 13),
          Token(TokenType.Word, 'A', 0, 14),
          Token(TokenType.Space, ' ', 0, 15),
          Token(TokenType.Tag, 'Finger', 0, 23),
        ];

        validateTokens(tokens, output);
      });

      test('no close tag', () {
        const input = '[Finger Part A';
        final tokens = tokenize(input);
        const output = [
          Token(TokenType.Word, '[', 0, 1),
          Token(TokenType.Word, 'Finger', 0, 7),
          Token(TokenType.Space, ' ', 0, 8),
          Token(TokenType.Word, 'Part', 0, 12),
          Token(TokenType.Space, ' ', 0, 13),
          Token(TokenType.Word, 'A', 0, 14),
        ];

        validateTokens(tokens, output);
      });

      test('escaped tag', () {
        const input = r'\[b\]test\[';
        final tokens = tokenize(
          input,
          enableEscapeTags: true,
        );
        const output = [
          Token(TokenType.Word, '[', 0, 2),
          Token(TokenType.Word, 'b', 0, 3),
          Token(TokenType.Word, ']', 0, 5),
          Token(TokenType.Word, 'test', 0, 9),
          Token(TokenType.Word, '[', 0, 11),
        ];

        validateTokens(tokens, output);
      });

      test('escaped tag and escaped backslash', () {
        const input = r'\\\[b\\\]test\\\[/b\\\]';
        final tokens = tokenize(
          input,
          enableEscapeTags: true,
        );
        const output = [
          Token(TokenType.Word, r'\', 0, 2),
          Token(TokenType.Word, '[', 0, 4),
          Token(TokenType.Word, 'b', 0, 5),
          Token(TokenType.Word, r'\', 0, 7),
          Token(TokenType.Word, ']', 0, 9),
          Token(TokenType.Word, 'test', 0, 13),
          Token(TokenType.Word, r'\', 0, 15),
          Token(TokenType.Word, '[', 0, 17),
          Token(TokenType.Word, '/b', 0, 19),
          Token(TokenType.Word, r'\', 0, 21),
          Token(TokenType.Word, ']', 0, 23),
        ];
        validateTokens(
          tokens,
          output,
        );
      });
    });

    group('html', () {
      List<Token> tokenizeHtml(String input,
              {enableEscapeTags = false,
              String openTag = '<',
              String closeTag = '>'}) =>
          Lexer.create(
            input,
            enableEscapeTags: enableEscapeTags,
            openTag: openTag,
            closeTag: closeTag,
          ).tokenize();

      test('normal attributes', () {
        const content = r'<button id="test0" class="value0" title="value1">'
            r'class="value0" title="value1"</button>';
        final tokens = tokenizeHtml(content);

        const output = [
          Token(TokenType.Tag, 'button', 0, 49),
          Token(TokenType.AttributeName, 'id', 0, 49),
          Token(TokenType.AttributeValue, 'test0', 0, 49),
          Token(TokenType.AttributeName, 'class', 0, 49),
          Token(TokenType.AttributeValue, 'value0', 0, 49),
          Token(TokenType.AttributeName, 'title', 0, 49),
          Token(TokenType.AttributeValue, 'value1', 0, 49),
          Token(TokenType.Word, 'class="value0"', 0, 63),
          Token(TokenType.Space, ' ', 0, 64),
          Token(TokenType.Word, 'title="value1"', 0, 78),
          Token(TokenType.Tag, '/button', 0, 87),
        ];
        validateTokens(
          tokens,
          output,
        );
      });

      test('attributes with no quotes or value', () {
        const content =
            r'<button id="test1" class=value2 disabled>class=value2 '
            r'disabled</button>';
        final tokens = tokenizeHtml(content);

        const output = [
          Token(TokenType.Tag, 'button'),
          Token(TokenType.AttributeName, 'id'),
          Token(TokenType.AttributeValue, 'test1'),
          Token(TokenType.AttributeName, 'class'),
          Token(TokenType.AttributeValue, 'value2'),
          Token(TokenType.AttributeValue, 'disabled'),
          Token(TokenType.Word, 'class=value2'),
          Token(
            TokenType.Space,
            ' ',
          ),
          Token(
            TokenType.Word,
            'disabled',
          ),
          Token(
            TokenType.Tag,
            '/button',
          ),
        ];
        validateTokens(
          tokens,
          output,
          skipColumnPositionChecking: true,
        );
      });

      test(
          'attributes with no space between them. No valid, but accepted by '
          'the browser', () {
        const content = r'<button id="test2" class="value4" title="value5">'
            r'class="value4"title="value5"</button>';
        final tokens = tokenizeHtml(content);

        const output = [
          Token(
            TokenType.Tag,
            'button',
          ),
          Token(
            TokenType.AttributeName,
            'id',
          ),
          Token(
            TokenType.AttributeValue,
            'test2',
          ),
          Token(
            TokenType.AttributeName,
            'class',
          ),
          Token(
            TokenType.AttributeValue,
            'value4',
          ),
          Token(
            TokenType.AttributeName,
            'title',
          ),
          Token(
            TokenType.AttributeValue,
            'value5',
          ),
          Token(
            TokenType.Word,
            'class="value4"title="value5"',
          ),
          Token(
            TokenType.Tag,
            '/button',
          ),
        ];
        validateTokens(
          tokens,
          output,
          skipColumnPositionChecking: true,
        );
      });
    });
  });
}
