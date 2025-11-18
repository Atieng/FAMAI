import 'package:flutter/material.dart';
import 'package:famai/models/post_model.dart';
import 'package:famai/services/community_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _communityService = CommunityService();
  final _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final isLiked = _currentUser != null && widget.post.likes.contains(_currentUser.uid);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.post.authorImageUrl != null
                      ? NetworkImage(widget.post.authorImageUrl!)
                      : null,
                  child: widget.post.authorImageUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.post.authorName, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      widget.post.timestamp.toDate().toLocal().toString().split(' ')[0],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(widget.post.text),
            if (widget.post.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Image.network(widget.post.imageUrl!),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _communityService.toggleLike(widget.post.id, isLiked);
                  },
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    color: isLiked ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                  label: Text('${widget.post.likes.length} Likes'),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to comment screen
                  },
                  icon: const Icon(Icons.comment_outlined),
                  label: const Text('Comments'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
