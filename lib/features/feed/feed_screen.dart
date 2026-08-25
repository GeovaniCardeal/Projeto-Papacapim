import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/models/post_model.dart';
import '../../core/widgets/post_card.dart';
import '../../data/mock/mock_data.dart';

/// Tela de feed (Parte 1 - Design da interface).
/// Foco em tela/navegação/widgets: os dados são fixos (mock) e os botões de
/// ação (curtir, descurtir) não alteram estado — isso fica para a Parte 2,
/// quando as ações passarão a refletir de fato no back-end.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  void _openProfile(String username) {
    Navigator.of(context).pushNamed(AppRoutes.perfil, arguments: username);
  }

  void _openReply(PostModel post) {
    Navigator.of(context).pushNamed(AppRoutes.responderPost, arguments: post);
  }

  @override
  Widget build(BuildContext context) {
    final posts = MockData.feedPosts;
    final seguindoPosts = posts.where((p) => p.author.isFollowing).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('papacapim', style: AppTextStyles.brand),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Para você'),
            Tab(text: 'Seguindo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(posts),
          _buildList(seguindoPosts),
        ],
      ),
    );
  }

  Widget _buildList(List<PostModel> posts) {
    if (posts.isEmpty) {
      return const Center(
        child: Text('Nenhuma postagem por aqui ainda.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          post: post,
          onTapAuthor: () => _openProfile(post.author.username),
          onLike: () {},
          onDislike: () {},
          onReply: () => _openReply(post),
        );
      },
    );
  }
}
