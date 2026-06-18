// ═══ FILE: lib/repositories/firestore_demande_repository.dart ═══
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/demande.dart';
import '../services/notification_service.dart'; // AJOUT : FCM notifications (CDC §8.1)
import 'demande_repository.dart';

class FirestoreDemandeRepository implements DemandeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'demandes';

  /// Récupère le fcmToken d'un utilisateur à partir de son UID.
  /// Retourne null si le document ou le champ n'existe pas.
  Future<String?> _getFcmToken(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['fcmToken'] as String?;
      }
    } catch (e) {
      debugPrint('_getFcmToken error for $uid: $e');
    }
    return null;
  }

  @override
  Future<bool> create(Demande demande) async {
    try {
      await _firestore.collection(_collection).add(demande.toMap());

      // AJOUT : Notifier l'artisan de la nouvelle demande (CDC §8.1)
      if (demande.artisanId.isNotEmpty) {
        final token = await _getFcmToken(demande.artisanId);
        if (token != null && token.isNotEmpty) {
          await NotificationService.sendToToken(
            token: token,
            title: 'Nouvelle demande reçue',
            body: 'Un client vous a envoyé une nouvelle demande',
          );
        }
      }

      return true;
    } catch (e) {
      debugPrint('FirestoreDemandeRepository.create error: $e');
      return false;
    }
  }

  @override
  Stream<List<Demande>> getByClientId(String clientId) {
    return _firestore
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Demande.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((e) { // CORRECTION 3 : Gestion d'erreurs sur le stream de requêtes client
          debugPrint('getByClientId error: $e');
          return <Demande>[];
        });
  }

  @override
  Future<String> delete(String id, String status) async {
    try {
      if (status != 'envoye') {
        return "Impossible d'annuler : la demande a déjà été prise en charge.";
      }
      await _firestore.collection(_collection).doc(id).delete();
      return 'Demande annulée avec succès.';
    } catch (e) {
      return 'Erreur : ${e.toString()}';
    }
  }

  @override
  Stream<List<Demande>> getPending() {
    return _firestore
        .collection(_collection)
        .where('statut', isEqualTo: 'envoye')
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Demande.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((e) { // CORRECTION 3 : Gestion d'erreurs sur le stream de requêtes disponibles
          debugPrint('getPending error: $e');
          return <Demande>[];
        });
  }

  @override
  Stream<List<Demande>> getAcceptedByArtisanId(String artisanId) {
    return _firestore
        .collection(_collection)
        .where('artisanId', isEqualTo: artisanId)
        .where('statut', whereIn: ['accepte', 'en_cours', 'termine', 'refuse'])
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Demande.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((e) { // CORRECTION 3 : Gestion d'erreurs sur le stream de requêtes acceptées artisan
          debugPrint('getAcceptedByArtisanId error: $e');
          return <Demande>[];
        });
  }

  /// Notifie le client d'un changement de statut sur sa demande (CDC §8.1).
  Future<void> _notifyClientStatutChange(String demandeId, String statut) async {
    try {
      final demandeDoc = await _firestore.collection(_collection).doc(demandeId).get();
      if (!demandeDoc.exists) return;

      final clientId = demandeDoc.data()?['clientId'] as String?;
      if (clientId == null || clientId.isEmpty) return;

      final token = await _getFcmToken(clientId);
      if (token == null || token.isEmpty) return;

      String body;
      switch (statut) {
        case 'accepte':
          body = 'Votre demande a été acceptée !';
          break;
        case 'refuse':
          body = 'Votre demande a été refusée.';
          break;
        case 'en_cours':
          body = "L'artisan est en route.";
          break;
        case 'termine':
          body = 'Mission terminée. Pensez à noter l\'artisan !';
          break;
        default:
          body = 'Le statut de votre demande a été mis à jour.';
      }

      await NotificationService.sendToToken(
        token: token,
        title: 'Mise à jour de votre demande',
        body: body,
      );
    } catch (e) {
      debugPrint('_notifyClientStatutChange error: $e');
    }
  }

  @override
  Future<void> accept(String id, String artisanId) async {
    await _firestore.collection(_collection).doc(id).update({
      'statut': 'accepte',
      'artisanId': artisanId,
    });
    // AJOUT : Notification client (CDC §8.1)
    await _notifyClientStatutChange(id, 'accepte');
  }

  @override
  Future<void> abandon(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'statut': 'envoye',
      'artisanId': '',
    });
  }

  @override
  Future<void> terminate(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'statut': 'termine',
    });
    // AJOUT : Notification client (CDC §8.1)
    await _notifyClientStatutChange(id, 'termine');
  }

  @override
  Future<void> refuse(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'statut': 'refuse',
      'artisanId': '',
    });
    // AJOUT : Notification client (CDC §8.1)
    await _notifyClientStatutChange(id, 'refuse');
  }

  @override
  Future<void> startWork(String id, {DateTime? dateIntervention}) async {
    await _firestore.collection(_collection).doc(id).update({
      'statut': 'en_cours',
      if (dateIntervention != null) 'date_intervention': Timestamp.fromDate(dateIntervention),
    });
    // AJOUT : Notification client (CDC §8.1)
    await _notifyClientStatutChange(id, 'en_cours');
  }
  
}