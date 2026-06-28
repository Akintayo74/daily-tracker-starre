import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';
import 'cells.dart';

/// Today's woven cell, enlarged. Re-weaves live as chips are toggled.
class FocalTile extends StatelessWidget {
  const FocalTile(this.state, {super.key, this.size = 86});
  final AppState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hues = [
      for (final h in state.activeHabits)
        if (state.tendedToday(h.id)) h.hue.solid(),
    ];

    Color? bg;
    Gradient? gradient;
    if (hues.isEmpty) {
      bg = T.emptyCell;
    } else if (hues.length == 1) {
      bg = hues.first;
    } else {
      gradient = wovenGradient(hues);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        gradient: gradient,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: hues.isEmpty ? const Color(0xFFEBE3D4) : Colors.white.withValues(alpha: 0.28),
          width: 1,
        ),
        boxShadow: hues.isEmpty
            ? const []
            : [
                BoxShadow(
                  color: const Color(0xFF503C1E).withValues(alpha: 0.55),
                  blurRadius: 22,
                  spreadRadius: -10,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
    );
  }
}

/// One toggle pill per thread; tapping tends/un-tends it for today.
class CheckInChips extends StatelessWidget {
  const CheckInChips(this.state, {super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final h in state.activeHabits)
          _Chip(
            on: state.tendedToday(h.id),
            hue: h.hue,
            label: h.chip,
            onTap: () => state.toggleToday(h.id),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.on, required this.hue, required this.label, required this.onTap});
  final bool on;
  final HabitHue hue;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.fromLTRB(11, 8, 13, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: on ? hue.solid(0.14) : Colors.transparent,
          border: Border.all(color: on ? hue.solid(0.5) : const Color(0xFFE2DACA)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? hue.solid() : Colors.transparent,
                border: on ? null : Border.all(color: hue.solid(0.55), width: 1.5),
              ),
            ),
            const SizedBox(width: 7),
            Text(label,
                style: T.sans(size: 13, weight: FontWeight.w500, color: on ? const Color(0xFF564E43) : const Color(0xFF9A9082))),
          ],
        ),
      ),
    );
  }
}

/// The faint 9×7 loom shown on the first-run / empty screen.
class EmptyLoom extends StatelessWidget {
  const EmptyLoom({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var c = 0; c < 9; c++) ...[
            if (c > 0) const SizedBox(width: 5),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var r = 0; r < 7; r++) ...[
                  if (r > 0) const SizedBox(height: 5),
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFE8DA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
