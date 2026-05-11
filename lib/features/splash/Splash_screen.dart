import 'package:flutter/material.dart';
import '../onBoarding/on_boarding_screen.dart';
import '../dashboard/presentation/screens/dashboard_screen.dart';
import '../../core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startAnimationAndNavigate();
  }

  Future<void> _startAnimationAndNavigate() async {
    // Small initial delay before starting animation
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // 1. Fade in the logo
    await _controller.forward();

    // 2. Hold the splash screen for 2 seconds
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // 3. Fade out the logo
    await _controller.reverse();

    // 4. Navigate based on login status
    if (mounted) {
      final bool isLoggedIn = StorageService.isLoggedIn;
      
      Widget nextScreen = isLoggedIn 
          ? const DashboardScreen() 
          : const OnboardingScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/images/splash.webp',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
