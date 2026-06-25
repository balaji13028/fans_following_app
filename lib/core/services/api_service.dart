import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

/// Categories of API failures so the UI can react appropriately
/// (e.g. show a "server down" vs "no internet" message).
enum ApiErrorType {
  noInternet,
  serverDown,
  timeout,
  unauthorized,
  badRequest,
  forbidden,
  notFound,
  server,
  unknown,
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorType type;

  ApiException(
    this.message, {
    this.statusCode,
    this.type = ApiErrorType.unknown,
  });

  /// Whether this failure is a connectivity/server-reachability problem
  /// (as opposed to a normal API error like 400/401).
  bool get isConnectionIssue =>
      type == ApiErrorType.noInternet ||
      type == ApiErrorType.serverDown ||
      type == ApiErrorType.timeout;

  @override
  String toString() => message;
}

/// API Service using Dio for HTTP requests
/// Handles: API calls, authentication, error handling, interceptors
class ApiService {
  late Dio _dio;

  Exception _handleException(dynamic e) {
    if (e is DioException) {
      // Timeouts: server reachable too slowly, or down/overloaded.
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return ApiException(
          'The server is taking too long to respond. It may be down. '
          'Please try again later.',
          type: ApiErrorType.timeout,
        );
      }

      // Connection errors: distinguish "server is down" (host reachable but
      // refusing) from a genuine "no internet" situation.
      if (e.type == DioExceptionType.connectionError) {
        if (_isServerUnreachable(e.error)) {
          return ApiException(
            'Unable to reach the server. The server may be down. '
            'Please try again later.',
            type: ApiErrorType.serverDown,
          );
        }
        return ApiException(
          'No internet connection. Please check your network and try again.',
          type: ApiErrorType.noInternet,
        );
      }

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String message = 'An error occurred';
        if (responseData is Map<String, dynamic>) {
          message = responseData['error'] ?? responseData['message'] ?? message;
        }

        switch (statusCode) {
          case 400:
            return ApiException(
              'Bad request: $message',
              statusCode: statusCode,
              type: ApiErrorType.badRequest,
            );
          case 401:
            return ApiException(
              message,
              statusCode: statusCode,
              type: ApiErrorType.unauthorized,
            );
          case 403:
            return ApiException(
              'Access forbidden: $message',
              statusCode: statusCode,
              type: ApiErrorType.forbidden,
            );
          case 404:
            return ApiException(
              'Not found: $message',
              statusCode: statusCode,
              type: ApiErrorType.notFound,
            );
          case 500:
          case 502:
          case 503:
          case 504:
            return ApiException(
              'The server is currently unavailable. Please try again later.',
              statusCode: statusCode,
              type: ApiErrorType.server,
            );
          default:
            return ApiException(message, statusCode: statusCode);
        }
      }
      return ApiException(e.message ?? 'An unexpected error occurred');
    }
    return ApiException(e.toString());
  }

  /// Returns true when the underlying error indicates the host was reachable
  /// but the connection was actively refused (i.e. the server is down), rather
  /// than a missing network / DNS failure.
  bool _isServerUnreachable(Object? error) {
    if (error is SocketException) {
      final osError = error.osError;
      // Connection refused: macOS/iOS = 61, Android/Linux = 111.
      if (osError != null && (osError.errorCode == 61 || osError.errorCode == 111)) {
        return true;
      }
      final text = '${osError?.message ?? ''} ${error.message}'.toLowerCase();
      return text.contains('connection refused') ||
          text.contains('connection failed');
    }
    return false;
  }

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl + AppConstants.apiVersion,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
  }

  /// Get Dio instance
  Dio get dio => _dio;

  // ==================== HTTP Methods ====================

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  // ==================== Helper Methods ====================

  /// Create FormData from Map
  Future<FormData> createFormData(Map<String, dynamic> data) async {
    return FormData.fromMap(data);
  }

  /// Create MultipartFile from file path
  Future<MultipartFile> createMultipartFile(String filePath) async {
    return await MultipartFile.fromFile(filePath);
  }
}

/// Interceptor to add auth token to requests
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = StorageService.authToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Interceptor for logging requests and responses
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    debugPrint('Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    debugPrint('Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    debugPrint('Message: ${err.message}');
    handler.next(err);
  }
}

/// Interceptor for error handling
class _ErrorInterceptor extends Interceptor {
  /// Auth endpoints where a 401 means "invalid credentials" (a normal,
  /// in-screen error) rather than "session expired". These must NOT trigger the
  /// global logout/redirect, otherwise the login screen gets rebuilt instead of
  /// showing the error.
  bool _isAuthRequest(String path) {
    return path.contains(AppConstants.userLoginEndpoint) ||
        path.contains(AppConstants.userSignUpEndpoint) ||
        path.contains(AppConstants.signOutEndpoint);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - session expired: clear auth and redirect to
    // login. Skipped for auth requests (e.g. wrong credentials during sign in),
    // which are surfaced as a normal error on the current screen.
    if (err.response?.statusCode == 401 &&
        !_isAuthRequest(err.requestOptions.path)) {
      StorageService.clearAuthData();

      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
        );
      }
    }

    // Handle other errors
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // Handle timeout errors
        break;
      case DioExceptionType.badResponse:
        // Handle bad response
        break;
      case DioExceptionType.cancel:
        // Handle cancelled requests
        break;
      default:
        // Handle other errors
        break;
    }

    handler.next(err);
  }
}
