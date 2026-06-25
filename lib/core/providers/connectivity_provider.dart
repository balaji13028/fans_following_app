import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/connectivity_service.dart';

/// Provides the singleton [ConnectivityService].
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Streams the current internet connectivity status.
///
/// Emits `true` when the internet is reachable and `false` when it is not.
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).statusStream;
});
