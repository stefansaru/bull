// Theme: light/dark × colour-vision mode (UIC-NAV-06).
//
// The vision modes recolour the interface only. Stamp images and colour swatches are
// drawn with their own colours in every mode: they are the evidence the reader
// studies, not decoration.
import 'package:flutter/material.dart';

import 'settings.dart';

/// Paper and ink of the 1858 stamps: cream laid paper, black and blue handstamps
/// (APP-UX-002 design tokens).
const _ink = Color(0xFF1E1E1E);
const _seed = Color(0xFF6B3A2A);

/// Vision-mode anchors, from Amethyst's palettes: Okabe-Ito blue/orange for
/// red-green safety, magenta-red/green for tritan safety, pure greys for grayscale.
ColorScheme _scheme(VisionMode mode, Brightness b) => switch (mode) {
  VisionMode.standard => ColorScheme.fromSeed(seedColor: _seed, brightness: b),
  VisionMode.redGreenSafe => ColorScheme.fromSeed(
    seedColor: const Color(0xFF0072B2),
    secondary: b == Brightness.light
        ? const Color(0xFF8A5A00)
        : const Color(0xFFEDBA47),
    brightness: b,
  ),
  VisionMode.tritanSafe => ColorScheme.fromSeed(
    seedColor: const Color(0xFFC0143C),
    secondary: b == Brightness.light
        ? const Color(0xFF1A7040)
        : const Color(0xFF9BC0AC),
    brightness: b,
  ),
  VisionMode.grayscale => ColorScheme.fromSeed(
    seedColor: const Color(0xFF808080),
    dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
    brightness: b,
  ),
};

Color _paper(VisionMode mode, Brightness b) {
  final light = b == Brightness.light;
  return switch (mode) {
    VisionMode.standard =>
      light ? const Color(0xFFF7F1E3) : const Color(0xFF151311),
    VisionMode.redGreenSafe =>
      light ? const Color(0xFFF2F6F8) : const Color(0xFF10151A),
    VisionMode.tritanSafe =>
      light ? const Color(0xFFF8F1F2) : const Color(0xFF181012),
    VisionMode.grayscale =>
      light ? const Color(0xFFF0F0F0) : const Color(0xFF121212),
  };
}

ThemeData buildTheme(
  Brightness brightness, [
  VisionMode mode = VisionMode.standard,
]) {
  final scheme = _scheme(mode, brightness);
  final light = brightness == Brightness.light;
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: _paper(mode, brightness),
    textTheme: Typography.material2021(platform: TargetPlatform.android).black
        .apply(
          bodyColor: light ? _ink : null,
          displayColor: light ? _ink : null,
        )
        .merge(light ? null : Typography.material2021().white),
    // Keyboard and D-pad focus must always be visible (H-APP-ADP-002, H-APP-ACC-001).
    focusColor: scheme.primary.withValues(alpha: 0.24),
    visualDensity: VisualDensity.standard,
  );
}

ThemeMode themeModeOf(ThemeChoice c) => switch (c) {
  ThemeChoice.automatic => ThemeMode.system,
  ThemeChoice.light => ThemeMode.light,
  ThemeChoice.dark => ThemeMode.dark,
};
