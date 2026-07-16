import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiException implements Exception {
  final int? status;
  final String code;
  final String? message;
  ApiException(this.code, {this.status, this.message});
  @override
  String toString() => 'ApiException($code${status != null ? ' [$status]' : ''})';
}

class ApiClient {
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  Map<String, String> _headers({bool json = true}) {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  Uri _u(String path, [Map<String, dynamic>? q]) {
    final base = Uri.parse(AppConfig.apiBase);
    return base.replace(path: path, queryParameters: q?.map((k, v) => MapEntry(k, '$v')));
  }

  Future<dynamic> _decode(http.Response r) async {
    final body = r.body.isEmpty ? '{}' : r.body;
    dynamic data;
    try {
      data = jsonDecode(body);
    } catch (_) {
      data = body;
    }
    if (r.statusCode >= 200 && r.statusCode < 300) return data;
    final code = (data is Map && data['error'] is String) ? data['error'] as String : 'http_${r.statusCode}';
    throw ApiException(code, status: r.statusCode, message: data.toString());
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final r = await http.get(_u(path, query), headers: _headers(json: false));
    return _decode(r);
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    final r = await http.post(_u(path), headers: _headers(), body: body == null ? '{}' : jsonEncode(body));
    return _decode(r);
  }

  Future<dynamic> delete(String path) async {
    final r = await http.delete(_u(path), headers: _headers());
    return _decode(r);
  }
}
