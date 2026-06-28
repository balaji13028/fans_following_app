import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../data/services/home_service.dart';
import '../../../feed/data/models/event_model.dart';
import '../../../feed/data/models/post_model.dart';
import '../../../feed/data/models/social_link_model.dart';

final homeServiceProvider = Provider<HomeService>((ref) => HomeService());

class DashboardState {
  final List<EventModel> events;
  final List<PostModel> posts;
  final List<SocialLinkModel> socialLinks;
  final bool isLoading;
  final bool isLoadingMorePosts;
  final bool postsHasMore;
  final int postsPage;
  final bool loadMorePostsError;

  DashboardState({
    this.events = const [],
    this.posts = const [],
    this.socialLinks = const [],
    this.isLoading = false,
    this.isLoadingMorePosts = false,
    this.postsHasMore = true,
    this.postsPage = 1,
    this.loadMorePostsError = false,
  });

  DashboardState copyWith({
    List<EventModel>? events,
    List<PostModel>? posts,
    List<SocialLinkModel>? socialLinks,
    bool? isLoading,
    bool? isLoadingMorePosts,
    bool? postsHasMore,
    int? postsPage,
    bool? loadMorePostsError,
  }) {
    return DashboardState(
      events: events ?? this.events,
      posts: posts ?? this.posts,
      socialLinks: socialLinks ?? this.socialLinks,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMorePosts: isLoadingMorePosts ?? this.isLoadingMorePosts,
      postsHasMore: postsHasMore ?? this.postsHasMore,
      postsPage: postsPage ?? this.postsPage,
      loadMorePostsError: loadMorePostsError ?? this.loadMorePostsError,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final HomeService _homeService;
  final Ref _ref;

  DashboardNotifier(this._homeService, this._ref) : super(DashboardState());

  /// Current connectivity, sourced from the same reliable status stream that
  /// drives the banner. Defaults to online when unknown so the first load isn't
  /// blocked.
  bool get _isOnline =>
      _ref.read(connectivityStatusProvider).value ?? true;

  /// Auto-resume when the internet comes back, with no user action (YouTube-like).
  /// Wired from the provider via `ref.listen` so it fires reliably.
  void handleConnectivityChange(
    AsyncValue<bool>? previous,
    AsyncValue<bool> next,
  ) {
    final cameBackOnline = previous?.value == false && next.value == true;
    if (!cameBackOnline) return;

    if (state.events.isEmpty && state.posts.isEmpty) {
      loadDashboard();
    } else if (state.loadMorePostsError) {
      state = state.copyWith(loadMorePostsError: false);
      loadMorePosts();
    }
  }

  Future<void> loadDashboard() async {
    // Don't hit the API with no connection; the connectivity listener will
    // retry automatically once the internet returns.
    if (!_isOnline) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([
        _homeService.getDashboardData(),
        _homeService.getEvents(page: 1, limit: 10),
        _homeService.getPosts(page: 1, limit: AppConstants.defaultPageSize),
      ]);

      final dashboardData = results[0];
      final eventsData = results[1];
      final postsData = results[2];

      final events = (eventsData['items'] as List)
          .map((e) => EventModel.fromJson(e))
          .toList();
      final posts = (postsData['items'] as List)
          .map((p) => PostModel.fromJson(p))
          .toList();

      state = DashboardState(
        events: events,
        posts: posts,
        socialLinks: dashboardData['socialMedia'],
        isLoading: false,
        postsHasMore: postsData['hasMore'] ?? false,
        postsPage: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMorePosts() async {
    // Don't trigger again while loading, when there's nothing more, or after a
    // previous failure (prevents an endless retry loop while scrolling offline).
    if (state.isLoadingMorePosts ||
        !state.postsHasMore ||
        state.loadMorePostsError) {
      return;
    }

    state = state.copyWith(isLoadingMorePosts: true, loadMorePostsError: false);

    // Don't even attempt the API when there's no connection.
    if (!_isOnline) {
      state = state.copyWith(
        isLoadingMorePosts: false,
        loadMorePostsError: true,
      );
      return;
    }

    try {
      final nextPage = state.postsPage + 1;
      final postsData = await _homeService.getPosts(
        page: nextPage,
        limit: AppConstants.defaultPageSize,
      );

      final newPosts = (postsData['items'] as List)
          .map((p) => PostModel.fromJson(p))
          .toList();

      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        postsHasMore: postsData['hasMore'] ?? false,
        postsPage: nextPage,
        isLoadingMorePosts: false,
        loadMorePostsError: false,
      );
    } catch (e) {
      // Stop auto-loading; user can tap "retry" or pull to refresh.
      state = state.copyWith(
        isLoadingMorePosts: false,
        loadMorePostsError: true,
      );
    }
  }

  /// Manually retry loading the next page after a failure.
  void retryLoadMorePosts() {
    if (state.isLoadingMorePosts) return;
    state = state.copyWith(loadMorePostsError: false);
    loadMorePosts();
  }

  bool? _getCurrentIsLiked(String id, String type) {
    if (type == 'event') {
      final index = state.events.indexWhere((e) => e.id == id);
      if (index != -1) return state.events[index].isLiked;
    } else {
      final index = state.posts.indexWhere((p) => p.id == id);
      if (index != -1) return state.posts[index].isLiked;
    }
    return null;
  }

  void updateLikeLocal(String id, String type, bool isLiked) {
    if (type == 'event') {
      final index = state.events.indexWhere((e) => e.id == id);
      if (index != -1) {
        final newEvents = [...state.events];
        final event = newEvents[index];
        newEvents[index] = event.copyWith(
          isLiked: isLiked,
          likesCount: event.likesCount + (isLiked ? 1 : -1),
        );
        state = state.copyWith(events: newEvents);
      }
    } else {
      final index = state.posts.indexWhere((p) => p.id == id);
      if (index != -1) {
        final newPosts = [...state.posts];
        final post = newPosts[index];
        newPosts[index] = post.copyWith(
          isLiked: isLiked,
          likesCount: post.likesCount + (isLiked ? 1 : -1),
        );
        state = state.copyWith(posts: newPosts);
      }
    }
  }

  Future<void> toggleLike(String id, String type) async {
    final previousIsLiked = _getCurrentIsLiked(id, type);
    if (previousIsLiked == null) return;

    final optimisticIsLiked = !previousIsLiked;
    updateLikeLocal(id, type, optimisticIsLiked);
    _ref
        .read(feedNotifierProvider.notifier)
        .updateLikeLocal(id, type, optimisticIsLiked);

    try {
      final isLiked = await _homeService.toggleLike(id, type);
      if (isLiked != optimisticIsLiked) {
        updateLikeLocal(id, type, isLiked);
        _ref.read(feedNotifierProvider.notifier).updateLikeLocal(id, type, isLiked);
      }
    } catch (e) {
      updateLikeLocal(id, type, previousIsLiked);
      _ref
          .read(feedNotifierProvider.notifier)
          .updateLikeLocal(id, type, previousIsLiked);
    }
  }
}

final dashboardNotifierProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final notifier = DashboardNotifier(ref.watch(homeServiceProvider), ref);
  // Auto-resume loads when connectivity is restored.
  ref.listen<AsyncValue<bool>>(
    connectivityStatusProvider,
    notifier.handleConnectivityChange,
  );
  return notifier;
});

class FeedState {
  final List<dynamic> items;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool loadMoreError;

