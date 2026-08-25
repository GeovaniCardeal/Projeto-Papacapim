import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/user_avatar.dart';

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

  @override
  void dispose() {
    _nomeController.dispose();
    _usuarioController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _handleCriarConta() {
    // Parte 1: simula o cadastro e retorna para o login.
    // Na Parte 2 aqui entrará a chamada de criação de conta na API.
    if (_senhaController.text != _confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }
    Navigator.of(context).pop();
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
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const UserAvatar(radius: 40),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: GestureDetector(
                        onTap: () {
                          // Na tela de cadastro a foto é opcional; o fluxo completo
                          // de escolher/tirar foto está na tela de edição de perfil.
                        },
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
              AppTextField(label: 'Nome completo', hint: 'Seu nome', controller: _nomeController),
              const SizedBox(height: 16),
              AppTextField(label: 'Usuário', hint: 'seu_usuario', controller: _usuarioController),
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
              PrimaryButton(label: 'Criar conta', onPressed: _handleCriarConta),
              const SizedBox(height: 16),
              const Center(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    children: [
                      TextSpan(text: 'Ao criar uma conta, você concorda com os '),
                      TextSpan(
                        text: 'Termos de Uso.',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
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
