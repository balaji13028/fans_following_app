import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../feed/data/models/event_model.dart';
import '../../../feed/data/models/post_model.dart';
import '../providers/dashboard_provider.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../feed/presentation/screens/event_detail_screen.dart';
import '../../../feed/presentation/screens/post_detail_screen.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(feedNotifierProvider).items.isEmpty) {
        ref.read(feedNotifierProvider.notifier).loadFeed();
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedNotifierProvider.notifier).loadFeed();
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);

    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s ago';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else if (duration.inDays < 30) {
      return '${duration.inDays}d ago';
    } else if (duration.inDays < 365) {
      final months = (duration.inDays / 30).floor();
      return '${months}m ago';
    } else {
      final years = (duration.inDays / 365).floor();
      return '${years}yrs ago';
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(2)}m';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedNotifierProvider);
    final feedItems = feedState.items;
    final hasMore = feedState.hasMore;
    final isLoading = feedState.isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Updates',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: feedItems.isEmpty && isLoading
          ? ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 140),
              itemCount: 5,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Skeleton(height: 350, borderRadius: 12, width: double.infinity),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(feedNotifierProvider.notifier).loadFeed(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8, bottom: 140),
                itemCount: feedItems.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == feedItems.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white70),
                      ),
                    );
                  }

                  final item = feedItems[index];
                  if (item is EventModel) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailScreen(event: item),
                          ),
                        );
                      },
                      child: _buildNotificationCard(
                        id: item.id,
                        type: 'event',
                        title: item.name,
                        hashtags: [
                          '#TFC',
                          '#NewEvent',
                        ], // Mocking hashtags for now
                        description:
                            'Join us for ${item.name} at ${item.location ?? "TBA"}.',
                        imageUrl: item.imageUrl,
                        likesCount: item.likesCount,
                        createdAt: item.createdAt,
                        isLiked: item.isLiked,
                      ),
                    );
                  } else if (item is PostModel) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(post: item),
                          ),
                        );
                      },
                      child: _buildNotificationCard(
                        id: item.id,
                        type: 'post',
                        title: item.title,
                        hashtags: item.tags.map((t) => '#$t').toList(),
                        description: item.description,
                        imageUrl: item.imageUrl,
                        likesCount: item.likesCount,
                        createdAt: item.postedOn,
                        isLiked: item.isLiked,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
    );
  }

  Widget _buildNotificationCard({
    required String id,
    required String type,
    required String title,
    required List<String> hashtags,
    required String description,
    String? imageUrl,
    required int likesCount,
    required DateTime createdAt,
    required bool isLiked,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Dark grey background like in image
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          if (hashtags.isNotEmpty)
            Text(
              hashtags.join(' '),
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => ref.read(feedNotifierProvider.notifier).toggleLike(id, type),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white60,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatCount(likesCount),
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.white60,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimeAgo(createdAt),
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
