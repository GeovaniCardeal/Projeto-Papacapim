import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/models/post_model.dart';
import '../../data/api_service.dart';
import '../../core/widgets/user_avatar.dart';

class ResponderPostScreen extends StatefulWidget {
  final PostModel postOriginal;

  const ResponderPostScreen({super.key, required this.postOriginal});

  @override
  State<ResponderPostScreen> createState() => _ResponderPostScreenState();
}

class _ResponderPostScreenState extends State<ResponderPostScreen> {
  static const int _maxChars = 280;
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService.instance;

  bool _publishing = false;
  bool _loadingReplies = true;
  String? _repliesError;
  List<PostModel> _replies = [];

  int get _remaining => _maxChars - _controller.text.length;

  bool get _canPublish =>
      !_publishing &&
      _controller.text.trim().isNotEmpty &&
      _remaining >= 0;

  @override
  void initState() {
    super.initState();
    _loadReplies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadReplies() async {
    if (mounted) {
      setState(() {
        _loadingReplies = true;
        _repliesError = null;
      });
    }

    try {
      final replies = await _apiService.getReplies(widget.postOriginal.id);

      if (!mounted) return;
      setState(() {
        _replies = replies;
        _loadingReplies = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingReplies = false;
        _repliesError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingReplies = false;
        _repliesError = 'Não foi possível carregar as respostas.';
      });
    }
  }

  Future<void> _publicar() async {
    if (!_canPublish) return;

    setState(() => _publishing = true);

    try {
      await _apiService.replyToPost(
        widget.postOriginal.id,
        _controller.text.trim(),
      );

      await _loadReplies();

      if (!mounted) return;
      _controller.clear();
      setState(() => _publishing = false);
      _showMessage('Resposta publicada.');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _publishing = false);
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _publishing = false);
      _showMessage('Não foi possível enviar a resposta.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildReplies() {
    if (_loadingReplies) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_repliesError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              _repliesError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadReplies,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_replies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Ainda não há respostas.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final reply in _replies) _buildReply(reply),
      ],
    );
  }

  Widget _buildReply(PostModel reply) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            radius: 18,
            imageUrl: reply.author.avatarUrl,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reply.author.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      reply.timeAgo,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '@${reply.author.username}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  reply.content,
                  style: const TextStyle(fontSize: 14, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respostas'),
        actions: [
          IconButton(
            tooltip: 'Atualizar respostas',
            onPressed: _loadingReplies ? null : _loadReplies,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadReplies,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UserAvatar(
                                radius: 20,
                                imageUrl: widget.postOriginal.author.avatarUrl,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.postOriginal.author.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '@${widget.postOriginal.author.username}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                widget.postOriginal.timeAgo,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.postOriginal.content,
                            style: const TextStyle(fontSize: 15, height: 1.35),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_replies.length} resposta${_replies.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Respostas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildReplies(),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      minLines: 1,
                      maxLength: _maxChars,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Escreva sua resposta...',
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Responder',
                    onPressed: _canPublish ? _publicar : null,
                    icon: _publishing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}