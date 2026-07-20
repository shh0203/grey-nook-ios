import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../api/domain_services.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

class MemoriesPage extends ConsumerStatefulWidget {
  const MemoriesPage({super.key});
  @override
  ConsumerState<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends ConsumerState<MemoriesPage> {
  late Future<List<Memory>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = ref.read(memoriesServiceProvider).list();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appAuthProvider);
    final couple = state.couple;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text('我们的纪念', style: TextStyle(color: AppColors.butterDeep)),
        iconTheme: const IconThemeData(color: AppColors.butterDeep),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.butterDeep),
            onPressed: () => _showAdd(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Memory>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.butterDeep));
          }
          final items = snap.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (couple?.anniversaryDate != null) _AnniversaryCard(iso: couple!.anniversaryDate!),
              const SizedBox(height: 16),
              if (items.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('还没有纪念日～点 + 添加一个', style: AppTypography.caption),
                  ),
                )
              else
                ...items.map((m) => Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                      child: ListTile(
                        leading: const Text('📌', style: TextStyle(fontSize: 22)),
                        title: Text(m.title, style: AppTypography.labelLarge),
                        subtitle: Text(m.memoryDate + (m.note != null ? ' · ${m.note}' : '')),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () async {
                            await ref.read(memoriesServiceProvider).remove(m.id);
                            setState(_reload);
                          },
                        ),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }

  void _showAdd(BuildContext context) {
    final title = TextEditingController();
    final note = TextEditingController();
    DateTime picked = DateTime.now();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('添加纪念日', style: AppTypography.headlineMedium),
              const SizedBox(height: 12),
              TextField(controller: title, decoration: const InputDecoration(labelText: '标题', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
              const SizedBox(height: 8),
              TextField(controller: note, decoration: const InputDecoration(labelText: '备注（可选）', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final d = await showDatePicker(context: ctx, initialDate: picked, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (d != null) setS(() => picked = d);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat('yyyy-MM-dd').format(picked)),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.butterDeep, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  await ref.read(memoriesServiceProvider).add(
                        title: title.text.trim(),
                        date: DateFormat('yyyy-MM-dd').format(picked),
                        note: note.text.trim().isEmpty ? null : note.text.trim(),
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                  setState(_reload);
                },
                child: Text('保存', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnniversaryCard extends StatelessWidget {
  const _AnniversaryCard({required this.iso});
  final String iso;
  @override
  Widget build(BuildContext context) {
    final start = DateTime.parse(iso);
    final now = DateTime.now();
    final days = now.difference(start).inDays;
    final next = DateTime(now.year, start.month, start.day);
    final daysToNext = next.isBefore(now) ? DateTime(now.year + 1, start.month, start.day).difference(now).inDays : next.difference(now).inDays;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.butter, borderRadius: AppRadii.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('在一起第 $days 天', style: AppTypography.headlineMedium.copyWith(color: AppColors.butterDeep)),
          const SizedBox(height: 4),
          Text('距离下个纪念日还有 $daysToNext 天', style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
