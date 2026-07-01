// ═══ FILE: test/validators_test.dart ═══
//
// Unit tests for the Validators utility class.
// Covers email validation, phone validation, password validation,
// and the form-validator helper functions.
//
// Run: flutter test test/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:hirfahome/utils/validators.dart';

void main() {
  // ── Email validation ──────────────────────────────────────────────────
  group('Validators.isValidEmail', () {
    test('accepte les emails simples', () {
      expect(Validators.isValidEmail('user@example.com'), isTrue);
      expect(Validators.isValidEmail('alice@bob.org'), isTrue);
    });

    test('accepte les TLD longs (.museum, .tech, .photography)', () {
      expect(Validators.isValidEmail('user@example.museum'), isTrue);
      expect(Validators.isValidEmail('user@example.tech'), isTrue);
      expect(Validators.isValidEmail('user@example.photography'), isTrue);
      expect(Validators.isValidEmail('user@example.online'), isTrue);
    });

    test('accepte le signe + dans la partie locale (alias Gmail)', () {
      expect(Validators.isValidEmail('alice+work@gmail.com'), isTrue);
      expect(Validators.isValidEmail('bob+newsletter@yahoo.fr'), isTrue);
    });

    test('accepte les points et tirets dans la partie locale', () {
      expect(Validators.isValidEmail('john.doe@example.com'), isTrue);
      expect(Validators.isValidEmail('john-doe@example.com'), isTrue);
      expect(Validators.isValidEmail('john_doe@example.com'), isTrue);
    });

    test('accepte les sous-domaines', () {
      expect(Validators.isValidEmail('user@sub.example.com'), isTrue);
      expect(Validators.isValidEmail('user@a.b.c.example.com'), isTrue);
    });

    test('refuse les emails sans @', () {
      expect(Validators.isValidEmail('notanemail'), isFalse);
      expect(Validators.isValidEmail('user.example.com'), isFalse);
    });

    test('refuse les emails sans domaine', () {
      expect(Validators.isValidEmail('user@'), isFalse);
      expect(Validators.isValidEmail('user@.com'), isFalse);
    });

    test('refuse les emails sans partie locale', () {
      expect(Validators.isValidEmail('@example.com'), isFalse);
      expect(Validators.isValidEmail('@'), isFalse);
    });

    test('refuse les emails vides', () {
      expect(Validators.isValidEmail(''), isFalse);
      expect(Validators.isValidEmail('   '), isFalse);
    });

    test('trim les espaces autour de l\'email', () {
      expect(Validators.isValidEmail('  user@example.com  '), isTrue);
    });
  });

  // ── Phone validation ──────────────────────────────────────────────────
  group('Validators.isValidMoroccanPhone', () {
    test('accepte les numéros marocains locaux (06/07/05)', () {
      expect(Validators.isValidMoroccanPhone('0612345678'), isTrue);
      expect(Validators.isValidMoroccanPhone('0712345678'), isTrue);
      expect(Validators.isValidMoroccanPhone('0512345678'), isTrue);
    });

    test('accepte les numéros marocains internationaux (+212)', () {
      expect(Validators.isValidMoroccanPhone('+212612345678'), isTrue);
      expect(Validators.isValidMoroccanPhone('+212712345678'), isTrue);
      expect(Validators.isValidMoroccanPhone('+212512345678'), isTrue);
    });

    test('accepte les espaces dans le numéro', () {
      expect(Validators.isValidMoroccanPhone('06 12 34 56 78'), isTrue);
      expect(Validators.isValidMoroccanPhone('+212 6 12 34 56 78'), isTrue);
    });

    test('accepte les tirets dans le numéro', () {
      expect(Validators.isValidMoroccanPhone('06-12-34-56-78'), isTrue);
    });

    test('refuse les numéros non marocains', () {
      expect(Validators.isValidMoroccanPhone('+33123456789'), isFalse);  // France
      expect(Validators.isValidMoroccanPhone('+441234567890'), isFalse); // UK
      expect(Validators.isValidMoroccanPhone('+13456789012'), isFalse);  // US
    });

    test('refuse les numéros trop courts', () {
      expect(Validators.isValidMoroccanPhone('061234'), isFalse);
      expect(Validators.isValidMoroccanPhone('+212612'), isFalse);
    });

    test('refuse les numéros trop longs', () {
      expect(Validators.isValidMoroccanPhone('06123456789012'), isFalse);
    });

    test('refuse les préfixes invalides (08, 09)', () {
      expect(Validators.isValidMoroccanPhone('0812345678'), isFalse);
      expect(Validators.isValidMoroccanPhone('0912345678'), isFalse);
    });

    test('refuse les chaînes vides', () {
      expect(Validators.isValidMoroccanPhone(''), isFalse);
      expect(Validators.isValidMoroccanPhone('   '), isFalse);
    });
  });

  // ── Password validation ───────────────────────────────────────────────
  group('Validators.isValidPassword', () {
    test('accepte les mots de passe robustes', () {
      expect(Validators.isValidPassword('password1'), isTrue);
      expect(Validators.isValidPassword('Abcdefgh123'), isTrue);
      expect(Validators.isValidPassword('MySecure2024!'), isTrue);
    });

    test('refuse les mots de passe trop courts (< 8 caractères)', () {
      expect(Validators.isValidPassword('abc12'), isFalse);
      expect(Validators.isValidPassword(''), isFalse);
      expect(Validators.isValidPassword('1234567'), isFalse);
    });

    test('refuse les mots de passe sans lettres', () {
      expect(Validators.isValidPassword('12345678'), isFalse);
      expect(Validators.isValidPassword('1234567890'), isFalse);
    });

    test('refuse les mots de passe sans chiffres', () {
      expect(Validators.isValidPassword('abcdefgh'), isFalse);
      expect(Validators.isValidPassword('AbcdefghIjk'), isFalse);
    });
  });

  // ── Form validator helpers ────────────────────────────────────────────
  group('Validators form helpers', () {
    test('required() retourne null si non-vide, message sinon', () {
      expect(Validators.required('hello'), isNull);
      expect(Validators.required(''), isNotNull);
      expect(Validators.required(null), isNotNull);
      expect(Validators.required('   '), isNotNull);
    });

    test('email() validator combiné', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email(''), isNotNull);          // requis
      expect(Validators.email('invalid-email'), isNotNull); // invalide
      expect(Validators.email(null), isNotNull);        // requis
    });

    test('phone() validator combiné', () {
      expect(Validators.phone('0612345678'), isNull);
      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone('+3312345678'), isNotNull); // pas marocain
      expect(Validators.phone(null), isNotNull);
    });

    test('password() validator combiné', () {
      expect(Validators.password('password1'), isNull);
      expect(Validators.password(''), isNotNull);            // requis
      expect(Validators.password('short1'), isNotNull);      // trop court
      expect(Validators.password('allletters'), isNotNull);  // pas de chiffre
      expect(Validators.password('12345678'), isNotNull);    // pas de lettre
      expect(Validators.password(null), isNotNull);
    });
  });
}
