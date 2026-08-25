import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../models/post_model.dart';
import 'user_avatar.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTapAuthor;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onReply;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.onTapAuthor,
    required this.onLike,
    required this.onDislike,
    required this.onReply,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTapAuthor,
            child: UserAvatar(radius: 20, imageUrl: post.author.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onTapAuthor,
                      child: Text(
                        post.author.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '@${post.author.username}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                    Text(post.timeAgo, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(post.content, style: const TextStyle(fontSize: 14, height: 1.35)),
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Image.network(post.imageUrl!, fit: BoxFit.cover),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    _PostAction(
                      icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? AppColors.like : AppColors.textSecondary,
                      label: '${post.likesCount}',
                      onTap: onLike,
                    ),
                    const SizedBox(width: 20),
                    _PostAction(
                      icon: post.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                      color: post.isDisliked ? AppColors.primary : AppColors.textSecondary,
                      label: '${post.dislikesCount}',
                      onTap: onDislike,
                    ),
                    const SizedBox(width: 20),
                    _PostAction(
                      icon: Icons.mode_comment_outlined,
                      color: AppColors.textSecondary,
                      label: '${post.commentsCount}',
                      onTap: onReply,
                    ),
                    if (onDelete != null) ...[
                      const Spacer(),
                      _PostAction(
                        icon: Icons.delete_outline,
                        color: AppColors.danger,
                        label: '',
                        onTap: onDelete!,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _PostAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}
