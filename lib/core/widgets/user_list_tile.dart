import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../models/user_model.dart';
import 'user_avatar.dart';

String _formatCount(int count) {
  if (count >= 1000) {
    final k = count / 1000;
    return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
  }
  return '$count';
}

class UserListTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final VoidCallback onToggleFollow;

  const UserListTile({
    super.key,
    required this.user,
    required this.onTap,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            UserAvatar(radius: 22, imageUrl: user.avatarUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username} · ${_formatCount(user.followersCount)} seguidores',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            _FollowButton(isFollowing: user.isFollowing, onTap: onToggleFollow),
          ],
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const _FollowButton({required this.isFollowing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.transparent : AppColors.primary,
        foregroundColor: isFollowing ? AppColors.textSecondary : Colors.white,
        side: BorderSide(color: isFollowing ? AppColors.border : AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        isFollowing ? 'Seguindo' : 'Seguir',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
