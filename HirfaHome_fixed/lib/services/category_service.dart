
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map<String, bool>> getEnabledCategories() {
    return _firestore
        .collection('config')
        .doc('categories')
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return {};
          }
          return Map<String, bool>.from(snapshot.data()!);
        });
  }
}