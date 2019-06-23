/// Base class for any AST item.
abstract class Node {
  String get textContent;
}

/// A named tag that can contain other nodes.
class Element implements Node {
  /// Tag name.
  final String tag;

  /// Attributes on this [Element].
  final Map<String, String> attributes;

  /// All children of this [Element], it might be nested.
  final List<Node> children;

  Element(
    this.tag, [
    Map<String, String> attributes,
    List<Node> children = const [],
  ])  : this.children = [...children],
        attributes = attributes ?? {};

  /// Update attributes with [name] and [value] if both are not null.
  /// Returns [attributes] value by querying [name] even if [attributes]
  /// is not updated.
  String updateAttributes(String name, String value) {
    if (name != null && value != null) {
      attributes[name] = value;
    }

    return attributes[name];
  }

  /// Appends a new [child] to [children].
  appendChild(Node child) {
    return children.add(child);
  }

  @override
  String toString() {
    return 'Element{tag: \'$tag\', attributes: \'$attributes\','
        ' children: $children}';
  }

  @override
  String get textContent => children.map((child) => child.textContent).join('');
}

/// A plain text element.
class Text implements Node {
  final String text;

  Text(this.text);

  String get textContent => text;

  @override
  String toString() {
    return 'Text{text: \'$text\'}';
  }
}
