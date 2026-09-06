import 'package:flutter/material.dart';
import '../../app/theme.dart';

class NovaPostagemScreen extends StatefulWidget {
  const NovaPostagemScreen({super.key});

  @override
  State<NovaPostagemScreen> createState() => _NovaPostagemScreenState();
}

class _NovaPostagemScreenState extends State<NovaPostagemScreen> {
  static const _maxChars = 280;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _maxChars - _controller.text.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Nova postagem')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  maxLength: _maxChars,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'O que está acontecendo?',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Publicação ainda não faz parte das funções conectadas nesta etapa.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Text('$remaining',
                      style: TextStyle(
                          color: remaining < 0
                              ? AppColors.danger
                              : AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
