import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

class CoupleScreen extends ConsumerStatefulWidget {
  const CoupleScreen({super.key});
  @override
  ConsumerState<CoupleScreen> createState() => _CoupleScreenState();
}

class _CoupleScreenState extends ConsumerState<CoupleScreen> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _create() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(coupleServiceProvider).createInvite();
      await ref.read(appAuthProvider.notifier).refreshCouple();
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _join() async {
    final code = _code.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = '邀请码不能为空');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(coupleServiceProvider).joinInvite(code);
      await ref.read(appAuthProvider.notifier).refreshCouple();
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
        title: const Text('配对你的 bb', style: TextStyle(color: AppColors.butterDeep)),
        iconTheme: const IconThemeData(color: AppColors.butterDeep),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                couple?.userB == null
                    ? '你们还没绑定。让一个人创建邀请码，另一个人输入。'
                    : '已绑定 🎉',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: 24),
              if (couple?.inviteCode != null && couple?.userB == null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.lg,
                    border: Border.all(color: AppColors.butter, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text('你的邀请码', style: AppTypography.bodyMedium),
                      const SizedBox(height: 8),
                      Text(
                        couple!.inviteCode!,
                        style: AppTypography.displayLarge.copyWith(letterSpacing: 4, color: AppColors.butterDeep),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: couple.inviteCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('邀请码已复制，发给 TA 吧')),
                          );
                        },
                        icon: const Icon(Icons.copy, color: AppColors.honey),
                        label: const Text('复制', style: TextStyle(color: AppColors.honey)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('等 TA 输入后这里会自动显示 🎉', style: AppTypography.caption),
              ] else if (couple?.userB == null) ...[
                FilledButton(
                  onPressed: _busy ? null : _create,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.butterDeep,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                  ),
                  child: Text(_busy ? '生成中...' : '我是先来的，创建邀请码', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text('我有 TA 的邀请码', style: AppTypography.labelLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: _code,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: '邀请码',
                    hintText: '比如 A1B2C3D4',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _busy ? null : _join,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.honey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                  ),
                  child: Text(_busy ? '加入中...' : '加入', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
