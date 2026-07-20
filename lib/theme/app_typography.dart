import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale for Grey Nook.
///
/// The app uses the system font on iOS / Android for a clean baseline.
/// A custom rounded font can be wired in later via `pubspec.yaml`
/// without touching the screens — they only depend on these styles.
class AppTypography {
  AppTypography._();

  static const String _fontFamily = '.SF Pro Text';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Body text used in messages, paragraphs.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Caption / timestamps / metadata.
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Inline label / button label.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.onBrand,
    letterSpacing: 0.1,
  );

  /// Applies the typography to a [TextTheme] so Material widgets pick
  /// the right defaults.
  static TextTheme toTextTheme() {
    return const TextTheme(
      displayLarge: displayLarge,
      headlineMedium: headlineMedium,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      labelLarge: labelLarge,
      bodySmall: caption,
    );
  }

  // ---- Backward-compat aliases ----------------------------------------
  // Older feature code referenced the previous typography names. Keep
  // these so the build stays green while the rest of the app migrates.
  static const TextStyle h1 = displayLarge;
  static const TextStyle h2 = headlineMedium;
  static const TextStyle h3 = labelLarge;
  static const TextStyle body = bodyMedium;
}
