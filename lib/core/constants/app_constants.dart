class AppConstants {
  // App Information
  static const String appName = 'AA Fans';
  static const String appVersion = '1.0.0';

  // API Endpoints (Update with your actual API base URL)
  // Use 10.0.2.2 for Android Emulator, or 127.0.0.1 for iOS Simulator connecting to localhost
  static const String baseUrl = 'https://api.aafansassociation.com';
  static const String apiVersion = '/api/v1';

  // Authentication
  static const String signInEndpoint = '/auth/user/login';
  static const String sendOtpEndpoint = '/auth/user/send-otp';
  static const String verifyOtpEndpoint = '/auth/user/verify-otp';
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
}
