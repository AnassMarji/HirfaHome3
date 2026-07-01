// ═══ FILE: test/models_test.dart ═══
//
// Unit tests for the data models (AppUser, Demande, ChatMessage).
// Verifies serialization/deserialization roundtrip (toMap ↔ fromMap)
// and proper handling of null/missing fields.
//
// Run: flutter test test/models_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hirfahome/models/app_user.dart';
import 'package:hirfahome/models/demande.dart';
import 'package:hirfahome/models/chat_message.dart';

void main() {
  // ── AppUser ───────────────────────────────────────────────────────────
  group('AppUser model', () {
    test('toMap contient tous les champs obligatoires', () {
      final user = AppUser(
        uid: 'uid123',
        email: 'test@example.com',
        nom: 'Test User',
        role: 'client',
        telephone: '0612345678',
      );
      final map = user.toMap();
      expect(map['email'], 'test@example.com');
      expect(map['nom'], 'Test User');
      expect(map['role'], 'client');
      expect(map['telephone'], '0612345678');
    });

    test('fromMap récupère correctement les champs', () {
      final map = {
        'email': 'test2@example.com',
        'nom': 'Test Two',
        'role': 'artisan',
        'telephone': '0712345678',
        'photoUrl': 'https://example.com/photo.jpg',
        'specialite': 'Plombier',
        'yearsExperience': 10,
        'verifie': true,
      };
      final user = AppUser.fromMap(map, 'uid456');
      expect(user.uid, 'uid456');
      expect(user.email, 'test2@example.com');
      expect(user.nom, 'Test Two');
      expect(user.role, 'artisan');
      expect(user.telephone, '0712345678');
      expect(user.specialite, 'Plombier');
      expect(user.verifie, isTrue);
    });

    test('fromMap gère les champs manquants avec valeurs par défaut', () {
      final map = <String, dynamic>{
        'email': 'minimal@example.com',
        'nom': 'Minimal',
        'role': 'client',
      };
      final user = AppUser.fromMap(map, 'uid789');
      expect(user.telephone, '');
      expect(user.verifie, isFalse);
      expect(user.noteMoyenne, 0.0);
      expect(user.nombreAvis, 0);
    });

    test('roundtrip toMap → fromMap préserve les données', () {
      final original = AppUser(
        uid: 'uid_rt',
        email: 'rt@example.com',
        nom: 'Roundtrip',
        role: 'artisan',
        telephone: '0612345678',
        specialite: 'Électricien',
        yearsExperience: 5,
        verifie: true,
        noteMoyenne: 4.5,
        nombreAvis: 12,
      );
      final map = original.toMap();
      final restored = AppUser.fromMap(map, 'uid_rt');
      expect(restored.email, original.email);
      expect(restored.nom, original.nom);
      expect(restored.role, original.role);
      expect(restored.specialite, original.specialite);
      expect(restored.yearsExperience, original.yearsExperience);
      expect(restored.verifie, original.verifie);
    });
  });

  // ── Demande ───────────────────────────────────────────────────────────
  group('Demande model', () {
    test('toMap contient les champs requis', () {
      final demande = Demande(
        id: 'dem1',
        clientId: 'client1',
        artisanId: 'artisan1',
        titre: 'Fuite robinet',
        description: 'Fuite sous l\'évier de la cuisine',
        categorie: 'plomberie',
        adresse: '12 Rue Casablanca',
        statut: 'envoye',
        dateCreation: DateTime.now(),
      );
      final map = demande.toMap();
      expect(map['clientId'], 'client1');
      expect(map['artisanId'], 'artisan1');
      expect(map['description'], 'Fuite sous l\'évier de la cuisine');
      expect(map['statut'], 'envoye');
      expect(map['categorie'], 'plomberie');
    });

    test('fromMap récupère les champs correctement', () {
      final ts = Timestamp.fromDate(DateTime(2024, 1, 15));
      final map = {
        'clientId': 'client2',
        'artisanId': 'artisan2',
        'titre': 'Panne électrique',
        'description': 'Plus de courant dans la cuisine',
        'categorie': 'electricite',
        'adresse': 'Casablanca',
        'statut': 'accepte',
        'images': ['url1', 'url2'],
        'dateCreation': ts,
      };
      final demande = Demande.fromMap(map, 'dem2');
      expect(demande.clientId, 'client2');
      expect(demande.artisanId, 'artisan2');
      expect(demande.description, 'Plus de courant dans la cuisine');
      expect(demande.statut, 'accepte');
      expect(demande.images.length, 2);
    });

    test('fromMap gère les champs manquants', () {
      final map = <String, dynamic>{
        'clientId': 'client3',
        'description': 'Test minimal',
        'statut': 'envoye',
        'dateCreation': Timestamp.fromDate(DateTime.now()),
      };
      final demande = Demande.fromMap(map, 'dem3');
      expect(demande.artisanId, '');
      expect(demande.images, isEmpty);
    });

    test('fromMap supporte l\'ancien format photoUrls (legacy)', () {
      final ts = Timestamp.fromDate(DateTime(2024, 1, 15));
      final map = {
        'clientId': 'c1',
        'photoUrls': ['old_url1', 'old_url2', 'old_url3'],
        'dateCreation': ts,
      };
      final demande = Demande.fromMap(map, 'd1');
      expect(demande.images.length, 3);
    });
  });

  // ── ChatMessage ───────────────────────────────────────────────────────
  group('ChatMessage model', () {
    test('toMap/fromMap roundtrip préserve les données', () {
      final original = ChatMessage(
        id: 'msg1',
        senderId: 'user1',
        receiverId: 'user2',
        message: 'Bonjour, je peux venir demain ?',
        timestamp: DateTime(2024, 6, 15, 14, 30),
        lu: false,
      );
      final map = original.toMap();
      final restored = ChatMessage.fromMap(map, 'msg1');
      expect(restored.senderId, original.senderId);
      expect(restored.receiverId, original.receiverId);
      expect(restored.message, original.message);
      expect(restored.lu, original.lu);
    });

    test('fromMap définit lu=false par défaut', () {
      final map = <String, dynamic>{
        'senderId': 'user1',
        'receiverId': 'user2',
        'message': 'Test',
        'timestamp': Timestamp.fromDate(DateTime.now()),
      };
      final msg = ChatMessage.fromMap(map, 'msg2');
      expect(msg.lu, isFalse);
    });
  });
}
