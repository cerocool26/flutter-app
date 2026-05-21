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
}
