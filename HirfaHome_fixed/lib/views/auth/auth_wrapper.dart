// ═══ FILE: lib/views/auth/auth_wrapper.dart ═══
//
// Root router that listens to the Firebase auth state and directs the
// user to the appropriate screen:
//   - No user → LoginScreen
//   - User but email unverified → VerifyEmailScreen
//   - User + verified → fetch AppUser profile, then route by role:
//       admin → AdminHomeScreen
//       artisan → onboarding if profile incomplete, else ArtisanHomeScreen
//       client → ClientHomeScreen
//
// Improvements vs original:
//   1. Reads auth state from AuthViewModel (via Provider) instead of
//      instantiating AuthService directly — single source of truth.
//   2. NotificationService.initialize() is awaited and wrapped in
//      try/catch — FCM failures no longer crash the app silently.
//   3. Uses ErrorState widget when the user profile can't be loaded
//      instead of an inline retry column.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:hirfahome/models/app_user.dart';
import 'package:hirfahome/services/notification_service.dart';
import 'package:hirfahome/viewmodels/auth_viewmodel.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/viewmodels/theme_viewmodel.dart';
import 'package:hirfahome/widgets/error_state.dart';
import 'package:hirfahome/views/admin/admin_home_screen.dart';
import 'package:hirfahome/views/auth/artisan_onboarding_screen.dart';
import 'package:hirfahome/views/client/client_home_screen.dart';
import 'package:hirfahome/views/artisan/artisan_home_screen.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}
class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    // Watch BOTH AuthViewModel and LanguageViewModel.
    // LanguageViewModel is watched here so that when the user switches
    // language, the entire widget tree below rebuilds with the new lang.
    final authVm = context.watch<AuthViewModel>();
    context.watch<LanguageViewModel>();
    context.watch<ThemeViewModel>();
    return StreamBuilder<User?>(
      stream: authVm.authStateStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }
        final firebaseUser = snapshot.data;
        if (firebaseUser == null) {
          return const LoginScreen();
        }
        if (!firebaseUser.emailVerified) {
          return const VerifyEmailScreen();
        }
        return FutureBuilder<AppUser?>(
          key: ValueKey(firebaseUser.uid),
          future: authVm.getUserData(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScaffold();
            }
            if (userSnapshot.hasError) {
              return Scaffold(
                body: ErrorState(
                  message: 'Erreur lors du chargement du profil.',
                  onRetry: () => setState(() {}),
                ),
              );
            }
            final appUser = userSnapshot.data;
            if (appUser == null) {
              return Scaffold(
                body: ErrorState(
                  message: 'Profil utilisateur introuvable.',
                  onRetry: () => setState(() {}),
                ),
              );
            }
            // Initialize FCM with the user's uid. Awaits completion to
            // ensure the token is registered before any notifications
            // might be sent. Wrapped in try/catch — FCM failures should
            // not block the user from using the app.
            _initializeFcm(appUser.uid);
            return _routeByRole(appUser);
          },
        );
      },
    );
  }
  /// Routes the user to their role-specific home screen.
  /// NOTE: Do NOT use `const` here — const widgets don't rebuild when
  /// the LanguageViewModel changes, which would prevent the UI from
  /// updating when the user switches language.
  Widget _routeByRole(AppUser appUser) {
    switch (appUser.role) {
      case 'admin':
        return AdminHomeScreen();
      case 'artisan':
        // Artisan must complete onboarding if their specialite is missing.
        final needsOnboarding = appUser.specialite == null ||
            appUser.specialite!.isEmpty ||
            appUser.specialite == 'Non défini';
        if (needsOnboarding) {
          return const ArtisanOnboardingScreen();
        }
        return ArtisanHomeScreen(artisan: appUser);
      case 'client':
      default:
        return ClientHomeScreen();
    }
  }
  /// Fire-and-forget FCM initialization with error logging.
  Future<void> _initializeFcm(String uid) async {
    try {
      await NotificationService.initialize(uid);
    } catch (e) {
      debugPrint('FCM initialization failed (non-blocking): $e');
    }
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
