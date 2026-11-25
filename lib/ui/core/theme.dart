import 'package:material_ui/material_ui.dart';

abstract final class AppTheme {
  // Warm teal: calm, family-friendly, readable in both modes.
  static const _seed = Color(0xFF2A9D8F);

  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seed),
  );

  static final dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
  );
}
