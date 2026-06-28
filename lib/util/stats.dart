/// Streak / completion stats, computed from real check-in history.
///
/// All functions take the habit's tended-day booleans from oldest→newest,
/// ending at today (future cells excluded). The schedule (`days`) is not applied
/// here — the prototype does not filter the grid by it.
class HabitStats {
  /// Trailing consecutive tended days ending today.
  static int currentStreak(List<bool> days) {
    var s = 0;
    for (var i = days.length - 1; i >= 0; i--) {
      if (days[i]) {
        s++;
      } else {
        break;
      }
    }
    return s;
  }

  /// Longest run of consecutive tended days.
  static int longest(List<bool> days) {
    var best = 0, run = 0;
    for (final d in days) {
      if (d) {
        run++;
        if (run > best) best = run;
      } else {
        run = 0;
      }
    }
    return best;
  }

  /// Percentage of the last [window] days tended (default 8 weeks = 56 days).
  static int rate(List<bool> days, {int window = 56}) {
    if (days.isEmpty) return 0;
    final start = days.length > window ? days.length - window : 0;
    final slice = days.sublist(start);
    final tended = slice.where((d) => d).length;
    return (tended / slice.length * 100).round();
  }

  static int tendedCount(List<bool> days) => days.where((d) => d).length;
}
