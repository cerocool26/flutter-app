import 'package:flutter/foundation.dart';

import '../models/user_stats.dart';
import '../services/user_service.dart';

class UserStatsProvider extends ChangeNotifier {
  final String? token;
  late final UserService _service;

  UserStats? _stats;
  bool _loading = false;
  String? _error;

  UserStatsProvider({required this.token}) {
    _service = UserService(token: token);
  }

  UserStats? get stats => _stats;
  bool get isLoading => _loading;
  String? get error => _error;
  int get productCount => _stats?.productCount ?? 0;

  Future<void> refresh() async {
    if (token == null) {
      _stats = null;
      _error = 'Sin sesión activa';
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _stats = await _service.getMyStats();
    } on UserServiceException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error de red: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
