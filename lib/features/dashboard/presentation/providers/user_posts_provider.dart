import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/connectivity_provider.dart';
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
  final bool loadMoreError;

  UserPostsState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.total = 0,
    this.error,
    this.loadMoreError = false,
  });

  UserPostsState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    int? total,
    String? error,
    bool? loadMoreError,
  }) {
    return UserPostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      total: total ?? this.total,
      error: error,
      loadMoreError: loadMoreError ?? this.loadMoreError,
    );
  }
}

class UserPostsNotifier extends StateNotifier<UserPostsState> {
  final HomeService _homeService;
  final Ref _ref;

  UserPostsNotifier(this._homeService, this._ref) : super(UserPostsState());

  /// Current connectivity, sourced from the reliable status stream.
  bool get _isOnline =>
      _ref.read(connectivityStatusProvider).value ?? true;

  /// Auto-resume when the internet comes back, with no user action.
  /// Wired from the provider via `ref.listen` so it fires reliably.
  void handleConnectivityChange(
    AsyncValue<bool>? previous,
    AsyncValue<bool> next,
  ) {
    final cameBackOnline = previous?.value == false && next.value == true;
    if (!cameBackOnline) return;

    if (state.posts.isEmpty) {
      loadPosts(refresh: true);
    } else if (state.loadMoreError) {
      state = state.copyWith(loadMoreError: false);
      loadPosts();
    }
  }

  Future<void> loadPosts({bool refresh = false}) async {
    if (state.isLoadingMore) return;
    // After a failed page, wait for explicit retry/refresh instead of looping
    // on every scroll event (e.g. while offline).
    if (!refresh && (!state.hasMore || state.loadMoreError)) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        page: 1,
        hasMore: true,
        loadMoreError: false,
      );
    } else {
      state = state.copyWith(
        isLoadingMore: true,
        error: null,
        loadMoreError: false,
      );
    }

    // Don't even attempt the API when there's no connection.
    if (!_isOnline) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        loadMoreError: !refresh,
        error: refresh
            ? 'No internet connection. Please check your network.'
            : null,
      );
      return;
    }

    try {
      final page = refresh ? 1 : state.page + 1;
      final data = await _homeService.getMyPosts(
        page: page,
        limit: AppConstants.defaultPageSize,
      );
      final rawItems = data['items'];
      final items = (rawItems is List ? rawItems : const <dynamic>[])
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        posts: refresh ? items : [...state.posts, ...items],
        page: page,
        hasMore: data['hasMore'] ?? false,
        total: data['total'] ?? state.posts.length,
        isLoading: false,
        isLoadingMore: false,
        loadMoreError: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
        // Only block auto-loading for load-more failures, not initial/refresh.
        loadMoreError: !refresh,
      );
    }
  }

  /// Manually retry loading the next page after a failure.
  void retryLoadMore() {
    if (state.isLoadingMore) return;
    state = state.copyWith(loadMoreError: false);
    loadPosts();
  }
}

final userPostsProvider =
    StateNotifierProvider<UserPostsNotifier, UserPostsState>((ref) {
  final notifier = UserPostsNotifier(ref.watch(homeServiceProvider), ref);
  // Auto-resume loads when connectivity is restored.
  ref.listen<AsyncValue<bool>>(
    connectivityStatusProvider,
    notifier.handleConnectivityChange,
  );
  return notifier;
});
