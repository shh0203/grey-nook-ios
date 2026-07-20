import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/domain_services.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

class MoodPage extends ConsumerStatefulWidget {
  const MoodPage({super.key});
  @override
  ConsumerState<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends ConsumerState<MoodPage> {
  final _moods = ['😄', '🙂', '😐', '😢', '🥰', '😴', '🤩', '😡', '🥺'];
  Future<List<Mood>>? _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(moodsServiceProvider).list();
  }

  Future<void> _add(String emoji) async {
    await ref.read(moodsServiceProvider).add(mood: emoji);
    setState(() => _future = ref.read(moodsServiceProvider).list());
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(appAuthProvider).user;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text('今天心情', style: TextStyle(color: AppColors.butterDeep)),
        iconTheme: const IconThemeData(color: AppColors.butterDeep),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _moods.map((e) => GestureDetector(
                onTap: () => _add(e),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadii.md),
                  alignment: Alignment.center,
                  child: Text(e, style: const TextStyle(fontSize: 28)),
                ),
              )).toList(),
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<Mood>>(
              future: _future,
              builder: (ctx, snap) {
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return Center(child: Text('还没有打卡～', style: AppTypography.caption));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final m = list[i];
                    final mine = m.userId == me?.id;
                    return ListTile(
                      leading: Text(m.mood, style: const TextStyle(fontSize: 28)),
                      title: Text(mine ? '你' : 'TA'),
                      subtitle: Text(DateTime.fromMillisecondsSinceEpoch(m.createdAt).toString().split('.').first),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
