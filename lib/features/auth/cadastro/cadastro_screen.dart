import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/api_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _usuarioController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _handleCriarConta() async {
    final nome = _nomeController.text.trim();
    final usuario = _usuarioController.text.trim();
    final senha = _senhaController.text;
    final confirmacao = _confirmarSenhaController.text;

    if (nome.isEmpty || usuario.isEmpty || senha.isEmpty || confirmacao.isEmpty) {
      _showMessage('Preencha todos os campos.');
      return;
    }
    if (senha != confirmacao) {
      _showMessage('As senhas não coincidem.');
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiService.instance.cadastrar(
        login: usuario,
        name: nome,
        password: senha,
        passwordConfirmation: confirmacao,
      );
      if (!mounted) return;
      _showMessage('Conta criada com sucesso.');
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } on ApiException catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (_) {
      if (mounted) _showMessage('Não foi possível criar a conta.');
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
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Center(child: UserAvatar(radius: 40)),
              const SizedBox(height: 28),
              AppTextField(
                  label: 'Nome completo',
                  hint: 'Seu nome',
                  controller: _nomeController),
              const SizedBox(height: 16),
              AppTextField(
                  label: 'Usuário',
                  hint: 'seu_usuario',
                  controller: _usuarioController),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Senha',
                hint: 'Mínimo 6 caracteres',
                controller: _senhaController,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Confirmar senha',
                hint: 'Repita a senha',
                controller: _confirmarSenhaController,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _loading ? 'Criando...' : 'Criar conta',
                onPressed: _loading ? null : _handleCriarConta,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}