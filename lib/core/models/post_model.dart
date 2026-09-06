import 'user_model.dart';

class PostModel {
  final int id;
  final int? replyToId;
  final UserModel author;
  final String content;
  final DateTime createdAt;
  int likesCount;
  int commentsCount;
  bool isLiked;

  PostModel({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.replyToId,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: (json['id'] as num).toInt(),
      replyToId: (json['post_id'] as num?)?.toInt(),
      author: UserModel.fromJson(
        Map<String, dynamic>.from(json['user'] as Map),
      ),
      content: (json['message'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      likesCount: (json['likes_number'] as num?)?.toInt() ?? 0,
      commentsCount: (json['replies_number'] as num?)?.toInt() ?? 0,
      isLiked: json['you_liked'] == true,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt.toLocal());
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}';
  }
}
