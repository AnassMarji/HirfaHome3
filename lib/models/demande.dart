// ═══ FILE: lib/models/demande.dart ═══
import 'package:cloud_firestore/cloud_firestore.dart';

class Demande {
  String? id;
  String clientId;
  String artisanId;
  String titre;
  String description;
  String categorie;
  String adresse;
  double prixPropose;
  String statut; // "envoye" | "accepte" | "en_cours" | "termine" | "refuse" | "annule"
  DateTime dateCreation;
  String clientEmail;
  String clientTelephone;
  double? clientRating;   
  double? artisanRating;  
  String? clientComment;
  String? artisanComment;
  List<String> images;
  GeoPoint? localisation;
  DateTime? dateIntervention; // Ajout de la date d'intervention (Section 9.3 du CDC)

  Demande({
    this.id,
    required this.clientId,
    this.artisanId = '',
    required this.titre,
    required this.description,
    required this.categorie,
    required this.adresse,
    this.prixPropose = 0,
    this.statut = 'envoye',
    required this.dateCreation,
    this.clientEmail = '',
    this.clientTelephone = '',
    this.clientRating,
    this.artisanRating,
    this.clientComment,
    this.artisanComment,
    this.images = const [],
    this.localisation,
    this.dateIntervention,
  });

  factory Demande.fromMap(Map<String, dynamic> data, String documentId) {
    GeoPoint? local;
    if (data['localisation'] != null) {
      final raw = data['localisation'];
      if (raw is GeoPoint) {
        local = raw;
      } else if (raw is Map) {
        // Legacy format: { 'latitude': ..., 'longitude': ... }
        local = GeoPoint(
          (raw['latitude'] as num).toDouble(),
          (raw['longitude'] as num).toDouble(),
        );
      }
    }

    return Demande(
      id: documentId,
      clientId: data['clientId'] ?? '',
      artisanId: data['artisanId'] ?? '',
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      categorie: data['categorie'] ?? 'autre',
      adresse: data['adresse'] ?? '',
      prixPropose: (data['prixPropose'] ?? 0).toDouble(),
      statut: data['statut'] ?? 'envoye',
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      clientEmail: data['clientEmail'] ?? '',
      clientTelephone: data['clientTelephone'] ?? '',
      clientRating: (data['clientRating'] as num?)?.toDouble(),
      artisanRating: (data['artisanRating'] as num?)?.toDouble(),
      clientComment: data['clientComment'],
      artisanComment: data['artisanComment'],
      images: List<String>.from(data['images'] ?? data['photoUrls'] ?? []),
      localisation: local,
      dateIntervention: (data['date_intervention'] as Timestamp?)?.toDate(), // Désérialisation
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'artisanId': artisanId,
      'titre': titre,
      'description': description,
      'categorie': categorie,
      'adresse': adresse,
      'prixPropose': prixPropose,
      'statut': statut,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'clientEmail': clientEmail,
      'clientTelephone': clientTelephone,
      'clientRating': clientRating,
      'artisanRating': artisanRating,
      'clientComment': clientComment,
      'artisanComment': artisanComment,
      'images': images,
      if (localisation != null) 'localisation': localisation,
      if (dateIntervention != null) 'date_intervention': Timestamp.fromDate(dateIntervention!), // Sérialisation
    };
  }
}