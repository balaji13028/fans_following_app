import 'package:aa_fans/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import '../auth/presentation/screens/sign_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Start fade animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Auto-scrolling images
          Row(
            children: [
              Expanded(
                child: ScrollingColumn(
                  imagePath: 'assets/images/center_slide.webp',
                  startFromBottom: false,
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: ScrollingColumn(
                  imagePath: 'assets/images/left_slide.webp',
                  startFromBottom: true, // Scrolls down first
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: ScrollingColumn(
                  imagePath: 'assets/images/right_slide.webp',
                  startFromBottom: false,
                ),
              ),
            ],
          ),

          // Bottom shaded section for content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black,
                    Colors.black,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.05, 0.2, 0.35, 1.0],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // AA Logo Placeholder (or use splash.webp if it's the logo)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo/aa.png',
                          width: 60,
                          height: 60,
                          color: Colors.white,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ALLU ARJUN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'FANS ASSOCIATION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const SignUpScreen(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const SignInScreen(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 1),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScrollingColumn extends StatefulWidget {
  final String imagePath;
  final bool startFromBottom;

  const ScrollingColumn({
    super.key,
    required this.imagePath,
    this.startFromBottom = false,
  });

  @override
  State<ScrollingColumn> createState() => _ScrollingColumnState();
}

class _ScrollingColumnState extends State<ScrollingColumn> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() async {
    if (!mounted) return;

    // Wait a brief moment to ensure the layout is fully built
    await Future.delayed(const Duration(milliseconds: 100));

    int scrollCount = 0;
    bool initialPositionSet = false;
    _isScrolling = true;

    while (_isScrolling && mounted && scrollCount < 2) {
      if (!_scrollController.hasClients) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      final maxExtent = _scrollController.position.maxScrollExtent;
      final minExtent = _scrollController.position.minScrollExtent;

      // If the image fits exactly on screen, there is nowhere to scroll
      if (maxExtent == minExtent) {
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }

      // Set initial position once we have a valid maxExtent
      if (!initialPositionSet) {
        if (widget.startFromBottom) {
          _scrollController.jumpTo(maxExtent);
        }
        initialPositionSet = true;
      }

      // Determine the target offset (bounce back and forth)
      final double target = _scrollController.offset <= minExtent + 10
          ? maxExtent
          : minExtent;

      final distance = (target - _scrollController.offset).abs();
      // Scroll speed: 50 pixels per second
      final durationMilliseconds = (distance / 50 * 1000).toInt();

      if (durationMilliseconds > 0) {
        try {
          await _scrollController.animateTo(
            target,
            duration: Duration(milliseconds: durationMilliseconds),
            curve: Curves.linear,
          );
          scrollCount++;
        } catch (e) {
          // Exception can happen if the controller is disposed while animating
          break;
        }
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  void dispose() {
    _isScrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics:
          const NeverScrollableScrollPhysics(), // User shouldn't manually scroll it
      child: Column(
        children: [
          Image.asset(
            widget.imagePath,
            fit: BoxFit.fitWidth,
            width: double.infinity,
          ),
          Image.asset(
            widget.imagePath,
            fit: BoxFit.fitWidth,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
