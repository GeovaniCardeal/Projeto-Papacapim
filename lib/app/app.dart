import 'package:flutter/material.dart';
import '../core/models/post_model.dart';
import '../features/auth/cadastro/cadastro_screen.dart';
import '../features/auth/login/login_screen.dart';
import '../features/main/main_shell.dart';
import '../features/perfil/editar_perfil_screen.dart';
import '../features/perfil/perfil_screen.dart';
import '../features/postagem/nova_postagem_screen.dart';
import '../features/postagem/responder_post_screen.dart';
import 'routes.dart';
import 'theme.dart';

class PapacapimApp extends StatelessWidget {
  const PapacapimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Papacapim',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: AppRoutes.login,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case AppRoutes.cadastro:
            return MaterialPageRoute(builder: (_) => const CadastroScreen());

          case AppRoutes.main:
            return MaterialPageRoute(builder: (_) => const MainShell());

          case AppRoutes.perfil:
            final username = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => PerfilScreen(username: username));

          case AppRoutes.editarPerfil:
            return MaterialPageRoute(builder: (_) => const EditarPerfilScreen());

          case AppRoutes.novaPostagem:
            return MaterialPageRoute(builder: (_) => const NovaPostagemScreen());

          case AppRoutes.responderPost:
            final post = settings.arguments as PostModel;
            return MaterialPageRoute(builder: (_) => ResponderPostScreen(postOriginal: post));

          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
