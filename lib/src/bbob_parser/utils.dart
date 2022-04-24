import 'dart:core' as prefix0;
import 'dart:core';

import 'package:bbob_dart/src/bbob_plugin_helper/char.dart';

/// A grabber wrapper that helps to scan over source string char by char.
class CharGrabber {
  /// Callback function that will be executed every time [CharGrabber] skips a
  /// character.
  final Function()? onSkip;

  final String _source;

  /// Current index that [CharGrabber] has scanned until.
  int _index = 0;

  CharGrabber(this._source, {this.onSkip});

  /// Whether [_source] has next string.
  bool get hasNext => _index < _source.length;

  /// Whether [CharGrabber] is at the end of [_source].
  bool get isLast => _index == _source.length - 1;

  /// Gets character that's at the current scan [_index].
  String? get current => _index >= _source.length ? null : _source[_index];

  /// Gets character that's at the next scan [_index]. Returns null if [_index] is the
  /// last character of [_source].
  String? get next => _index >= _source.length - 1 ? null : _source[_index + 1];

  /// Gets previous character that's at the previous scan [_index]. Returns
  /// null if `_index<=0`
  String? get previous => _index <= 0 ? null : _source[_index - 1];

  /// Grabs next character as long as [test] is evaluated to true.
  String grabWhile(bool Function(String? str) test) {
    final start = _index;

    while (hasNext && test(current)) {
      skip();
    }

    return _source.substring(start, _index);
  }

  /// Grabs rest of string until [CharGrabber] finds [char].
  String substringUntil(String char) {
    final indexOfChar = _source.indexOf(char, _index);

    if (indexOfChar >= 0) {
      return _source.substring(_index, indexOfChar);
    }

    return '';
  }

  /// Skips one character and calls [onSkip].
  skip() {
    _index++;

    if (onSkip != null) {
      onSkip!();
    }
  }
}

E? lastOrNull<E>(Iterable<E> items) {
  return items.isNotEmpty ? items.last : null;
}

/// Removes and returns last item if [_nodes] is not empty, otherwise returns
/// null.
E? removePossibleLast<E>(List<E> items) {
  if (items.isNotEmpty) {
    return items.removeLast();
  }

  return null;
}

/// Trims string from start and end by char
///
/// Example: `trimChar('*hello*', '*') ==> 'hello'`
String trimChar(String str, String charToRemove) {
  while (str[0] == charToRemove) {
    str = str.substring(1);
  }

  while (str[str.length - 1] == charToRemove) {
    str = str.substring(0, str.length - 1);
  }

  return str;
}

/// Unquotes `\"` to `"`
String unquote(String str) =>
    str.replaceAll('$backslash$doubleQuote', doubleQuote);
