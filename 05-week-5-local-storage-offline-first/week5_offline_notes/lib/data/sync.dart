import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'local/db.dart';
import 'local/post.dart';
import 'repositories/note_repository.dart';

final forceOfflineProvider = NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void setOffline(bool value) {
    state = value;
  }
}

final syncRepositoryProvider = Provider((ref) {
  final isOffline = ref.watch(forceOfflineProvider);
  return SyncRepository(forceOffline: isOffline);
});

final postsCacheProvider = FutureProvider<List<Post>>((ref) async {
  final repo = ref.watch(syncRepositoryProvider);
  return repo.loadPostsCacheFirst(ref);
});

class RefreshErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setError(String? error) => state = error;
}
final refreshErrorProvider = NotifierProvider<RefreshErrorNotifier, String?>(RefreshErrorNotifier.new);

class IsFromNetworkNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setNetwork(bool value) => state = value;
}
final isFromNetworkProvider = NotifierProvider<IsFromNetworkNotifier, bool>(IsFromNetworkNotifier.new);

class LastCacheTimeNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;
  void setTime(DateTime? time) => state = time;
}
final lastCacheTimeProvider = NotifierProvider<LastCacheTimeNotifier, DateTime?>(LastCacheTimeNotifier.new);

class SyncRepository {
  final bool forceOffline;
  final Dio _dio = Dio();
  
  SyncRepository({this.forceOffline = false});

  Future<List<Post>> readCachedPosts(Ref ref) async {
    final db = await openNotesDb();
    final rows = await db.query('cached_posts', orderBy: 'cached_at DESC', limit: 1);
    if (rows.isNotEmpty) {
      final payload = rows.first['payload'] as String;
      final cachedAtStr = rows.first['cached_at'] as String;
      Future.microtask(() {
        ref.read(lastCacheTimeProvider.notifier).setTime(DateTime.tryParse(cachedAtStr));
      });
      final List<dynamic> jsonList = jsonDecode(payload);
      return jsonList.map((e) => Post.fromMap(e)).toList();
    }
    return [];
  }

  Future<void> refreshPostsInBackground(Ref ref) async {
    if (forceOffline) return;
    
    try {
      final response = await _dio.get('https://jsonplaceholder.typicode.com/posts');
      if (response.statusCode == 200) {
        ref.read(refreshErrorProvider.notifier).setError(null);
        ref.read(isFromNetworkProvider.notifier).setNetwork(true);
        
        final newPayload = jsonEncode(response.data);
        final db = await openNotesDb();
        
        final rows = await db.query('cached_posts', where: 'id = 1');
        String? oldPayload;
        if (rows.isNotEmpty) {
          oldPayload = rows.first['payload'] as String;
        }
        
        final now = DateTime.now();
        if (newPayload != oldPayload) {
          await db.insert(
            'cached_posts',
            {
              'id': 1,
              'payload': newPayload,
              'cached_at': now.toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          ref.read(lastCacheTimeProvider.notifier).setTime(now);
          ref.invalidate(postsCacheProvider);
        } else {
          // Tetap update waktu cache meskipun data sama
          await db.update('cached_posts', {'cached_at': now.toIso8601String()}, where: 'id = 1');
          ref.read(lastCacheTimeProvider.notifier).setTime(now);
        }
      }
    } catch (e) {
      ref.read(refreshErrorProvider.notifier).setError('Gagal refresh: Server bermasalah (500). Coba lagi nanti.\nMenampilkan cache.');
      ref.read(isFromNetworkProvider.notifier).setNetwork(false);
    }
  }

  Future<List<Post>> loadPostsCacheFirst(Ref ref) async {
    Future.microtask(() {
      ref.read(isFromNetworkProvider.notifier).setNetwork(false);
      ref.read(refreshErrorProvider.notifier).setError(null);
    });
    final cached = await readCachedPosts(ref);
    refreshPostsInBackground(ref);
    return cached;
  }

  Future<int> syncNotes(NoteRepository repo) async {
    if (forceOffline) throw Exception('Offline mode is active');
    
    final dirtyCount = await repo.countDirty();
    if (dirtyCount == 0) return 0;
    
    await Future.delayed(const Duration(seconds: 1));
    await repo.markAllSynced();
    return dirtyCount;
  }
}
