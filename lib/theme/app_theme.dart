import 'package:flutter/material.dart';

import 'package:flashcards_app/theme/app_ui_colors.dart';

class AppTheme {
  const AppTheme._();

  static final ColorScheme _lightScheme =
      ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: AppUiColors.lightPrimary,
      ).copyWith(
        primary: AppUiColors.lightPrimary,
        onPrimary: Colors.white,
        secondary: AppUiColors.lightBlue,
        onSecondary: AppUiColors.lightTextPrimary,
        tertiary: AppUiColors.lightLavender,
        onTertiary: AppUiColors.lightStudyText,
        error: AppUiColors.lightDanger,
        onError: Colors.white,
        surface: AppUiColors.lightSurface,
        onSurface: AppUiColors.lightTextPrimary,
        onSurfaceVariant: AppUiColors.lightTextSecondary,
        outline: AppUiColors.lightBorder,
        outlineVariant: AppUiColors.lightBorder.withValues(alpha: 0.72),
        primaryContainer: const Color(0xFFD8F4F6),
        onPrimaryContainer: AppUiColors.lightTextPrimary,
        secondaryContainer: const Color(0xFFE6F4FF),
        onSecondaryContainer: AppUiColors.lightTextPrimary,
        tertiaryContainer: const Color(0xFFF0E8FB),
        onTertiaryContainer: AppUiColors.lightStudyText,
        errorContainer: const Color(0xFFFFE4E4),
        onErrorContainer: AppUiColors.lightOverdue,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: const Color(0xFFFCFEFE),
        surfaceContainer: const Color(0xFFF8FBFC),
        surfaceContainerHigh: const Color(0xFFF5F7FA),
        surfaceContainerHighest: AppUiColors.lightBackgroundAlt,
        shadow: Colors.black.withValues(alpha: 0.12),
        surfaceTint: Colors.transparent,
      );

  static final ColorScheme _darkScheme =
      ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppUiColors.darkPrimary,
      ).copyWith(
        primary: AppUiColors.darkPrimary,
        onPrimary: AppUiColors.darkBackground,
        secondary: AppUiColors.darkBlue,
        onSecondary: AppUiColors.darkBackground,
        tertiary: AppUiColors.darkLavender,
        onTertiary: AppUiColors.darkBackground,
        error: AppUiColors.darkDanger,
        onError: AppUiColors.darkBackground,
        surface: AppUiColors.darkSurface,
        onSurface: AppUiColors.darkTextPrimary,
        onSurfaceVariant: AppUiColors.darkTextSecondary,
        outline: AppUiColors.darkBorder,
        outlineVariant: AppUiColors.darkBorder.withValues(alpha: 0.9),
        primaryContainer: const Color(0xFF164A52),
        onPrimaryContainer: AppUiColors.darkTextPrimary,
        secondaryContainer: const Color(0xFF203A59),
        onSecondaryContainer: AppUiColors.darkTextPrimary,
        tertiaryContainer: const Color(0xFF3A2D5D),
        onTertiaryContainer: AppUiColors.darkTextPrimary,
        errorContainer: const Color(0xFF4C2228),
        onErrorContainer: AppUiColors.darkTextPrimary,
        surfaceContainerLowest: AppUiColors.darkBackground,
        surfaceContainerLow: const Color(0xFF162235),
        surfaceContainer: const Color(0xFF1B273A),
        surfaceContainerHigh: const Color(0xFF223147),
        surfaceContainerHighest: const Color(0xFF2A3A52),
        shadow: Colors.black.withValues(alpha: 0.5),
        surfaceTint: Colors.transparent,
      );

  static ThemeData light() => _buildTheme(_lightScheme);

  static ThemeData dark() => _buildTheme(_darkScheme);

  static ThemeData _buildTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.outline),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.primary, width: 1.6),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? AppUiColors.darkBackground
          : AppUiColors.lightBackground,
      canvasColor: scheme.surface,
      splashColor: scheme.primary.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: scheme.primary),
        actionsIconTheme: IconThemeData(color: scheme.primary),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: isDark ? 1 : 2,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 15,
          height: 1.45,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF243146) : scheme.onSurface,
        contentTextStyle: TextStyle(
          color: isDark ? scheme.onSurface : scheme.surface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppUiColors.darkBackground : scheme.surface,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        helperStyle: TextStyle(color: scheme.onSurfaceVariant),
        errorStyle: TextStyle(color: scheme.error),
        border: outlineBorder,
        enabledBorder: outlineBorder,
        disabledBorder: outlineBorder,
        focusedBorder: focusedBorder,
        errorBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: focusedBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.surfaceContainerHighest,
          disabledForegroundColor: scheme.onSurfaceVariant,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.secondaryContainer,
        disabledColor: scheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
        brightness: scheme.brightness,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: scheme.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: TextStyle(color: scheme.onSurface),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        textColor: scheme.onSurface,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.16),
        circularTrackColor: scheme.primary.withValues(alpha: 0.16),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return scheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary.withValues(alpha: 0.35);
          }
          return scheme.surfaceContainerHighest;
        }),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.24),
        selectionHandleColor: scheme.primary,
      ),
    );
  }
}
