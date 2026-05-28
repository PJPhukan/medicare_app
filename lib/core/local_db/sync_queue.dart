import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'local_cache.dart';

const _kQueueKey = 'sync_outbox_v1';
const _uuid = Uuid();

// ─── Outbox operation ─────────────────────────────────────────────────────────

class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.feature,
    required this.action,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });

  final String id;

  /// Feature namespace: 'schedule', 'vitals', 'medicines', 'reports'.
  final String feature;

  /// Specific action: 'mark_dose', 'add_reading', 'delete_medicine', 'delete_report'.
  final String action;

  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;

  String get key => '$feature:$action';

  factory SyncOperation.create({
    required String feature,
    required String action,
    required Map<String, dynamic> payload,
  }) =>
      SyncOperation(
        id: _uuid.v4(),
        feature: feature,
        action: action,
        payload: payload,
        createdAt: DateTime.now(),
      );

  SyncOperation incrementRetry() => SyncOperation(
        id: id,
        feature: feature,
        action: action,
        payload: payload,
        createdAt: createdAt,
        retryCount: retryCount + 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'feature': feature,
        'action': action,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory SyncOperation.fromJson(Map<String, dynamic> j) => SyncOperation(
        id: j['id'] as String,
        feature: j['feature'] as String,
        action: j['action'] as String,
        payload: (j['payload'] as Map).cast<String, dynamic>(),
        createdAt: DateTime.parse(j['createdAt'] as String),
        retryCount: j['retryCount'] as int? ?? 0,
      );
}

// ─── Queue ────────────────────────────────────────────────────────────────────

class SyncQueue {
  SyncQueue(this._prefs);
  final SharedPreferences _prefs;

  static const int maxRetries = 5;

  List<SyncOperation> get all {
    final s = _prefs.getString(_kQueueKey);
    if (s == null) return [];
    final list = jsonDecode(s) as List<dynamic>;
    return list
        .map((e) => SyncOperation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  bool get isEmpty => all.isEmpty;
  int get length => all.length;

  Future<void> enqueue(SyncOperation op) async {
    await _save([...all, op]);
  }

  Future<void> remove(String id) async {
    await _save(all.where((o) => o.id != id).toList());
  }

  Future<void> updateRetry(String id) async {
    await _save(all.map((o) => o.id == id ? o.incrementRetry() : o).toList());
  }

  Future<void> _save(List<SyncOperation> ops) async {
    await _prefs.setString(
      _kQueueKey,
      jsonEncode(ops.map((o) => o.toJson()).toList()),
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue(ref.read(sharedPreferencesProvider));
});
