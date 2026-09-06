import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/api_service.dart';
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
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: ApiService.instance.currentUser?.name ?? '',
    );
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

  Future<void> _salvar() async {
    if (_nomeController.text.trim().isEmpty) {
      _showMessage('Informe um nome.');
      return;
    }

    if (_senhaController.text.isNotEmpty &&
        _senhaController.text.length < 6) {
      _showMessage('A nova senha deve ter pelo menos 6 caracteres.');
      return;
    }

    setState(() => _loading = true);
    try {
      String? imageData;
      if (_fotoSelecionada != null) {
        final bytes = await _fotoSelecionada!.readAsBytes();
        imageData = base64Encode(bytes);
      }

      final mudouSenha = _senhaController.text.isNotEmpty;

      await ApiService.instance.alterarUsuario(
        name: _nomeController.text.trim(),
        password: mudouSenha ? _senhaController.text : null,
        passwordConfirmation:
            mudouSenha ? _senhaController.text : null,
        imageData: imageData,
      );

      if (!mounted) return;

      if (mudouSenha) {
        ApiService.instance.clearSession();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Dados alterados. Como a senha mudou, faça login novamente.'),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      } else {
        _showMessage('Alterações salvas com sucesso.');
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (_) {
      if (mounted) _showMessage('Não foi possível salvar as alterações.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _loading = true);
    try {
      await ApiService.instance.excluirConta();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } on ApiException catch (e) {
      if (mounted) _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
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
        title: const Text('Editar perfil'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _salvar,
            child: const Text('Salvar',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
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
                    UserAvatar(
                      radius: 40,
                      imageFile: _fotoSelecionada,
                      imageUrl: ApiService.instance.currentUser?.avatarUrl,
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: GestureDetector(
                        onTap: _loading ? null : _escolherFoto,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              AppTextField(
                  label: 'Nome',
                  hint: 'Seu nome',
                  controller: _nomeController),
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
                  onPressed: _loading ? null : _salvar,
                  child: Text(_loading ? 'Salvando...' : 'Salvar alterações'),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _loading ? null : _confirmarExclusao,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.dangerBackground,
                    foregroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Excluir conta',
                      style: TextStyle(fontWeight: FontWeight.w600)),
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
