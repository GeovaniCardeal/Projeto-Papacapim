import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/models/post_model.dart';
import '../../core/widgets/post_card.dart';
import '../../data/api_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => FeedScreenState();
}

class FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService.instance;

  List<PostModel> _posts = [];
  List<PostModel> _followingPosts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFeed();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> refreshFeed() => _loadFeed();

  Future<void> _loadFeed() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait([
        _apiService.buscarPosts(),
        _apiService.buscarPosts(somenteSeguindo: true),
      ]);

      if (!mounted) return;
      setState(() {
        _posts = results[0];
        _followingPosts = results[1];
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar o feed.';
      });
    }
  }

  Future<void> _openReply(PostModel post) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.responderPost,
      arguments: post,
    );

    if (result == true) {
      await _loadFeed();
    }
  }

  Future<void> _toggleLike(PostModel post) async {
    final wasLiked = post.isLiked;
    final previousCount = post.likesCount;

    setState(() {
      post.isLiked = !wasLiked;
      post.likesCount = wasLiked
          ? (previousCount > 0 ? previousCount - 1 : 0)
          : previousCount + 1;
    });

    try {
      if (wasLiked) {
        await _apiService.unlikePost(post.id);
      } else {
        await _apiService.likePost(post.id);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        post.isLiked = wasLiked;
        post.likesCount = previousCount;
      });
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        post.isLiked = wasLiked;
        post.likesCount = previousCount;
      });
      _showMessage('Não foi possível alterar a curtida.');
    }
  }

  Future<void> _deletePost(PostModel post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir postagem'),
        content: const Text('Tem certeza que deseja excluir esta postagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiService.deletePost(post.id);

      if (!mounted) return;
      setState(() {
        _posts.removeWhere((item) => item.id == post.id);
        _followingPosts.removeWhere((item) => item.id == post.id);
      });

      _showMessage('Postagem excluída.');
    } on ApiException catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (_) {
      if (mounted) _showMessage('Não foi possível excluir a postagem.');
    }
  }

  void _openProfile(String username) {
    Navigator.of(context).pushNamed(AppRoutes.perfil, arguments: username);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(_posts),
                    _buildList(_followingPosts),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 220),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Não foi possível carregar o feed.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFeed,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<PostModel> posts) {
    if (posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadFeed,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 240),
            Center(child: Text('Nenhuma postagem por aqui ainda.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final currentLogin = _apiService.currentUser?.username ?? _apiService.login;
          final isOwnPost = currentLogin != null && post.author.username == currentLogin;

          return PostCard(
            post: post,
            onTapAuthor: () => _openProfile(post.author.username),
            onLike: () => _toggleLike(post),
            onReply: () => _openReply(post),
            onDelete: isOwnPost ? () => _deletePost(post) : null,
          );
        },
      ),
    );
  }
}
