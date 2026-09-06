import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/models/post_model.dart';

class ResponderPostScreen extends StatelessWidget {
  final PostModel postOriginal;

  const ResponderPostScreen({super.key, required this.postOriginal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comentários')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(postOriginal.content,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const Text(
              'Respostas ainda não fazem parte das funções conectadas nesta etapa.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
