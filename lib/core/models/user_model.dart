class UserModel {
  String username;
  String name;
  String bio;
  String? avatarUrl;
  int postsCount;
  int followersCount;
  int followingCount;
  bool isFollowing;

  UserModel({
    required this.username,
    required this.name,
    this.bio = '',
    this.avatarUrl,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: (json['login'] ?? json['username'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      avatarUrl: json['profile_image']?.toString() ?? json['avatar_url']?.toString(),
      followersCount: _toInt(json['followers_number']),
      followingCount: _toInt(json['following_number']),
      isFollowing: json['you_follow'] == true,
    );
  }

  static int _toInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
}
