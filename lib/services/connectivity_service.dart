// lib/services/connectivity_service.dart
import 'dart:io';

/// Tells the repository whether the device currently has internet access.
///
/// Implemented with a pure-Dart DNS lookup ([InternetAddress.lookup]) instead
/// of a native plugin like `connectivity_plus`. This keeps the dependency
/// footprint small and avoids platform channel setup, while still giving a
/// real reachability check (not just "is wifi on", but "can we actually reach
/// a host"). Works on Android, iOS, desktop. On web `dart:io` is unavailable —
/// there the repository's try/cache fallback still keeps the app correct.
class ConnectivityService {
  final String _lookupHost;
  final Duration _timeout;

  const ConnectivityService({
    String lookupHost = 'example.com',
    Duration timeout = const Duration(seconds: 3),
  })  : _lookupHost = lookupHost,
        _timeout = timeout;

  /// Returns true if a DNS lookup succeeds within the timeout window.
  /// Never throws — any failure is treated as "offline".
  Future<bool> get isOnline async {
    try {
      final result =
          await InternetAddress.lookup(_lookupHost).timeout(_timeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
