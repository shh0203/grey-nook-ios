import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _registerMode = false;
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final notifier = ref.read(appAuthProvider.notifier);
    bool ok;
    if (_registerMode) {
      ok = await notifier.register(_email.text.trim(), _password.text, _name.text.trim());
    } else {
      ok = await notifier.login(_email.text.trim(), _password.text);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = ok ? null : '注册/登录失败：检查邮箱密码，或看下面错误';
    });
    final state = ref.read(appAuthProvider);
    if (state.error != null && _error == null) {
      setState(() => _error = state.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.butter,
                    borderRadius: AppRadii.large,
                  ),
                  alignment: Alignment.center,
                  child: const Text('🐱', style: TextStyle(fontSize: 48)),
                ),
                const SizedBox(height: 16),
                Text('Grey Nook', style: AppTypography.h1.copyWith(color: AppColors.brownDeep)),
                const SizedBox(height: 4),
                Text('你们的灰色小角落', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                if (_registerMode)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: '你希望我叫你什么？',
                        hintText: '比如：老公、老婆、bb',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '密码（至少 6 位）',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.butterDeep,
                      shape: RoundedRectangleBorder(borderRadius: AppRadii.medium),
                    ),
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_registerMode ? '注册' : '登录', style: AppTypography.h3.copyWith(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _registerMode = !_registerMode),
                  child: Text(
                    _registerMode ? '已有账号？去登录' : '第一次用？去注册',
                    style: AppTypography.body.copyWith(color: AppColors.brown),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
