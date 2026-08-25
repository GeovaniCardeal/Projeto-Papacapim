import 'user_model.dart';

class PostModel {
  final String id;
  final UserModel author;
  final String content;
  final String? imageUrl;
  final String timeAgo;
  int likesCount;
  int dislikesCount;
  int commentsCount;
  bool isLiked;
  bool isDisliked;
  final String? replyToId;

  PostModel({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    required this.timeAgo,
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isDisliked = false,
    this.replyToId,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: '${json['id']}',
      author: UserModel.fromJson((json['user'] ?? {}) as Map<String, dynamic>),
      content: (json['message'] ?? '').toString(),
      imageUrl: json['image_url']?.toString(),
      timeAgo: _timeAgo(json['created_at']?.toString()),
      likesCount: _toInt(json['likes_number']),
      commentsCount: _toInt(json['replies_number']),
      isLiked: json['you_liked'] == true,
      replyToId: json['post_id'] == null ? null : '${json['post_id']}',
    );
  }

  static int _toInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

  static String _timeAgo(String? value) {
    if (value == null) return '';
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}
