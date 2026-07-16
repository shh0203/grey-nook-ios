import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/couple_service.dart';
import '../api/messages_service.dart';
import '../api/domain_services.dart';
import '../services/auth_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.read(apiClientProvider)));
final coupleServiceProvider = Provider<CoupleService>((ref) => CoupleService(ref.read(apiClientProvider)));
final messagesServiceProvider = Provider<MessagesService>((ref) => MessagesService(ref.read(apiClientProvider)));
final memoriesServiceProvider = Provider<MemoriesService>((ref) => MemoriesService(ref.read(apiClientProvider)));
final moodsServiceProvider = Provider<MoodsService>((ref) => MoodsService(ref.read(apiClientProvider)));
final tasksServiceProvider = Provider<TasksService>((ref) => TasksService(ref.read(apiClientProvider)));
final lettersServiceProvider = Provider<LettersService>((ref) => LettersService(ref.read(apiClientProvider)));
final petServiceProvider = Provider<PetService>((ref) => PetService(ref.read(apiClientProvider)));

class AppAuthState {
  final bool loading;
  final AuthUser? user;
  final CoupleInfo? couple;
  final String? error;
  const AppAuthState({required this.loading, this.user, this.couple, this.error});
  AppAuthState copyWith({bool? loading, AuthUser? user, CoupleInfo? couple, String? error, bool clearUser = false, bool clearCouple = false}) =>
      AppAuthState(
        loading: loading ?? this.loading,
        user: clearUser ? null : (user ?? this.user),
        couple: clearCouple ? null : (couple ?? this.couple),
        error: error,
      );
}

class AppAuthNotifier extends StateNotifier<AppAuthState> {
  AppAuthNotifier(this.ref) : super(const AppAuthState(loading: true)) {
    _bootstrap();
  }
  final Ref ref;

  Future<void> _bootstrap() async {
    final auth = ref.read(authServiceProvider);
    final saved = await auth.loadSaved();
    if (saved.token == null || saved.user == null) {
      state = const AppAuthState(loading: false);
      return;
    }
    state = state.copyWith(loading: false, user: saved.user);
    await refreshCouple();
  }

  Future<void> refreshCouple() async {
    try {
      final c = await ref.read(coupleServiceProvider).me();
      state = state.copyWith(couple: c, clearCouple: c == null);
    } catch (_) {
      // token invalid
      await ref.read(authServiceProvider).logout();
      state = const AppAuthState(loading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final user = await ref.read(authServiceProvider).login(email: email, password: password);
      state = AppAuthState(loading: false, user: user);
      await refreshCouple();
      return true;
    } catch (e) {
      state = state.copyWith(error: '$e', loading: false);
      return false;
    }
  }

  Future<bool> register(String email, String password, String displayName) async {
    try {
      final user = await ref.read(authServiceProvider).register(
            email: email,
            password: password,
            displayName: displayName,
          );
      state = AppAuthState(loading: false, user: user);
      await refreshCouple();
      return true;
    } catch (e) {
      state = state.copyWith(error: '$e', loading: false);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const AppAuthState(loading: false);
  }
}

final appAuthProvider = StateNotifierProvider<AppAuthNotifier, AppAuthState>((ref) => AppAuthNotifier(ref));
