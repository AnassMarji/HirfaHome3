// ═══ FILE: lib/viewmodels/auth_viewmodel.dart ═══
//
// ViewModel for authentication state.
// Wraps AuthService and exposes:
//   - authState stream (so AuthWrapper can listen to it via Provider)
//   - isLoading / errorMessage for UI binding
//   - login, loginWithGoogle, register, logout, etc.
//
// Improvements vs original:
//   1. Exposes `authStateStream` so AuthWrapper doesn't need to instantiate
//      AuthService directly — single source of truth via Provider.
//   2. Equality checks on _isLoading / _errorMessage before notifyListeners
//      prevents redundant rebuilds.
//   3. Uses AppException (typed) instead of throwing raw Strings.
//   4. Clean error messages via _cleanFirebaseError().

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:hirfahome/services/auth_service.dart';
import 'package:hirfahome/models/app_user.dart';

/// Typed authentication exception with a user-friendly message.
class AppAuthException implements Exception {
  final String message;
  final String? code;
  AppAuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthViewModel extends ChangeNotifier {
  // AuthService is instantiated here — single point of access.
  // AuthWrapper reads this stream via context.select<AuthViewModel, Stream<User?>>.
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Stream of Firebase auth state — exposed so the AuthWrapper can listen
  /// via Provider instead of instantiating its own AuthService.
  Stream<User?> get authStateStream => _authService.user;

  void _setLoading(bool value) {
    if (_isLoading == value) return; // no-op if unchanged
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    if (_errorMessage == message) return; // no-op if unchanged
    _errorMessage = message;
    notifyListeners();
  }

  void resetError() => _setError(null);

  /// Maps a raw Firebase Auth error into a French user-friendly message.
  String _cleanFirebaseError(Object e) {
    final raw = e.toString();
    if (raw.contains('unverified_email')) {
      return 'Veuillez vérifier votre adresse email avant de vous connecter.';
    }
    if (raw.contains('invalid-credential') ||
        raw.contains('wrong-password') ||
        raw.contains('user-not-found')) {
      return 'Email ou mot de passe incorrect.';
    }
    if (raw.contains('email-already-in-use')) {
      return 'Un compte existe déjà avec cet email.';
    }
    if (raw.contains('weak-password')) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    if (raw.contains('invalid-email')) {
      return 'Adresse email invalide.';
    }
    if (raw.contains('too-many-requests')) {
      return 'Trop de tentatives. Réessayez plus tard.';
    }
    if (raw.contains('network-request-failed')) {
      return 'Problème de connexion réseau.';
    }
    if (raw.contains('user-disabled')) {
      return 'Ce compte a été désactivé.';
    }
    // Fallback: strip the "Exception: " prefix.
    return raw.replaceAll('Exception: ', '');
  }

  /// Login with email & password. Throws AppAuthException on failure
  /// (also stored in errorMessage for UI binding).
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.login(email, password);
    } catch (e) {
      final msg = _cleanFirebaseError(e);
      _setError(msg);
      throw AppAuthException(msg);
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Google. Returns true on success, false if user cancels.
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) return true;
      return false; // user cancelled the prompt
    } catch (e) {
      _setError(_cleanFirebaseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register a new user with the given role.
  Future<bool> register(
    String email,
    String password,
    String nom,
    String role, [
    String telephone = '',
  ]) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.register(email, password, nom, role, telephone);
      return true;
    } catch (e) {
      _setError(_cleanFirebaseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    return sendPasswordResetEmail(email);
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.sendPasswordReset(email);
      return true;
    } catch (e) {
      _setError(_cleanFirebaseError(e));
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
      _setError(_cleanFirebaseError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  /// Convenience: load the AppUser profile from Firestore.
  Future<AppUser?> getUserData(String uid) async {
    return _authService.getUserData(uid);
  }

  /// Convenience: get the user's role string.
  Future<String> getUserRole(String uid) async {
    return _authService.getUserRole(uid);
  }
}
