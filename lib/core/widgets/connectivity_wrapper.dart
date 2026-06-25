import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/connectivity_provider.dart';

/// Keeps the global connectivity status stream alive for the whole app so that
/// polling runs regardless of which screen is shown.
///
/// The actual offline/online message is rendered per-screen by
/// [ConnectivityBanner] (a YouTube-style bar below the AppBar), so this widget
/// no longer shows a SnackBar itself.
class ConnectivityWrapper extends ConsumerWidget {
  const ConnectivityWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Subscribing here keeps the status stream (and its polling) active app-wide.
    ref.listen<AsyncValue<bool>>(connectivityStatusProvider, (_, _) {});
    return child;
  }
}
