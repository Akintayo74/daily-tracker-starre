import 'dart:math' as math;
import 'package:flutter/painting.dart';

/// Converts an OKLCH color to a Flutter [Color].
///
/// OKLCH is the source of truth for the Habit Tapestry palette (see the design
/// handoff): habit hues share lightness/chroma discipline and vary mainly in
/// hue so any combination weaves harmoniously. We convert
/// OKLCH → OKLab → linear sRGB → gamma-encoded sRGB at runtime so the values in
/// the spec can be transcribed verbatim.
///
/// [l] is perceptual lightness (0..1), [c] is chroma, [h] is hue in degrees,
/// [alpha] is opacity (0..1).
Color oklch(double l, double c, double h, [double alpha = 1.0]) {
  final hr = h * math.pi / 180.0;
  final a = c * math.cos(hr);
  final b = c * math.sin(hr);

  // OKLab -> approximate cone responses (cube of the l'/m'/s' terms).
  final l_ = l + 0.3963377774 * a + 0.2158037573 * b;
  final m_ = l - 0.1055613458 * a - 0.0638541728 * b;
  final s_ = l - 0.0894841775 * a - 1.2914855480 * b;

  final lc = l_ * l_ * l_;
  final mc = m_ * m_ * m_;
  final sc = s_ * s_ * s_;

  // Linear sRGB.
  final rLin = 4.0767416621 * lc - 3.3077115913 * mc + 0.2309699292 * sc;
  final gLin = -1.2684380046 * lc + 2.6097574011 * mc - 0.3413193965 * sc;
  final bLin = -0.0041960863 * lc - 0.7034186147 * mc + 1.7076147010 * sc;

  return Color.fromARGB(
    (alpha.clamp(0.0, 1.0) * 255).round(),
    _toByte(rLin),
    _toByte(gLin),
    _toByte(bLin),
  );
}

int _toByte(double linear) {
  // Linear sRGB -> gamma-encoded sRGB.
  final v = linear <= 0.0031308
      ? 12.92 * linear
      : 1.055 * math.pow(linear, 1 / 2.4) - 0.055;
  return (v.clamp(0.0, 1.0) * 255).round();
}
