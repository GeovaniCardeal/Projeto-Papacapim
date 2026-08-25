import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/mock/mock_data.dart';

class NovaPostagemScreen extends StatefulWidget {
  const NovaPostagemScreen({super.key});

  @override
  State<NovaPostagemScreen> createState() => _NovaPostagemScreenState();
}

class _NovaPostagemScreenState extends State<NovaPostagemScreen> {
  static const _maxChars = 280;
  final _controller = TextEditingController();
  int _remaining = _maxChars;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _remaining = _maxChars - _controller.text.length);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canPublish => _controller.text.trim().isNotEmpty && _remaining >= 0;

  void _publicar() {
    // Parte 1: apenas navega de volta ao publicar. O envio de fato do
    // conteúdo ao back-end (POST /posts) fica para a Parte 2.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova postagem'),
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
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserAvatar(radius: 20, imageUrl: MockData.currentUser.avatarUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(MockData.currentUser.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _controller,
                            maxLines: null,
                            maxLength: _maxChars,
                            style: const TextStyle(fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: 'O que está acontecendo?',
                              border: InputBorder.none,
                              counterText: '',
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // UI de anexar imagem à postagem (fora do escopo obrigatório
                      // da Parte 1, mas o ícone já fica disponível na tela).
                    },
                    icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                  ),
                  const Spacer(),
                  Text(
                    '$_remaining',
                    style: TextStyle(
                      color: _remaining < 0 ? AppColors.danger : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
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
