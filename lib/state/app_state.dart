import 'package:flutter/foundation.dart';

import '../data/repository.dart';
import '../models/habit.dart';
import '../util/dates.dart';

enum AppView { home, detail, form, settings, empty }

/// Working copy for the Add/Edit form.
class Draft {
  Draft({required this.name, required this.hueIdx, required this.days, this.editingId});
  String name;
  int hueIdx;
  List<bool> days;
  final String? editingId;

  bool get isEdit => editingId != null;
}

/// Single source of truth for navigation and data. Mutations persist through the
/// [Repository]; the UI derives everything (woven cells, counts, stats) from
/// here so a tend toggle re-weaves the focal tile, the season grid and the
/// detail grid together.
class AppState extends ChangeNotifier {
  AppState(this._repo);
  final Repository _repo;

  late AppData _data;
  final DateTime today = dateOnly(DateTime.now());
  bool loading = true;

  AppView view = AppView.home;
  String? selectedId;
  Draft? draft;

  Future<void> init() async {
    _data = await _repo.load(today);
    selectedId = activeHabits.isNotEmpty ? activeHabits.first.id : null;
    loading = false;
    notifyListeners();
  }

  // ---- derived ----
  String get weekStart => _data.weekStart;

  List<Habit> get activeHabits =>
      _data.habits.where((h) => !h.archived).toList()..sort((a, b) => a.order.compareTo(b.order));

  int get habitTotal => activeHabits.length;

  GridWindow get window => GridWindow.ending(today, weekStart: weekStart);

  bool tendedToday(String id) => _data.entries[id]?.contains(dateKey(today)) ?? false;

  int get todayCount => activeHabits.where((h) => tendedToday(h.id)).length;

  Habit? get selected {
    final list = activeHabits;
    if (list.isEmpty) return null;
    return list.firstWhere((h) => h.id == selectedId, orElse: () => list.first);
  }

  /// Per-cell tended booleans across the whole window (future cells = false).
  List<bool> effectiveDays(Habit h) {
    final w = window;
    final tended = _data.entries[h.id] ?? const <String>{};
    return List<bool>.generate(w.length, (i) {
      if (w.isFuture(i)) return false;
      return tended.contains(dateKey(w.dates[i]));
    });
  }

  /// History up to and including today — the input to streak/longest/rate.
  List<bool> historyDays(Habit h) {
    final w = window;
    return effectiveDays(h).sublist(0, w.todayIndex + 1);
  }

  // ---- navigation ----
  void open(String id) {
    selectedId = id;
    view = AppView.detail;
    notifyListeners();
  }

  void goHome() {
    view = AppView.home;
    notifyListeners();
  }

  void goSettings() {
    view = AppView.settings;
    notifyListeners();
  }

  void goEmpty() {
    view = AppView.empty;
    notifyListeners();
  }

  // ---- tending ----
  void toggleToday(String id) {
    final key = dateKey(today);
    final set = _data.entries.putIfAbsent(id, () => <String>{});
    if (!set.remove(key)) set.add(key);
    _repo.saveEntries(_data.entries);
    notifyListeners();
  }

  void toggleWeekStart() {
    _data.weekStart = weekStart == 'sun' ? 'mon' : 'sun';
    _repo.saveWeekStart(_data.weekStart);
    notifyListeners();
  }

  // ---- form ----
  void startAdd() {
    draft = Draft(
      name: '',
      hueIdx: activeHabits.length % 10,
      days: List.filled(7, true),
    );
    view = AppView.form;
    notifyListeners();
  }

  void startEdit() {
    final h = selected;
    if (h == null) return;
    draft = Draft(
      name: h.name,
      hueIdx: h.hueIdx,
      days: h.days.toList(),
      editingId: h.id,
    );
    view = AppView.form;
    notifyListeners();
  }

  void setDraftName(String name) {
    draft?.name = name;
    notifyListeners();
  }

  void setDraftHue(int idx) {
    draft?.hueIdx = idx;
    notifyListeners();
  }

  void toggleDraftDay(int i) {
    final d = draft;
    if (d == null) return;
    d.days[i] = !d.days[i];
    notifyListeners();
  }

  void setEveryDay() {
    draft?.days = List.filled(7, true);
    notifyListeners();
  }

  void cancelForm() {
    view = (draft?.isEdit ?? false) ? AppView.detail : AppView.home;
    draft = null;
    notifyListeners();
  }

  bool get canCommit => (draft?.name.trim().isNotEmpty) ?? false;

  void commitForm() {
    final d = draft;
    if (d == null) return;
    final name = d.name.trim();
    if (name.isEmpty) return;

    if (d.isEdit) {
      final h = _data.habits.firstWhere((x) => x.id == d.editingId);
      h.name = name;
      h.chip = Habit.chipFrom(name);
      h.hueIdx = d.hueIdx;
      h.days = d.days.toList();
      _repo.saveHabits(_data.habits);
      selectedId = h.id;
      view = AppView.detail;
    } else {
      final id = 'h${DateTime.now().millisecondsSinceEpoch}';
      final maxOrder = _data.habits.fold<int>(-1, (m, h) => h.order > m ? h.order : m);
      _data.habits.add(Habit(
        id: id,
        name: name,
        chip: Habit.chipFrom(name),
        hueIdx: d.hueIdx,
        days: d.days.toList(),
        note: 'A thread you chose to tend. Come back to it when you can.',
        sub: 'A thread you chose to tend.',
        createdAt: today,
        order: maxOrder + 1,
      ));
      // Auto-tend on create so the new thread immediately shows color.
      _data.entries.putIfAbsent(id, () => <String>{}).add(dateKey(today));
      _repo.saveHabits(_data.habits);
      _repo.saveEntries(_data.entries);
      view = AppView.home;
    }
    draft = null;
    notifyListeners();
  }

  /// Archive hides the thread but preserves its history.
  void archiveHabit(String id) {
    final h = _data.habits.firstWhere((x) => x.id == id);
    h.archived = true;
    _repo.saveHabits(_data.habits);
    _afterRemove();
  }

  /// Delete removes the thread and its history.
  void deleteHabit(String id) {
    _data.habits.removeWhere((x) => x.id == id);
    _data.entries.remove(id);
    _repo.saveHabits(_data.habits);
    _repo.saveEntries(_data.entries);
    _afterRemove();
  }

  void _afterRemove() {
    selectedId = activeHabits.isNotEmpty ? activeHabits.first.id : null;
    view = activeHabits.isEmpty ? AppView.empty : AppView.home;
    draft = null;
    notifyListeners();
  }

  /// Wipes data and re-seeds (the "See first-run screen" affordance routes here
  /// after showing the empty state).
  Future<void> reseed() async {
    await _repo.resetSeed();
    _data = await _repo.load(today);
    selectedId = activeHabits.isNotEmpty ? activeHabits.first.id : null;
    notifyListeners();
  }
}
