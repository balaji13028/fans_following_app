import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../feed/data/models/post_model.dart';
import '../../../feed/data/models/social_link_model.dart';

class HomeService {
  final ApiService _apiService = ApiService();

  /// YYYY-MM-DD in IST for filtering upcoming events on feed fallback.
  String _todayIstDateString() {
    final ist = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final y = ist.year;
    final m = ist.month.toString().padLeft(2, '0');
    final d = ist.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  List<SocialLinkModel> _parseSocialLinks(dynamic data) {
    final list = data is List ? data : (data as Map<String, dynamic>)['socialMedia'] as List?;
    if (list == null) return [];
    return list.map((s) => SocialLinkModel.fromJson(s as Map<String, dynamic>)).toList();
  }

  Future<List<SocialLinkModel>> _getSocialLinksFallback() async {
    final response = await _apiService.get('/social-media');
    return _parseSocialLinks(response.data);
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _apiService.get('/mobile/dashboard');
      if (response.statusCode == 200) {
        return {
          'socialMedia': _parseSocialLinks(response.data),
        };
      }
      throw Exception('Failed to load dashboard');
    } on ApiException catch (e) {
      // Production may still run the legacy dashboard that errors (500) when
      // loading all posts/events. Social links are available separately.
      if (e.statusCode == 500 || e.statusCode == 404) {
        return {'socialMedia': await _getSocialLinksFallback()};
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPosts({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    try {
      final response = await _apiService.get(
        '/mobile/posts',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to load posts');
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return _getPostsFromFeed(page: page, limit: limit);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getEvents({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    bool futureOnly = true,
  }) async {
    try {
      final response = await _apiService.get(
        '/mobile/events',
        queryParameters: {
          'page': page,
          'limit': limit,
          'futureOnly': futureOnly,
        },
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to load events');
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return _getEventsFromFeed(
          page: page,
          limit: limit,
          futureOnly: futureOnly,
        );
      }
      rethrow;
    }
  }

  /// Fallback when `/mobile/posts` is not deployed: paginate via `/mobile/feed`.
  Future<Map<String, dynamic>> _getPostsFromFeed({
    required int page,
    required int limit,
  }) async {
    final feed = await getFeed(page: page, limit: limit);
    final items = (feed['feed'] as List)
        .where((item) => (item as Map<String, dynamic>)['feedType'] == 'post')
        .toList();

    return {
      'items': items,
      'page': page,
      'limit': limit,
      'total': items.length,
      'hasMore': feed['hasMore'] ?? false,
    };
  }

  /// Fallback when `/mobile/events` is not deployed: extract events from feed.
  Future<Map<String, dynamic>> _getEventsFromFeed({
    required int page,
    required int limit,
    required bool futureOnly,
  }) async {
    final feed = await getFeed(page: page, limit: 100);
    final today = _todayIstDateString();

    final allEvents = (feed['feed'] as List)
        .where((item) => (item as Map<String, dynamic>)['feedType'] == 'event')
        .where((item) {
          if (!futureOnly) return true;
          final date = (item as Map<String, dynamic>)['date'] as String?;
          return date != null && date.compareTo(today) >= 0;
        })
        .toList();

    allEvents.sort((a, b) {
      final aMap = a as Map<String, dynamic>;
      final bMap = b as Map<String, dynamic>;
      final dateCmp = (aMap['date'] as String).compareTo(bMap['date'] as String);
      if (dateCmp != 0) return dateCmp;
      return (aMap['time'] as String? ?? '').compareTo(bMap['time'] as String? ?? '');
    });

    final skip = (page - 1) * limit;
    final items = allEvents.skip(skip).take(limit).toList();

    return {
      'items': items,
      'page': page,
      'limit': limit,
      'total': allEvents.length,
      'hasMore': skip + limit < allEvents.length,
    };
  }

  Future<bool> toggleLike(String targetId, String targetType) async {
    final response = await _apiService.post('/mobile/like', data: {
      'targetId': targetId,
      'targetType': targetType,
    });
    return response.data['liked'] as bool;
  }

  Future<Map<String, dynamic>> getFeed({int page = 1, int limit = 15}) async {
    try {
      final response = await _apiService.get('/mobile/feed', queryParameters: {
        'page': page,
        'limit': limit,
      });
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to load feed');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMyPosts({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    try {
      final response = await _apiService.get(
        '/mobile/my-posts',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to load my posts');
    } catch (e) {
      rethrow;
    }
  }

  Future<PostModel> createPost(Map<String, dynamic> postData) async {
    try {
      final formData = await _apiService.createFormData(postData);
      final response = await _apiService.post('/mobile/posts', data: formData);
      if (response.statusCode == 201) {
        return PostModel.fromJson(response.data);
      }
      throw Exception('Failed to create post');
    } catch (e) {
      rethrow;
    }
  }
}
