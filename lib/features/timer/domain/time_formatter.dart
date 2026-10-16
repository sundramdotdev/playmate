/// Formatting utilities for timers, stopwatches, and clocks.
class TimeFormatter {
  TimeFormatter._();

  /// Formats duration as MM:SS or HH:MM:SS
  static String formatMmSs(Duration d) {
    final hours = d.inHours;
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  /// Formats stopwatch duration with centiseconds: MM:SS.cc or HH:MM:SS.cc
  static String formatStopwatch(Duration d) {
    final hours = d.inHours;
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    final centiseconds = ((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutes:$seconds.$centiseconds';
    }
    return '$minutes:$seconds.$centiseconds';
  }

  /// Formats chess clock: MM:SS or SS.c when under 10 seconds for high-tension blitz
  static String formatChess(Duration d) {
    if (d.inSeconds < 10 && d > Duration.zero) {
      final seconds = d.inSeconds;
      final tenths = ((d.inMilliseconds % 1000) ~/ 100);
      return '$seconds.${tenths}s';
    }
    return formatMmSs(d);
  }
}

