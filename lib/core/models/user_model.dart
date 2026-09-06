class UserModel {
  final String username;
  final String name;
  final String? avatarUrl;
  final int followersCount;
  final int followingCount;
  bool isFollowing;

  UserModel({
    required this.username,
    required this.name,
    this.avatarUrl,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: (json['login'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      avatarUrl: json['profile_image']?.toString(),
      followersCount: (json['followers_number'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_number'] as num?)?.toInt() ?? 0,
      isFollowing: json['you_follow'] == true,
    );
  }
}
