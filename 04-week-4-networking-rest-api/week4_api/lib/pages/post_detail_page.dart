import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/paged_posts.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(postId) ?? 0;
    final state = ref.watch(pagedPostsProvider);
    
    final post = state.items.where((p) => p.id == id).firstOrNull;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Post')),
      body: post == null 
        ? const Center(child: Text('Data tidak ditemukan atau belum dimuat.'))
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text(post.body),
              ],
            ),
          ),
    );
  }
}
