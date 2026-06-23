import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;

  const DashboardScreen({super.key, this.initialIndex = 1});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const NotificationsScreen(),
    const HomeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: Stack(
        children: [
          _screens[_currentIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFloatingBottomNav(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomNav(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      height: 75,
      margin: EdgeInsets.fromLTRB(20, 0, 20, 10 + bottomPadding),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              0,
              Icons.auto_awesome_mosaic_rounded,
              Icons.auto_awesome_mosaic_outlined,
              'Updates',
            ),
            _buildNavItem(
              1,
              Icons.home_rounded,
              Icons.home_outlined,
              'Home',
              isLarge: true,
            ),
            _buildNavItem(
              2,
              Icons.person_rounded,
              Icons.person_outline_rounded,
              'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData selectedIcon,
    IconData unselectedIcon,
    String label, {
    bool isLarge = false,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = AppColors.primary; // The trendy indigo/purple color

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? activeColor : Colors.white54,
              size: isLarge ? 28 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : Colors.white54,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
