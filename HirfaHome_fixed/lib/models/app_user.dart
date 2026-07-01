
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String nom;
  final String role; // 'client' | 'artisan' | 'admin'
  final String telephone;
  final double noteMoyenne;
  final int nombreAvis;
  final String? photoUrl;
  final String? ville;
  final String? specialite;
  final String? description; // CORRECTION : Harmonisation de la bio de l'artisan
  final int? yearsExperience;
  final Map<String, bool>? availability;
  final double? tarifs;
  final bool verifie;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.nom,
    required this.role,
    this.telephone = '',
    this.noteMoyenne = 0.0,
    this.nombreAvis = 0,
    this.photoUrl,
    this.ville,
    this.specialite,
    this.description,
    this.yearsExperience,
    this.availability,
    this.tarifs,
    this.verifie = false,
    this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) => AppUser(
        uid: uid,
        email: data['email'] as String? ?? '',
        nom: data['nom'] as String? ?? '',
        role: data['role'] as String? ?? 'client',
        telephone: data['telephone'] as String? ?? '',
        noteMoyenne: (data['noteMoyenne'] as num?)?.toDouble() ?? 0.0,
        nombreAvis: (data['nombreAvis'] as num?)?.toInt() ?? 0,
        photoUrl: data['photoUrl'] as String?,
        ville: data['ville'] as String?,
        specialite: data['specialite'] as String?,
        description: data['description'] as String?, // CORRECTION
        yearsExperience: (data['yearsExperience'] as num?)?.toInt(),
        availability: data['availability'] != null
            ? Map<String, bool>.from(data['availability'] as Map)
            : null,
        tarifs: (data['tarifs'] as num?)?.toDouble(),
        verifie: data['verifie'] as bool? ?? false,
        // Defensive: createdAt may be a FieldValue.serverTimestamp() sentinel
        // when the map was produced by toMap() but not yet written to Firestore
        // (which would replace the sentinel with a real server Timestamp).
        // In that case we treat it as null until Firestore resolves it.
        createdAt: _parseTimestamp(data['createdAt']),
      );

  /// Parses a value that may be a Timestamp, an ISO string, or a
  /// FieldValue.serverTimestamp() sentinel (which we treat as null).
  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    // FieldValue and other non-Timestamp sentinels → null
    return null;
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'nom': nom,
        'role': role,
        'telephone': telephone,
        'noteMoyenne': noteMoyenne,
        'nombreAvis': nombreAvis,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (ville != null) 'ville': ville,
        if (specialite != null) 'specialite': specialite,
        if (description != null) 'description': description, // CORRECTION
        if (yearsExperience != null) 'yearsExperience': yearsExperience,
        if (availability != null) 'availability': availability,
        if (tarifs != null) 'tarifs': tarifs,
        'verifie': verifie,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };
}