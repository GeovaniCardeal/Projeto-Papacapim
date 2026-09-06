# Papacapim — Parte 2

Esta versão conecta o aplicativo Flutter à API `https://api.papacapim.just.pro.br`.

## Funcionalidades conectadas

- Cadastro de usuário
- Login e autenticação por `x-session-token`
- Alteração de nome, senha e foto de perfil
- Exclusão da conta
- Busca de usuários
- Busca de posts
- Seguir usuário
- Deixar de seguir usuário
- Carregamento do feed a partir da API
- Carregamento do perfil e dos posts do perfil

## Estrutura

A comunicação HTTP ficou centralizada em:

`lib/data/api_service.dart`

Os dados fictícios da Parte 1 foram removidos de:

`lib/data/mock/`

e todas as telas deixaram de depender de `MockData`.

## Dependência adicionada

No `pubspec.yaml` foi adicionada a biblioteca:

`http`

## Observação sobre a API

O código do servidor atual do Papacapim mostra que:

- `POST /users` recebe `login`, `name`, `password` e `password_confirmation` diretamente no JSON.
- `POST /sessions` recebe `login` e `password`.
- `PATCH /users/me` atualiza o usuário autenticado e recebe os campos dentro de `user`.
- `DELETE /users/me` exclui a conta.
- `POST /users/{login}/followers` segue um usuário.
- `DELETE /users/{login}/followers/me` deixa de seguir.
- `GET /users`, `GET /users/{login}` e `GET /posts` fornecem os dados usados pelas telas.

Se a senha for alterada, a API invalida as sessões ativas. Por isso, o aplicativo leva o usuário de volta à tela de login após uma troca de senha.
