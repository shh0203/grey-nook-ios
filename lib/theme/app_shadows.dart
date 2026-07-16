import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Subtle elevation / shadow tokens.
///
/// Grey Nook leans on a flat aesthetic — most surfaces use no shadow at
/// all. Cards that *do* float (FAB, modals, action sheets) get one of
/// these soft, warm shadows so they read as physical but never harsh.
class AppShadows {
  AppShadows._();

  /// Very subtle shadow used on the chat composer and a few cards.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  /// Standard card / FAB shadow. Warm tinted, low opacity.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A8B7F66),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  /// Stronger shadow for modals, popovers.
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1F8B7F66),
      offset: Offset(0, 12),
      blurRadius: 28,
    ),
  ];

  /// Helper to apply via [BoxDecoration].
  static BoxDecoration card({
    Color color = AppColors.card,
    double radius = 16,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: sm,
    );
  }
}
