
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hirfahome/models/app_user.dart';
import 'package:hirfahome/services/auth_service.dart';
import 'package:hirfahome/services/notification_service.dart'; // AJOUT : FCM (CDC §8.1)
import 'package:hirfahome/views/admin/admin_home_screen.dart';
import 'package:hirfahome/views/auth/artisan_onboarding_screen.dart'; // Importation
import '../client/client_home_screen.dart';
import '../artisan/artisan_home_screen.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }

        final User? firebaseUser = snapshot.data;

        if (firebaseUser == null) {
          return const LoginScreen();
        }

        if (!firebaseUser.emailVerified) {
          return const VerifyEmailScreen();
        }

        return FutureBuilder<AppUser?>(
          key: ValueKey(firebaseUser.uid),
          future: _authService.getUserData(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScaffold();
            }

            final appUser = userSnapshot.data;

            if (appUser == null) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Chargement du profil…'),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // AJOUT : Initialiser FCM et sauvegarder le token (CDC §8.1)
            NotificationService.initialize(appUser.uid);

            if (appUser.role == 'admin') {
              return const AdminHomeScreen();
            } else if (appUser.role == 'artisan') {
              // FIX : Redirection vers onboarding si les infos d'artisan sont absentes (Section 2)
              if (appUser.specialite == null || appUser.specialite!.isEmpty || appUser.specialite == 'Non défini') {
                return const ArtisanOnboardingScreen();
              }
              return ArtisanHomeScreen(artisan: appUser);
            } else {
              return const ClientHomeScreen();
            }
          },
        );
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}