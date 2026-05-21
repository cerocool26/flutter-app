import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/product.dart';

class ProductException implements Exception {
  final int statusCode;
  final String message;
  ProductException(this.statusCode, this.message);
  @override
  String toString() => 'ProductException($statusCode): $message';
}

class ProductService {
  final String? token;
  ProductService({required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  /// GET /products
  Future<List<Product>> getAll() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/products'),
      headers: _headers,
    );

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw ProductException(res.statusCode, _errorOf(res));
  }

  /// GET /products/:id
  Future<Product> getOne(String id) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/products/$id'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return Product.fromJson(jsonDecode(res.body));
    }
    throw ProductException(res.statusCode, _errorOf(res));
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
