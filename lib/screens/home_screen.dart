import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../util/stats.dart';
import '../widgets/grids.dart';
import '../widgets/home_widgets.dart';

const _weekdaysFull = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
const _monthsFull = [
  'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
  'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
];

String _greeting(int hour) {
  if (hour < 12) return 'Good morning';
  if (hour < 18) return 'Good afternoon';
  return 'Good evening';
}

/// Home — "The loom". See today at a glance, tend threads, glance at the season.
class HomeScreen extends StatelessWidget {
  const HomeScreen(this.state, {super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final t = state.today;
    final dateLabel = '${_weekdaysFull[t.weekday - 1]} · ${_monthsFull[t.month - 1]} ${t.day}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 58, 20, 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateLabel, style: T.eyebrow(color: T.faint, spacing: 2.4)),
                    const SizedBox(height: 6),
                    Text(_greeting(DateTime.now().hour), style: T.serif(size: 31, color: T.ink)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _AddButton(onTap: state.startAdd),
              ),
            ],
          ),

          // ON THE LOOM · TODAY.
          const SizedBox(height: 20),
          Container(
            decoration: T.card(),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ON THE LOOM · TODAY', style: T.eyebrow()),
                const SizedBox(height: 15),
                Row(
                  children: [
                    FocalTile(state),
                    const SizedBox(width: 17),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(text: '${state.todayCount}', style: T.serif(size: 38, color: const Color(0xFF4A4239), height: 1)),
                              TextSpan(text: ' / ${state.habitTotal}', style: T.serif(size: 21, color: const Color(0xFFBEB39C), height: 1)),
                            ]),
                          ),
                          const SizedBox(height: 7),
                          Text('threads woven into today', style: T.sans(size: 13, color: T.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                CheckInChips(state),
              ],
            ),
          ),

          // THIS SEASON.
          const SizedBox(height: 16),
          Container(
            decoration: T.card(),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: Text('THIS SEASON', style: T.eyebrow())),
                    Text('18 weeks', style: T.sans(size: 12, color: T.faint3)),
                  ],
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SeasonGrid(state),
                ),
                const SizedBox(height: 11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final m in const ['Feb', 'Mar', 'Apr', 'May', 'Jun'])
                      Text(m, style: T.sans(size: 10.5, color: const Color(0xFFC3B9A3))),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Some threads thick, some thin — the cloth grows kinder than it does complete.',
                  style: T.serif(size: 14.5, italic: true, color: const Color(0xFF857C6E), height: 1.5),
                ),
              ],
            ),
          ),

          // THREADS list.
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
            child: Text('THREADS', style: T.eyebrow()),
          ),
          for (var i = 0; i < state.activeHabits.length; i++)
            _ThreadRow(
              state: state,
              index: i,
              isLast: i == state.activeHabits.length - 1,
            ),
          GestureDetector(
            onTap: state.goSettings,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 15, 4, 4),
              child: Row(
                children: [
                  Expanded(child: Text('Settings & backup', style: T.sans(size: 14, color: T.faint))),
                  Text('›', style: T.sans(size: 17, color: T.chevron)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: T.surface,
          border: Border.all(color: T.inputBorder),
          boxShadow: const [
            BoxShadow(color: Color(0x4D3C2D14), blurRadius: 16, spreadRadius: -10, offset: Offset(0, 6)),
          ],
        ),
        child: Text('+', style: T.sans(size: 22, color: const Color(0xFF7A7163), height: 1)),
      ),
    );
  }
}

class _ThreadRow extends StatelessWidget {
  const _ThreadRow({required this.state, required this.index, required this.isLast});
  final AppState state;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final h = state.activeHabits[index];
    final streak = HabitStats.currentStreak(state.historyDays(h));
    return GestureDetector(
      onTap: () => state.open(h.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: T.hairline2)),
        ),
        child: Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: h.hue.solid())),
            const SizedBox(width: 12),
            Expanded(child: Text(h.name, style: T.serif(size: 18, color: T.ink2))),
            Text('${streak}d', style: T.sans(size: 12.5, color: const Color(0xFFA59B8A))),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text('›', style: T.sans(size: 17, color: T.chevron)),
            ),
          ],
        ),
      ),
    );
  }
}
