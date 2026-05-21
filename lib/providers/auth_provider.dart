import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _kToken = 'jwt_token';
  static const _kUser  = 'jwt_user';

  final _storage = const FlutterSecureStorage();
  final _service = AuthService();

  String? _token;
  User? _user;
  bool _loading = true;
  String? _error;

  String? get token => _token;
  User?   get user  => _user;
  bool    get isAuthenticated => _token != null && _user != null;
  bool    get isLoading => _loading;
  String? get error => _error;

  /// Carga el token guardado al iniciar la app
  Future<void> loadFromStorage() async {
    try {
      final t = await _storage.read(key: _kToken);
      final u = await _storage.read(key: _kUser);
      if (t != null && u != null) {
        _token = t;
        _user = User.fromJson(jsonDecode(u));
      }
    } catch (e) {
      _error = 'No se pudo cargar la sesión: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final r = await _service.login(email, password);
      _token = r.token;
      _user = r.user;
      await _persist();
      _error = null;
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error de red: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _setLoading(true);
    try {
      await _service.signup(name, email, password);
      // Después de registrar, hacemos login automático
      return await login(email, password);
    } on AuthException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Error de red: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kUser);
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_token != null) await _storage.write(key: _kToken, value: _token);
    if (_user  != null) await _storage.write(key: _kUser,  value: jsonEncode(_user!.toJson()));
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
