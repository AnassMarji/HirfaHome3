
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus());
  }

  void _checkStatus() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final navigator = Navigator.of(context);
    bool isVerified = await authVM.checkEmailVerification();
    if (!mounted) return;
    if (isVerified) {
      timer?.cancel();
      navigator.pushReplacementNamed('/'); // Go to Home
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_rounded, size: 80, color: Color(0xFFD94F00)),
              const SizedBox(height: 24),
              const Text("Vérifiez votre Gmail", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                "Un lien de confirmation a été envoyé. Veuillez cliquer dessus pour activer votre compte.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: authVM.isLoading ? null : () => authVM.resendVerification(),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD94F00)),
                child: const Text("Renvoyer l'email"),
              ),
              TextButton(
                onPressed: () {
                  final nav = Navigator.of(context);
                  authVM.logout().then((_) => nav.pop());
                },
                child: const Text("Annuler"),
              )
            ],
          ),
        ),
      ),
    );
  }
}