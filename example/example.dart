import 'dart:convert';

import 'package:bbob_dart/bbob_dart.dart';

const _blockTags = <String>['url', 'i', 'b'];

/// Translates a parsed AST to HTML.
class HtmlRenderer implements NodeVisitor {
  late StringBuffer buffer;
  late Set<String> uniqueIds;

  final _elementStack = <Element>[];
  String? _lastVisitedTag;

  HtmlRenderer();

  String render(List<Node> nodes) {
    buffer = StringBuffer();
    uniqueIds = <String>{};

    for (final node in nodes) {
      node.accept(this);
    }

    return buffer.toString();
  }

  @override
  void visitText(Text text) {
    var content = text.text;
    if (const ['br', 'p', 'li'].contains(_lastVisitedTag)) {
      final lines = LineSplitter.split(content);
      content = content.contains('<pre>')
          ? lines.join('\n')
          : lines.map((line) => line.trimLeft()).join('\n');
      if (text.text.endsWith('\n')) {
        content = '$content\n';
      }
    }
    buffer.write(content);

    _lastVisitedTag = null;
  }

  @override
  bool visitElementBefore(Element element) {
    // Hackish. Separate block-level elements with newlines.
    if (buffer.isNotEmpty && _blockTags.contains(element.tag)) {
      buffer.writeln();
    }

    buffer.write('<${element.tag}');

    for (final entry in element.attributes.entries) {
      buffer.write(' ${entry.key}="${entry.value}"');
    }

    _lastVisitedTag = element.tag;

    if (element.textContent.isEmpty) {
      // Empty element like <hr/>.
      buffer.write(' />');

      if (element.tag == 'br') {
        buffer.write('\n');
      }

      return false;
    } else {
      _elementStack.add(element);
      buffer.write('>');
      return true;
    }
  }

  @override
  void visitElementAfter(Element element) {
    assert(identical(_elementStack.last, element));

    if (element.children != null &&
        element.children.isNotEmpty &&
        _blockTags.contains(_lastVisitedTag) &&
        _blockTags.contains(element.tag)) {
      buffer.writeln();
    } else if (element.tag == 'blockquote') {
      buffer.writeln();
    }
    buffer.write('</${element.tag}>');

    _lastVisitedTag = _elementStack.removeLast().tag;
  }

  /// Uniquifies an id generated from text.
  String uniquifyId(String id) {
    if (!uniqueIds.contains(id)) {
      uniqueIds.add(id);
      return id;
    }

    var suffix = 2;
    var suffixedId = '$id-$suffix';
    while (uniqueIds.contains(suffixedId)) {
      suffixedId = '$id-${suffix++}';
    }
    uniqueIds.add(suffixedId);
    return suffixedId;
  }
}

main() {
  Set<String> validTags = Set<String>.from(_blockTags);

  var ast = parse(
    '''print [b]a[/b] [i][url=https://github.com]hello world![/url][/i]
  Yes this\'s an exampe''',
    onError: (msg) {
      print(msg);
    },
    openTag: '[',
    closeTag: ']',
    enableEscapeTags: false,
    validTags: validTags,
  );

  // print(ast);

  print(HtmlRenderer().render(ast));

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
}
