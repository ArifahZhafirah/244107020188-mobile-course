class Comment {
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  // fromJson aman null sesuai requirement codelab
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: int.tryParse(json['postId']?.toString() ?? '') ?? 0,
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
    );
  }
}
