// ═══ FILE: lib/services/rating_service.dart ═══
//
// Service for submitting and aggregating ratings on completed demandes.
//
// Improvements vs original:
//   1. Atomic WriteBatch — the rating doc + demande update happen in a
//      single Firestore transaction. If either fails, both roll back.
//      Previously a partial failure could leave inconsistent state.
//   2. Deterministic doc ID "{demandeId}_{raterId}" — guarantees one
//      rating per (demande, rater) pair without a query. The Firestore
//      security rule enforces this convention.
//   3. Error logging — `catch (e)` no longer swallows silently; the
//      error is logged via debugPrint so issues can be diagnosed.
//   4. Average recompute kept on client for now (acceptable for MVP),
//      but documented as a future Cloud Function candidate.
//
// NOTE: For a production app, the average recompute should be done
// in a Cloud Function trigger (on ratings write) to:
//   - Avoid race conditions when multiple clients rate simultaneously.
//   - Reduce client bandwidth (no need to fetch all ratings).
//   - Allow FieldValue.increment for the count.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Submits a rating for a completed demande.
  ///
  /// - [demandeId] The rated demande.
  /// - [clientId] The client of the demande.
  /// - [artisanId] The artisan of the demande.
  /// - [rating] 1-5 stars.
  /// - [raterRole] 'client' (rating the artisan) or 'artisan' (rating the client).
  /// - [comment] Optional textual comment.
  ///
  /// Returns true on success, false on failure (error logged via debugPrint).
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

      // Deterministic doc ID — enforces one rating per (demande, rater).
      // The Firestore rule rejects creates where ratingId != demandeId + '_' + raterId.
      final ratingDocId = '${demandeId}_$raterId';
      final ratingRef = _firestore.collection('ratings').doc(ratingDocId);

      final ratingField =
          raterRole == 'client' ? 'clientRating' : 'artisanRating';
      final commentField =
          raterRole == 'client' ? 'clientComment' : 'artisanComment';
      final demandeRef = _firestore.collection('demandes').doc(demandeId);

      // Atomic batch: write rating + update demande in one transaction.
      final batch = _firestore.batch();
      batch.set(
        ratingRef,
        {
          'demandeId': demandeId,
          'clientId': clientId,
          'artisanId': artisanId,
          'raterId': raterId,
          'rating': rating,
          'raterRole': raterRole,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // upsert — overwrite if already exists
      );
      batch.update(demandeRef, {
        ratingField: rating,
        commentField: comment,
      });
      await batch.commit();

      // Recompute average for the rated party.
      // (Future: move to Cloud Function trigger.)
      if (raterRole == 'client') {
        await _updateArtisanAverage(artisanId);
      } else {
        await _updateClientAverage(clientId);
      }
      return true;
    } catch (e, st) {
      debugPrint('RatingService.submitRating failed: $e\n$st');
      return false;
    }
  }

  /// Recomputes the artisan's average rating and total count from all
  /// client ratings they've received.
  Future<void> _updateArtisanAverage(String artisanId) async {
    final snapshot = await _firestore
        .collection('ratings')
        .where('artisanId', isEqualTo: artisanId)
        .where('raterRole', isEqualTo: 'client')
        .get();

    if (snapshot.docs.isEmpty) {
      await _firestore.collection('users').doc(artisanId).update({
        'noteMoyenne': 0.0,
        'nombreAvis': 0,
      });
      return;
    }

    final total = snapshot.docs.fold<double>(
      0,
      (acc, doc) => acc + (doc['rating'] as num).toDouble(),
    );
    final average = total / snapshot.docs.length;

    await _firestore.collection('users').doc(artisanId).update({
      'noteMoyenne': average,
      'nombreAvis': snapshot.docs.length,
    });
  }

  /// Recomputes the client's average rating from all artisan ratings.
  Future<void> _updateClientAverage(String clientId) async {
    final snapshot = await _firestore
        .collection('ratings')
        .where('clientId', isEqualTo: clientId)
        .where('raterRole', isEqualTo: 'artisan')
        .get();

    if (snapshot.docs.isEmpty) {
      await _firestore.collection('users').doc(clientId).update({
        'noteMoyenne': 0.0,
        'nombreAvis': 0,
      });
      return;
    }

    final total = snapshot.docs.fold<double>(
      0,
      (acc, doc) => acc + (doc['rating'] as num).toDouble(),
    );
    final average = total / snapshot.docs.length;

    await _firestore.collection('users').doc(clientId).update({
      'noteMoyenne': average,
      'nombreAvis': snapshot.docs.length,
    });
  }
}
