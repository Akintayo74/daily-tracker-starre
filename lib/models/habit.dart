import '../theme/tokens.dart';

/// A "thread" the user tends. Color is chosen from the curated palette (stored
/// as an index into [T.palette]); [days] is the Sun..Sat schedule (metadata for
/// now — it informs future reminders, the grid is not filtered by it).
class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.chip,
    required this.hueIdx,
    required this.days,
    required this.note,
    required this.sub,
    this.archived = false,
    required this.createdAt,
    required this.order,
    this.reminderTime, // RESERVED — no UI yet; field kept per spec.
  });

  final String id;
  String name;
  String chip;
  int hueIdx;
  List<bool> days;
  String note;
  String sub;
  bool archived;
  final DateTime createdAt;
  int order;
  String? reminderTime;

  HabitHue get hue => T.palette[hueIdx.clamp(0, T.palette.length - 1)];

  /// Short label for the check-in pill, derived from the name when absent.
  static String chipFrom(String name) => name.trim().split(RegExp(r'\s+')).first;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'chip': chip,
        'hueIdx': hueIdx,
        'days': days,
        'note': note,
        'sub': sub,
        'archived': archived,
        'createdAt': createdAt.toIso8601String(),
        'order': order,
        'reminderTime': reminderTime,
      };

  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
        id: j['id'] as String,
        name: j['name'] as String,
        chip: j['chip'] as String? ?? chipFrom(j['name'] as String),
        hueIdx: j['hueIdx'] as int,
        days: (j['days'] as List).map((e) => e as bool).toList(),
        note: j['note'] as String? ?? '',
        sub: j['sub'] as String? ?? '',
        archived: j['archived'] as bool? ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String),
        order: j['order'] as int? ?? 0,
        reminderTime: j['reminderTime'] as String?,
      );
}
