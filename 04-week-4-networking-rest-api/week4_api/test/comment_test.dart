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

  test('Comment.fromJson menangani tipe data yang salah dengan aman', () {
    // Edge case: tipe data pada JSON tidak sesuai (misal int menjadi string)
    // Walau dari json server API tidak tertulis ini, ini case robust-nya model.
    final jsonMap = {
      'id': '102', // harusnya num/int
      'postId': null, // null eksplisit
      'name': 123, // harusnya string
      'email': true, // harusnya string
      'body': [], // harusnya string
    };

    final comment = Comment.fromJson(jsonMap);

    expect(comment.id, 102); // string '102' berhasil diparsing
    expect(comment.postId, 0); // Fallback null
    // toString() mem-parsing tipe lain menjadi representasi string
    expect(comment.name, '123'); 
    expect(comment.email, 'true'); 
    expect(comment.body, '[]'); 
  });
}
