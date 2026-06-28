import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../util/stats.dart';
import '../widgets/grids.dart';

/// Detail — "A thread". Look closely at one thread over the season; edit it.
class DetailScreen extends StatelessWidget {
  const DetailScreen(this.state, {super.key});
  final AppState state;

  String _schedule(Habit h) {
    if (h.days.every((d) => d)) return 'Every day';
    const nm = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final picked = [for (var i = 0; i < 7; i++) if (h.days[i]) nm[i]];
    return picked.isEmpty ? 'No set days' : picked.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final h = state.selected;
    if (h == null) return const SizedBox.shrink();
    final hist = state.historyDays(h);
    final hue = h.hue;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 58, 22, 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: state.goHome,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text('‹', style: T.sans(size: 18, color: T.faint, height: 1)),
                    const SizedBox(width: 5),
                    Text('Threads', style: T.sans(size: 14, color: T.faint)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: state.startEdit,
                behavior: HitTestBehavior.opaque,
                child: Text('Edit', style: T.sans(size: 14, color: T.faint)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Title.
          Row(
            children: [
              Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hue.solid(),
                  boxShadow: [BoxShadow(color: hue.solid(0.16), spreadRadius: 4)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(h.name, style: T.serif(size: 28, color: T.ink))),
            ],
          ),
          const SizedBox(height: 8),
          Text(h.sub, style: T.serif(size: 16, italic: true, color: T.muted)),
          const SizedBox(height: 8),
          Text(_schedule(h), style: T.sans(size: 12, color: const Color(0xFFB0A692), letterSpacing: 0.4)),

          // Stat tiles.
          const SizedBox(height: 22),
          Row(
            children: [
              _StatTile(value: '${HabitStats.currentStreak(hist)}d', label: 'CURRENT'),
              const SizedBox(width: 10),
              _StatTile(value: '${HabitStats.longest(hist)}d', label: 'LONGEST'),
              const SizedBox(width: 10),
              _StatTile(value: '${HabitStats.rate(hist)}%', label: '8 WEEKS'),
            ],
          ),

          // Grid card.
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            decoration: T.card(radius: 22),
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DetailGrid(state, h),
                ),
                const SizedBox(height: 13),
                Text(
                  '${HabitStats.tendedCount(hist)} days tended this season',
                  textAlign: TextAlign.right,
                  style: T.sans(size: 11, color: T.faint3),
                ),
              ],
            ),
          ),

          // Note card.
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: hue.wash,
              border: Border.all(color: T.cardBorder),
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
            child: Text(
              h.note,
              style: T.serif(size: 16.5, italic: true, color: const Color(0xFF6F665A), height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: T.statTile,
          border: Border.all(color: T.tileBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: T.serif(size: 26, color: const Color(0xFF544C42))),
            const SizedBox(height: 3),
            Text(label, style: T.sans(size: 10.5, color: const Color(0xFFA59B8A), letterSpacing: 0.4)),
          ],
        ),
      ),
    );
  }
}
