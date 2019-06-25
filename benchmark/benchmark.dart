import 'dart:math' as math;

import 'package:bbob_dart/bbob_dart.dart';

import 'input.dart';

const numTrials = 100;
const runsPerTrial = 50;

final expected = parse(input);

/// Modified from dart markdown benchmark
/// https://github.com/dart-lang/markdown/blob/master/benchmark/benchmark.dart
void main() {
  var best = double.infinity;
  var worst = double.negativeInfinity;

  // Run the benchmark several times. This ensures the VM is warmed up and lets
  // us see how much variance there is.
  for (var i = 0; i <= numTrials; i++) {
    var stopwatch = Stopwatch()
      ..start();

    // For a single benchmark, convert the source multiple times.
    var result;
    for (var j = 0; j < runsPerTrial; j++) {
      result = parse(input);
    }

    var elapsed = stopwatch.elapsedMilliseconds / runsPerTrial;

    // Keep track of the best/worst run so far.
    if (elapsed >= best) {
      worst = math.max(worst, elapsed);
      continue;
    }
    best = elapsed;

    // Sanity check to make sure the VM doesn't optimize "dead" code away.
    // TODO: It's ported from dart markdown, check if it works in bbob_dart.
    if (result.toString() != expected.toString()) {
      throw Exception('Incorrect result:\n$result.\nExpected: $expected');
    }
  }

  printResult('Best', best);
  printResult('Worst', worst);
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
