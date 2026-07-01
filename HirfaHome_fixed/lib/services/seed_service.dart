// lib/services/seed_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  SeedService._();

  static Future<void> seedDatabase() async {
    final firestore = FirebaseFirestore.instance;

    final List<Map<String, dynamic>> mockArtisans = [
      {
        'uid': 'mock_artisan_1',
        'nom': 'Youssef El Mansouri',
        'email': 'youssef.plomberie@gmail.com',
        'role': 'artisan',
        'telephone': '0661234567',
        'ville': 'Casablanca',
        'specialite': 'plomberie',
        'yearsExperience': 8,
        'noteMoyenne': 4.8,
        'nombreAvis': 14,
        'cinUrl': 'https://images.unsplash.com/photo-1557804506-669a67965ba0?q=80&w=200',
        'portfolioUrls': [
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=400',
          'https://images.unsplash.com/photo-1504307651254-35680f356dfd?q=80&w=400',
        ],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'mock_artisan_2',
        'nom': 'Rachid Amrani',
        'email': 'rachid.elec@gmail.com',
        'role': 'artisan',
        'telephone': '0662987654',
        'ville': 'Rabat',
        'specialite': 'electricite',
        'yearsExperience': 5,
        'noteMoyenne': 4.5,
        'nombreAvis': 8,
        'cinUrl': 'https://images.unsplash.com/photo-1557804506-669a67965ba0?q=80&w=200',
        'portfolioUrls': [
          'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=400',
        ],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'mock_artisan_3',
        'nom': 'Karim Bensouda',
        'email': 'karim.peintre@gmail.com',
        'role': 'artisan',
        'telephone': '0663112233',
        'ville': 'Marrakech',
        'specialite': 'peinture',
        'yearsExperience': 12,
        'noteMoyenne': 4.9,
        'nombreAvis': 23,
        'cinUrl': 'https://images.unsplash.com/photo-1557804506-669a67965ba0?q=80&w=200',
        'portfolioUrls': [
          'https://images.unsplash.com/photo-1562259949-e8e7689d7828?q=80&w=400',
          'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?q=80&w=400',
        ],
        'createdAt': FieldValue.serverTimestamp(),
      }
    ];

    for (var artisan in mockArtisans) {
      // Changed to set with merge options to prevent overwrites on every startup
      await firestore.collection('users').doc(artisan['uid']).set(artisan, SetOptions(merge: true));
    }
  }
}