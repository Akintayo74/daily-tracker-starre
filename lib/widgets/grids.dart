import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../util/dates.dart';
import 'cells.dart';

/// The shared woven tapestry: every day shows all threads tended that day as
/// equal conic-gradient wedges. Stable thread order = active-habit order.
class SeasonGrid extends StatelessWidget {
  const SeasonGrid(this.state, {super.key, this.size = 13, this.gap = 3, this.radius = 3});
  final AppState state;
  final double size;
  final double gap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final habits = state.activeHabits;
    final eff = {for (final h in habits) h.id: state.effectiveDays(h)};
    final w = state.window;

    final columns = <Widget>[];
    for (var ci = 0; ci < w.weeks; ci++) {
      final cells = <Widget>[];
      for (var ri = 0; ri < 7; ri++) {
        final idx = ci * 7 + ri;
        final hues = [
          for (final h in habits)
            if (eff[h.id]![idx]) h.hue.solid(),
        ];
        if (ri > 0) cells.add(SizedBox(height: gap));
        cells.add(Container(
          width: size,
          height: size,
          decoration: wovenCellDecoration(hues, isToday: idx == w.todayIndex, radius: radius),
        ));
      }
      if (ci > 0) columns.add(SizedBox(width: gap));
      columns.add(Column(mainAxisSize: MainAxisSize.min, children: cells));
    }
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: columns);
  }
}

/// The single-hue contribution grid for one thread, with month labels across the
/// top and weekday labels down the left.
class DetailGrid extends StatelessWidget {
  const DetailGrid(this.state, this.habit, {super.key, this.size = 13, this.gap = 3.5, this.radius = 3});
  final AppState state;
  final Habit habit;
  final double size;
  final double gap;
  final double radius;

  static const double _labelWidth = 22;

  @override
  Widget build(BuildContext context) {
    final days = state.effectiveDays(habit);
    final w = state.window;
    final hue = habit.hue;

    // Month row.
    var prevMonth = -1;
    final monthCells = <Widget>[];
    for (var ci = 0; ci < w.weeks; ci++) {
      final top = w.dates[ci * 7];
      String label = '';
      if (top.month != prevMonth) {
        label = kMonthAbbr[top.month - 1];
        prevMonth = top.month;
      }
      if (ci > 0) monthCells.add(SizedBox(width: gap));
      monthCells.add(SizedBox(
        width: size,
        height: 12,
        child: OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: Text(label, maxLines: 1, style: T.sans(size: 10, color: T.faint3)),
        ),
      ));
    }
    final monthRow = Padding(
      padding: EdgeInsets.only(left: _labelWidth + gap, bottom: 5),
      child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: monthCells),
    );

    // Weekday label column.
    final labels = weekdayRowLabels(state.weekStart);
    final wdCells = <Widget>[];
    for (var ri = 0; ri < 7; ri++) {
      if (ri > 0) wdCells.add(SizedBox(height: gap));
      wdCells.add(SizedBox(
        width: _labelWidth,
        height: size,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(labels[ri], style: T.sans(size: 9.5, color: T.faint3)),
          ),
        ),
      ));
    }
    final wdCol = Column(mainAxisSize: MainAxisSize.min, children: wdCells);

    // Grid.
    final columns = <Widget>[];
    for (var ci = 0; ci < w.weeks; ci++) {
      final cells = <Widget>[];
      for (var ri = 0; ri < 7; ri++) {
        final idx = ci * 7 + ri;
        if (ri > 0) cells.add(SizedBox(height: gap));
        cells.add(Container(
          width: size,
          height: size,
          decoration: singleCellDecoration(hue, days[idx], isToday: idx == w.todayIndex, radius: radius),
        ));
      }
      if (ci > 0) columns.add(SizedBox(width: gap));
      columns.add(Column(mainAxisSize: MainAxisSize.min, children: cells));
    }
    final grid = Row(mainAxisSize: MainAxisSize.min, children: columns);

    final body = Row(
      mainAxisSize: MainAxisSize.min,
      children: [wdCol, SizedBox(width: gap), grid],
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [monthRow, body]);
  }
}
