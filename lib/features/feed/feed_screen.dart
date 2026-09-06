import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/models/post_model.dart';
import '../../core/widgets/post_card.dart';
import '../../data/api_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PostModel> _posts = [];
  List<PostModel> _seguindoPosts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarFeed();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarFeed() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ApiService.instance.buscarPosts(),
        ApiService.instance.buscarPosts(somenteSeguindo: true),
      ]);
      if (!mounted) return;
      setState(() {
        _posts = results[0];
        _seguindoPosts = results[1];
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Erro ao carregar o feed.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openProfile(String username) {
    Navigator.of(context).pushNamed(AppRoutes.perfil, arguments: username);
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_posts),
          _buildList(_seguindoPosts),
        ],
      ),
    );
  }

  Widget _buildList(List<PostModel> posts) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return RefreshIndicator(
        onRefresh: _carregarFeed,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 180),
            Center(child: Text(_error!)),
          ],
        ),
      );
    }
    if (posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _carregarFeed,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(
              child: Text('Nenhuma postagem por aqui ainda.',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarFeed,
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            post: post,
            onTapAuthor: () => _openProfile(post.author.username),
            onLike: () => _showNotImplemented(),
            onReply: () => _showNotImplemented(),
          );
        },
      ),
    );
  }

  void _showNotImplemented() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Esta função será implementada na próxima etapa.'),
      ),
    );
  }
}
