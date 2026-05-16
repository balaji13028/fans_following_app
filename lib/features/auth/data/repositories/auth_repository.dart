import '../data_sources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../../../../core/services/storage_service.dart';

/// Repository for authentication operations
/// Combines remote data source and local storage
class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepository(this._remoteDataSource);

  /// Sign in user
  Future<UserModel> userLogin({
    required String mobileNumber,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.userLogin(
        mobileNumber: mobileNumber,
        password: password,
      );

      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;

      await StorageService.saveAuthToken(token);
      await StorageService.saveUserData(userData);
      await StorageService.saveUserId(
        userData['publicId'] ?? userData['id'] as String,
      );
      await StorageService.setLoggedIn(true);

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
    throw UnimplementedError('Use sendOtp and verifyOtp instead');
  }

  /// Send OTP
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    return await _remoteDataSource.sendOtp(mobileNumber: mobileNumber);
  }

  /// Verify OTP and login
  Future<UserModel> verifyOtp({
    required String mobileNumber,
    required String otp,
    String? fcmToken,
    String? password,
  }) async {
    try {
      final response = await _remoteDataSource.verifyOtp(
        mobileNumber: mobileNumber,
        otp: otp,
        fcmToken: fcmToken,
        password: password,
      );

      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;

      await StorageService.saveAuthToken(token);
      await StorageService.saveUserData(userData);
      await StorageService.saveUserId(
        userData['publicId'] ?? userData['id'] as String,
      );
      await StorageService.setLoggedIn(true);

      return UserModel.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  /// Register FCM Token
  Future<void> registerFcmToken(String fcmToken) async {
    await _remoteDataSource.registerFcmToken(fcmToken);
  }

  /// Update User Details
  Future<void> updateUserDetails({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await _remoteDataSource.updateUserDetails(userId: userId, data: data);
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

  /// Upload profile image
  Future<String> uploadProfileImage({
    required String userId,
    required String filePath,
  }) async {
    try {
      final imageUrl = await _remoteDataSource.uploadProfileImage(
        userId: userId,
        filePath: filePath,
      );

      // Update local user data
      final userData = StorageService.getUserData();
      if (userData != null) {
        userData['profileImage'] = imageUrl;
        await StorageService.saveUserData(userData);
      }

      return imageUrl;
    } catch (e) {
      rethrow;
    }
  }
}
