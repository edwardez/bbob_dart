/// Base class for any AST item.
///
/// This ast structure is based on bbob ast structure with dart-markdown
/// https://github.com/dart-lang/markdown/blob/master/lib/src/ast.dart
/// like structure.
abstract class Node {
  void accept(NodeVisitor visitor);

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
    Map<String, String> attributes = const {},
    List<Node> children = const [],
  ])  : children = [...children],
        attributes = attributes;

  @override
  String get textContent => children.map((child) => child.textContent).join('');

  bool get isChildrenNullOrEmpty => children.isEmpty;

  /// Update attributes with [name] and [value] if both are not null.
  /// Returns [attributes] value by querying [name] even if [attributes]
  /// is not updated.
  String updateAttributes(String name, String value) {
    attributes[name] = value;
    return attributes[name]!;
  }

  /// Appends a new [child] to [children].
  void appendChild(Node child) {
    return children.add(child);
  }

  @override
  void accept(NodeVisitor visitor) {
    if (visitor.visitElementBefore(this)) {
      if (!isChildrenNullOrEmpty) {
        for (var child in children) {
          child.accept(visitor);
        }
      }
      visitor.visitElementAfter(this);
    }
  }

  @override
  String toString() {
    return 'Element{tag: \'$tag\', attributes: \'$attributes\','
        ' children: $children}';
  }
}

/// A plain text element.
class Text implements Node {
  final String text;

  Text(this.text);

  @override
  String get textContent => text;

  @override
  void accept(NodeVisitor visitor) => visitor.visitText(this);

  @override
  String toString() {
    return 'Text{text: \'$text\'}';
  }
}

/// Visitor pattern for the AST.
///
/// Renderers or other AST transformers should implement this.
abstract class NodeVisitor {
  /// Called when a Text node has been reached.
  void visitText(Text text);

  /// Called when an Element has been reached, before its children have been
  /// visited.
  ///
  /// Returns `false` to skip its children.
  bool visitElementBefore(Element element);

  /// Called when an Element has been reached, after its children have been
  /// visited.
  ///
  /// Will not be called if [visitElementBefore] returns `false`.
  void visitElementAfter(Element element);
}
