class AppConstants {
  // App Information
  static const String appName = 'AA Fans';
  static const String appVersion = '1.0.0';

  // API Endpoints (Update with your actual API base URL)
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/api/v1';

  // Authentication
  static const String signInEndpoint = '/auth/signin';
  static const String signUpEndpoint = '/auth/signup';
  static const String signOutEndpoint = '/auth/signout';

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
  static const String profileEndpoint = '/profile';
  static const String updateProfileImageEndpoint = '/profile/image';

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

