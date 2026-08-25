import '../../core/models/post_model.dart';
import '../../core/models/user_model.dart';

/// Fonte única de dados fictícios da Parte 1 (Design da interface).
/// Na Parte 2, este arquivo será substituído por chamadas reais à API,
/// mas os widgets devem continuar consumindo os mesmos models (UserModel/PostModel).
class MockData {
  MockData._();

  /// Usuário atualmente "logado" na simulação.
  static final currentUser = UserModel(
    username: 'giovanni',
    name: 'Giovanni',
    bio: 'Líder da Equipe Rocket',
    avatarUrl: 'assets/images/giovanni.jpg',
    postsCount: 1,
    followersCount: 128,
    followingCount: 97,
  );

  static final userN = UserModel(
    username: 'n',
    name: 'N',
    bio: 'Rei da Team Plasma',
    avatarUrl: 'assets/images/n.jpg',
    postsCount: 2,
    followersCount: 894,
    followingCount: 201,
    isFollowing: true,
  );

  static List<UserModel> get allUsers => [userN];

  static List<UserModel> get suggestedUsers => [userN];

  static final List<PostModel> feedPosts = [
    PostModel(
      id: 'p1',
      author: userN,
      content: 'Gente acabei de descobrir que meu pai não liga para mim',
      timeAgo: '1h',
      likesCount: 87,
      commentsCount: 2,
    ),
    PostModel(
      id: 'p2',
      author: userN,
      content:
          'Gente entendam, a separação entre humanos e Pokémon é essencial para acabar com a exploração e o sofrimento deles',
      timeAgo: '2h',
      likesCount: 342,
      commentsCount: 3,
    ),
    PostModel(
      id: 'p3',
      author: currentUser,
      content:
          'Os Pokémon são apenas ferramentas sem sentimento que deveriam ser utilizadas conforme a sua vontade',
      timeAgo: '3h',
      likesCount: 45,
      commentsCount: 1,
    ),
  ];

  /// Retorna os posts de um usuário específico (usado na tela de perfil).
  static List<PostModel> postsOf(String username) {
    return feedPosts.where((p) => p.author.username == username).toList();
  }
}
