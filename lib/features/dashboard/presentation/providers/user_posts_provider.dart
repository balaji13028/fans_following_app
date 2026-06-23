import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/services/home_service.dart';
import '../../../feed/data/models/post_model.dart';
import 'dashboard_provider.dart';

class UserPostsState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final int total;
  final String? error;

  UserPostsState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.total = 0,
    this.error,
  });

  UserPostsState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    int? total,
    String? error,
  }) {
    return UserPostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      total: total ?? this.total,
      error: error,
    );
  }
}

class UserPostsNotifier extends StateNotifier<UserPostsState> {
  final HomeService _homeService;

  UserPostsNotifier(this._homeService) : super(UserPostsState());

  Future<void> loadPosts({bool refresh = false}) async {
    if (state.isLoadingMore || (!refresh && !state.hasMore)) return;

    if (refresh) {
      state = state.copyWith(isLoading: true, error: null, page: 1, hasMore: true);
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      final page = refresh ? 1 : state.page + 1;
      final data = await _homeService.getMyPosts(
        page: page,
        limit: AppConstants.defaultPageSize,
      );
      final items = (data['items'] as List)
          .map((json) => PostModel.fromJson(json))
          .toList();

      state = state.copyWith(
        posts: refresh ? items : [...state.posts, ...items],
        page: page,
        hasMore: data['hasMore'] ?? false,
        total: data['total'] ?? state.posts.length,
        isLoading: false,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
}

final userPostsProvider =
    StateNotifierProvider<UserPostsNotifier, UserPostsState>((ref) {
  return UserPostsNotifier(ref.watch(homeServiceProvider));
});
