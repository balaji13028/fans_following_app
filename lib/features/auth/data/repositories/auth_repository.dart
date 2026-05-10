import '../data_sources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../../../../core/services/storage_service.dart';

/// Repository for authentication operations
/// Combines remote data source and local storage
class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepository(this._remoteDataSource);

  /// Sign in user
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Call API
      final response = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );

      // Extract data
      final token = response['token'] as String;
      final refreshToken = response['refreshToken'] as String?;
      final userData = response['user'] as Map<String, dynamic>;

      // Save to local storage
      await StorageService.saveAuthToken(token);
      if (refreshToken != null) {
        await StorageService.saveRefreshToken(refreshToken);
      }
      await StorageService.saveUserData(userData);
      await StorageService.saveUserId(userData['id'] as String);
      await StorageService.setLoggedIn(true);

      // Return user model
      return UserModel.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign up user
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Call API
      final response = await _remoteDataSource.signUp(
        email: email,
        password: password,
        name: name,
      );

      // Extract data
      final token = response['token'] as String;
      final refreshToken = response['refreshToken'] as String?;
      final userData = response['user'] as Map<String, dynamic>;

      // Save to local storage
      await StorageService.saveAuthToken(token);
      if (refreshToken != null) {
        await StorageService.saveRefreshToken(refreshToken);
      }
      await StorageService.saveUserData(userData);
      await StorageService.saveUserId(userData['id'] as String);
      await StorageService.setLoggedIn(true);

      // Return user model
      return UserModel.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      // Call API (optional - can fail silently)
      try {
        await _remoteDataSource.signOut();
      } catch (e) {
        // Continue with local sign out even if API fails
      }

      // Clear local storage
      await StorageService.clearAll();
    } catch (e) {
      // Even if there's an error, clear local data
      await StorageService.clearAll();
      rethrow;
    }
  }

  /// Get current user from local storage
  UserModel? getCurrentUser() {
    final userData = StorageService.getUserData();
    if (userData == null) return null;
    
    try {
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => StorageService.isLoggedIn;

  /// Get auth token
  String? get authToken => StorageService.authToken;

  /// Refresh user data from server
  Future<UserModel> refreshUserData() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      await StorageService.saveUserData(user.toJson());
      await StorageService.saveUserId(user.id);
      return user;
    } catch (e) {
      rethrow;
    }
  }
}

