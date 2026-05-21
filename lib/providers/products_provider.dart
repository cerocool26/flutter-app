import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductsProvider extends ChangeNotifier {
  final String? token;
  late final ProductService _service;

  ProductsProvider({required this.token}) {
    _service = ProductService(token: token);
  }

  List<Product> _products = [];
  bool _loading = false;
  String? _error;

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> fetch() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _service.getAll();
    } on ProductException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error de red: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Crea un producto y lo agrega al inicio de la lista (optimista).
  /// Devuelve el producto creado, o lanza ProductException con el mensaje del backend.
  Future<Product> create({
    required String name,
    required double price,
    String? description,
    int stock = 0,
  }) async {
    final created = await _service.create(
      name: name,
      price: price,
      description: description,
      stock: stock,
    );
    _products = [created, ..._products];
    notifyListeners();
    return created;
  }
}
