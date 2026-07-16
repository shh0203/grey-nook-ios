import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../api/api_client.dart';
import '../config.dart';

class ApiMessage {
  final int id;
  final int senderId;
  final String ciphertext;
  final String contentType;
  final int createdAt;
  final int? readAt;
  ApiMessage({
    required this.id,
    required this.senderId,
    required this.ciphertext,
    required this.contentType,
    required this.createdAt,
    required this.readAt,
  });
  factory ApiMessage.fromJson(Map<String, dynamic> j) => ApiMessage(
        id: j['id'] as int,
        senderId: j['sender_id'] as int,
        ciphertext: j['ciphertext'] as String,
        contentType: (j['content_type'] as String?) ?? 'text',
        createdAt: j['created_at'] as int,
        readAt: j['read_at'] as int?,
      );
  bool isMine(int myUserId) => senderId == myUserId;
}

class MessagesService {
  MessagesService(this.api);
  final ApiClient api;
  WebSocketChannel? _channel;
  StreamController<ApiMessage>? _ctrl;

  Stream<ApiMessage> connect(String token) {
    _ctrl = StreamController<ApiMessage>.broadcast();
    final wsUri = Uri.parse('${AppConfig.wsBase}?token=$token');
    _channel = WebSocketChannel.connect(wsUri);
    _channel!.stream.listen(
      (event) {
        try {
          final j = jsonDecode(event as String);
          if (j is Map && j['type'] == 'message' && j['payload'] is Map) {
            _ctrl?.add(ApiMessage.fromJson(Map<String, dynamic>.from(j['payload'] as Map)));
          }
        } catch (_) {}
      },
      onError: (e) {},
      onDone: () {},
    );
    return _ctrl!.stream;
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    await _ctrl?.close();
    _channel = null;
    _ctrl = null;
  }

  Future<List<ApiMessage>> list({int? sinceId, int limit = 200}) async {
    final r = await api.get('/api/messages', query: {
      if (sinceId != null) 'since': sinceId,
      'limit': limit,
    });
    return (r as List).map((e) => ApiMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ApiMessage> send(String ciphertext, {String contentType = 'text'}) async {
    final r = await api.post('/api/messages', {'ciphertext': ciphertext, 'contentType': contentType});
    return ApiMessage.fromJson(r as Map<String, dynamic>);
  }

  Future<void> markRead(int id) async {
    await api.post('/api/messages/$id/read');
  }
}
