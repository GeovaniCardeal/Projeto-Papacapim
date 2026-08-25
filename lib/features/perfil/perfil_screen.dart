import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/models/user_model.dart';
import '../../core/widgets/post_card.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/mock/mock_data.dart';

/// Tela de perfil — funciona tanto para o próprio usuário quanto para outros
/// (Parte 1 - Design da interface). Os dados são fixos (mock); o botão de
/// seguir/deixar de seguir e as ações dos posts (curtir, descurtir, excluir)
/// ficam apenas como widgets navegáveis/clicáveis, sem alterar estado — a
/// integração real com o back-end é assunto da Parte 2.
class PerfilScreen extends StatefulWidget {
  /// username do perfil a ser exibido.
  final String username;

  /// true quando esta tela está embutida como aba (perfil do próprio usuário
  /// dentro da navegação principal); nesse caso o botão "voltar" leva para o
  /// feed em vez de fazer pop de rota (já que não há rota anterior).
  final bool embedded;
  final VoidCallback? onBackToFeed;

  const PerfilScreen({
    super.key,
    required this.username,
    this.embedded = false,
    this.onBackToFeed,
  });

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  UserModel get _user {
    if (widget.username == MockData.currentUser.username) return MockData.currentUser;
    return MockData.allUsers.firstWhere(
      (u) => u.username == widget.username,
      orElse: () => MockData.currentUser,
    );
  }

  bool get _isOwnProfile => _user.username == MockData.currentUser.username;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.embedded) {
      widget.onBackToFeed?.call();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final posts = MockData.postsOf(user.username);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        title: Text('@${user.username}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(radius: 32, imageUrl: user.avatarUrl),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          Text('@${user.username}', style: const TextStyle(color: AppColors.textSecondary)),
                          if (user.bio.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(user.bio, style: const TextStyle(fontSize: 13)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatItem(value: user.postsCount, label: 'Posts'),
                    const SizedBox(width: 28),
                    _StatItem(value: user.followersCount, label: 'Seguidores'),
                    const SizedBox(width: 28),
                    _StatItem(value: user.followingCount, label: 'Seguindo'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: _isOwnProfile
                      ? OutlinedButton(
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.editarPerfil),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: const Text('Editar perfil', style: TextStyle(fontWeight: FontWeight.w600)),
                        )
                      : OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: user.isFollowing ? Colors.transparent : AppColors.primary,
                            foregroundColor: user.isFollowing ? AppColors.textPrimary : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: user.isFollowing ? AppColors.border : AppColors.primary),
                          ),
                          child: Text(
                            user.isFollowing ? 'Deixar de seguir' : 'Seguir',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Posts'),
              Tab(text: 'Mídia'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                posts.isEmpty
                    ? const Center(
                        child: Text('Nenhuma postagem ainda.', style: TextStyle(color: AppColors.textSecondary)),
                      )
                    : ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return PostCard(
                            post: post,
                            onTapAuthor: () {},
                            onLike: () {},
                            onDislike: () {},
                            onReply: () => Navigator.of(context).pushNamed(AppRoutes.responderPost, arguments: post),
                            onDelete: _isOwnProfile ? () {} : null,
                          );
                        },
                      ),
                const Center(
                  child: Text('Nenhuma mídia ainda.', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
