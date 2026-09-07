import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/models/post_model.dart';
import '../../core/models/user_model.dart';
import '../../core/widgets/post_card.dart';
import '../../core/widgets/user_list_tile.dart';
import '../../data/api_service.dart';

class BuscaScreen extends StatefulWidget {
  const BuscaScreen({super.key});

  @override
  State<BuscaScreen> createState() => _BuscaScreenState();
}

class _BuscaScreenState extends State<BuscaScreen> {
  final _searchController = TextEditingController();
  List<UserModel> _userResults = [];
  List<PostModel> _postResults = [];
  bool _loading = false;
  int _searchVersion = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String query) async {
    final version = ++_searchVersion;
    final q = query.trim();

    if (q.isEmpty) {
      setState(() {
        _userResults = [];
        _postResults = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final results = await Future.wait([
        ApiService.instance.buscarUsuarios(search: q),
        ApiService.instance.buscarPosts(search: q),
      ]);

      if (!mounted || version != _searchVersion) return;

      setState(() {
        _userResults = results[0] as List<UserModel>;
        _postResults = results[1] as List<PostModel>;
      });
    } on ApiException catch (e) {
      if (mounted && version == _searchVersion) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted && version == _searchVersion) {
        setState(() => _loading = false);
      }
    }
  }

  void _openProfile(String username) {
    Navigator.of(context).pushNamed(AppRoutes.perfil, arguments: username);
  }

  Future<void> _toggleFollow(UserModel user) async {
    final oldValue = user.isFollowing;
    setState(() => user.isFollowing = !oldValue);

    try {
      if (oldValue) {
        await ApiService.instance.deixarDeSeguir(user.username);
      } else {
        await ApiService.instance.seguir(user.username);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => user.isFollowing = oldValue);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final noResults = !_loading &&
        _searchController.text.trim().isNotEmpty &&
        _userResults.isEmpty &&
        _postResults.isEmpty;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Buscar'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearch,
              decoration: const InputDecoration(
                hintText: 'Buscar usuários ou posts...',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_loading)
            const LinearProgressIndicator(minHeight: 2)
          else
            const SizedBox(height: 2),
          Expanded(
            child: noResults
                ? const Center(
                    child: Text('Nenhum resultado encontrado.',
                        style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView(
                    children: [
                      if (_userResults.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('USUÁRIOS', style: AppTextStyles.label),
                        ),
                        const SizedBox(height: 8),
                        for (final user in _userResults)
                          UserListTile(
                            user: user,
                            onTap: () => _openProfile(user.username),
                            onToggleFollow: () => _toggleFollow(user),
                          ),
                      ],
                      if (_postResults.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('POSTS', style: AppTextStyles.label),
                        ),
                        const SizedBox(height: 4),
                        for (final post in _postResults)
                          PostCard(
                            post: post,
                            onTapAuthor: () =>
                                _openProfile(post.author.username),
                            onLike: () {},
                            onReply: () {},
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}