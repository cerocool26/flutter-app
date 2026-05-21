import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user.dart';

class AuthResult {
  final String token;
  final User user;
  AuthResult({required this.token, required this.user});
}

class AuthException implements Exception {
  final int statusCode;
  final String message;
  AuthException(this.statusCode, this.message);
  @override
  String toString() => 'AuthException($statusCode): $message';
}

class AuthService {
  /// POST /auth/login
  Future<AuthResult> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _decode(res);
    if (res.statusCode == 200) {
      return AuthResult(
        token: data['token'],
        user: User.fromJson(data['user']),
      );
    }
    throw AuthException(res.statusCode, data['error'] ?? 'Error de autenticación');
  }

  /// POST /auth/signup — siempre crea con rol 'client'
  Future<User> signup(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final data = _decode(res);
    if (res.statusCode == 201) {
      return User.fromJson(data['user']);
    }
    throw AuthException(res.statusCode, data['error'] ?? 'Error de registro');
  }

  Map<String, dynamic> _decode(http.Response res) {
    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'error': 'Respuesta inválida del servidor'};
    }
  }
}
