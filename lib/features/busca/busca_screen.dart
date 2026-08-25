import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/widgets/user_list_tile.dart';
import '../../data/mock/mock_data.dart';

/// Tela de busca (Parte 1 - Design da interface).
/// O campo de busca e a lista de sugeridos são estáticos; a busca de fato
/// (filtrar por conteúdo/usuário no back-end) fica para a Parte 2.
class BuscaScreen extends StatelessWidget {
  const BuscaScreen({super.key});

  void _openProfile(BuildContext context, String username) {
    Navigator.of(context).pushNamed(AppRoutes.perfil, arguments: username);
  }

  @override
  Widget build(BuildContext context) {
    final results = MockData.suggestedUsers;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Buscar'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar usuários ou posts...',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('SUGERIDOS', style: AppTextStyles.label),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final user = results[index];
                return UserListTile(
                  user: user,
                  onTap: () => _openProfile(context, user.username),
                  onToggleFollow: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
