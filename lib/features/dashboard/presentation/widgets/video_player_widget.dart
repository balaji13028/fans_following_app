import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isExternalLink = false;

  bool _checkIsExternalLink(String url) {
    final lower = url.toLowerCase();
    return lower.contains('youtube.com') ||
           lower.contains('youtu.be') ||
           lower.contains('facebook.com') ||
           lower.contains('instagram.com') ||
           lower.contains('twitter.com') ||
           lower.contains('x.com');
  }

  String? _getYoutubeThumbnail(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    
    if (uri.host.contains('youtube.com')) {
      if (uri.queryParameters.containsKey('v')) {
        return 'https://img.youtube.com/vi/${uri.queryParameters['v']}/hqdefault.jpg';
      }
    } else if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) {
        return 'https://img.youtube.com/vi/${uri.pathSegments.first}/hqdefault.jpg';
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _isExternalLink = _checkIsExternalLink(widget.videoUrl);
    if (!_isExternalLink) {
      _initializePlayer();
    }
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_extractBasePath(widget.videoUrl) != _extractBasePath(oldWidget.videoUrl)) {
      final newIsExternal = _checkIsExternalLink(widget.videoUrl);
      _isExternalLink = newIsExternal;
      _isInitialized = false;
      _errorMessage = null;
      _videoPlayerController?.dispose();
      _chewieController?.dispose();
      _videoPlayerController = null;
      _chewieController = null;
      
      if (!newIsExternal) {
        _initializePlayer();
      }
    }
  }

  String _extractBasePath(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.scheme}://${uri.host}${uri.path}';
    } catch (e) {
      return url;
    }
  }

  Future<void> _initializePlayer() async {
    final sanitizedUrl = widget.videoUrl.trim();
    
    if (sanitizedUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _errorMessage = "The video URL is empty.";
        });
      }
      return;
    }

    try {
      final uri = Uri.parse(sanitizedUrl);
      _videoPlayerController = VideoPlayerController.networkUrl(
        uri,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await _videoPlayerController!.initialize().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception('Connection timed out. Check your internet or CDN speed.'),
      );
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          ),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.orange,
          handleColor: Colors.orange,
          backgroundColor: Colors.grey[800]!,
          bufferedColor: Colors.white.withOpacity(0.3),
        ),
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      debugPrint("Video initialization failed: $e");
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isExternalLink) {
      final thumbUrl = _getYoutubeThumbnail(widget.videoUrl);
      
      return Container(
        height: 250,
        width: double.infinity,
        color: Colors.black,
        child: InkWell(
          onTap: () async {
            final uri = Uri.parse(widget.videoUrl);
            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                await launchUrl(uri);
              }
            } catch (e) {
              debugPrint('Could not launch ${widget.videoUrl}: $e');
            }
          },
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              if (thumbUrl != null)
                CachedNetworkImage(
                  imageUrl: thumbUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  ),
                  errorWidget: (context, url, error) => const SizedBox(),
                ),
              if (thumbUrl != null)
                Container(color: Colors.black45),
              const Center(
                child: Icon(Icons.play_circle_fill, color: Colors.orange, size: 64),
              ),
            ],
          ),
        ),
      );
    }

    if (_videoPlayerController?.value.hasError ?? false || _errorMessage != null) {
      return Container(
        height: 250,
        width: double.infinity,
        color: Colors.black,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.orange, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Failed to load video',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'The video format is unsupported or the connection was lost.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'URL Preview: ${widget.videoUrl.substring(0, widget.videoUrl.length > 40 ? 40 : widget.videoUrl.length)}...',
              style: const TextStyle(color: Colors.white24, fontSize: 10),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                _initializePlayer();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}
