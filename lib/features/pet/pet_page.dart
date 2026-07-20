import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/domain_services.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

class PetPage extends ConsumerStatefulWidget {
  const PetPage({super.key});
  @override
  ConsumerState<PetPage> createState() => _PetPageState();
}

class _PetPageState extends ConsumerState<PetPage> {
  Pet? _pet;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await ref.read(petServiceProvider).get();
      setState(() => _pet = p);
    } catch (e) {
      setState(() => _error = '$e');
    }
  }

  Future<void> _act(String action) async {
    setState(() => _busy = true);
    try {
      final p = await ref.read(petServiceProvider).action(action);
      setState(() => _pet = p);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失败: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _mood(int m) {
    if (m >= 80) return '超开心 😺';
    if (m >= 50) return '心情不错 😸';
    if (m >= 20) return '有点闷 😿';
    return '需要陪伴 😾';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(_pet?.petName ?? 'Nook', style: const TextStyle(color: AppColors.butterDeep)),
        iconTheme: const IconThemeData(color: AppColors.butterDeep),
      ),
      body: _pet == null
          ? Center(
              child: _error != null
                  ? Padding(padding: const EdgeInsets.all(16), child: Text(_error!, style: const TextStyle(color: Colors.red)))
                  : const CircularProgressIndicator(color: AppColors.butterDeep),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(color: AppColors.butter, borderRadius: BorderRadius.circular(90)),
                    alignment: Alignment.center,
                    child: const Text('🐱', style: TextStyle(fontSize: 110)),
                  ),
                  const SizedBox(height: 16),
                  Text(_mood(_pet!.mood), style: AppTypography.headlineMedium.copyWith(color: AppColors.butterDeep)),
                  const SizedBox(height: 32),
                  _Stat(label: '饱腹', value: _pet!.hunger, emoji: '🍚'),
                  const SizedBox(height: 12),
                  _Stat(label: '心情', value: _pet!.mood, emoji: '💛'),
                  const SizedBox(height: 12),
                  _Stat(label: '亲密度', value: _pet!.intimacy, emoji: '💞'),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Action(emoji: '🍚', label: '喂食', onTap: _busy ? null : () => _act('feed')),
                      _Action(emoji: '🧶', label: '玩耍', onTap: _busy ? null : () => _act('play')),
                      _Action(emoji: '🫳', label: '摸摸', onTap: _busy ? null : () => _act('pet')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('两个人一起照顾才升级得快哦', style: AppTypography.caption),
                ],
              ),
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.emoji});
  final String label;
  final int value;
  final String emoji;
  @override
  Widget build(BuildContext context) {
    final color = value > 60 ? AppColors.butterDeep : value > 30 ? AppColors.butter : AppColors.honey.withOpacity(0.4);
    return Row(
      children: [
        SizedBox(width: 30, child: Text(emoji, style: const TextStyle(fontSize: 22))),
        SizedBox(width: 60, child: Text(label, style: AppTypography.bodyMedium)),
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadii.sm,
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 12,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 30, child: Text('$value', textAlign: TextAlign.right, style: AppTypography.caption)),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.emoji, required this.label, this.onTap});
  final String emoji;
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.butter,
              borderRadius: AppRadii.md,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}
