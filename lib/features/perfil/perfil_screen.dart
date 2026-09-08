import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/models/post_model.dart';
import '../../core/models/user_model.dart';
import '../../core/widgets/post_card.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/api_service.dart';

class PerfilScreen extends StatefulWidget {
  final String username;
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

class _PerfilScreenState extends State<PerfilScreen> {
  UserModel? _user;
  List<PostModel> _posts = [];
  bool _loading = true;

  bool get _isOwnProfile =>
      _user != null &&
      ApiService.instance.currentUser?.username == _user!.username;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final current = ApiService.instance.currentUser;
      final login = widget.embedded && current != null
          ? current.username
          : widget.username;
      final user = await ApiService.instance.buscarUsuario(login);
      List<PostModel> posts = [];
      try {
        posts = await ApiService.instance.buscarPostsDoUsuario(user.username);
      } catch (_) {
      }
      if (!mounted) return;
      setState(() {
        _user = user;
        _posts = posts;
      });
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleBack() {
    if (widget.embedded) {
      widget.onBackToFeed?.call();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _toggleFollow() async {
    final user = _user!;
    final oldValue = user.isFollowing;
    setState(() => user.isFollowing = !oldValue);

    try {
      if (oldValue) {
        await ApiService.instance.deixarDeSeguir(user.username);
      } else {
        await ApiService.instance.seguir(user.username);
      }
      await _loadProfile();
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        title: Text(widget.username == 'me' ? 'Meu perfil' : '@${widget.username}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Usuário não encontrado.'))
              : _buildProfile(_user!),
    );
  }

  Widget _buildProfile(UserModel user) {
    return Column(
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
                        Text(user.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('@${user.username}',
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatItem(
                      value: _posts.length, label: 'Posts'),
                  const SizedBox(width: 28),
                  _StatItem(
                      value: user.followersCount, label: 'Seguidores'),
                  const SizedBox(width: 28),
                  _StatItem(
                      value: user.followingCount, label: 'Seguindo'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: _isOwnProfile
                    ? OutlinedButton(
                        onPressed: () async {
                          await Navigator.of(context)
                              .pushNamed(AppRoutes.editarPerfil);
                          _loadProfile();
                        },
                        child: const Text('Editar perfil'),
                      )
                    : OutlinedButton(
                        onPressed: _toggleFollow,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: user.isFollowing
                              ? Colors.transparent
                              : AppColors.primary,
                          foregroundColor: user.isFollowing
                              ? AppColors.textPrimary
                              : Colors.white,
                        ),
                        child: Text(user.isFollowing
                            ? 'Deixar de seguir'
                            : 'Seguir'),
                      ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Posts', style: AppTextStyles.label),
          ),
        ),
        Expanded(
          child: _posts.isEmpty
              ? const Center(
                  child: Text('Nenhuma postagem ainda.',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return PostCard(
                      post: post,
                      onTapAuthor: () {},
                      onLike: () {},
                      onReply: () {},
                    );
                  },
                ),
        ),
      ],
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
        Text('$value',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
