// lib/viewmodels/artisan_viewmodel.dart
import 'package:flutter/material.dart';
import '../repositories/demande_repository.dart';
import '../repositories/firestore_demande_repository.dart';

class ArtisanViewModel extends ChangeNotifier {
  // Dépendance injectée vers l'interface abstraite
  final DemandeRepository _demandeRepository = FirestoreDemandeRepository();

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

  Future<bool> accepterDemande(String demandeId, String artisanId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _demandeRepository.accept(demandeId, artisanId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de l\'acceptation : ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> abandonnerDemande(String demandeId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _demandeRepository.abandon(demandeId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de l\'abandon : ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
}