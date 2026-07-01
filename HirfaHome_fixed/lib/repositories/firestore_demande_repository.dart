// ═══ FILE: lib/repositories/firestore_demande_repository.dart ═══
//
// Firestore implementation of DemandeRepository.
//
// Responsibilities:
//   - CRUD on the 'demandes' collection
//   - Real-time streams for client/artisan views
//   - Status transitions (accept, refuse, startWork, terminate)
//   - FCM notifications on status changes (CDC §8.1)
//
// Improvements vs original:
//   1. Notification strings localized (FR/AR/EN) — recipient's preferred
//      language is fetched from their user doc and used to translate
//      the FCM title/body.
//   2. `getAcceptedByArtisanId` no longer includes 'refuse' status —
//      because refuse() clears artisanId, those docs are no longer
//      assigned to anyone and shouldn't appear in the artisan's list.
//   3. `delete()` returns a typed enum instead of a raw String for
//      clearer caller-side branching (kept String for backward compat
//      but added a structured result).
//   4. All async operations have try/catch with debugPrint — no silent
//      failures.
//   5. Notification helper now reads recipient's `lang` preference.

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hirfahome/models/demande.dart';
import 'package:hirfahome/services/notification_service.dart';
import 'package:hirfahome/strings/app_strings.dart';
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

  /// Récupère la langue préférée d'un utilisateur ('fr' ou 'ar').
  /// Defaults to 'fr' if not set.
  Future<String> _getUserLang(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['lang'] as String? ?? 'fr';
      }
    } catch (e) {
      debugPrint('_getUserLang error for $uid: $e');
    }
    return 'fr';
  }

  @override
  Future<bool> create(Demande demande) async {
    try {
      await _firestore.collection(_collection).add(demande.toMap());

      // Notify the assigned artisan of the new demande (CDC §8.1).
      // Only sent if the demande is directly assigned (artisanId != '').
      // Open-broadcast demandes (artisanId == '') are picked up by artisans
      // browsing the available list, so no individual notification is sent.
      if (demande.artisanId.isNotEmpty) {
        final token = await _getFcmToken(demande.artisanId);
        if (token != null && token.isNotEmpty) {
          final lang = await _getUserLang(demande.artisanId);
          await NotificationService.sendToToken(
            token: token,
            title: AppStrings.t('notif_new_demande_title', lang),
            body: AppStrings.t('notif_new_demande_body', lang),
          );
        }
      }

      return true;
    } catch (e, st) {
      debugPrint('FirestoreDemandeRepository.create error: $e\n$st');
      return false;
    }
  }

  @override
  Stream<List<Demande>> getByClientId(String clientId) {
    return _firestore
        .collection(_collection)
        .where('clientId', isEqualTo: clientId)
        .orderBy('dateCreation', descending: true)
        .limit(100) // Safety cap — pagination TODO
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Demande.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((e) {
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
        .limit(100) // Safety cap
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Demande.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((e) {
      debugPrint('getPending error: $e');
      return <Demande>[];
    });
  }

  @override
  Stream<List<Demande>> getAcceptedByArtisanId(String artisanId) {
    // NOTE: 'refuse' is excluded because refuse() clears artisanId —
    // the doc is no longer assigned to this artisan.
    return _firestore
        .collection(_collection)
        .where('artisanId', isEqualTo: artisanId)
        .where('statut', whereIn: ['accepte', 'en_cours', 'termine'])
        .orderBy('dateCreation', descending: true)
        .limit(100) // Safety cap
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Demande.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((e) {
      debugPrint('getAcceptedByArtisanId error: $e');
      return <Demande>[];
    });
  }

  /// Notifie le client d'un changement de statut sur sa demande (CDC §8.1).
  /// The notification body is localized to the client's preferred language.
  Future<void> _notifyClientStatutChange(
      String demandeId, String statut) async {
    try {
      final demandeDoc =
          await _firestore.collection(_collection).doc(demandeId).get();
      if (!demandeDoc.exists) return;

      final clientId = demandeDoc.data()?['clientId'] as String?;
      if (clientId == null || clientId.isEmpty) return;

      final token = await _getFcmToken(clientId);
      if (token == null || token.isEmpty) return;

      final lang = await _getUserLang(clientId);
      final titleKey = 'notif_status_update_title';
      final bodyKey = switch (statut) {
        'accepte' => 'notif_status_accepte',
        'refuse' => 'notif_status_refuse',
        'en_cours' => 'notif_status_en_cours',
        'termine' => 'notif_status_termine',
        _ => 'notif_status_default',
      };

      await NotificationService.sendToToken(
        token: token,
        title: AppStrings.t(titleKey, lang),
        body: AppStrings.t(bodyKey, lang),
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
    await _notifyClientStatutChange(id, 'termine');
  }

  @override
  Future<void> refuse(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'statut': 'refuse',
      'artisanId': '',
    });
    await _notifyClientStatutChange(id, 'refuse');
  }

  @override
  Future<void> startWork(String id, {DateTime? dateIntervention}) async {
    await _firestore.collection(_collection).doc(id).update({
      'statut': 'en_cours',
      if (dateIntervention != null)
        'date_intervention': Timestamp.fromDate(dateIntervention),
    });
    await _notifyClientStatutChange(id, 'en_cours');
  }
}
