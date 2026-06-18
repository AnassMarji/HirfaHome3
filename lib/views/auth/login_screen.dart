// lib/views/auth/login_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// HirfaHome — Login Screen (premium redesign: gradient hero + white card)
// ─────────────────────────────────────────────────────────────────────────────


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/language_viewmodel.dart';
import '../../strings/app_strings.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  late final AnimationController _anim;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _anim.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin(AuthViewModel authVM, String lang) async {
    FocusScope.of(context).unfocus();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.t('erreur_champs', lang)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
          margin: const EdgeInsets.all(AppSpacing.base),
        ),
      );
      return;
    }

    try {
      await authVM.login(email, pass);
    } catch (e) {
      if (e.toString().contains('unverified_email') ||
          e == 'unverified_email') {
        if (mounted) _showVerifyEmailSheet(context, authVM, email);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.cardRadius),
              margin: const EdgeInsets.all(AppSpacing.base),
            ),
          );
        }
      }
    }
  }

  void _showForgotPasswordSheet(
      BuildContext context, AuthViewModel authVM, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ForgotPasswordSheet(authVM: authVM, lang: lang),
    );
  }

  void _showVerifyEmailSheet(
      BuildContext context, AuthViewModel authVM, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _VerifyEmailSheet(authVM: authVM, email: email),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langVM = Provider.of<LanguageViewModel>(context);
    final lang = langVM.lang;
    final isRtl = langVM.isRtl;
    final authVM = Provider.of<AuthViewModel>(context);

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
                // ── Orange gradient hero header (height 220) ───────────────
                _LoginHeroHeader(lang: lang),

                // ── White card with form ───────────────────────────────────
                FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.base, 0, AppSpacing.base, AppSpacing.xl),
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
                            // ── Form heading ─────────────────────────────
                            Text(
                              AppStrings.t('bienvenue', lang),
                              style: AppTextStyles.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.t('connectez_vous', lang),
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // ── Email field ──────────────────────────────
                            _FieldLabel(AppStrings.t('email', lang)),
                            const SizedBox(height: AppSpacing.sm),
                            _AuthField(
                              controller: _emailCtrl,
                              hint: AppStrings.t('email_hint', lang),
                              icon: Icons.mail_outline_rounded,
                              keyboard: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: AppSpacing.base),

                            // ── Password field ───────────────────────────
                            _FieldLabel(
                                AppStrings.t('mot_de_passe', lang)),
                            const SizedBox(height: AppSpacing.sm),
                            _AuthField(
                              controller: _passCtrl,
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscure,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (s) =>
                                  _handleLogin(authVM, lang),
                              suffix: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppColors.textHint,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),

                            // ── Forgot password ──────────────────────────
                            Align(
                              alignment: isRtl
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    _showForgotPasswordSheet(
                                        context, authVM, lang),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  AppStrings.t(
                                      'mot_de_passe_oublié', lang),
                                  style: AppTextStyles.labelLarge.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // ── Primary CTA ──────────────────────────────
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: authVM.isLoading
                                    ? null
                                    : () => _handleLogin(authVM, lang),
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
                                        AppStrings.t(
                                            'se_connecter', lang),
                                        style: AppTextStyles.buttonText,
                                      ),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // ── Divider "ou" ─────────────────────────────
                            Row(
                              children: [
                                const Expanded(
                                    child: Divider(
                                        color: AppColors.divider)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md),
                                  child: Text('ou',
                                      style: AppTextStyles.labelSmall),
                                ),
                                const Expanded(
                                    child: Divider(
                                        color: AppColors.divider)),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.base),

                            // ── Google button ────────────────────────────
                            _GoogleSignInButton(
                              isLoading: authVM.isLoading,
                              lang: lang,
                              onPressed: () async {
                                final messenger =
                                    ScaffoldMessenger.of(context);
                                final success =
                                    await authVM.loginWithGoogle();
                                if (!mounted) return;
                                if (!success &&
                                    authVM.errorMessage != null) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          authVM.errorMessage!),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            AppRadius.cardRadius,
                                      ),
                                      margin: const EdgeInsets.all(
                                          AppSpacing.base),
                                    ),
                                  );
                                }
                              },
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // ── Register link ────────────────────────────
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppStrings.t('pas_de_compte', lang),
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
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) =>
                                          const RegisterScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    AppStrings.t('creer_compte', lang),
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

