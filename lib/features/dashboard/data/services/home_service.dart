import '../../../../core/services/api_service.dart';
import '../../../feed/data/models/event_model.dart';
import '../../../feed/data/models/post_model.dart';
import '../../../feed/data/models/social_link_model.dart';

class HomeService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _apiService.get('/mobile/dashboard');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        final events = (data['events'] as List)
            .map((e) => EventModel.fromJson(e))
            .toList();
            
        final posts = (data['posts'] as List)
            .map((p) => PostModel.fromJson(p))
            .toList();
            
        final socialMedia = (data['socialMedia'] as List)
            .map((s) => SocialLinkModel.fromJson(s))
            .toList();
            
        return {
          'events': events,
          'posts': posts,
          'socialMedia': socialMedia,
        };
      }
      throw Exception('Failed to load dashboard');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> toggleLike(String targetId, String targetType) async {
    try {
      final response = await _apiService.post('/mobile/like', data: {
        'targetId': targetId,
        'targetType': targetType,
      });
      return response.data['liked'] as bool;
    } catch (e) {
      return false;
    }
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
  Future<List<PostModel>> getMyPosts() async {
    try {
      final response = await _apiService.get('/mobile/my-posts');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['posts'];
        return data.map((json) => PostModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load my posts');
    } catch (e) {
      rethrow;
    }
  }

  Future<PostModel> createPost(Map<String, dynamic> postData) async {
    try {
      final response = await _apiService.post('/mobile/posts', data: postData);
      if (response.statusCode == 201) {
        return PostModel.fromJson(response.data);
      }
      throw Exception('Failed to create post');
    } catch (e) {
      rethrow;
    }
  }
}
