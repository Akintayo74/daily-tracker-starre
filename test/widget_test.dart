// Basic smoke tests for Habit Tapestry's pure logic (stats + OKLCH conversion).

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tapestry/util/stats.dart';
import 'package:habit_tapestry/theme/oklch.dart';

void main() {
  group('HabitStats', () {
    test('current streak counts trailing tended days', () {
      expect(HabitStats.currentStreak([true, false, true, true]), 2);
      expect(HabitStats.currentStreak([false]), 0);
      expect(HabitStats.currentStreak([]), 0);
    });

    test('longest finds the max run', () {
      expect(HabitStats.longest([true, true, false, true, true, true]), 3);
      expect(HabitStats.longest([false, false]), 0);
    });

    test('rate is the percentage tended over the window', () {
      expect(HabitStats.rate([true, true, false, true], window: 4), 75);
      expect(HabitStats.rate([], window: 4), 0);
    });
  });

  test('oklch produces a valid opaque color', () {
    final c = oklch(0.77, 0.085, 70);
    expect(c.a, 1.0);
  });
}
