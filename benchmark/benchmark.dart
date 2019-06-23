import 'dart:io';
import 'dart:math' as math;

import 'package:bbob_dart/bbob_dart.dart';
import 'package:path/path.dart' as p;

const numTrials = 100;
const runsPerTrial = 50;

final source = loadFile('input.txt');

final expected = parse(source);

/// Modified from dart markdown benchmark
/// https://github.com/dart-lang/markdown/blob/master/benchmark/benchmark.dart
void main() {
  var best = double.infinity;
  double worst;

  // Run the benchmark several times. This ensures the VM is warmed up and lets
  // us see how much variance there is.
  for (var i = 0; i <= numTrials; i++) {
    var start = DateTime.now();

    // For a single benchmark, convert the source multiple times.
    var result;
    for (var j = 0; j < runsPerTrial; j++) {
      result = parse(source);
    }

    var elapsed =
        DateTime.now().difference(start).inMilliseconds / runsPerTrial;

    // Keep track of the best run so far.
    if (elapsed >= best) {
      if (worst == null) {
        worst = elapsed;
      } else {
        worst = math.max(worst, elapsed);
      }
    }
    best = elapsed;

    // Sanity check to make sure the VM doesn't optimize "dead" code away.
    // TODO: It's ported from dart markdown, check if it works in bbob_dart.
    if (result.toString() != expected.toString()) {
      print("Incorrect result:\n$result.\nExpected: $expected");
      exit(1);
    }
  }

  printResult('Best', best);
  printResult('Worst', worst);
}

String loadFile(String name) {
  var path = p.join(p.dirname(p.fromUri(Platform.script)), name);
  return File(path).readAsStringSync();
}

void printResult(String label, double time) {
  print("$label: ${padLeft(time.toStringAsFixed(2), 4)}ms "
      "${'=' * ((time * 20).toInt())}");
}

String padLeft(input, int length) {
  var result = input.toString();
  if (result.length < length) {
    result = " " * (length - result.length) + result;
  }

  return result;
}
