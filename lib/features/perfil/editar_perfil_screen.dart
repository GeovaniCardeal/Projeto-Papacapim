import 'dart:io';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/mock/mock_data.dart';
import 'widgets/foto_perfil_picker.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late final TextEditingController _nomeController;
  final _senhaController = TextEditingController();
  File? _fotoSelecionada;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: MockData.currentUser.name);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _escolherFoto() async {
    final file = await showFotoPerfilPicker(context);
    if (file != null) {
      setState(() => _fotoSelecionada = file);
    }
  }

  void _salvar() {
    // Parte 1: apenas navega de volta. O envio de nome/senha/foto ao
    // back-end (PATCH no usuário) fica para a Parte 2.
    Navigator.of(context).pop();
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text('Tem certeza que deseja excluir sua conta? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Na Parte 2: chamar o endpoint de exclusão de conta e
              // redirecionar para a tela de login.
              Navigator.of(context).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        actions: [
          TextButton(
            onPressed: _salvar,
            child: const Text('Salvar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    UserAvatar(radius: 40, imageFile: _fotoSelecionada),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: GestureDetector(
                        onTap: _escolherFoto,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              AppTextField(label: 'Nome', hint: 'Seu nome', controller: _nomeController),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Nova senha',
                hint: 'Deixe em branco para manter',
                controller: _senhaController,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvar,
                  child: const Text('Salvar alterações'),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _confirmarExclusao,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.dangerBackground,
                    foregroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Excluir conta', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
