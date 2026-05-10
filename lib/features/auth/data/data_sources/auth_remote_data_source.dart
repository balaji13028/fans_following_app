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
        data: {
          'email': email,
          'password': password,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Sign up user
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.signUpEndpoint,
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _apiService.post(AppConstants.signOutEndpoint);
    } on DioException catch (e) {
      // Even if API call fails, we should still sign out locally
      throw _handleError(e);
    }
  }

  /// Get current user profile
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiService.get(AppConstants.profileEndpoint);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle API errors
  String _handleError(DioException error) {
    if (error.response != null) {
      // Server responded with error
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?['message'] ?? 'An error occurred';

      switch (statusCode) {
        case 400:
          return 'Bad request: $message';
        case 401:
          return 'Invalid credentials. Please check your email and password.';
        case 403:
          return 'Access forbidden: $message';
        case 404:
          return 'Not found: $message';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return message;
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}

