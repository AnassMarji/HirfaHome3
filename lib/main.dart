// ═══ FILE: lib/main.dart ═══
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import 'package:hirfahome/services/seed_service.dart';
import 'package:hirfahome/viewmodels/auth_viewmodel.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/views/auth/auth_wrapper.dart';
import 'package:hirfahome/views/artisan/artisan_settings_screen.dart';
import 'package:hirfahome/views/client/historique_screen.dart';
import 'package:hirfahome/views/client/settings_screen.dart';
import 'package:hirfahome/views/profile/profile_screen.dart';
import 'package:hirfahome/config/app_theme.dart'; // ← already imported

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background FCM message received: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter Error: ${details.exception}');
  };

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (kDebugMode) {
    try {
      await SeedService.seedDatabase();
    } catch (e) {
      debugPrint('Seed error (non-blocking): $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DemandeRepository>(create: (_) => FirestoreDemandeRepository()),
        Provider<ArtisanRepository>(create: (_) => FirestoreArtisanRepository()),
        Provider<ChatRepository>(create: (_) => FirestoreChatRepository()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
      ],
      child: MaterialApp(
        title: 'HirfaHome',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light, // ← single line replaces the entire ThemeData block
        home: const AuthWrapper(),
        routes: {
          '/historique': (context) => const HistoriqueScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/artisan-settings': (context) => const ArtisanSettingsScreen(),
        },
      ),
    );
  }
}