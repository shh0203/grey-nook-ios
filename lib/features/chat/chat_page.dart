import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../api/messages_service.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final List<ApiMessage> _messages = [];
  final _input = TextEditingController();
  final _scrollCtrl = ScrollController();
  StreamSubscription? _sub;
  bool _loaded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final api = ref.read(apiClientProvider);
    final svc = ref.read(messagesServiceProvider);
    try {
      final list = await svc.list();
      setState(() {
        _messages
          ..clear()
          ..addAll(list);
        _loaded = true;
      });
      _scrollToBottom();
      if (api.token != null) {
        _sub?.cancel();
        _sub = svc.connect(api.token!).listen((m) {
          if (_messages.any((e) => e.id == m.id)) return;
          setState(() => _messages.add(m));
          _scrollToBottom();
        });
      }
    } catch (e) {
      setState(() {
        _error = '$e';
        _loaded = true;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final svc = ref.read(messagesServiceProvider);
    try {
      final m = await svc.send(text);
      setState(() {
        _messages.add(m);
        _input.clear();
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('发送失败: $e')));
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _input.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appAuthProvider);
    final me = state.user;
    final couple = state.couple;
    if (me == null || couple == null) return const SizedBox.shrink();
    final partnerName = me.id == couple.userA ? (couple.nameB ?? 'bb') : (couple.nameA ?? 'bb');
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(radius: 16, backgroundColor: AppColors.butter, child: Text('🐱', style: TextStyle(fontSize: 18))),
            const SizedBox(width: 8),
            Text(partnerName, style: const TextStyle(color: AppColors.butterDeep)),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.butterDeep),
      ),
      body: Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              color: Colors.red.withOpacity(0.1),
              padding: const EdgeInsets.all(8),
              child: Text('提示: $_error', style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
          Expanded(
            child: !_loaded
                ? const Center(child: CircularProgressIndicator(color: AppColors.butterDeep))
                : _messages.isEmpty
                    ? const Center(child: Text('说点什么吧～', style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, i) {
                          final m = _messages[i];
                          final mine = m.isMine(me.id);
                          final showHeader = i == 0 || !_sameDay(_messages[i - 1].createdAt, m.createdAt);
                          return Column(
                            children: [
                              if (showHeader) _DayHeader(ts: m.createdAt),
                              Align(
                                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  constraints: const BoxConstraints(maxWidth: 280),
                                  decoration: BoxDecoration(
                                    color: mine ? AppColors.butterDeep : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(mine ? 16 : 4),
                                      bottomRight: Radius.circular(mine ? 4 : 16),
                                    ),
                                  ),
                                  child: Text(
                                    m.ciphertext, // TODO: decrypt for display in v1
                                    style: TextStyle(color: mine ? Colors.white : AppColors.butterDeep),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0x14000000))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: InputDecoration(
                        hintText: '跟 $partnerName 说点啥...',
                        filled: true,
                        fillColor: AppColors.cream,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: AppRadii.lg, borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send, color: AppColors.butterDeep),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _sameDay(int a, int b) {
    final da = DateTime.fromMillisecondsSinceEpoch(a);
    final db = DateTime.fromMillisecondsSinceEpoch(b);
    return da.year == db.year && da.month == db.month && da.day == db.day;
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.ts});
  final int ts;
  @override
  Widget build(BuildContext context) {
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    String label;
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      label = '今天';
    } else if (d.year == now.year && d.month == now.month && d.day == now.day - 1) {
      label = '昨天';
    } else {
      label = DateFormat('MM/dd').format(d);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(child: Text(label, style: AppTypography.caption)),
    );
  }
}
