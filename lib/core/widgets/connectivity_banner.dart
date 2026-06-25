import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/connectivity_provider.dart';
import '../theme/app_colors.dart';

/// A YouTube-style connectivity banner meant to sit at the very top of a
/// screen's body (just below the AppBar).
///
/// - Shows a persistent red "No internet connection" bar while offline.
/// - Shows a brief green "Back online" bar when the connection returns, then
///   slides away automatically.
///
/// Place it as the first child of a `Column` body, e.g.
/// `body: Column(children: [const ConnectivityBanner(), Expanded(child: ...)])`.
class ConnectivityBanner extends ConsumerStatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  ConsumerState<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends ConsumerState<ConnectivityBanner> {
  bool _showBackOnline = false;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // React to transitions for the transient "Back online" confirmation.
    ref.listen<AsyncValue<bool>>(connectivityStatusProvider, (previous, next) {
      final wasOnline = previous?.value;
      final isOnline = next.value;

      if (isOnline == true && wasOnline == false) {
        _hideTimer?.cancel();
        setState(() => _showBackOnline = true);
        _hideTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showBackOnline = false);
        });
      } else if (isOnline == false && _showBackOnline) {
        _hideTimer?.cancel();
        setState(() => _showBackOnline = false);
      }
    });

    // Drive the offline bar off the current value so it stays visible even when
    // switching between screens while offline.
    final isOnline = ref.watch(connectivityStatusProvider).value ?? true;
    final show = !isOnline || _showBackOnline;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: show
          ? _Bar(online: isOnline)
          : const SizedBox(width: double.infinity),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: online ? AppColors.success : Colors.black,
      // A faint divider keeps the black bar visible against a black body.
      shape: online
          ? null
          : const Border(bottom: BorderSide(color: Colors.white24)),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                online ? 'Back online' : 'No internet connection',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
