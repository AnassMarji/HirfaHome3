// lib/views/auth/register_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// HirfaHome — Register Screen (premium redesign: gradient hero + white card)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/language_viewmodel.dart';
import '../../strings/app_strings.dart';
import 'verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  String _role = 'client';
  bool _obscure = true;

  late final AnimationController _anim;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _anim.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  void _handleRegister(AuthViewModel authVM, String lang) async {
    FocusScope.of(context).unfocus();

    if (_nomController.text.trim().isEmpty ||
        _telephoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.t('erreur_champs', lang)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.cardRadius),
          margin: const EdgeInsets.all(AppSpacing.base),
        ),
      );
      return;
    }

    final phone = _telephoneController.text.trim();
    final phoneRegex = RegExp(r'^0[67]\d{8}$');
    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'ar'
              ? 'رقم الهاتف غير صالح. يجب أن يبدأ بـ 06 أو 07 ويتكون من 10 أرقام.'
              : lang == 'en'
                  ? 'Invalid phone number. Must start with 06 or 07 and be exactly 10 digits.'
                  : 'Numéro de téléphone invalide. Doit commencer par 06 ou 07 et contenir 10 chiffres.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.cardRadius),
          margin: const EdgeInsets.all(AppSpacing.base),
        ),
      );
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'ar'
              ? 'يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل.'
              : lang == 'en'
                  ? 'Password must be at least 6 characters.'
                  : 'Le mot de passe doit contenir au moins 6 caractères.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.cardRadius),
          margin: const EdgeInsets.all(AppSpacing.base),
        ),
      );
      return;
    }

    final success = await authVM.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nomController.text.trim(),
      _role,
      phone,
    );

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => const VerifyEmailScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final langVM = Provider.of<LanguageViewModel>(context);
    final lang = langVM.lang;
    final isRtl = langVM.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Orange gradient hero header (height 180) ──────────────
                _RegisterHeroHeader(lang: lang),

                // ── White card with form ──────────────────────────────────
                FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.base,
                          0,
                          AppSpacing.base,
                          AppSpacing.xl),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark
                                  .withValues(alpha: 0.08),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Heading
                            Text(
                              AppStrings.t('creer_un_compte', lang),
                              style: AppTextStyles.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.t('rejoindre_communaute', lang),
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // ── Nom complet ──────────────────────────────
                            _RegLabel(AppStrings.t('nom_complet', lang)),
                            const SizedBox(height: AppSpacing.sm),
                            _RegField(
                              controller: _nomController,
                              hint: AppStrings.t('nom_hint', lang),
                              icon: Icons.person_outline_rounded,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: AppSpacing.base),

                            // ── Téléphone ────────────────────────────────
                            _RegLabel(lang == 'ar'
                                ? 'رقم الهاتف'
                                : lang == 'en'
                                    ? 'Phone number'
                                    : 'Numéro de téléphone'),
                            const SizedBox(height: AppSpacing.sm),
                            _RegField(
                              controller: _telephoneController,
                              hint: '06XXXXXXXX',
                              icon: Icons.phone_outlined,
                              keyboard: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: AppSpacing.base),

                            // ── Email ────────────────────────────────────
                            _RegLabel(AppStrings.t('email', lang)),
                            const SizedBox(height: AppSpacing.sm),
                            _RegField(
                              controller: _emailController,
                              hint: AppStrings.t('email_hint', lang),
                              icon: Icons.mail_outline_rounded,
                              keyboard: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: AppSpacing.base),

                            // ── Mot de passe ─────────────────────────────
                            _RegLabel(
                                AppStrings.t('mot_de_passe', lang)),
                            const SizedBox(height: AppSpacing.sm),
                            _RegField(
                              controller: _passwordController,
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscure,
                              textInputAction: TextInputAction.done,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppColors.textHint,
                                ),
                                onPressed: () => setState(
                                    () => _obscure = !_obscure),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.base),

                            // ── Je suis (role) ───────────────────────────
                            _RegLabel(AppStrings.t('je_suis', lang)),
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.base),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _role,
                                  isExpanded: true,
                                  icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.textHint),
                                  style: AppTextStyles.bodyLarge,
                                  dropdownColor: AppColors.surface,
                                  items: [
                                    DropdownMenuItem(
                                      value: 'client',
                                      child: Text(AppStrings.t(
                                          'option_client', lang)),
                                    ),
                                    DropdownMenuItem(
                                      value: 'artisan',
                                      child: Text(AppStrings.t(
                                          'option_artisan', lang)),
                                    ),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => _role = val!),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // ── Error message ────────────────────────────
                            if (authVM.errorMessage != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  authVM.errorMessage!,
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.error),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                            // ── Primary CTA ──────────────────────────────
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: authVM.isLoading
                                    ? null
                                    : () => _handleRegister(authVM, lang),
                                child: authVM.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child:
                                            CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        AppStrings.t('sinscrire', lang),
                                        style: AppTextStyles.buttonText,
                                      ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // ── Login link ───────────────────────────────
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppStrings.t('deja_compte', lang),
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(width: 4),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: Text(
                                    AppStrings.t('se_connecter', lang),
                                    style: GoogleFonts.inter(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Register Hero Header ──────────────────────────────────────────────────────

class _RegisterHeroHeader extends StatelessWidget {
  final String lang;
  const _RegisterHeroHeader({required this.lang});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _RegisterWaveClipper(),
      child: Container(
        height: 180,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7A1500), AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Decorative circle
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: AppSpacing.sm, top: AppSpacing.sm),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              // Title & subtitle
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lang == 'ar'
                          ? 'إنشاء حساب'
                          : lang == 'en'
                              ? 'Create Account'
                              : 'Créer un compte',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lang == 'ar'
                          ? 'انضم إلى مجتمع HirfaHome'
                          : lang == 'en'
                              ? 'Join the HirfaHome community'
                              : 'Rejoignez la communauté HirfaHome',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Register Wave Clipper ────────────────────────────────────────────────────

class _RegisterWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 14,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 28,
      size.width,
      size.height - 8,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

// ─── Register Field Label ─────────────────────────────────────────────────────

class _RegLabel extends StatelessWidget {
  final String text;
  const _RegLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.titleMedium.copyWith(fontSize: 13),
    );
  }
}

// ─── Register Input Field ─────────────────────────────────────────────────────

class _RegField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboard;
  final Widget? suffix;
  final TextInputAction textInputAction;

  const _RegField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboard = TextInputType.text,
    this.suffix,
    this.textInputAction = TextInputAction.done,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      textInputAction: textInputAction,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textHint),
        suffixIcon: suffix,
      ),
    );
  }
}