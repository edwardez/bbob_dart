## bbob_dart

<a href="https://pub.dev/packages/bbob_dart" rel="pub link">![badge](https://img.shields.io/pub/v/bbob_dart.svg)</a>

⚡️Blazing fast port of the BBCode parser and transformer [bbob](https://github.com/JiLiZART/bbob) in dart.

### What's currently ported?

* `bbob_parser` :  parses bbcode into a ast.

### Usage
See code in [exmaple](https://github.com/edwardez/bbob_dart/tree/master/example) folder.

### What's different from the original bbob?
`bbob_dart` is written in dart, which has a sound type system. And with the help of dart,
`bbob_dart` is strongly typed.
  
### I want to render ast into html/markdown...
You have two ways to render:
1. Similar to https://github.com/JiLiZART/bbob/blob/master/packages/bbob-html/src/index.js, how `bbob` 
renders ast into html.

2. Similar to https://github.com/dart-lang/markdown/blob/master/lib/src/html_renderer.dart,
`bbob_dart` has implemented an ast which allows you to walk through the tree using visitor pattern.

Office support in `bbob_dart` for a html renderer  might not happen in the near future. Feel free to send a pull request 
if you have a well-tested implementation. 

### How fast it is?
See discussions [here](https://github.com/JiLiZART/bbob/issues/25). Performance is expected to be on par with original `bbob`.

### Feature requests & bugs
Since this is a port of [bbob](https://github.com/JiLiZART/bbob), feature requests and bug 
reports should preferably be reported to original [bbob](https://github.com/JiLiZART/bbob) repo if 
it's not directly related to this dart implementation. 