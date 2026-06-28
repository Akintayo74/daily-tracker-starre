import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Equal conic-gradient wedges for a woven day cell. Mirrors the prototype's
/// `conic-gradient(from 45deg, …)`: each thread gets a 360/N° wedge in stable
/// thread order. Hard edges are produced by repeating each color at the wedge
/// boundary.
Gradient wovenGradient(List<Color> hues) {
  final n = hues.length;
  final colors = <Color>[];
  final stops = <double>[];
  for (var i = 0; i < n; i++) {
    colors.add(hues[i]);
    stops.add(i / n);
    colors.add(hues[i]);
    stops.add((i + 1) / n);
  }
  // CSS `from 45deg` starts 45° clockwise from the top; SweepGradient starts at
  // 3 o'clock, so offset by -45° to put the first seam where the design does.
  return SweepGradient(colors: colors, stops: stops, transform: const GradientRotation(-math.pi / 4));
}

/// Decoration for a cell in the shared woven tapestry.
BoxDecoration wovenCellDecoration(List<Color> hues, {required bool isToday, required double radius}) {
  Color? bg;
  Gradient? gradient;
  if (hues.isEmpty) {
    bg = T.emptyCell;
  } else if (hues.length == 1) {
    bg = hues.first;
  } else {
    gradient = wovenGradient(hues);
  }

  List<BoxShadow> shadow = const [];
  if (hues.length >= 3) {
    shadow = const [
      BoxShadow(color: Color(0x59463614), blurRadius: 6, spreadRadius: -2, offset: Offset(0, 1)),
    ];
  }
  if (isToday) {
    // Last cell (today) → soft ring.
    shadow = [
      BoxShadow(color: const Color(0xFF78644A).withValues(alpha: 0.5), blurRadius: 0, spreadRadius: 1.6),
    ];
  }

  return BoxDecoration(
    color: bg,
    gradient: gradient,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: shadow,
  );
}

/// Decoration for a binary single-hue grid cell (the detail screen).
BoxDecoration singleCellDecoration(HabitHue hue, bool on, {required bool isToday, required double radius}) {
  List<BoxShadow> shadow = const [];
  if (on) {
    shadow = [
      BoxShadow(color: hue.solid(0.5), blurRadius: 4, spreadRadius: -2, offset: const Offset(0, 1)),
    ];
  }
  if (isToday) {
    shadow = [
      BoxShadow(color: hue.solid(0.85), blurRadius: 0, spreadRadius: 1.5),
    ];
  }
  return BoxDecoration(
    color: on ? hue.solid() : T.emptyCell,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: shadow,
  );
}
