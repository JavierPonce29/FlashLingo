import 'package:flutter/material.dart';

class AppUiColors {
  const AppUiColors._();

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color info(BuildContext context) =>
      isDark(context) ? Colors.lightBlue.shade300 : Colors.blue.shade700;

  static Color warning(BuildContext context) =>
      isDark(context) ? Colors.amber.shade300 : Colors.orange.shade700;

  static Color success(BuildContext context) =>
      isDark(context) ? Colors.green.shade300 : Colors.green.shade700;

  static Color danger(BuildContext context) =>
      isDark(context) ? Colors.red.shade300 : Colors.red.shade700;

  static Color mutedText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color panelFill(
    BuildContext context,
    Color accent, {
    double lightAlpha = 0.08,
    double darkAlpha = 0.16,
  }) {
    return accent.withValues(alpha: isDark(context) ? darkAlpha : lightAlpha);
  }

  static Color panelBorder(
    BuildContext context,
    Color accent, {
    double lightAlpha = 0.24,
    double darkAlpha = 0.44,
  }) {
    return accent.withValues(alpha: isDark(context) ? darkAlpha : lightAlpha);
  }

  static Color onAccent(Color accent) {
    final brightness = ThemeData.estimateBrightnessForColor(accent);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}
