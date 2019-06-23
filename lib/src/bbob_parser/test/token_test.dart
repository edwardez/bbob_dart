import 'package:bbob_dart/src/bbob_parser/token.dart';
import 'package:test/test.dart';

void main() {
  group('Token', () {
    test('isText', () {
      final token = Token(TokenType.Word, 'x');
      expect(token.isText, isTrue);
    });

    test('isTag', () {
      final token = Token(TokenType.Tag, 'x');
      expect(token.isTag, isTrue);
    });

    test('isAttrName', () {
      final token = Token(TokenType.AttributeName, 'x');
      expect(token.isAttributeName, isTrue);
    });

    test('isAttributeValue', () {
      final token = Token(TokenType.AttributeValue, 'x');
      expect(token.isAttributeValue, isTrue);
    });

    test('isStart', () {
      final token = Token(TokenType.Tag, 'my-tag');
      expect(token.isStart, isTrue);
    });

    test('isEnd', () {
      final token = Token(TokenType.Tag, '/my-tag');
      expect(token.isEnd, isTrue);
    });

    test('name', () {
      final token = Token(TokenType.Tag, '/my-tag');

      expect(token.name, 'my-tag');
    });

    test('value', () {
      final token = Token(TokenType.Tag, '/my-tag');

      expect(token.value, '/my-tag');
    });

    test('line', () {
      final token = Token(TokenType.Tag, '/my-tag', 12);

      expect(token.linePosition, 12);
    });

    test('column', () {
      final token = Token(TokenType.Tag, '/my-tag', 12, 14);

      expect(token.columnPosition, 14);
    });

    test('toString', () {
      final tokenEnd = Token(TokenType.Tag, '/my-tag', 12, 14);

      expect(tokenEnd.toString(), '[/my-tag]');

      final tokenStart = Token(TokenType.Tag, 'my-tag', 12, 14);

      expect(tokenStart.toString(), '[my-tag]');
    });
  });
}