// ─── Hero Header ──────────────────────────────────────────────────────────────

class _LoginHeroHeader extends StatelessWidget {
  final String lang;
  const _LoginHeroHeader({required this.lang});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: 220,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7A1500), AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo image with fallback
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/HirfaHome.png',
                    fit: BoxFit.cover,
                    errorBuilder: (e, o, s) => const Icon(
                      Icons.build_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // App name
              Text(
                'HirfaHome',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 6),
              // Subtitle
              Text(
                lang == 'ar'
                    ? 'اعثر على الحرفي المناسب لك'
                    : 'Trouvez l\'artisan qu\'il vous faut',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Wave Clipper ─────────────────────────────────────────────────────────────

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 36);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 18,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 36,
      size.width,
      size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

// ─── Google Sign-In Button ────────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final String lang;
  final VoidCallback onPressed;

  const _GoogleSignInButton({
    required this.isLoading,
    required this.lang,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final label = lang == 'ar'
        ? 'متابعة مع Google'
        : lang == 'en'
            ? 'Continue with Google'
            : 'Continuer avec Google';

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google multi-colour "G" via shader
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFF34A853),
                  Color(0xFFFBBC05),
                  Color(0xFFEA4335),
                ],
              ).createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: const Text(
                'G',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Auth Field ───────────────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboard;
  final Widget? suffix;
  final TextInputAction textInputAction;
  final Function(String)? onSubmitted;

  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboard = TextInputType.text,
    this.suffix,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textHint),
        suffixIcon: suffix,
      ),
    );
  }
}

// ─── Field Label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.titleMedium.copyWith(fontSize: 13),
    );
  }
}

// ─── Forgot Password Sheet ────────────────────────────────────────────────────

class _ForgotPasswordSheet extends StatefulWidget {
  final AuthViewModel authVM;
  final String lang;
  const _ForgotPasswordSheet({required this.authVM, required this.lang});

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _sendResetLink() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    setState(() => _isLoading = true);

    final success =
        await widget.authVM.sendPasswordResetEmail(email);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      setState(() => _sent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.authVM.errorMessage ??
              "Erreur lors de l'envoi du lien."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl,
          AppSpacing.xl + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: _sent ? _buildSuccess() : _buildEmailForm(),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Text('Mot de passe oublié', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Entrez votre adresse email pour recevoir un lien de réinitialisation.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        const _FieldLabel('Adresse Email'),
        const SizedBox(height: AppSpacing.sm),
        _AuthField(
          controller: _emailCtrl,
          hint: 'votre@email.com',
          icon: Icons.mail_outline_rounded,
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.xl),
        _SheetActionButton(
          text: 'Envoyer le lien',
          isLoading: _isLoading,
          onPressed: _sendResetLink,
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined,
                size: 32, color: AppColors.success),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Email envoyé !',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          "Si l'adresse ${_emailCtrl.text.trim()} correspond à un compte, vous recevrez un email avec les instructions.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

// ─── Verify Email Sheet ───────────────────────────────────────────────────────

class _VerifyEmailSheet extends StatefulWidget {
  final AuthViewModel authVM;
  final String email;
  const _VerifyEmailSheet({required this.authVM, required this.email});

  @override
  State<_VerifyEmailSheet> createState() => _VerifyEmailSheetState();
}

class _VerifyEmailSheetState extends State<_VerifyEmailSheet> {
  bool _isResending = false;

  void _resendVerification() async {
    setState(() => _isResending = true);
    await widget.authVM.resendVerification();
    setState(() => _isResending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email de vérification renvoyé.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl,
          AppSpacing.xl + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Vérifiez votre Email', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Un lien de vérification a été envoyé à ${widget.email}. Cliquez dessus pour activer votre compte.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          _SheetActionButton(
            text: 'Renvoyer le lien',
            isLoading: _isResending,
            onPressed: _resendVerification,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}

// ─── Sheet Action Button ──────────────────────────────────────────────────────

class _SheetActionButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;
  const _SheetActionButton(
      {required this.text,
      required this.isLoading,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(text, style: AppTextStyles.buttonText),
      ),
    );
  }
}