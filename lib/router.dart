import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_screens.dart';
import 'features/couple/couple_screen.dart';
import 'features/home/home_shell.dart';
import 'providers/app_state.dart';

class _AuthGate extends ConsumerWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appAuthProvider);
    if (state.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.user == null) {
      return const LoginScreen();
    }
    if (state.couple == null || !state.couple!.isPaired) {
      return const CoupleScreen();
    }
    return const HomeShell();
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'root',
      builder: (context, state) => const _AuthGate(),
    ),
  ],
);
