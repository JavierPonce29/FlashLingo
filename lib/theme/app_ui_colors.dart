import 'package:flutter/material.dart';

class AppUiColors {
  const AppUiColors._();

  static const Color lightPrimary = Color(0xFF40C0CC);
  static const Color lightMint = Color(0xFF8EDFD4);
  static const Color lightBlue = Color(0xFF8CCBFF);
  static const Color lightPeach = Color(0xFFFFC19E);
  static const Color lightLavender = Color(0xFFCDB7F0);
  static const Color lightSuccess = Color(0xFF4FB477);
  static const Color lightDanger = Color(0xFFF66B6B);
  static const Color lightOverdue = Color(0xFFD83A3A);
  static const Color lightLearning = Color(0xFFFF8A00);
  static const Color lightTextPrimary = Color(0xFF374151);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightBackground = Color(0xFFF3F4F6);
  static const Color lightBackgroundAlt = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightStudyWord = Color(0xFF6B4DE6);
  static const Color lightStudyText = Color(0xFF2E246B);
  static const Color lightStudyLine = Color(0xFFE6DFFF);

  static const Color darkPrimary = Color(0xFF4BD3E0);
  static const Color darkMint = Color(0xFF6EE4D7);
  static const Color darkBlue = Color(0xFF7EB6FF);
  static const Color darkPeach = Color(0xFFFFB68C);
  static const Color darkLavender = Color(0xFFD1B8FF);
  static const Color darkSuccess = Color(0xFF4ADE80);
  static const Color darkDanger = Color(0xFFFF5C5C);
  static const Color darkOverdue = Color(0xFFFF6B6B);
  static const Color darkLearning = Color(0xFFFFB020);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkBackgroundAlt = Color(0xFF162235);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextPrimary = Color(0xFFE2E8F0);
  static const Color darkStudyWord = darkLavender;
  static const Color darkStudyText = darkTextPrimary;
  static const Color darkStudyLine = darkBorder;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color _resolve(
    BuildContext context, {
    required Color light,
    required Color dark,
  }) => isDark(context) ? dark : light;

  static Color primary(BuildContext context) =>
      _resolve(context, light: lightPrimary, dark: darkPrimary);

  static Color secondary(BuildContext context) =>
      _resolve(context, light: lightBlue, dark: darkBlue);

  static Color mint(BuildContext context) =>
      _resolve(context, light: lightMint, dark: darkMint);

  static Color peach(BuildContext context) =>
      _resolve(context, light: lightPeach, dark: darkPeach);

  static Color lavender(BuildContext context) =>
      _resolve(context, light: lightLavender, dark: darkLavender);

  static Color info(BuildContext context) => primary(context);

  static Color warning(BuildContext context) =>
      _resolve(context, light: lightLearning, dark: darkLearning);

  static Color success(BuildContext context) =>
      _resolve(context, light: lightSuccess, dark: darkSuccess);

  static Color danger(BuildContext context) =>
      _resolve(context, light: lightDanger, dark: darkDanger);

  static Color overdue(BuildContext context) =>
      _resolve(context, light: lightOverdue, dark: darkOverdue);

  static Color studyWord(BuildContext context) =>
      _resolve(context, light: lightStudyWord, dark: darkStudyWord);

  static Color studyText(BuildContext context) =>
      _resolve(context, light: lightStudyText, dark: darkStudyText);

  static Color studyLine(BuildContext context) =>
      _resolve(context, light: lightStudyLine, dark: darkStudyLine);

  static Color mutedText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color border(BuildContext context) =>
      Theme.of(context).colorScheme.outline;

  static Color scrim(BuildContext context) =>
      (isDark(context) ? darkBackground : Colors.black).withValues(
        alpha: isDark(context) ? 0.72 : 0.24,
      );

  static Color chartNewActual(BuildContext context) => lavender(context);

  static Color chartDuration(BuildContext context) => primary(context);

  static Color panelFill(
    BuildContext context,
    Color accent, {
    double lightAlpha = 0.12,
    double darkAlpha = 0.18,
  }) {
    return accent.withValues(alpha: isDark(context) ? darkAlpha : lightAlpha);
  }

  static Color panelBorder(
    BuildContext context,
    Color accent, {
    double lightAlpha = 0.28,
    double darkAlpha = 0.44,
  }) {
    return accent.withValues(alpha: isDark(context) ? darkAlpha : lightAlpha);
  }

  static Color onAccent(Color accent) {
    final brightness = ThemeData.estimateBrightnessForColor(accent);
    return brightness == Brightness.dark ? Colors.white : lightTextPrimary;
  }
}
