import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/connectivity_provider.dart';
import '../theme/app_colors.dart';

/// Shows a transient "No internet connection" SnackBar that auto-dismisses
/// after a few seconds.
void showNoInternetSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No internet connection',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
}

/// Runs [onConnected] only when the internet is actually reachable (verified
/// with a real connectivity check, not just an interface check). Otherwise it
/// surfaces a transient "No internet connection" SnackBar so the user knows why
/// the retry didn't do anything.
Future<void> retryIfOnline(
  BuildContext context,
  WidgetRef ref,
  VoidCallback onConnected,
) async {
  final hasNet = await ref.read(connectivityServiceProvider).hasConnection();
  if (!context.mounted) return;
  if (!hasNet) {
    showNoInternetSnackBar(context);
    return;
  }
  onConnected();
}
