import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// API Service using Dio for HTTP requests
/// Handles: API calls, authentication, error handling, interceptors
class ApiService {
  late Dio _dio;

  Exception _handleException(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return ApiException('No internet connection. Please check your network.');
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
            return ApiException('Bad request: $message', statusCode);
          case 401:
            return ApiException(message, statusCode);
          case 403:
            return ApiException('Access forbidden: $message', statusCode);
          case 404:
            return ApiException('Not found: $message', statusCode);
          case 500:
            return ApiException('Server error. Please try again later.', statusCode);
          default:
            return ApiException(message, statusCode);
        }
      }
      return ApiException(e.message ?? 'An unexpected error occurred');
    }
    return ApiException(e.toString());
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
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - Clear auth and redirect to login
    if (err.response?.statusCode == 401) {
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
