/// Spacing & corner radius tokens.
///
/// Centralised so the entire app speaks the same "soft" geometry.
class AppRadii {
  AppRadii._();

  /// Tiny radius — 4px. Used on small chips, check marks.
  static const double xs = 4;

  /// Small — 8px. Used on tags, smaller cards.
  static const double sm = 8;

  /// Medium — 12px. Used on inputs, list rows.
  static const double md = 12;

  /// Large — 16px. Used on cards.
  static const double lg = 16;

  /// Extra large — 20px. Used on big cards / hero blocks.
  static const double xl = 20;

  /// Pill — used on bubbles, badges, action chips.
  static const double pill = 999;

  /// Specifically used for the chat bubble geometry.
  /// Asymmetric (top corners larger) gives the familiar messenger feel.
  static const double bubbleSelf = 20;
  static const double bubbleOther = 20;
}

/// Spacing scale. Use these names rather than raw numbers in widgets so
/// the rhythm stays consistent.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}
