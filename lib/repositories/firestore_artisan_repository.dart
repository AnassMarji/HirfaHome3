// lib/repositories/firestore_artisan_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import 'artisan_repository.dart';

class FirestoreArtisanRepository implements ArtisanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<AppUser>> getArtisans() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'artisan')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppUser.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<AppUser?> getArtisanById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromMap(doc.data()!, uid);
    }
    return null;
  }
}