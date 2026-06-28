/// Date helpers and the rolling grid window.
///
/// The tapestry is laid out as week-columns × 7 day-rows, oldest→newest
/// left→right, with today in the column/row matching its real weekday. Rows run
/// from [weekStart] (top) downward. Unlike the prototype's fixed 18-week window
/// and seeded RNG, production uses the real current date.
library;

const int kWeeks = 18;
const int kGridDays = kWeeks * 7; // 126

/// Strips the time component, returning a local date at midnight.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Stable `yyyy-mm-dd` key for a date (used to persist check-ins).
String dateKey(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

DateTime dateFromKey(String key) {
  final p = key.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

/// The rolling window of [kWeeks] columns ending in the current week.
class GridWindow {
  GridWindow._(this.dates, this.todayIndex, this.weeks);

  /// One entry per cell, row-major within columns: index = col*7 + row.
  final List<DateTime> dates;

  /// Index of today's cell within [dates] (the last non-future cell).
  final int todayIndex;
  final int weeks;

  int get length => dates.length;
  bool isFuture(int idx) => idx > todayIndex;

  /// Builds the window. [weekStart] is `'sun'` or `'mon'`.
  factory GridWindow.ending(DateTime today, {String weekStart = 'sun', int weeks = kWeeks}) {
    final t = dateOnly(today);
    // Dart weekday: Mon=1 .. Sun=7.
    final offset = weekStart == 'mon' ? t.weekday - 1 : t.weekday % 7;
    final startOfWeek = t.subtract(Duration(days: offset));
    final gridStart = startOfWeek.subtract(Duration(days: (weeks - 1) * 7));
    final dates = List<DateTime>.generate(
      weeks * 7,
      (i) => gridStart.add(Duration(days: i)),
    );
    return GridWindow._(dates, t.difference(gridStart).inDays, weeks);
  }
}

/// Weekday row labels (top→bottom) for a given week start. The detail grid only
/// renders Mon/Wed/Fri; the rest are blank.
List<String> weekdayRowLabels(String weekStart) {
  return weekStart == 'mon'
      ? const ['Mon', '', 'Wed', '', 'Fri', '', '']
      : const ['', 'Mon', '', 'Wed', '', 'Fri', ''];
}

const List<String> kMonthAbbr = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
