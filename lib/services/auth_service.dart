import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';

class AuthUser {
  final int id;
  final String email;
  final String displayName;
  AuthUser({required this.id, required this.email, required this.displayName});
  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: j['id'] as int,
        email: j['email'] as String,
        displayName: j['displayName'] as String,
      );
  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'displayName': displayName};
}

class AuthService {
  AuthService(this.api);
  final ApiClient api;
  static const _kToken = 'grey_nook_token';
  static const _kUser = 'grey_nook_user';

  Future<AuthUser> register({required String email, required String password, required String displayName}) async {
    final r = await api.post('/api/auth/register', {
      'email': email,
      'password': password,
      'displayName': displayName,
    });
    final token = r['token'] as String;
    final user = AuthUser.fromJson(r['user'] as Map<String, dynamic>);
    await _persist(token, user);
    api.setToken(token);
    return user;
  }

  Future<AuthUser> login({required String email, required String password}) async {
    final r = await api.post('/api/auth/login', {'email': email, 'password': password});
    final token = r['token'] as String;
    final user = AuthUser.fromJson(r['user'] as Map<String, dynamic>);
    await _persist(token, user);
    api.setToken(token);
    return user;
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
    await p.remove(_kUser);
    api.setToken(null);
  }

  Future<({String? token, AuthUser? user})> loadSaved() async {
    final p = await SharedPreferences.getInstance();
    final token = p.getString(_kToken);
    final userJson = p.getString(_kUser);
    if (token == null || userJson == null) return (token: null, user: null);
    api.setToken(token);
    final u = AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    return (token: token, user: u);
  }

  Future<void> _persist(String token, AuthUser user) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, token);
    await p.setString(_kUser, jsonEncode(user.toJson()));
  }
}
