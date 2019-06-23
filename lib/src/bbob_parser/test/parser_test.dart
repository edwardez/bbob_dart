import 'package:bbob_dart/bbob_dart.dart';
import 'package:bbob_dart/src/bbob_parser/parser.dart';
import 'package:test/test.dart';

void main() {
  group('Parser', () {
    // TODO: find a better way to validate nodes.
    validateNodes(List<Node> ast, List<Node> output) {
      expect(ast.length, output.length);

      validateNode(Node ast, Node output) {
        if (ast is Element && output is Element) {
          validateNodes(ast.children, output.children);
          expect(ast.tag, output.tag);
          expect(ast.attributes, equals(ast.attributes));
        } else if (ast is Text && output is Text) {
          expect(ast.textContent, output.textContent);
        } else {
          expect(ast, output);
        }

        expect(ast.toString(), equals(output.toString()));
      }

      for (var i = 0; i < ast.length; i++) {
        validateNode(ast[i], output[i]);
      }
      ;
    }

    group('bbcode', () {
      test('parses paired tags tokens', () {
        final ast = parse('[best name=value]Foo Bar[/best]');
        validateNodes(ast, [
          Element(
            'best',
            {'name': 'value'},
            [
              Text('Foo'),
              Text(' '),
              Text('Bar'),
            ],
          )
        ]);
      });

      test('parses only allowed tags', () {
        final ast = parse('[h1 name=value]Foo [Bar] [/h1]', validTags: {'h1'});
        validateNodes(ast, [
          Element(
            'h1',
            {'name': 'value'},
            [
              Text('Foo'),
              Text(' '),
              Text('[Bar]'),
              Text(' '),
            ],
          )
        ]);
      });

      test('parses inconsistent tags', () {
        final ast = parse(
          '[h1 name=value]Foo [Bar] /h1]',
        );
        validateNodes(ast, [
          Element(
            'h1',
            {'name': 'value'},
            [],
          ),
          Text('Foo'),
          Text(' '),
          Element(
            'Bar',
            {},
            [],
          ),
          Text(' '),
          Text('/h1]'),
        ]);
      });

      test('parses tag with value param', () {
        final ast = parse(
          '[url=https://github.com/jilizart/bbob]BBob[/url]',
        );
        validateNodes(ast, [
          Element(
            'url',
            {
              'https://github.com/jilizart/bbob':
                  'https://github.com/jilizart/bbob'
            },
            [
              Text('BBob'),
            ],
          ),
        ]);
      });

      test('parses tag with quoted param with spaces', () {
        final ast = parse(
          '[url href=https://ru.wikipedia.org target=_blank text="Foo Bar"]Text[/url]',
        );
        validateNodes(ast, [
          Element(
            'url',
            {
              'href': 'https://ru.wikipedia.org',
              'target': '_blank',
              'text': 'Foo Bar',
            },
            [
              Text('Text'),
            ],
          ),
        ]);
      });

      test('parses single tag with params', () {
        final ast = parse(
          '[url=https://github.com/jilizart/bbob]',
        );
        validateNodes(ast, [
          Element(
            'url',
            {
              'https://github.com/jilizart/bbob':
                  'https://github.com/jilizart/bbob',
            },
            [],
          ),
        ]);
      });

      test('detects inconsistent tag', () {
        // TODO: find a way to mock callback using mockito.
        bool onErrorCalled = false;

        final ast = parse('[c][/c][b]hello[/c][/b][b]', onError: (_) {
          onErrorCalled = true;
        });

        validateNodes(ast, [
          Element(
            'c',
            {},
            [],
          ),
          Element(
            'b',
            {},
            [Text('hello')],
          ),
        ]);

        expect(onErrorCalled, isTrue);
      });

      test('parse escaped tags tags', () {
        final ast = parse('\\[b\\]test\\[/b\\]', enableEscapeTags: true);

        validateNodes(ast, [
          Text('['),
          Text('b'),
          Text(']'),
          Text('test'),
          Text('['),
          Text('/b'),
          Text(']'),
        ]);
      });

      test('oo-style parser returns idempotent result', () {
        final parser = Parser();
        final input = '[h1 name=value]Foo [Bar] /h1]';

        final expected = [
          Element(
            'h1',
            {'name': 'value'},
            [],
          ),
          Text('Foo'),
          Text(' '),
          Element(
            'Bar',
            {},
            [],
          ),
          Text(' '),
          Text('/h1]'),
        ];

        validateNodes(parser.parse(input), expected);
        validateNodes(parser.parse(input), expected);
        validateNodes(parser.parse(input), expected);
      });
    });

    group('html', () {
      parseHTML(String input) => parse(
            input,
            openTag: '<',
            closeTag: '>',
          );

      test('normal attributes', () {
        const content =
            r'<button id="test0" class="value0" title="value1">class="value0" '
            r'title="value1"</button>';
        final ast = parseHTML(content);
        ;

        validateNodes(ast, [
          Element(
            'button',
            {'id': 'test0', 'class': 'value0', 'title': 'value1'},
            [
              Text('class="value0"'),
              Text(' '),
              Text('title="value1"'),
            ],
          ),
        ]);
      });

      test('attributes with no quotes or value', () {
        const content =
            r'<button id="test1" class=value2 disabled required>class=value2 '
            r'disabled</button>';
        final ast = parseHTML(content);

        validateNodes(ast, [
          Element(
            'button',
            {
              'id': 'test1',
              'class': 'value2',
              'disabled': 'disabled',
              'required': 'required',
            },
            [
              Text('class=value2'),
              Text(' '),
              Text('disabled'),
            ],
          ),
        ]);
      });

      test(
          'attributes with no space between them. no valid, but accepted by the browser',
          () {
        const content = r'<button id="test2" class="value4"title="value5">'
            r'class="value4"title="value5"</button>';

        final ast = parseHTML(content);

        validateNodes(ast, [
          Element(
            'button',
            {
              'id': 'test2',
              'class': 'value4',
              'title': 'value5',
            },
            [
              Text('class="value4"title="value5"'),
            ],
          ),
        ]);
      });
    });
  });
}
