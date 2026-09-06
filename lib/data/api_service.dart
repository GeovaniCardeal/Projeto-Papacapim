import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/models/post_model.dart';
import '../core/models/user_model.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const String baseUrl = 'https://api.papacapim.just.pro.br';

  String? _token;
  String? _login;
  UserModel? currentUser;

  bool get isAuthenticated => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'x-session-token': _token!,
      };

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool authenticated = true,
  }) async {
    if (authenticated && !isAuthenticated) {
      throw ApiException(401, 'Usuário não autenticado.');
    }

    final uri = _uri(path, query);
    final headers = authenticated ? _headers : {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    late http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw ApiException(500, 'Método HTTP não suportado.');
      }
    } on SocketException {
      throw ApiException(0, 'Não foi possível conectar à API.');
    }

    dynamic data;
    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = response.body;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Erro ${response.statusCode}.';
      if (data is Map) {
        if (data['error'] != null) {
          message = data['error'].toString();
        } else if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          message = errors.values.expand((e) => e is List ? e : [e]).join(', ');
        } else if (data.isNotEmpty) {
          message = data.values.expand((e) => e is List ? e : [e]).join(', ');
        }
      }
      throw ApiException(response.statusCode, message);
    }

    return data;
  }

  Future<UserModel> cadastrar({
    required String login,
    required String name,
    required String password,
    required String passwordConfirmation,
  }) async {
    // O controller atual da API recebe estes campos no nível raiz.
    final data = await _request(
      'POST',
      '/users',
      authenticated: false,
      body: {
        'login': login,
        'name': name,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    return UserModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<UserModel> login({
    required String login,
    required String password,
  }) async {
    final data = await _request(
      'POST',
      '/sessions',
      authenticated: false,
      body: {'login': login, 'password': password},
    );

    _token = (data as Map)['token']?.toString();
    _login = (data)['user_login']?.toString();

    if (_token == null) {
      throw ApiException(500, 'A API não retornou o token da sessão.');
    }

    currentUser = await buscarUsuario('me');
    return currentUser!;
  }

  Future<UserModel> buscarUsuario(String login) async {
    final data = await _request('GET', '/users/$login');
    final user = UserModel.fromJson(Map<String, dynamic>.from(data as Map));
    if (login == 'me' || user.username == _login) {
      currentUser = user;
    }
    return user;
  }

  Future<List<UserModel>> buscarUsuarios({String? search}) async {
    final data = await _request(
      'GET',
      '/users',
      query: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    return (data as List)
        .map((item) => UserModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<PostModel>> buscarPosts({
    String? search,
    bool somenteSeguindo = false,
    int page = 0,
  }) async {
    final data = await _request(
      'GET',
      '/posts',
      query: {
        'page': '$page',
        if (somenteSeguindo) 'feed': '1',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    return (data as List)
        .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<PostModel>> buscarPostsDoUsuario(String login) async {
    final data = await _request('GET', '/users/$login/posts');
    return (data as List)
        .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<UserModel> alterarUsuario({
    String? login,
    String? name,
    String? password,
    String? passwordConfirmation,
    String? imageData,
  }) async {
    final user = <String, dynamic>{};
    if (login != null && login.trim().isNotEmpty) user['login'] = login.trim();
    if (name != null && name.trim().isNotEmpty) user['name'] = name.trim();
    if (password != null && password.isNotEmpty) {
      user['password'] = password;
      user['password_confirmation'] = passwordConfirmation ?? password;
    }
    if (imageData != null) user['image_data'] = imageData;

    final data = await _request(
      'PATCH',
      '/users/me',
      body: {'user': user},
    );

    final updated = UserModel.fromJson(Map<String, dynamic>.from(data as Map));
    currentUser = updated;

    if (password != null && password.isNotEmpty) {
      _token = null;
    }

    return updated;
  }

  Future<void> excluirConta() async {
    await _request('DELETE', '/users/me');
    _token = null;
    _login = null;
    currentUser = null;
  }

  Future<void> seguir(String login) async {
    await _request('POST', '/users/$login/followers');
  }

  Future<void> deixarDeSeguir(String login) async {
    await _request('DELETE', '/users/$login/followers/me');
  }

  void clearSession() {
    _token = null;
    _login = null;
    currentUser = null;
  }
}
