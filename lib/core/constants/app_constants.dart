import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // App Information
  static const String appName = 'AA Fans';
  static const String appVersion = '1.0.0';

  // API Endpoints
  // Set to true to point at the production API instead of the local dev server.
  static const bool useProduction = false;
  static const String productionBaseUrl = 'https://api.aafansassociation.com';
  static const int localPort = 4000;

  /// Base URL resolved per-platform so local development works everywhere:
  /// - Android emulator can't reach the host via `localhost`; it uses 10.0.2.2.
  /// - iOS simulator, web and desktop reach the host via `localhost`.
  /// - Physical devices need the machine's LAN IP (set [useProduction] or
  ///   override this for on-device testing).
  static String get baseUrl {
    if (useProduction) return productionBaseUrl;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:$localPort';
    return 'http://localhost:$localPort';
  }

  static const String apiVersion = '/api/v1';

  // Authentication
  static const String signInEndpoint = '/auth/user/login';
  static const String userLoginEndpoint = '/auth/user/login';
  static const String userSignUpEndpoint = '/auth/user/signup';
  // static const String sendOtpEndpoint = '/auth/user/send-otp';
  // static const String verifyOtpEndpoint = '/auth/user/verify-otp';
  static const String signOutEndpoint = '/auth/signout';
  static const String userDetailsEndpoint = '/users';

  // Feed
  static const String feedEndpoint = '/feed';
  static const String postsEndpoint = '/posts';
  static const String eventsEndpoint = '/events';
  static const String socialLinksEndpoint = '/social-links';
  static const String likePostEndpoint = '/posts';

  // Notifications
  static const String notificationsEndpoint = '/notifications';
  static const String markNotificationSeenEndpoint = '/notifications';

  // Profile
  static const String profileEndpoint = '/mobile/profile';
  static const String updateProfileImageEndpoint = '/mobile/profile/image';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Legal
  static const String privacyPolicyUrl =
      'https://www.aafansassociation.com/privacy-policy';
  static const String termsAndConditionsUrl =
      'https://www.aafansassociation.com/terms-and-conditions';
}
