
import 'package:cloud_firestore/cloud_firestore.dart';


class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return doc.data();
    } catch (_) {}
    return null;
  }

  // Was: (String uid, String nom, String telephone)
  // Now: accepts any partial update map — fixes all 5 profile_screen errors
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }
}