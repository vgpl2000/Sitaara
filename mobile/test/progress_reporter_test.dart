import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sitaara/features/content/application/progress_reporter.dart';
import 'package:sitaara/features/content/data/content_models.dart';

void main() {
  test(
    'progress reporter ignores lower progress and coalesces newer ticks',
    () async {
      final submitted = <int>[];
      final firstResponse = Completer<ProgressResult>();
      var first = true;
      final reporter = ProgressReporter(
        initialSeconds: 10,
        submit: (seconds) async {
          submitted.add(seconds);
          if (first) {
            first = false;
            return firstResponse.future;
          }
          return _result(seconds);
        },
      );

      await reporter.report(5);
      final firstReport = reporter.report(20);
      final coalescedReport = reporter.report(30);
      firstResponse.complete(_result(20));
      await Future.wait([firstReport, coalescedReport]);

      expect(submitted, [20, 30]);
      expect(reporter.acknowledgedSeconds, 30);
    },
  );

  test('a failed tick remains retryable', () async {
    var calls = 0;
    final reporter = ProgressReporter(
      initialSeconds: 0,
      submit: (seconds) async {
        calls++;
        if (calls == 1) throw StateError('offline');
        return _result(seconds);
      },
    );

    await expectLater(reporter.report(15), throwsStateError);
    await reporter.report(15);

    expect(calls, 2);
    expect(reporter.acknowledgedSeconds, 15);
  });
}

ProgressResult _result(int seconds) => ProgressResult(
  furthestSeconds: seconds,
  durationSeconds: 100,
  percent: seconds,
  completed: seconds >= 90,
);
