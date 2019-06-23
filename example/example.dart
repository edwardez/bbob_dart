import 'package:bbob_dart/bbob_dart.dart';

main() {
  const validTags = {'url'};

  var ast = parse(
    '''print [b]a[/b] [url=https://github.com]hello world![/url]
  Yes this\'s an exampe''',
    onError: (msg) {
      print(msg);
    },
    openTag: '[',
    closeTag: ']',
    enableEscapeTags: false,
    validTags: validTags,
  );

  /// Parsed ast. Note that `b` is parsed as text because
  /// it's not in [validTags].
  ///
  ///[Text{text: 'print'}, Text{text: ' '}, Text{text: '[b]'}, Text{text: 'a'},
  ///Text{text: '[/b]'}, Text{text: ' '},
  ///Element{tag: 'url', attributes: '{https://github.com: https://github.com}',
  ///children: [Text{text: 'hello'}, Text{text: ' '}, Text{text: 'world!'}]},
  ///Text{text: '
  //'}, Text{text: '  '}, Text{text: 'Yes'}, Text{text: ' '},
  // Text{text: 'this's'}, Text{text: ' '}, Text{text: 'an'}, Text{text: ' '},
  // Text{text: 'exampe'}]

  /// Each [Node] has a [Node.textContent] which can be used to access its
  /// content in raw text format.
  ast.forEach((node) => print(node.textContent));
}
