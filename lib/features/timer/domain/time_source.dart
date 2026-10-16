/// Represents an authoritative source of monotonic elapsed time.
/// Allows deterministic testing via mocking or fake clocks.
abstract class TimeSource {
  const TimeSource();

  /// The current monotonic timestamp in microseconds.
  int get nowMicroseconds;

  /// The current monotonic timestamp as a [Duration].
  Duration get nowDuration => Duration(microseconds: nowMicroseconds);
}

/// System-based implementation of [TimeSource].
class SystemTimeSource extends TimeSource {
  const SystemTimeSource();

  @override
  int get nowMicroseconds => DateTime.now().microsecondsSinceEpoch;
}

/// Fake implementation of [TimeSource] for deterministic unit and widget testing.
class TestTimeSource extends TimeSource {
  int _currentMicroseconds;

  TestTimeSource([this._currentMicroseconds = 0]);

  @override
  int get nowMicroseconds => _currentMicroseconds;

  void setMicroseconds(int microseconds) {
    _currentMicroseconds = microseconds;
  }

  void advance(Duration duration) {
    _currentMicroseconds += duration.inMicroseconds;
  }
}
