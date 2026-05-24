import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/home_service.dart';
import '../../../feed/data/models/post_model.dart';
import 'dashboard_provider.dart';

class UserPostsState {
  final List<PostModel> posts;
  final bool isLoading;
  final String? error;

  UserPostsState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  UserPostsState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    String? error,
  }) {
    return UserPostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can clear error by not passing it or passing null explicitly if we wanted to, but simple implementation is fine
    );
  }
}

class UserPostsNotifier extends StateNotifier<UserPostsState> {
  final HomeService _homeService;

  UserPostsNotifier(this._homeService) : super(UserPostsState());

  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final posts = await _homeService.getMyPosts();
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userPostsProvider = StateNotifierProvider<UserPostsNotifier, UserPostsState>((ref) {
  return UserPostsNotifier(ref.watch(homeServiceProvider));
});
