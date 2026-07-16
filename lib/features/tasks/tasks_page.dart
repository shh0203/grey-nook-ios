import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/domain_services.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});
  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  Future<List<TaskItem>>? _future;
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = ref.read(tasksServiceProvider).list();
  }

  Future<void> _add() async {
    final t = _input.text.trim();
    if (t.isEmpty) return;
    await ref.read(tasksServiceProvider).add(t);
    _input.clear();
    setState(() => _future = ref.read(tasksServiceProvider).list());
  }

  Future<void> _toggle(int id) async {
    await ref.read(tasksServiceProvider).toggle(id);
    setState(() => _future = ref.read(tasksServiceProvider).list());
  }

  Future<void> _del(int id) async {
    await ref.read(tasksServiceProvider).remove(id);
    setState(() => _future = ref.read(tasksServiceProvider).list());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text('一起做的事', style: TextStyle(color: AppColors.brownDeep)),
        iconTheme: const IconThemeData(color: AppColors.brownDeep),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: InputDecoration(
                      hintText: '想做点什么？比如"周末去爬山"',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: AppRadii.large, borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: _add, icon: const Icon(Icons.add_circle, color: AppColors.butterDeep, size: 36)),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TaskItem>>(
              future: _future,
              builder: (ctx, snap) {
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return Center(child: Text('还没有事项～', style: AppTypography.caption));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final t = list[i];
                    return CheckboxListTile(
                      value: t.done,
                      onChanged: (_) => _toggle(t.id),
                      title: Text(t.title, style: TextStyle(decoration: t.done ? TextDecoration.lineThrough : null)),
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => _del(t.id)),
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
