import '../models/habit.dart';
import '../util/dates.dart';

/// First-run seed.
///
/// The prototype ships five example threads and a seeded-RNG history. In the
/// real app that history must live in the local store as actual check-ins, so
/// on first launch we generate a plausible history *once* and persist it as
/// [Entry]-style records. After that, everything reads from stored data and the
/// RNG is never consulted again. New installs can instead start empty — this
/// simply gives the season grid something to show, matching the design.
class SeedResult {
  SeedResult(this.habits, this.entries);
  final List<Habit> habits;

  /// habitId -> set of tended `yyyy-mm-dd` keys.
  final Map<String, Set<String>> entries;
}

class _Seed {
  const _Seed(this.id, this.name, this.sub, this.chip, this.hueIdx, this.days,
      this.base, this.rngSeed, this.note);
  final String id;
  final String name;
  final String sub;
  final String chip;
  final int hueIdx;
  final List<bool> days;
  final double base;
  final int rngSeed;
  final String note;
}

const _all = [true, true, true, true, true, true, true];
const _mwf = [false, true, false, true, false, true, false];

const _seeds = <_Seed>[
  _Seed('wake', 'Wake at 5:00', 'Before the world stirs.', '5am', 0, _all, 0.80,
      1011,
      'The quiet hour is yours alone. Most of the day quietly leans on how this one begins.'),
  _Seed('jog', 'Morning jog', 'Out the door, into the light.', 'Jog', 1, _mwf,
      0.60, 2027,
      'Not for the distance — for the air, the blood, the simple proof that you woke and moved.'),
  _Seed('poem', 'Read a poem', 'A few lines, slowly.', 'Poem', 2, _all, 0.70,
      3041,
      'Any poem. Even a single line. Let it sit with you longer than it takes to read.'),
  _Seed('sleep', 'Sleep by 11:00', 'Let the day close.', '11pm', 3, _all, 0.72,
      4057,
      "Tomorrow's good morning is quietly made tonight. Let the day end before it ends you."),
  _Seed('breath', 'A 30-min breather', 'Step away, just be.', 'Breather', 4,
      _all, 0.64, 5077,
      'Nothing to achieve in this half hour. That emptiness is the whole point of it.'),
];

/// Today's initial tended state in the prototype.
const _todayState = {
  'wake': true,
  'jog': false,
  'poem': true,
  'sleep': false,
  'breath': true,
};

double Function() _mulberry32(int a) {
  return () {
    a = (a + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = a;
    t = (t ^ (t >>> 15)) * (1 | a) & 0xFFFFFFFF;
    t = (t + ((t ^ (t >>> 7)) * (61 | t) & 0xFFFFFFFF)) & 0xFFFFFFFF;
    t = t ^ (t >>> 14);
    return (t & 0xFFFFFFFF) / 4294967296;
  };
}

/// Generates [n] daily booleans (oldest→newest) with gentle momentum and a
/// couple of fallow stretches, mirroring the prototype's `genDays`.
List<bool> _genDays(int n, double base, int seed) {
  final rnd = _mulberry32(seed);
  final out = <bool>[];
  var prev = false;
  for (var i = 0; i < n; i++) {
    var p = base + (prev ? 0.16 : -0.06);
    final ph = i / n;
    if (ph > 0.32 && ph < 0.42) p -= 0.35;
    if (ph > 0.66 && ph < 0.73) p -= 0.28;
    p = p.clamp(0.04, 0.95);
    final d = rnd() < p;
    out.add(d);
    prev = d;
  }
  return out;
}

SeedResult buildSeed(DateTime today, {String weekStart = 'sun'}) {
  final window = GridWindow.ending(today, weekStart: weekStart);
  final createdAt = window.dates.first;
  final histLen = window.todayIndex + 1; // gridStart .. today inclusive

  final habits = <Habit>[];
  final entries = <String, Set<String>>{};

  for (var s = 0; s < _seeds.length; s++) {
    final seed = _seeds[s];
    habits.add(Habit(
      id: seed.id,
      name: seed.name,
      chip: seed.chip,
      hueIdx: seed.hueIdx,
      days: seed.days.toList(),
      note: seed.note,
      sub: seed.sub,
      createdAt: createdAt,
      order: s,
    ));

    final gen = _genDays(histLen, seed.base, seed.rngSeed);
    final tended = <String>{};
    for (var i = 0; i < window.todayIndex; i++) {
      if (gen[i]) tended.add(dateKey(window.dates[i]));
    }
    if (_todayState[seed.id] == true) {
      tended.add(dateKey(window.dates[window.todayIndex]));
    }
    entries[seed.id] = tended;
  }

  return SeedResult(habits, entries);
}
