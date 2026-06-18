
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/language_viewmodel.dart';
import '../../strings/app_strings.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 22, color: const Color(0xFFE65100)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  void _handleReset(AuthViewModel authVM, String lang) async {
    if (_emailController.text.trim().isEmpty) return;

    final success = await authVM.forgotPassword(_emailController.text.trim());
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'ar'
                ? 'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني!'
                : lang == 'en'
                    ? 'Reset link sent to your email!'
                    : 'Lien de réinitialisation envoyé à votre Gmail !',
          ),
          backgroundColor: const Color(0xFFD94F00),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final langVM = Provider.of<LanguageViewModel>(context);
    final lang = langVM.lang;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1C1C1C)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              AppStrings.t('mot_de_passe_oublié', lang),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1C)),
            ),
            const SizedBox(height: 10),
            Text(
              lang == 'ar'
                  ? 'أدخل بريدك الإلكتروني لتلقي رابط إعادة تعيين كلمة المرور.'
                  : lang == 'en'
                      ? 'Enter your email to receive a password reset link.'
                      : 'Entrez votre email pour recevoir un lien de réinitialisation.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 32),
            _ProfileTextField(
              controller: _emailController,
              label: AppStrings.t('email', lang),
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: authVM.isLoading ? null : () => _handleReset(authVM, lang),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD94F00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: authVM.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        lang == 'ar'
                            ? 'إرسال الرابط'
                            : lang == 'en'
                                ? 'Send link'
                                : 'Envoyer le lien',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}