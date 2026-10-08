import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  test('Comment.fromJson aman terhadap field yang hilang (null safety)', () {
    // Memberikan JSON yang tidak memiliki field name, email, dan body
    final jsonMap = {
      'id': 101,
      'postId': 1,
      // name, email, dan body sengaja dihilangkan untuk menguji penanganan null
    };

    final comment = Comment.fromJson(jsonMap);

    // Memastikan nilai default diberikan ketika field hilang
    expect(comment.id, 101);
    expect(comment.postId, 1);
    expect(comment.name, ''); // String kosong sebagai fallback
    expect(comment.email, ''); // String kosong sebagai fallback
    expect(comment.body, ''); // String kosong sebagai fallback
  });
}
