// ═══ FILE: lib/main.dart ═══
//
// HirfaHome — Application mobile de mise en relation entre artisans
// et particuliers au Maroc.
//
// Entry point: initializes Firebase, registers DI providers, sets up
// localization (FR/AR with RTL), theme mode (light/dark/system), and
// boots the root widget.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:hirfahome/firebase_options.dart';
import 'package:hirfahome/repositories/demande_repository.dart';
import 'package:hirfahome/repositories/firestore_demande_repository.dart';
import 'package:hirfahome/repositories/artisan_repository.dart';
import 'package:hirfahome/repositories/firestore_artisan_repository.dart';
import 'package:hirfahome/repositories/chat_repository.dart';
import 'package:hirfahome/repositories/firestore_chat_repository.dart';
import 'package:hirfahome/viewmodels/auth_viewmodel.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/viewmodels/theme_viewmodel.dart';
import 'package:hirfahome/views/auth/auth_wrapper.dart';
import 'package:hirfahome/views/artisan/artisan_settings_screen.dart';
import 'package:hirfahome/views/client/historique_screen.dart';
import 'package:hirfahome/views/client/settings_screen.dart';
import 'package:hirfahome/views/profile/profile_screen.dart';
import 'package:hirfahome/config/app_theme.dart';

/// Background FCM handler — must be top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background FCM message received: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    debugPrint('Firebase initialization failed: $e\n$st');
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter Error: ${details.exception}');
    FlutterError.presentError(details);
  };

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (kDebugMode) {
    debugPrint('HirfaHome running in DEBUG mode.');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DemandeRepository>(
          create: (_) => FirestoreDemandeRepository(),
        ),
        Provider<ArtisanRepository>(
          create: (_) => FirestoreArtisanRepository(),
        ),
        Provider<ChatRepository>(create: (_) => FirestoreChatRepository()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer3<LanguageViewModel, ThemeViewModel, AuthViewModel>(
        builder: (context, languageVm, themeVm, _, _) {
          final isArabic = languageVm.isRtl;
          return MaterialApp(
            title: 'HirfaHome',
            debugShowCheckedModeBanner: false,
            // ── Theme ────────────────────────────────────────────────────
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeVm.themeMode,
            // ── Localization ─────────────────────────────────────────────
            locale: Locale(languageVm.lang),
            supportedLocales: const [
              Locale('fr'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // ── RTL support + dark mode color sync + gradient bg ─────────
            builder: (context, child) {
              // Sync legacy AppColors aliases with the current theme brightness.
              AppColors.updateForTheme(Theme.of(context).brightness);

              final isDark = Theme.of(context).brightness == Brightness.dark;

              // Gradient background — this is what makes LiquidGlass visible.
              // Every screen's Scaffold has transparent background, so this
              // gradient shows through and the glass blur has something to blur.
              final gradient = isDark
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0A0A0A),
                        Color(0xFF1A1A1A),
                        Color(0xFF0F0F0F),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF5F0EB), // warm cream
                        Color(0xFFFAFAFA), // off-white
                        Color(0xFFEFEEF3), // cool lavender-gray
                      ],
                    );

              return Directionality(
                textDirection: isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Container(
                  decoration: BoxDecoration(gradient: gradient),
                  child: child!,
                ),
              );
            },
            home: const AuthWrapper(),
            routes: {
              '/historique': (context) => const HistoriqueScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/artisan-settings': (context) =>
                  const ArtisanSettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
