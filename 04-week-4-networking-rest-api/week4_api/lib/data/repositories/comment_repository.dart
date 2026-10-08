import 'package:dio/dio.dart';
import '../models/comment.dart';

class CommentRepository {
  // Menerima dio instance dari provider agar terpusat
  CommentRepository(this._dio);
  final Dio _dio;

  // Method fetchComments(postId) + timeout 10 detik
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
      // Timeout 10 detik sesuai requirement codelab
      options: Options(
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
