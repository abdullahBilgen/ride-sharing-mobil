import 'package:flutter/material.dart';

abstract final class RideColors {
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E2F);
  static const coral = Color(0xFFFF6B35);
  static const purple = Color(0xFFD946EF);
  static const muted = Color(0xFF9A9AA6);
}

ThemeData buildRideTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: RideColors.background,
  colorScheme: const ColorScheme.dark(
    primary: RideColors.coral,
    secondary: RideColors.purple,
    surface: RideColors.surface,
  ),
  useMaterial3: true,
  fontFamily: 'Inter',
  cardTheme: CardThemeData(
    color: RideColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: BorderSide(color: Colors.white.withValues(alpha: .08)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: RideColors.surface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
  ),
);
