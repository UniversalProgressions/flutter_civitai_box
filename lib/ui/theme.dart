import 'package:flutter/material.dart';

import '../settings/nsfw_settings.dart';

// ---------------------------------------------------------------------------
// Color Schemes
// ---------------------------------------------------------------------------

const _sfwColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF4A90D9),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD6E8FB),
  onPrimaryContainer: Color(0xFF0D2136),
  secondary: Color(0xFF6B7D8E),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFE0E7EF),
  onSecondaryContainer: Color(0xFF1A2A38),
  tertiary: Color(0xFF34C759),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFD0F5DA),
  onTertiaryContainer: Color(0xFF0A3D16),
  error: Color(0xFFDC3545),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFDE0E3),
  onErrorContainer: Color(0xFF3D0A10),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF1A1D22),
  surfaceContainerHighest: Color(0xFFE8ECF1),
  onSurfaceVariant: Color(0xFF43474E),
  outline: Color(0xFFD1D7E0),
  outlineVariant: Color(0xFFC4CAD3),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF2F3136),
  onInverseSurface: Color(0xFFF0F1F4),
  inversePrimary: Color(0xFFA8C8ED),
  surfaceTint: Color(0xFF4A90D9),
);

const _nsfwColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFB44D8F),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF3D1B3D),
  onPrimaryContainer: Color(0xFFF7D8EB),
  secondary: Color(0xFFE85D75),
  onSecondary: Color(0xFF1A0008),
  secondaryContainer: Color(0xFF4D1A2A),
  onSecondaryContainer: Color(0xFFFDD8E0),
  tertiary: Color(0xFFFF6B9D),
  onTertiary: Color(0xFF1A0010),
  tertiaryContainer: Color(0xFF4D1A35),
  onTertiaryContainer: Color(0xFFFFD8E8),
  error: Color(0xFFFF4D6A),
  onError: Color(0xFF2D0010),
  errorContainer: Color(0xFF4D1A28),
  onErrorContainer: Color(0xFFFFD8E0),
  surface: Color(0xFF1A1424),
  onSurface: Color(0xFFEDE4F2),
  surfaceContainerHighest: Color(0xFF251D33),
  onSurfaceVariant: Color(0xFFC4BED0),
  outline: Color(0xFF302540),
  outlineVariant: Color(0xFF4A4058),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFEDE4F2),
  onInverseSurface: Color(0xFF1A1424),
  inversePrimary: Color(0xFFD49AC0),
  surfaceTint: Color(0xFFB44D8F),
);

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Pre-built [ThemeData] for each NSFW filter mode.
final sfwTheme = ThemeData(colorScheme: _sfwColorScheme, useMaterial3: true);

final nsfwTheme = ThemeData(colorScheme: _nsfwColorScheme, useMaterial3: true);

/// Returns the [ThemeData] for the given [NsfwFilter].
///
/// Only two palettes exist: SFW (light) and NSFW (dark).
/// The "All" filter shares the NSFW palette.
ThemeData themeForMode(NsfwFilter mode) => switch (mode) {
  NsfwFilter.no => sfwTheme,
  NsfwFilter.yes || NsfwFilter.all => nsfwTheme,
};
