import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

/// Storage Service using Hive for local data persistence
/// Handles: logged in status, user details, auth tokens, etc.
class StorageService {
  static const String _authBoxName = 'auth_box';
  static const String _userBoxName = 'user_box';

  // Keys for storing data
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _userIdKey = 'user_id';

  static Box? _authBox;
  static Box? _userBox;

  /// Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes
    _authBox = await Hive.openBox(_authBoxName);
    _userBox = await Hive.openBox(_userBoxName);
  }

  // ==================== Authentication ====================

  /// Check if user is logged in
  static bool get isLoggedIn =>
      _authBox?.get(_isLoggedInKey, defaultValue: false) ?? false;

  /// Set logged in status
  static Future<void> setLoggedIn(bool value) async {
    await _authBox?.put(_isLoggedInKey, value);
  }

  /// Get auth token
  static String? get authToken => _authBox?.get(_authTokenKey);

  /// Save auth token
  static Future<void> saveAuthToken(String token) async {
    await _authBox?.put(_authTokenKey, token);
  }

  /// Get refresh token
  static String? get refreshToken => _authBox?.get(_refreshTokenKey);

  /// Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    await _authBox?.put(_refreshTokenKey, token);
  }

  /// Get user ID
  static String? get userId => _authBox?.get(_userIdKey);

  /// Save user ID
  static Future<void> saveUserId(String userId) async {
    await _authBox?.put(_userIdKey, userId);
  }

  // ==================== User Data ====================

  /// Save user data as JSON string
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _userBox?.put(_userDataKey, jsonEncode(userData));
  }

  /// Get user data as Map
  static Map<String, dynamic>? getUserData() {
    final userDataString = _userBox?.get(_userDataKey);
    if (userDataString == null) return null;

    try {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Clear user data
  static Future<void> clearUserData() async {
    await _userBox?.delete(_userDataKey);
  }

  // ==================== General Storage ====================

  /// Save any data to auth box
  static Future<void> saveToAuthBox(String key, dynamic value) async {
    await _authBox?.put(key, value);
  }

  /// Get data from auth box
  static dynamic getFromAuthBox(String key, {dynamic defaultValue}) {
    return _authBox?.get(key, defaultValue: defaultValue);
  }

  /// Save any data to user box
  static Future<void> saveToUserBox(String key, dynamic value) async {
    await _userBox?.put(key, value);
  }

  /// Get data from user box
  static dynamic getFromUserBox(String key, {dynamic defaultValue}) {
    return _userBox?.get(key, defaultValue: defaultValue);
  }

  // ==================== Clear All Data ====================

  /// Clear all authentication data (logout)
  static Future<void> clearAuthData() async {
    await _authBox?.clear();
  }

  /// Clear all user data
  static Future<void> clearAllUserData() async {
    await _userBox?.clear();
  }

  /// Clear all data (complete logout)
  static Future<void> clearAll() async {
    await clearAuthData();
    await clearAllUserData();
  }

  // ==================== Utility Methods ====================

  /// Check if key exists in auth box
  static bool hasAuthKey(String key) {
    return _authBox?.containsKey(key) ?? false;
  }

  /// Check if key exists in user box
  static bool hasUserKey(String key) {
    return _userBox?.containsKey(key) ?? false;
  }

  /// Delete specific key from auth box
  static Future<void> deleteAuthKey(String key) async {
    await _authBox?.delete(key);
  }

  /// Delete specific key from user box
  static Future<void> deleteUserKey(String key) async {
    await _userBox?.delete(key);
  }
}
