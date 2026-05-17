import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/post_model.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../dashboard/presentation/widgets/video_player_widget.dart';

class PostDetailScreen extends ConsumerWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  String _getRelativeTime(DateTime dateTime) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to changes for this specific post in the dashboard state
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final currentPost = dashboardState.posts.firstWhere(
      (p) => p.id == post.id,
      orElse: () => post,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Post Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentPost.videoUrl != null)
              VideoPlayerWidget(videoUrl: currentPost.videoUrl!)
            else if (currentPost.imageUrl != null)
              CachedNetworkImage(
                imageUrl: currentPost.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: Colors.grey[900],
                  child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 300,
                  color: Colors.grey[900],
                  child: const Icon(Icons.error, color: Colors.white),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentPost.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref
                            .read(dashboardNotifierProvider.notifier)
                            .toggleLike(currentPost.id, 'post'),
                        icon: Icon(
                          currentPost.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: currentPost.isLiked ? Colors.red : Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white60, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _getRelativeTime(currentPost.postedOn),
                        style: const TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.thumb_up_alt_outlined, color: Colors.white60, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${currentPost.likesCount} Likes',
                        style: const TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (currentPost.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: currentPost.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      )).toList(),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentPost.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
