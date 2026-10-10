import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

/// Provider repository komentar, memakai Dio terpusat dari dioProvider.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// Notifier untuk daftar komentar milik satu post.
/// Di Riverpod 3, parameter family diterima lewat constructor.
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  CommentListNotifier(this.postId);

  final int postId;

  @override
  Future<List<Comment>> build() async {
    // Exception dari repository otomatis menjadi AsyncError.
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(postId);
  }
}

final commentListProvider =
    AsyncNotifierProvider.family<CommentListNotifier, List<Comment>, int>(
  CommentListNotifier.new,
  // Nonaktifkan retry otomatis agar error langsung final dan mudah diuji.
  retry: (retryCount, error) => null,
);