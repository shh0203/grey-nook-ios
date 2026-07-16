/// Grey Nook — runtime config
/// Override with --dart-define=GREY_NOOK_API_BASE=...
class AppConfig {
  static const String apiBase = String.fromEnvironment(
    'GREY_NOOK_API_BASE',
    defaultValue: 'http://47.76.240.99:3000',
  );
  static const String wsBase = String.fromEnvironment(
    'GREY_NOOK_WS_BASE',
    defaultValue: 'ws://47.76.240.99:3000/ws',
  );
  static const String appName = 'Grey Nook';
  static const String petName = 'Nook';
  static const String anniversary = '2025-05-01'; // default; user can change in app
}
