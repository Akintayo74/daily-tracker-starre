import 'package:flutter/material.dart';

import 'oklch.dart';

/// A curated habit hue, defined in OKLCH (the source of truth).
@immutable
class HabitHue {
  const HabitHue(this.l, this.c, this.h);
  final double l;
  final double c;
  final double h;

  /// Full thread color (dots, filled cells, swatches).
  Color solid([double? alpha]) => oklch(l, c, h, alpha ?? 1.0);

  /// A 1.5%-chroma wash of this hue — used for note / preview card backgrounds.
  Color get wash => oklch(0.985, 0.013, h);
}

/// Design tokens for Habit Tapestry. Surfaces are warm and paper-like; the tone
/// is calm — no alarm-red, no guilt states.
class T {
  T._();

  // Surfaces & ink.
  static const Color paper = Color(0xFFF6F1E8);
  static final Color surface = oklch(0.99, 0.008, 80); // cards / list groups
  static final Color emptyCell = oklch(0.945, 0.012, 78); // untended day
  static const Color hairline = Color(0xFFEFE7D8);
  static const Color hairline2 = Color(0xFFECE4D5);
  static const Color cardBorder = Color(0xFFEFE7D8);
  static const Color tileBorder = Color(0xFFECE3D2);

  static const Color ink = Color(0xFF34302A); // headings
  static const Color ink2 = Color(0xFF3A352E); // body
  static const Color muted = Color(0xFF8A8174); // subtitles
  static const Color faint = Color(0xFFA89E8D); // eyebrows
  static const Color faint2 = Color(0xFFB6AC96);
  static const Color faint3 = Color(0xFFBDB39E);
  static const Color chevron = Color(0xFFC9BEA8);

  static const Color darkButton = Color(0xFF5C5346);
  static const Color darkButtonText = Color(0xFFFBF7F0);
  static const Color inputFill = Color(0xFFFFFDF9);
  static const Color inputBorder = Color(0xFFE6DDCC);

  /// Calm brick-red for the Edit-mode "Delete" affordance — never alarm-red.
  static final Color destructive = oklch(0.55, 0.1, 30);

  static final Color statTile = oklch(0.985, 0.009, 80);

  // The curated dusty palette — the only colors a user may assign to a thread.
  static const List<HabitHue> palette = [
    HabitHue(0.77, 0.085, 70), // dawn gold
    HabitHue(0.66, 0.105, 41), // clay
    HabitHue(0.66, 0.08, 352), // plum
    HabitHue(0.62, 0.08, 272), // indigo
    HabitHue(0.70, 0.06, 158), // sage
    HabitHue(0.68, 0.09, 22), // rose
    HabitHue(0.66, 0.075, 205), // teal
    HabitHue(0.71, 0.065, 120), // olive
    HabitHue(0.66, 0.075, 300), // orchid
    HabitHue(0.70, 0.07, 95), // warm chartreuse
  ];

  // Card shadow — very soft, warm: 0 12px 34px -24px rgba(60,45,20,.55).
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x8C3C2D14), // rgba(60,45,20,.55)
      blurRadius: 34,
      spreadRadius: -24,
      offset: Offset(0, 12),
    ),
  ];

  /// Standard rounded card surface used across screens.
  static BoxDecoration card({double radius = 24}) => BoxDecoration(
        color: surface,
        border: Border.all(color: cardBorder),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: cardShadow,
      );

  // ---- Typography ----------------------------------------------------------

  static const String serifFamily = 'Newsreader';
  static const String sansFamily = 'HankenGrotesk';

  static TextStyle serif({
    double size = 18,
    FontWeight weight = FontWeight.w500,
    bool italic = false,
    Color color = ink,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: serifFamily,
      fontSize: size,
      fontWeight: weight,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = ink2,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: sansFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Uppercase eyebrow label (date, section labels).
  static TextStyle eyebrow({Color color = faint2, double spacing = 1.6}) {
    return sans(size: 11, weight: FontWeight.w600, color: color, letterSpacing: spacing);
  }
}
