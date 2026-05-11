import 'package:flutter/material.dart';
import '../../data/services/home_service.dart';
import '../../../feed/data/models/event_model.dart';
import '../../../feed/data/models/post_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final HomeService _homeService = HomeService();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _feedItems = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
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
      if (!_isLoading && _hasMore) {
        _loadFeed();
      }
    }
  }

  Future<void> _loadFeed() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final result = await _homeService.getFeed(page: _page, limit: 15);
      final List<dynamic> newItems = (result['feed'] as List).map((item) {
        if (item['feedType'] == 'event') {
          return EventModel.fromJson(item);
        } else {
          return PostModel.fromJson(item);
        }
      }).toList();

      setState(() {
        _feedItems.addAll(newItems);
        _page++;
        _hasMore = result['hasMore'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading feed: $e')));
      }
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const AssetImage(
                'assets/images/profile_placeholder.png',
              ),
              backgroundColor: Colors.grey[800],
            ),
          ),
        ],
      ),
      body: _feedItems.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _feedItems = [];
                  _page = 1;
                  _hasMore = true;
                });
                await _loadFeed();
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _feedItems.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _feedItems.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white70),
                      ),
                    );
                  }

                  final item = _feedItems[index];
                  if (item is EventModel) {
                    return _buildNotificationCard(
                      title: item.name,
                      hashtags: [
                        '#TFC',
                        '#NewEvent',
                      ], // Mocking hashtags for now
                      description:
                          'Join us for ${item.name} at ${item.location ?? "TBA"}.',
                      imageUrl: item.imageUrl,
                      likesCount: item.likesCount,
                      createdAt: DateTime.parse(
                        item.date,
                      ), // Using date as createdAt for events
                      isLiked: item.isLiked,
                    );
                  } else if (item is PostModel) {
                    return _buildNotificationCard(
                      title: item.title,
                      hashtags: item.tags.map((t) => '#$t').toList(),
                      description: item.description,
                      imageUrl: item.imageUrl,
                      likesCount: item.likesCount,
                      createdAt: DateTime.now().subtract(
                        const Duration(hours: 4),
                      ), // Mocking time for now
                      isLiked: item.isLiked,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
    );
  }

  Widget _buildNotificationCard({
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
                  Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.white60,
                    size: 18,
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
