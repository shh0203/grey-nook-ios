import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/domain_services.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

class LettersPage extends ConsumerStatefulWidget {
  const LettersPage({super.key});
  @override
  ConsumerState<LettersPage> createState() => _LettersPageState();
}

class _LettersPageState extends ConsumerState<LettersPage> {
  Future<List<Letter>>? _future;
  @override
  void initState() {
    super.initState();
    _future = ref.read(lettersServiceProvider).list();
  }

  Future<void> _write() async {
    final ctrl = TextEditingController();
    DateTime? unlockAt;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('写一封情书', style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '说点平时不好意思当面说的...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(context: ctx, initialDate: DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365 * 5)));
                      if (d != null) setS(() => unlockAt = d);
                    },
                    icon: const Icon(Icons.lock_clock),
                    label: Text(unlockAt == null ? '设置解锁日期' : '${unlockAt!.year}-${unlockAt!.month.toString().padLeft(2, '0')}-${unlockAt!.day.toString().padLeft(2, '0')}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.butterDeep, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () async {
                if (ctrl.text.trim().isEmpty) return;
                await ref.read(lettersServiceProvider).add(
                      ctrl.text,
                      unlockAt: unlockAt?.millisecondsSinceEpoch,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                setState(() => _future = ref.read(lettersServiceProvider).list());
              },
              child: Text('封存', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
            ),
          ],
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(appAuthProvider).user;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text('情书', style: TextStyle(color: AppColors.butterDeep)),
        iconTheme: const IconThemeData(color: AppColors.butterDeep),
        actions: [IconButton(icon: const Icon(Icons.add, color: AppColors.butterDeep), onPressed: _write)],
      ),
      body: FutureBuilder<List<Letter>>(
        future: _future,
        builder: (ctx, snap) {
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('还没有情书～点 + 写一封', style: AppTypography.caption, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final l = list[i];
              final mine = l.senderId == me?.id;
              final locked = l.unlockAt != null && DateTime.now().millisecondsSinceEpoch < l.unlockAt!;
              return Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                child: ListTile(
                  leading: Text(locked ? '🔒' : (mine ? '💌' : '✉️'), style: const TextStyle(fontSize: 24)),
                  title: Text(mine ? '你写的' : 'TA 写的'),
                  subtitle: Text(locked
                      ? '将在 ${DateTime.fromMillisecondsSinceEpoch(l.unlockAt!).toString().split(' ').first} 解锁'
                      : (l.unlocked ? '已读' : '未读')),
                  trailing: locked
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.visibility_outlined),
                          onPressed: () async {
                            if (!l.unlocked) await ref.read(lettersServiceProvider).open(l.id);
                            if (!ctx.mounted) return;
                            showDialog(
                              context: ctx,
                              builder: (_) => AlertDialog(
                                title: const Text('💌'),
                                content: Text(l.ciphertext),
                                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关'))],
                              ),
                            );
                          },
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
