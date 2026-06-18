// lib/services/rating_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> submitRating({
    required String demandeId,
    required String clientId,
    required String artisanId,
    required double rating,
    required String raterRole, 
    String comment = '',
  }) async {
    try {
      final raterId = raterRole == 'client' ? clientId : artisanId;

      final existing = await _firestore
          .collection('ratings')
          .where('demandeId', isEqualTo: demandeId)
          .where('raterId', isEqualTo: raterId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        await existing.docs.first.reference.update({
          'rating': rating,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('ratings').add({
          'demandeId': demandeId,
          'clientId': clientId,
          'artisanId': artisanId,
          'raterId': raterId,
          'rating': rating,
          'raterRole': raterRole,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      final ratingField = raterRole == 'client' ? 'clientRating' : 'artisanRating';
      final commentField = raterRole == 'client' ? 'clientComment' : 'artisanComment';
      await _firestore.collection('demandes').doc(demandeId).update({
        ratingField: rating,
        commentField: comment,
      });

      if (raterRole == 'client') {
        await _updateArtisanAverage(artisanId);
      } else {
        await _updateClientAverage(clientId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateArtisanAverage(String artisanId) async {
    final snapshot = await _firestore
        .collection('ratings')
        .where('artisanId', isEqualTo: artisanId)
        .where('raterRole', isEqualTo: 'client')
        .get();

    if (snapshot.docs.isEmpty) return;
    // Renamed parameter "sum" to "acc" to avoid warnings (Fix 8)
    final total = snapshot.docs.fold<double>(0, (acc, doc) => acc + (doc['rating'] as num).toDouble());
    final average = total / snapshot.docs.length;

    await _firestore.collection('users').doc(artisanId).update({
      'noteMoyenne': average,
      'nombreAvis': snapshot.docs.length,
    });
  }

  Future<void> _updateClientAverage(String clientId) async {
    final snapshot = await _firestore
        .collection('ratings')
        .where('clientId', isEqualTo: clientId)
        .where('raterRole', isEqualTo: 'artisan')
        .get();

    if (snapshot.docs.isEmpty) return;
    // Renamed parameter "sum" to "acc" to avoid warnings (Fix 8)
    final total = snapshot.docs.fold<double>(0, (acc, doc) => acc + (doc['rating'] as num).toDouble());
    final average = total / snapshot.docs.length;

    await _firestore.collection('users').doc(clientId).update({
      'noteMoyenne': average,
      'nombreAvis': snapshot.docs.length,
    });
  }
}