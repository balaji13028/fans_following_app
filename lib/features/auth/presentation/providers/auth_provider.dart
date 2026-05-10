import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/data_sources/auth_remote_data_source.dart';
import '../../data/models/user_model.dart';
import '../../../../core/services/api_service.dart';

part 'auth_provider.g.dart';

// ==================== Providers ====================

/// API Service Provider
@riverpod
ApiService apiService(ApiServiceRef ref) {
  return ApiService();
}

/// Auth Remote Data Source Provider
@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSource(ref.watch(apiServiceProvider));
}

/// Auth Repository Provider
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(authRemoteDataSourceProvider));
}

// ==================== Auth Notifier ====================

/// Auth State
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

/// Auth Notifier - Manages authentication state
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // Initialize with stored user data
    final repository = ref.watch(authRepositoryProvider);
    final user = repository.getCurrentUser();
    final isAuthenticated = repository.isLoggedIn;

    return AuthState(
      user: user,
      isAuthenticated: isAuthenticated,
    );
  }

  /// Sign in
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signIn(
        email: email,
        password: password,
      );

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign up
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signUp(
        email: email,
        password: password,
        name: name,
      );

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();

      state = AuthState(
        user: null,
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.refreshUserData();

      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

