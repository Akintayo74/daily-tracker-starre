import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';
import 'seed.dart';

/// The in-memory snapshot the app works with, hydrated from local storage.
class AppData {
  AppData({
    required this.habits,
    required this.entries,
    required this.weekStart,
  });

  final List<Habit> habits;

  /// habitId -> set of tended `yyyy-mm-dd` keys.
  final Map<String, Set<String>> entries;
  String weekStart; // 'sun' | 'mon'
}

/// Local persistence backed by [SharedPreferences] (JSON). The check-in model is
/// binary: a date key present in a habit's set means that day was tended. This
/// is the real, durable store stats and grids read from.
class Repository {
  static const _kHabits = 'habits';
  static const _kEntries = 'entries';
  static const _kWeekStart = 'weekStart';
  static const _kSeeded = 'seeded';

  SharedPreferences? _prefs;
  Future<SharedPreferences> get _p async => _prefs ??= await SharedPreferences.getInstance();

  Future<AppData> load(DateTime today) async {
    final p = await _p;
    final weekStart = p.getString(_kWeekStart) ?? 'sun';

    if (!(p.getBool(_kSeeded) ?? false)) {
      final seed = buildSeed(today, weekStart: weekStart);
      final data = AppData(habits: seed.habits, entries: seed.entries, weekStart: weekStart);
      await saveHabits(data.habits);
      await saveEntries(data.entries);
      await p.setBool(_kSeeded, true);
      return data;
    }

    final habits = <Habit>[];
    final habitsRaw = p.getString(_kHabits);
    if (habitsRaw != null) {
      for (final h in jsonDecode(habitsRaw) as List) {
        habits.add(Habit.fromJson(h as Map<String, dynamic>));
      }
      habits.sort((a, b) => a.order.compareTo(b.order));
    }

    final entries = <String, Set<String>>{};
    final entriesRaw = p.getString(_kEntries);
    if (entriesRaw != null) {
      (jsonDecode(entriesRaw) as Map<String, dynamic>).forEach((id, keys) {
        entries[id] = {for (final k in keys as List) k as String};
      });
    }

    return AppData(habits: habits, entries: entries, weekStart: weekStart);
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final p = await _p;
    await p.setString(_kHabits, jsonEncode(habits.map((h) => h.toJson()).toList()));
  }

  Future<void> saveEntries(Map<String, Set<String>> entries) async {
    final p = await _p;
    await p.setString(
      _kEntries,
      jsonEncode(entries.map((id, keys) => MapEntry(id, keys.toList()))),
    );
  }

  Future<void> saveWeekStart(String weekStart) async {
    final p = await _p;
    await p.setString(_kWeekStart, weekStart);
  }

  /// Wipes persisted data so the next launch re-seeds (used by "See first-run").
  Future<void> resetSeed() async {
    final p = await _p;
    await p.remove(_kHabits);
    await p.remove(_kEntries);
    await p.remove(_kSeeded);
  }
}
