import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/models/post_model.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/mock/mock_data.dart';

class ResponderPostScreen extends StatefulWidget {
  final PostModel postOriginal;

  const ResponderPostScreen({super.key, required this.postOriginal});

  @override
  State<ResponderPostScreen> createState() => _ResponderPostScreenState();
}

class _ResponderPostScreenState extends State<ResponderPostScreen> {
  static const _maxChars = 280;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canPublish => _controller.text.trim().isNotEmpty;

  void _publicar() {
    // Parte 1: apenas navega de volta ao publicar. O envio de fato da
    // resposta ao back-end (POST /posts com id do post pai) fica para a Parte 2.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final original = widget.postOriginal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _canPublish ? _publicar : null,
              style: TextButton.styleFrom(
                backgroundColor: _canPublish ? AppColors.primary : AppColors.border,
                foregroundColor: _canPublish ? Colors.white : AppColors.textSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              ),
              child: const Text('Publicar', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(radius: 18, imageUrl: original.author.avatarUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${original.author.name}  @${original.author.username}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(original.content, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserAvatar(radius: 20, imageUrl: MockData.currentUser.avatarUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        maxLength: _maxChars,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Respondendo a @${original.author.username}',
                          border: InputBorder.none,
                          counterText: '',
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
