import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../feed/data/models/social_link_model.dart';
import '../../../feed/presentation/screens/event_detail_screen.dart';
import '../../../feed/presentation/screens/post_detail_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/video_player_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/skeleton.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentEventIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardNotifierProvider.notifier).loadDashboard();
    });
  }

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

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(2)}m';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  String _formatEventDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd-MMM, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final events = dashboardState.events;
    final posts = dashboardState.posts;
    final socialLinks = dashboardState.socialLinks;

    if (dashboardState.isLoading && events.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          title: Image.asset('assets/logo/aa.png', height: 60),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Skeleton(
                  height: 220,
                  borderRadius: 16,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 36),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Skeleton(height: 20, width: 150),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Skeleton(height: 40, width: 100, borderRadius: 20),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Skeleton(height: 20, width: 120),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Skeleton(
                    height: 300,
                    borderRadius: 16,
                    width: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/logo/aa.png', height: 50),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: (authState.user?.profileImageUrl != null)
                  ? NetworkImage(authState.user!.profileImageUrl!)
                  : const AssetImage('assets/images/profile_placeholder.png')
                        as ImageProvider,
              backgroundColor: Colors.grey[800],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.white,
        onRefresh: () =>
            ref.read(dashboardNotifierProvider.notifier).loadDashboard(),
        child:
            (!dashboardState.isLoading &&
                events.isEmpty &&
                posts.isEmpty &&
                socialLinks.isEmpty)
            ? LayoutBuilder(
                builder: (context, constraints) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.4),
                    const Center(
                      child: Text(
                        'No data found',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Upcoming Events Carousel
                    if (events.isNotEmpty) ...[
                      SizedBox(
                        height: 220,
                        child: PageView.builder(
                          itemCount: events.length,
                          onPageChanged: (index) =>
                              setState(() => _currentEventIndex = index),
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventDetailScreen(event: event),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: event.imageUrl != null
                                        ? NetworkImage(event.imageUrl!)
                                        : const AssetImage(
                                                'assets/images/event_placeholder.png',
                                              )
                                              as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.8),
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event.name,
                                                  style: const TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  event.location ?? "TBA",
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${_formatEventDate(event.date)}  •  ${event.time}',
                                                  style: const TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => ref
                                                .read(
                                                  dashboardNotifierProvider
                                                      .notifier,
                                                )
                                                .toggleLike(event.id, 'event'),
                                            icon: Icon(
                                              event.isLiked
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: event.isLiked
                                                  ? Colors.red
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          events.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentEventIndex == index
                                  ? Colors.white
                                  : Colors.white24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Visibility(
                      visible: socialLinks.isNotEmpty,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Stay Connected',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: socialLinks.length,
                              itemBuilder: (context, index) {
                                final link = socialLinks[index];
                                final color = _getSocialColor(link.name);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    splashColor: color.withValues(alpha: 0.3),
                                    highlightColor: color.withValues(
                                      alpha: 0.1,
                                    ),
                                    onTap: () async {
                                      final uri = Uri.parse(link.url);
                                      try {
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } catch (e) {
                                        debugPrint(
                                          'Could not launch ${link.url}: $e',
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(
                                              0xFF1A1A1A,
                                            ).withValues(alpha: 0.9),
                                            const Color(
                                              0xFF1A1A1A,
                                            ).withValues(alpha: 0.5),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: color.withValues(alpha: 0.5),
                                          width: 0.4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withValues(
                                              alpha: 0.25,
                                            ),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 8,
                                            sigmaY: 8,
                                          ),
                                          child: Center(
                                            child: _buildSocialImage(link),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    // Stay Connected

                    // Latest Buzz
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Latest Buzz',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostDetailScreen(post: post),
                              ),
                            );
                          },
                          onDoubleTap: () => ref
                              .read(dashboardNotifierProvider.notifier)
                              .toggleLike(post.id, 'post'),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (post.tags.isNotEmpty)
                                  Text(
                                    post.tags.map((t) => '#$t').join(' '),
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  post.description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                                if (post.videoUrl != null) ...[
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: VideoPlayerWidget(
                                      videoUrl: post.videoUrl!,
                                    ),
                                  ),
                                ] else if (post.imageUrl != null) ...[
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: post.imageUrl!,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      fadeInDuration: Duration.zero,
                                      fadeOutDuration: Duration.zero,
                                      placeholder: (context, url) => Container(
                                        height: 200,
                                        width: double.infinity,
                                        color: Colors.grey[800],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            height: 200,
                                            width: double.infinity,
                                            color: Colors.grey[800],
                                            child: const Icon(
                                              Icons.error,
                                              color: Colors.white,
                                            ),
                                          ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => ref
                                              .read(
                                                dashboardNotifierProvider
                                                    .notifier,
                                              )
                                              .toggleLike(post.id, 'post'),
                                          child: Icon(
                                            post.isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: post.isLiked
                                                ? Colors.red
                                                : Colors.white60,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatCount(post.likesCount),
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 13,
                                          ),
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
                                          _getRelativeTime(post.postedOn),
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 140), // Bottom padding for scroll
                  ],
                ),
              ),
      ),
    );
  }

  Color _getSocialColor(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('instagram')) return Colors.pinkAccent;
    if (lowerName.contains('facebook')) return Colors.blue;
    if (lowerName.contains('x') || lowerName.contains('twitter')) {
      return Colors.cyanAccent;
    }
    if (lowerName.contains('telegram')) return Colors.lightBlue;
    return Colors.white70;
  }

  Widget _buildSocialImage(SocialLinkModel link) {
    if (link.image == null || link.image!.isEmpty) {
      return _getSocialIcon(link.name);
    }

    if (link.image!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: link.image!,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        placeholder: (context, url) => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => _getSocialIcon(link.name),
      );
    } else if (link.image!.endsWith('.svg')) {
      return SvgPicture.asset(link.image!, width: 32, height: 32);
    } else if (link.image!.startsWith('assets/')) {
      return Image.asset(
        link.image!,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      );
    }

    return _getSocialIcon(link.name);
  }

  Widget _getSocialIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('instagram')) {
      return const Icon(Icons.camera_alt, color: Colors.pinkAccent, size: 28);
    } else if (lowerName.contains('facebook')) {
      return const Icon(Icons.facebook, color: Colors.blue, size: 28);
    } else if (lowerName.contains('x') || lowerName.contains('twitter')) {
      return const Icon(Icons.close, color: Colors.cyanAccent, size: 28);
    } else if (lowerName.contains('telegram')) {
      return const Icon(Icons.telegram, color: Colors.lightBlue, size: 28);
    }
    return const Icon(Icons.link, color: Colors.white, size: 28);
  }
}
