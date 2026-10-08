import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'providers.dart'; // import untuk menggunakan dioProvider
import 'models/comment.dart';
import 'repositories/comment_repository.dart';

// Provider untuk CommentRepository
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

// AsyncNotifierProvider dengan penanganan error otomatis
class CommentListNotifier extends FamilyAsyncNotifier<List<Comment>, int> {
  @override
  Future<List<Comment>> build(int arg) async {
    // Exception akan otomatis menjadi AsyncError
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(arg);
  }
}

final commentListProvider =
    AsyncNotifierProviderFamily<CommentListNotifier, List<Comment>, int>(
        CommentListNotifier.new);

// Fungsi pesan error ramah pengguna (timeout, connection error, 404, 500)
String friendlyCommentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi ke komentar lambat atau timeout (10s). Coba lagi.';
      case DioExceptionType.connectionError:
        return 'Gagal mengambil komentar. Periksa internet Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode ?? 0;
        if (code == 404) return 'Komentar tidak ditemukan (404).';
        if (code >= 500) return 'Server komentar bermasalah ($code). Coba lagi nanti.';
        return 'Terjadi masalah akses komentar ($code).';
      default:
        return 'Terjadi kesalahan jaringan pada komentar.';
    }
  }
  return 'Terjadi kesalahan tak terduga: $error';
}
