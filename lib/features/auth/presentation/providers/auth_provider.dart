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
  Future<void> userLogin({
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Send OTP
  Future<String?> sendOtp(String mobileNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.sendOtp(mobileNumber);
      state = state.copyWith(isLoading: false);

      // Try to extract OTP from response, it could be in 'otp' or 'data.otp'
      final otp = response['otp']?.toString() ??
          (response['data'] is Map
              ? response['data']['otp']?.toString()
              : null);
      return otp;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

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

  /// Update Profile
  Future<void> updateProfile(Map<String, dynamic> userDetails) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(authRepositoryProvider);
      final userId = state.user?.id;
      if (userId == null) return;

      await repository.updateUserDetails(
        userId: userId,
        data: userDetails,
      );

      // Refresh to get latest data
      await refreshUser();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
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
  Future<void> uploadProfileImage(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(authRepositoryProvider);
      final userId = state.user?.id;
      if (userId == null) return;

      await repository.uploadProfileImage(
        userId: userId,
        filePath: filePath,
      );

      // Refresh to get latest data (including presigned URL)
      await refreshUser();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}
