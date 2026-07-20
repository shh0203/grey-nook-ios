import 'package:flutter/material.dart';

/// Grey Nook color palette.
///
/// Source of truth is `/workspace/grey-nook/design/colors.md`. The palette
/// favors a soft butter yellow that is easy on the eyes, balanced with
/// off-white surfaces and warm grey text. All values are tuned for a
/// "治愈系扁平" (healing / flat) feel.
class AppColors {
  AppColors._();

  // ---- Brand: 温柔淡黄 (soft butter yellow) ----------------------------
  /// The lightest brand surface. Used as the default page background
  /// so the entire app feels "wrapped in cream".
  static const Color cream = Color(0xFFFFF8E1);

  /// Primary brand color. Chat bubble background, primary buttons,
  /// key accents. Reads as warm butter, not a saturated taxi yellow.
  static const Color butter = Color(0xFFFFE082);

  /// Slightly deeper brand color. Used for pressed states, selected
  /// highlights, and the tail of outgoing chat bubbles.
  static const Color butterDeep = Color(0xFFFFD54F);

  /// Warm accent for call-to-action and unread badges. Use sparingly.
  static const Color honey = Color(0xFFFFC857);

  // ---- Surfaces / neutrals --------------------------------------------
  /// Page-level surface — same as cream but a hair lighter so cards
  /// float above the background.
  static const Color surface = Color(0xFFFFFBF1);

  /// Pure-white card / input background.
  static const Color card = Color(0xFFFFFFFF);

  /// Subtle divider / outline.
  static const Color divider = Color(0xFFEEE5C9);

  /// Soft border for inputs and cards.
  static const Color outline = Color(0xFFE7DCB8);

  // ---- Text ------------------------------------------------------------
  /// Primary text. A warm near-black that pairs with cream.
  static const Color textPrimary = Color(0xFF3A352D);

  /// Secondary text — captions, timestamps.
  static const Color textSecondary = Color(0xFF8B7F66);

  /// Tertiary text — placeholders.
  static const Color textTertiary = Color(0xFFB8AE91);

  /// Text rendered on top of [butter] / [butterDeep] — usually near-black
  /// for legibility against the soft yellow.
  static const Color onBrand = Color(0xFF3A352D);

  // ---- Semantic --------------------------------------------------------
  /// "Ta" side — the partner's bubble. A cool, off-white that
  /// contrasts gently with the cream background.
  static const Color bubbleOther = Color(0xFFFFFFFF);

  /// Self side — outgoing bubble. Brand butter.
  static const Color bubbleSelf = Color(0xFFFFE082);

  /// Love / hearts / subtle accent.
  static const Color love = Color(0xFFE89B9B);

  /// Status colors (kept very soft to match the palette).
  static const Color success = Color(0xFF8FBF8F);
  static const Color warning = Color(0xFFE6B96B);
  static const Color danger = Color(0xFFD98282);

  // ---- Misc ------------------------------------------------------------
  /// Scrim used for modal sheets and menus.
  static const Color scrim = Color(0x33000000);

  // ---- Backward-compat aliases ----------------------------------------
  // Older feature code referenced the previous palette names. Keep these
  // so the build stays green while the rest of the app migrates.
  static const Color brown = honey;
  static const Color brownDeep = butterDeep;
  static const Color brownLight = butter;
}
