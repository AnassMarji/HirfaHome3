
import 'package:cloud_firestore/cloud_firestore.dart';
import 'portfolio_item.dart';

class Artisan {
  final String uid;
  final String nom;
  final String email;
  final String telephone;
  final String specialite;
  final String description;
  final List<String> competences;
  final double? tarifs;
  final double noteMoyenne;
  final int nombreAvis;
  final bool verifie;
  final List<String> portfolioUrls; // Rétro-compatibilité format simple
  final List<PortfolioItem> portfolioItems; // AJOUT : Avant/Après (Section 14)
  final String? photoUrl;
  final String? ville;
  final DateTime? createdAt;

  const Artisan({
    required this.uid,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.specialite,
    required this.description,
    required this.competences,
    this.tarifs,
    this.noteMoyenne = 0.0,
    this.nombreAvis = 0,
    this.verifie = false,
    this.portfolioUrls = const [],
    this.portfolioItems = const [],
    this.photoUrl,
    this.ville,
    this.createdAt,
  });

  factory Artisan.fromMap(Map<String, dynamic> data, String uid) {
    final List<dynamic>? rawItems = data['portfolioItems'] as List<dynamic>?;
    final List<PortfolioItem> items = rawItems != null
        ? rawItems.map((item) => PortfolioItem.fromMap(Map<String, dynamic>.from(item))).toList()
        : const [];

    return Artisan(
      uid: uid,
      nom: data['nom'] as String? ?? '',
      email: data['email'] as String? ?? '',
      telephone: data['telephone'] as String? ?? '',
      specialite: data['specialite'] as String? ?? '',
      description: data['description'] as String? ?? '',
      competences: List<String>.from(data['competences'] as List? ?? []),
      tarifs: (data['tarifs'] as num?)?.toDouble(),
      noteMoyenne: (data['noteMoyenne'] as num?)?.toDouble() ?? 0.0,
      nombreAvis: (data['nombreAvis'] as num?)?.toInt() ?? 0,
      verifie: data['verifie'] as bool? ?? false,
      portfolioUrls: List<String>.from(data['portfolioUrls'] as List? ?? []),
      portfolioItems: items,
      photoUrl: data['photoUrl'] as String?,
      ville: data['ville'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nom': nom,
        'email': email,
        'telephone': telephone,
        'specialite': specialite,
        'description': description,
        'competences': competences,
        if (tarifs != null) 'tarifs': tarifs,
        'noteMoyenne': noteMoyenne,
        'nombreAvis': nombreAvis,
        'verifie': verifie,
        'portfolioUrls': portfolioUrls,
        'portfolioItems': portfolioItems.map((item) => item.toMap()).toList(),
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (ville != null) 'ville': ville,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };
}