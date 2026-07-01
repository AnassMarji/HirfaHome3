
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<AppUser?> register(String email, String password, String nom, String role, [String telephone = '']) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? firebaseUser = result.user;

    if (firebaseUser != null) {
      await firebaseUser.sendEmailVerification();

      AppUser newUser = AppUser(
        uid: firebaseUser.uid,
        email: email,
        nom: nom,
        role: role,
        telephone: telephone,
      );
      await _db.collection('users').doc(firebaseUser.uid).set(newUser.toMap());

      if (role == 'artisan') {
        await _db.collection('artisans').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'specialite': 'Non défini',
          'verifie': false,
        });
      }
      return newUser;
    }
    return null;
  }

  Future<AppUser?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      final DocumentSnapshot doc = await _db.collection('users').doc(firebaseUser.uid).get();

      AppUser appUser;
      if (!doc.exists) {
        appUser = AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          nom: firebaseUser.displayName ?? 'Utilisateur',
          role: 'client',
          photoUrl: firebaseUser.photoURL,
        );
        await _db.collection('users').doc(firebaseUser.uid).set(appUser.toMap());
      } else {
        appUser = AppUser.fromMap(doc.data() as Map<String, dynamic>, firebaseUser.uid);
      }
      return appUser;
    }
    return null;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<bool> checkEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  Future<void> resendVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Vérification de l'adresse email validée lors de la connexion.
  // Throws a typed exception 'unverified_email' (caught by AuthViewModel).
  Future<User?> login(String email, String password) async {
    UserCredential result =
        await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (result.user != null && !result.user!.emailVerified) {
      await _auth.signOut();
      throw Exception('unverified_email');
    }
    return result.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<AppUser?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!, uid);
      }
    } catch (_) {}
    return null;
  }

  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['role'] as String? ?? 'client';
      }
    } catch (_) {}
    return 'client';
  }
}