  FeedState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.loadMoreError = false,
  });

  FeedState copyWith({
    List<dynamic>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    bool? loadMoreError,
  }) {
    return FeedState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError ?? this.loadMoreError,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final HomeService _homeService;
  final Ref _ref;

  FeedNotifier(this._homeService, this._ref) : super(FeedState());

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

    if (state.items.isEmpty) {
      loadFeed(refresh: true);
    } else if (state.loadMoreError) {
      state = state.copyWith(loadMoreError: false);
      loadFeed();
    }
  }

  Future<void> loadFeed({bool refresh = false}) async {
    // Guard against duplicate/looping calls. After a load-more failure we wait
    // for an explicit retry/refresh instead of re-firing on every scroll.
    if (state.isLoading || state.isLoadingMore) return;
    if (!refresh && (!state.hasMore || state.loadMoreError)) return;

    // Don't even attempt the API when there's no connection.
    if (!_isOnline) {
      if (!refresh) state = state.copyWith(loadMoreError: true);
      return;
    }

    final currentPage = refresh ? 1 : state.page;
    if (refresh) {
      state = FeedState(isLoading: true);
    } else {
      state = state.copyWith(isLoadingMore: true, loadMoreError: false);
    }

    try {
      final result = await _homeService.getFeed(
        page: currentPage,
        limit: AppConstants.defaultPageSize,
      );

      final List<dynamic> newItems = (result['feed'] as List).map((item) {
        if (item['feedType'] == 'event') {
          return EventModel.fromJson(item);
        } else {
          return PostModel.fromJson(item);
        }
      }).toList();

      state = state.copyWith(
        items: refresh ? newItems : [...state.items, ...newItems],
        page: currentPage + 1,
        hasMore: result['hasMore'] ?? false,
        isLoading: false,
        isLoadingMore: false,
        loadMoreError: false,
      );
    } catch (e) {
      // Mark the failure so the UI can show a retry control instead of looping.
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        loadMoreError: !refresh,
      );
    }
  }

  /// Manually retry loading the next page after a failure.
  void retryLoadFeed() {
    if (state.isLoading || state.isLoadingMore) return;
    state = state.copyWith(loadMoreError: false);
    loadFeed();
  }

  bool? _getCurrentIsLiked(String id, String type) {
    for (final item in state.items) {
      if (type == 'event' && item is EventModel && item.id == id) {
        return item.isLiked;
      }
      if (type == 'post' && item is PostModel && item.id == id) {
        return item.isLiked;
      }
    }
    return null;
  }

  void updateLikeLocal(String id, String type, bool isLiked) {
    final index = state.items.indexWhere((item) {
      if (type == 'event' && item is EventModel) return item.id == id;
      if (type == 'post' && item is PostModel) return item.id == id;
      return false;
    });

    if (index != -1) {
      final newItems = [...state.items];
      final item = newItems[index];
      if (item is EventModel) {
        newItems[index] = item.copyWith(
          isLiked: isLiked,
          likesCount: item.likesCount + (isLiked ? 1 : -1),
        );
      } else if (item is PostModel) {
        newItems[index] = item.copyWith(
          isLiked: isLiked,
          likesCount: item.likesCount + (isLiked ? 1 : -1),
        );
      }
      state = state.copyWith(items: newItems);
    }
  }

  Future<void> toggleLike(String id, String type) async {
    final previousIsLiked = _getCurrentIsLiked(id, type);
    if (previousIsLiked == null) return;

    final optimisticIsLiked = !previousIsLiked;
    updateLikeLocal(id, type, optimisticIsLiked);
    _ref
        .read(dashboardNotifierProvider.notifier)
        .updateLikeLocal(id, type, optimisticIsLiked);

    try {
      final isLiked = await _homeService.toggleLike(id, type);
      if (isLiked != optimisticIsLiked) {
        updateLikeLocal(id, type, isLiked);
        _ref
            .read(dashboardNotifierProvider.notifier)
            .updateLikeLocal(id, type, isLiked);
      }
    } catch (e) {
      updateLikeLocal(id, type, previousIsLiked);
      _ref
          .read(dashboardNotifierProvider.notifier)
          .updateLikeLocal(id, type, previousIsLiked);
    }
  }
}

final feedNotifierProvider =
    StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final notifier = FeedNotifier(ref.watch(homeServiceProvider), ref);
  // Auto-resume loads when connectivity is restored.
  ref.listen<AsyncValue<bool>>(
    connectivityStatusProvider,
    notifier.handleConnectivityChange,
  );
  return notifier;
});
