import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Parte 1: apenas simula a navegação, sem validar credenciais de verdade.
    // Na Parte 2 aqui entrará a chamada de autenticação na API.
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Image.asset(
                  'assets/images/papacapim_logo.png',
                  height: 110,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Bem-vindo de volta', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                'Entre no papacapim para ver o que está acontecendo.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: 'Usuário',
                hint: 'seu_usuario',
                controller: _usernameController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Senha',
                hint: '••••••••',
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Entrar', onPressed: _handleLogin),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ou', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.cadastro),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      children: [
                        TextSpan(text: 'Não tem conta? '),
                        TextSpan(
                          text: 'Criar conta',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Use qualquer usuário e senha para entrar.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
