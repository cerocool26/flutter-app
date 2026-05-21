import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user_stats.dart';

class UserServiceException implements Exception {
  final int statusCode;
  final String message;
  UserServiceException(this.statusCode, this.message);
  @override
  String toString() => 'UserServiceException($statusCode): $message';
}

class UserService {
  final String? token;
  UserService({required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  /// GET /users/me/stats
  Future<UserStats> getMyStats() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/me/stats'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return UserStats.fromJson(jsonDecode(res.body));
    }
    throw UserServiceException(res.statusCode, _errorOf(res));
  }

  String _errorOf(http.Response res) {
    try {
      final m = jsonDecode(res.body) as Map<String, dynamic>;
      return m['error']?.toString() ?? 'Error desconocido';
    } catch (_) {
      return 'Respuesta inválida del servidor';
    }
  }
}
