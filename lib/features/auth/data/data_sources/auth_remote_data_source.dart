import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Remote data source for authentication API calls
class AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSource(this._apiService);

  /// Sign in user
  Future<Map<String, dynamic>> userLogin({
    required String mobileNumber,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.userLoginEndpoint,
        data: {'mobileNumber': mobileNumber, 'password': password},
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Send OTP
  Future<Map<String, dynamic>> sendOtp({required String mobileNumber}) async {
    try {
      final response = await _apiService.post(
        AppConstants.sendOtpEndpoint,
        data: {'mobileNumber': mobileNumber},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String mobileNumber,
    required String otp,
    String? fcmToken,
    String? password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.verifyOtpEndpoint,
        data: {
          'mobileNumber': mobileNumber,
          'otp': otp,
          'fcmToken': fcmToken,
          'password': password,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Update User Details
  Future<void> updateUserDetails({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _apiService.put(
        '${AppConstants.userDetailsEndpoint}/$userId/details',
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _apiService.post(AppConstants.signOutEndpoint);
    } catch (e) {
      // Even if API call fails, we should still sign out locally
      rethrow;
    }
  }

  /// Get current user profile
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiService.get(AppConstants.profileEndpoint);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Register FCM Token
  Future<void> registerFcmToken(String fcmToken) async {
    try {
      await _apiService.post(
        '${AppConstants.userDetailsEndpoint}/fcm-token',
        data: {'fcmToken': fcmToken},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Upload Profile Image
  Future<String> uploadProfileImage({
    required String userId,
    required String filePath,
  }) async {
    try {
      final formData = await _apiService.createFormData({
        'image': await _apiService.createMultipartFile(filePath),
      });

      final response = await _apiService.post(
        '${AppConstants.userDetailsEndpoint}/$userId/profile-image',
        data: formData,
      );

      return response.data['imageUrl'] as String;
    } catch (e) {
      rethrow;
    }
  }
}
