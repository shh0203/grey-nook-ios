# assets/fonts/

Custom fonts would live here once the design system settles on a
non-system typeface. The demo currently uses the iOS / Android system
font (`.SF Pro Text` on iOS, `Roboto` on Android) to keep the first
run lightweight.

When a font is added:
1. Drop the `.ttf` / `.otf` files here
2. Declare them under `flutter.fonts:` in `pubspec.yaml`
3. Update `AppTypography._fontFamily` in `lib/theme/app_typography.dart`
