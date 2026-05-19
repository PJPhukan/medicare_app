import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream of connectivity results.
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Simple bool: true when at least one non-none result is present.
final isOnlineProvider = Provider<bool>((ref) {
  final results = ref.watch(connectivityStreamProvider).valueOrNull;
  if (results == null || results.isEmpty) return true; // optimistic default
  return results.any((r) => r != ConnectivityResult.none);
});

/// Async check (one-shot, not a stream).
Future<bool> checkConnectivity() async {
  final results = await Connectivity().checkConnectivity();
  return results.any((r) => r != ConnectivityResult.none);
}
