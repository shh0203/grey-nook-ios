import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../chat/chat_page.dart';
import '../memories/memories_page.dart';
import '../pet/pet_page.dart';
import '../mood/mood_page.dart';
import '../tasks/tasks_page.dart';
import '../letters/letters_page.dart';
import '../album/album_page.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appAuthProvider);
    final me = state.user!;
    final couple = state.couple!;
    final pages = <Widget>[
      const ChatPage(),
      const MemoriesPage(),
      const PetPage(),
      const MoodPage(),
      const TasksPage(),
      const LettersPage(),
      const AlbumPage(),
    ];
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(child: pages[_idx]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        backgroundColor: AppColors.cream,
        indicatorColor: AppColors.butter,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: '聊天'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: '纪念'),
          NavigationDestination(icon: Icon(Icons.pets), selectedIcon: Icon(Icons.pets, color: AppColors.brownDeep), label: '小猫'),
          NavigationDestination(icon: Icon(Icons.mood_outlined), selectedIcon: Icon(Icons.mood), label: '心情'),
          NavigationDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: '任务'),
          NavigationDestination(icon: Icon(Icons.mail_outline), selectedIcon: Icon(Icons.mail), label: '情书'),
          NavigationDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library), label: '相册'),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Text('🐱')),
                title: Text(me.displayName),
                subtitle: Text(me.email),
              ),
              ListTile(
                leading: const Text('💞', style: TextStyle(fontSize: 22)),
                title: const Text('纪念日'),
                subtitle: Text(couple.anniversaryDate ?? '暂未设置'),
                trailing: const Icon(Icons.edit, size: 18),
                onTap: () async {
                  Navigator.pop(context);
                  await _editAnniversary(context, ref);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('退出登录'),
                onTap: () async {
                  await ref.read(appAuthProvider.notifier).logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editAnniversary(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final iso = picked.toIso8601String().split('T').first;
    try {
      await ref.read(coupleServiceProvider).setAnniversary(iso);
      await ref.read(appAuthProvider.notifier).refreshCouple();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('纪念日已设为 $iso')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('设置失败: $e')));
      }
    }
  }
}
