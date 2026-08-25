import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/post_model.dart';
import '../models/user_model.dart';

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

  String? get token => _token;
  String? get login => _login;
  bool get isAuthenticated => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'x-session-token': _token!,
      };

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final headers = authenticated ? _headers : {'Content-Type': 'application/json'};

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
          throw ArgumentError('Método HTTP não suportado: $method');
      }
    } on SocketException {
      throw ApiException(0, 'Não foi possível conectar à API. Verifique sua internet.');
    } on http.ClientException {
      throw ApiException(0, 'Não foi possível conectar à API.');
    }

    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = response.body;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Erro na API (${response.statusCode}).';
      if (decoded is Map && decoded['error'] != null) {
        message = decoded['error'].toString();
      } else if (decoded is Map && decoded['message'] != null) {
        message = decoded['message'].toString();
      } else if (decoded is String && decoded.isNotEmpty) {
        message = decoded;
      }
      throw ApiException(response.statusCode, message);
    }

    return decoded;
  }

  Future<void> loginUser(String login, String password) async {
    final data = await _request(
      'POST',
      '/sessions',
      body: {'login': login, 'password': password},
      authenticated: false,
    );
    if (data is! Map || data['token'] == null) {
      throw ApiException(500, 'A API não retornou um token de sessão.');
    }
    _token = data['token'].toString();
    _login = data['user_login']?.toString() ?? login;
  }

  Future<void> registerUser({
    required String login,
    required String name,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _request(
      'POST',
      '/users',
      body: {
        'user': {
          'login': login,
          'name': name,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      },
      authenticated: false,
    );
  }

  Future<UserModel> getUser([String? username]) async {
    final login = username ?? 'me';
    final data = await _request('GET', '/users/$login');
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final data = await _request(
      'GET',
      '/users',
      query: query.trim().isEmpty ? null : {'search': query.trim()},
    );
    final users = (data as List)
        .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
        .toList();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return users;
    return users
        .where((u) => u.username.toLowerCase().contains(q) || u.name.toLowerCase().contains(q))
        .toList();
  }

  Future<void> updateUser({
    String? login,
    String? name,
    String? password,
    File? imageFile,
  }) async {
    final user = <String, dynamic>{};
    if (login != null && login.trim().isNotEmpty) user['login'] = login.trim();
    if (name != null && name.trim().isNotEmpty) user['name'] = name.trim();
    if (password != null && password.isNotEmpty) {
      user['password'] = password;
      user['password_confirmation'] = password;
    }
    if (imageFile != null) {
      user['image_data'] = base64Encode(await imageFile.readAsBytes());
    }

    if (user.isEmpty) return;
    await _request('PATCH', '/users/1', body: {'user': user});
  }

  Future<void> deleteCurrentUser() async {
    await _request('DELETE', '/users/me');
    _token = null;
    _login = null;
  }

  Future<void> follow(String username) async {
    await _request('POST', '/users/$username/followers');
  }

  Future<void> unfollow(String username) async {
    await _request('DELETE', '/users/$username/followers/me');
  }

  Future<List<PostModel>> getPosts({int? page, bool followingOnly = false, String? search}) async {
    final query = <String, String>{};
    if (page != null) query['page'] = page.toString();
    if (followingOnly) query['feed'] = '1';
    if (search != null && search.trim().isNotEmpty) query['search'] = search.trim();

    final data = await _request('GET', '/posts', query: query.isEmpty ? null : query);
    return (data as List)
        .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<PostModel>> getUserPosts(String username, {int? page}) async {
    final data = await _request(
      'GET',
      '/users/$username/posts',
      query: page == null ? null : {'page': page.toString()},
    );
    return (data as List)
        .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PostModel> createPost(String message) async {
    final data = await _request(
      'POST',
      '/posts',
      body: {'post': {'message': message}},
    );
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PostModel> replyToPost(int postId, String message) async {
    final data = await _request(
      'POST',
      '/posts/$postId/replies',
      body: {'reply': {'message': message}},
    );
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<PostModel>> getReplies(int postId) async {
    final data = await _request('GET', '/posts/$postId/replies');
    return (data as List)
        .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> deletePost(String postId) async {
    await _request('DELETE', '/posts/$postId');
  }

  Future<void> likePost(String postId) async {
    await _request('POST', '/posts/$postId/likes');
  }

  Future<void> unlikePost(String postId) async {
    await _request('DELETE', '/posts/$postId/likes/me');
  }
}
