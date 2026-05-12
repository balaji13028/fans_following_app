import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/services/home_service.dart';
import '../../../feed/data/models/event_model.dart';
import '../../../feed/data/models/post_model.dart';
import '../../../feed/data/models/social_link_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _homeService = HomeService();
  List<EventModel> _events = [];
  List<PostModel> _posts = [];
  List<SocialLinkModel> _socialLinks = [];
  bool _isLoading = true;
  int _currentEventIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _homeService.getDashboardData();
      if (mounted) {
        setState(() {
          _events = data['events'];
          _posts = data['posts'];
          _socialLinks = data['socialMedia'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/logo/aa.png',
          height: 35,
          // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
      body: RefreshIndicator(
        color: Colors.white,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Upcoming Events Carousel
              if (_events.isNotEmpty) ...[
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    itemCount: _events.length,
                    onPageChanged: (index) =>
                        setState(() => _currentEventIndex = index),
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                          '${event.location ?? "TBA"} • ${event.date}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _homeService.toggleLike(
                                      event.id,
                                      'event',
                                    ),
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
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _events.length,
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

              // Stay Connected
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
                child: Builder(
                  builder: (context) {
                    final displayLinks = _socialLinks.isNotEmpty
                        ? _socialLinks
                        : [
                            SocialLinkModel(
                              id: '1',
                              name: 'Instagram',
                              url: 'https://www.instagram.com/alluarjunonline/',
                              image: 'assets/icons/instagram.svg',
                            ),
                            SocialLinkModel(
                              id: '2',
                              name: 'Facebook',
                              url: 'https://facebook.com/AlluArjun',
                              image: 'assets/icons/Facebook.svg',
                            ),
                            SocialLinkModel(
                              id: '3',
                              name: 'X',
                              url: 'https://x.com/alluarjun',
                              image: 'assets/icons/x.svg',
                            ),
                          ];

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: displayLinks.length,
                      itemBuilder: (context, index) {
                        final link = displayLinks[index];
                        final color = _getSocialColor(link.name);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            splashColor: color.withValues(alpha: 0.3),
                            highlightColor: color.withValues(alpha: 0.1),
                            onTap: () async {
                              final uri = Uri.parse(link.url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
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
                                    color: color.withValues(alpha: 0.25),
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
                                  child: Center(child: _buildSocialImage(link)),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
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
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
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
                              const SizedBox(height: 4),
                              if (post.tags.isNotEmpty)
                                Text(
                                  post.tags.join(', '),
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                post.description,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (post.imageUrl != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                            child: Image.network(
                              post.imageUrl!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 100), // Bottom padding for scroll
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
