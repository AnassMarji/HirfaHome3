import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void resetError() => _setError(null);

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.login(email, password);
    } catch (e) {
      final cleanError = e.toString().replaceAll('Exception: ', '');
      _setError(cleanError);
      throw cleanError;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        return true;
      }
      return false; // Connexion annulée
    } catch (e) {
      final cleanError = e.toString().replaceAll('Exception: ', '');
      _setError(cleanError);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password, String nom, String role, [String telephone = '']) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.register(email, password, nom, role, telephone);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    return await sendPasswordResetEmail(email);
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.sendPasswordReset(email);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkEmailVerification() async =>
      await _authService.checkEmailVerified();

  Future<void> resendVerification() async {
    _setLoading(true);
    try {
      await _authService.resendVerification();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}