import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Remote data source for authentication API calls
class AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSource(this._apiService);

  /// Sign in user
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.signInEndpoint,
        data: {'email': email, 'password': password},
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign up user (Deprecated, use sendOtp instead)
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Just returning mock data since the actual flow uses OTP now
      return {'message': 'Deprecated'};
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
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.verifyOtpEndpoint,
        data: {'mobileNumber': mobileNumber, 'otp': otp},
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
}
