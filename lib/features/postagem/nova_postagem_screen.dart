import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../data/api_service.dart';

class NovaPostagemScreen extends StatefulWidget {
  const NovaPostagemScreen({super.key});

  @override
  State<NovaPostagemScreen> createState() => _NovaPostagemScreenState();
}

class _NovaPostagemScreenState extends State<NovaPostagemScreen> {
  static const int _maxChars = 280;
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService.instance;
  bool _publishing = false;

  int get _remaining => _maxChars - _controller.text.length;

  bool get _canPublish =>
      !_publishing &&
      _controller.text.trim().isNotEmpty &&
      _remaining >= 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _publicar() async {
    if (!_canPublish) return;

    setState(() => _publishing = true);

    try {
      await _apiService.createPost(_controller.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _publishing = false);
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _publishing = false);
      _showMessage('Não foi possível publicar a postagem.');
    }
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
        title: const Text('Nova postagem'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _canPublish ? _publicar : null,
              child: _publishing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Publicar'),
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
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  maxLength: _maxChars,
                  autofocus: true,
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
                  Expanded(
                    child: Text(
                      'Publique uma mensagem de até $_maxChars caracteres.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '$_remaining',
                    style: TextStyle(
                      color: _remaining < 0
                          ? AppColors.danger
                          : AppColors.textSecondary,
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
