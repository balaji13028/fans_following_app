import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors network connectivity and verifies actual internet reachability.
///
/// `connectivity_plus` only reports whether a network interface (wifi/mobile)
/// is available, not whether the internet is actually reachable, and its report
/// can be unreliable on simulators / VPNs. Reachability is therefore confirmed
/// with parallel probes (DNS lookups + raw TCP connects to public DNS IPs), and
/// the status is polled periodically so changes are detected without user
/// action.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Hosts used to verify real internet access. The first to respond wins.
  static const List<String> _lookupHosts = [
    'google.com',
    'cloudflare.com',
  ];

  /// How often we actively re-check real internet reachability.
  ///
  /// `connectivity_plus` only notifies on interface changes (wifi <-> mobile,
  /// etc.). When the internet drops or comes back on the *same* wifi, no event
  /// fires, so we poll to detect it within a few seconds.
  static const Duration _pollInterval = Duration(seconds: 4);

  Stream<bool>? _statusStream;

  /// Emits `true` when the device has a working internet connection and
  /// `false` otherwise. Only emits when the status actually changes.
  ///
  /// Combines OS interface-change events with periodic polling so that a
  /// connection that comes back while the user sits on a screen is detected
  /// automatically, with no user action.
  Stream<bool> get statusStream => _statusStream ??= _buildStatusStream();

  Stream<bool> _buildStatusStream() {
    final controller = StreamController<bool>.broadcast();
    Timer? timer;
    StreamSubscription<List<ConnectivityResult>>? subscription;
    bool? last;
    var checking = false;

    Future<void> check() async {
      if (checking) return;
      checking = true;
      try {
        final current = await hasConnection();
        if (current != last && !controller.isClosed) {
          last = current;
          controller.add(current);
        }
      } finally {
        checking = false;
      }
    }

    controller.onListen = () {
      check();
      timer = Timer.periodic(_pollInterval, (_) => check());
      subscription = _connectivity.onConnectivityChanged.listen((_) => check());
    };
    controller.onCancel = () {
      timer?.cancel();
      subscription?.cancel();
      timer = null;
      subscription = null;
      last = null;
    };

    return controller.stream;
  }

  /// Returns `true` if the internet is actually reachable.
  ///
  /// The reachability probe is the source of truth here rather than
  /// `connectivity_plus`'s interface report, which can be inaccurate on
  /// simulators / VPNs and cause false "offline" results.
  Future<bool> hasConnection() async {
    return _verifyInternet();
  }

  /// Fast check (no network round-trip) of whether any network interface is
  /// available. Use this to gate requests so we don't even attempt an API call
  /// when the device is clearly offline (e.g. airplane mode / wifi off).
  Future<bool> hasNetworkInterface() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<bool> _verifyInternet() async {
    // Probe several independent signals in parallel; the device is considered
    // online if ANY of them succeeds. Raw socket connects to well-known DNS
    // server IPs are the most reliable: they need no DNS resolution and aren't
    // subject to iOS App Transport Security, so they work whenever real
    // internet is available (even if google.com is slow/blocked).
    final probes = <Future<bool>>[
      ..._lookupHosts.map(_canResolve),
      _canConnect('1.1.1.1', 443),
      _canConnect('8.8.8.8', 53),
    ];

    try {
      final results = await Future.wait(probes);
      return results.any((reachable) => reachable);
    } catch (_) {
      return false;
    }
  }

  /// Returns true if [host] can be resolved via DNS.
  Future<bool> _canResolve(String host) async {
    try {
      final addresses = await InternetAddress.lookup(
        host,
      ).timeout(const Duration(seconds: 3));
      return addresses.isNotEmpty && addresses.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if a TCP connection to [host]:[port] can be opened.
  Future<bool> _canConnect(String host, int port) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 3),
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      socket?.destroy();
    }
  }
}
