import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  DashboardState({
    this.events = const [],
    this.posts = const [],
    this.socialLinks = const [],
    this.isLoading = false,
  });

  DashboardState copyWith({
    List<EventModel>? events,
    List<PostModel>? posts,
    List<SocialLinkModel>? socialLinks,
    bool? isLoading,
  }) {
    return DashboardState(
      events: events ?? this.events,
      posts: posts ?? this.posts,
      socialLinks: socialLinks ?? this.socialLinks,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final HomeService _homeService;
  final Ref _ref;

  DashboardNotifier(this._homeService, this._ref) : super(DashboardState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _homeService.getDashboardData();
      state = state.copyWith(
        events: data['events'],
        posts: data['posts'],
        socialLinks: state.socialLinks.isNotEmpty
            ? state.socialLinks
            : data['socialMedia'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
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
    try {
      final isLiked = await _homeService.toggleLike(id, type);
      updateLikeLocal(id, type, isLiked);
      // Also update feed if it exists
      _ref
          .read(feedNotifierProvider.notifier)
          .updateLikeLocal(id, type, isLiked);
    } catch (e) {
      // Handle error
    }
  }
}

final dashboardNotifierProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      return DashboardNotifier(ref.watch(homeServiceProvider), ref);
    });

class FeedState {
  final List<dynamic> items;
  final int page;
  final bool hasMore;
  final bool isLoading;

  FeedState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
  });

  FeedState copyWith({
    List<dynamic>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
  }) {
    return FeedState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final HomeService _homeService;
  final Ref _ref;

  FeedNotifier(this._homeService, this._ref) : super(FeedState());

  Future<void> loadFeed({bool refresh = false}) async {
    if (state.isLoading || (!state.hasMore && !refresh)) return;

    final currentPage = refresh ? 1 : state.page;
    if (refresh) {
      state = FeedState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final result = await _homeService.getFeed(page: currentPage, limit: 15);

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
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
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
    try {
      final isLiked = await _homeService.toggleLike(id, type);
      updateLikeLocal(id, type, isLiked);
      // Also update dashboard if it exists
      _ref
          .read(dashboardNotifierProvider.notifier)
          .updateLikeLocal(id, type, isLiked);
    } catch (e) {
      // Handle error
    }
  }
}

final feedNotifierProvider = StateNotifierProvider<FeedNotifier, FeedState>((
  ref,
) {
  return FeedNotifier(ref.watch(homeServiceProvider), ref);
});
