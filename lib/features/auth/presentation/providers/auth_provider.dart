import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/data_sources/auth_remote_data_source.dart';
import '../../data/models/user_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/push_notification_service.dart';

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

  /// User Login (Mobile + Password)
  /// Returns `true` on success, `false` on failure. On failure the error
  /// message is stored in [AuthState.error] for the UI to display, instead of
  /// throwing (which would surface as an unhandled exception in debug).
  Future<bool> userLogin({
    required String mobileNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.userLogin(
        mobileNumber: mobileNumber,
        password: password,
      );

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /* Deprecated: OTP verification is removed
  /// Send OTP
  Future<String?> sendOtp(String mobileNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(authRepositoryProvider);
      // final response = await repository.sendOtp(mobileNumber); // Removed from repository
      state = state.copyWith(isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
  */

  /// User Sign Up
  /// Returns `true` on success, `false` on failure (error stored in state).
  Future<bool> userSignUp({
    required Map<String, dynamic> userDetails,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(authRepositoryProvider);

      // Get FCM Token
      final fcmToken = await PushNotificationService.getToken();
      final data = {
        ...userDetails,
        'mobileNumber': userDetails['mobile'],
        'fcmToken': fcmToken,
      };

      final user = await repository.signUp(data: data);

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /* Deprecated: OTP verification is removed
  /// Verify OTP and Update Details
  Future<void> verifyOtpAndUpdateDetails({
    required String mobileNumber,
    required String otp,
    required Map<String, dynamic> userDetails,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(authRepositoryProvider);

      // 0. Get FCM Token
      final fcmToken = await PushNotificationService.getToken();
      debugPrint('FCM Token retrieved: ${fcmToken != null ? "YES" : "NO"}');

      // 1. Verify OTP to get token
      final user = await repository.verifyOtp(
        mobileNumber: mobileNumber,
        otp: otp,
        fcmToken: fcmToken,
        password: userDetails['password'],
      );

      // 2. Update user details
      await repository.updateUserDetails(
        userId: user.id,
        data: userDetails,
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
  */

  /// Sign out
  /// Returns `true` on success, `false` on failure (error stored in state).
  Future<bool> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();

      state = AuthState(
        user: null,
        isAuthenticated: false,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Refresh user data
  /// Background refresh. Failures are intentionally not surfaced to the user
  /// (they don't break the current screen); returns `false` if it failed.
  Future<bool> refreshUser() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.refreshUserData();

      state = state.copyWith(user: user);
      return true;
    } catch (e) {
      debugPrint('refreshUser failed: $e');
      return false;
    }
  }

  /// Update Profile
  /// Returns `true` on success, `false` on failure (error stored in state).
  Future<bool> updateProfile(Map<String, dynamic> userDetails) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(authRepositoryProvider);
      final userId = state.user?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      await repository.updateUserDetails(
        userId: userId,
        data: userDetails,
      );

      // Refresh to get latest data
      await refreshUser();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Initialize FCM Token for logged-in user
  Future<void> initializeFcmToken() async {
    if (!state.isAuthenticated) return;
    
    try {
      final token = await PushNotificationService.getToken();
      if (token != null) {
        final repository = ref.read(authRepositoryProvider);
        await repository.registerFcmToken(token);
      }
    } catch (e) {
      // Ignore FCM registration errors during initialization
      debugPrint('FCM registration failed: $e');
    }
  }

  /// Upload Profile Image
  /// Returns `true` on success, `false` on failure (error stored in state).
  Future<bool> uploadProfileImage(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(authRepositoryProvider);
      final userId = state.user?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      await repository.uploadProfileImage(
        userId: userId,
        filePath: filePath,
      );

      // Refresh to get latest data (including presigned URL)
      await refreshUser();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
