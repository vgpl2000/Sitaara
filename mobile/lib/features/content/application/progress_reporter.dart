import 'dart:math' as math;

import '../data/content_models.dart';

typedef ProgressSubmitter = Future<ProgressResult> Function(int seconds);

/// Coalesces playback ticks and never sends progress below the acknowledged max.
class ProgressReporter {
  ProgressReporter({required int initialSeconds, required this.submit})
    : _acknowledgedSeconds = initialSeconds,
      _pendingSeconds = initialSeconds;

  final ProgressSubmitter submit;
  int _acknowledgedSeconds;
  int _pendingSeconds;
  Future<void>? _inFlight;

  int get acknowledgedSeconds => _acknowledgedSeconds;

  Future<void> report(int seconds) {
    if (seconds <= _acknowledgedSeconds) return Future.value();
    _pendingSeconds = math.max(_pendingSeconds, seconds);
    return _inFlight ??= _drain().whenComplete(() => _inFlight = null);
  }

  Future<void> _drain() async {
    while (_pendingSeconds > _acknowledgedSeconds) {
      final target = _pendingSeconds;
      final result = await submit(target);
      _acknowledgedSeconds = math.max(
        _acknowledgedSeconds,
        result.furthestSeconds,
      );
    }
  }
}
