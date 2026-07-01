// ═══ FILE: lib/views/auth/login_screen.dart ═══
//
// HirfaHome — Login Screen
//
// iOS 26 Liquid Glass redesign:
//  - Full-bleed gradient hero with glassmorphic logo
//  - Form card is a LiquidGlass surface (translucent with backdrop blur)
//  - Glass input fields
//  - LiquidButton with gradient + glow
//  - Glass Google sign-in button
//  - All content sits on the gradient — no separate white background
//  - Fully localized (FR/AR/EN)
//  - Theme-aware (light/dark mode)
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/viewmodels/auth_viewmodel.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/utils/validators.dart';
import 'register_screen.dart';
import 'package:hirfahome/widgets/liquid_glass.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  late final AnimationController _anim;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
  Future<void> _handleLogin(AuthViewModel authVM, String lang) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    try {
      await authVM.login(email, pass);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('unverified_email')) {
        _showVerifyEmailSheet(context, authVM, email, lang);
      } else {
        _showGlassSnack(msg, isError: true);
      }
    }
  }
  void _showGlassSnack(String message, {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : isSuccess ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
              color: Colors.white, size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
          ],
        ),
        backgroundColor: isError ? AppColors.error : isSuccess ? AppColors.success : AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  void _showForgotPasswordSheet(BuildContext context, AuthViewModel authVM, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GlassForgotPasswordSheet(authVM: authVM, lang: lang),
    );
  }
  void _showVerifyEmailSheet(BuildContext context, AuthViewModel authVM, String email, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GlassVerifyEmailSheet(authVM: authVM, email: email, lang: lang),
    );
  }
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageViewModel>().lang;
    final authVM = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      // Full-bleed gradient background — the entire screen is the gradient
      body: Container(
        decoration: AppDecorations.heroGradient,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: topPad > 0 ? AppSpacing.xxl : AppSpacing.xxxl),
                    // ── Glassmorphic logo badge ──────────────────────────
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.asset(
                                'assets/images/HirfaHome.png',
                                fit: BoxFit.cover,
                                errorBuilder: (e, o, s) => const Icon(Icons.build_rounded, color: Colors.white, size: 44),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // ── Brand name ────────────────────────────────────────
                    Text(
                      'HirfaHome',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // ── Tagline ───────────────────────────────────────────
                    Text(
                      AppStrings.t('app_tagline', lang),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl * 2),
                    // ── Liquid Glass form card ────────────────────────────
                    FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: LiquidGlass(
                          blur: 25,
                          opacity: isDark ? 0.15 : 0.5,
                          borderRadius: 28,
                          padding: const EdgeInsets.all(28),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ── Heading ───────────────────────────────
                                Text(
                                  AppStrings.t('bienvenue', lang),
                                  style: GoogleFonts.inter(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppStrings.t('connectez_vous', lang),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.6)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                                // ── Email field ───────────────────────────
                                _GlassField(
                                  controller: _emailCtrl,
                                  label: AppStrings.t('email', lang),
                                  hint: AppStrings.t('email_hint', lang),
                                  icon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  isDark: isDark,
                                  validator: (v) => Validators.email(
                                    v,
                                    requiredMsg: AppStrings.t('email', lang),
                                    invalidMsg: AppStrings.t('login_invalid_email', lang),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.base),
                                // ── Password field ────────────────────────
                                _GlassField(
                                  controller: _passCtrl,
                                  label: AppStrings.t('mot_de_passe', lang),
                                  hint: '••••••••',
                                  icon: Icons.lock_outline_rounded,
                                  obscure: _obscure,
                                  textInputAction: TextInputAction.done,
                                  isDark: isDark,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return AppStrings.t('mot_de_passe', lang);
                                    if (v.length < 6) return AppStrings.t('login_password_too_short', lang);
                                    return null;
                                  },
                                  onSubmitted: (s) => _handleLogin(authVM, lang),
                                  suffix: GestureDetector(
                                    onTap: () => setState(() => _obscure = !_obscure),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Icon(
                                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        size: 22,
                                        color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textHint,
                                      ),
                                    ),
                                  ),
                                ),
                                // ── Forgot password ───────────────────────
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => _showForgotPasswordSheet(context, authVM, lang),
                                    child: Text(
                                      AppStrings.t('mot_de_passe_oublié', lang),
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                // ── Liquid Glass CTA ──────────────────────
                                LiquidButton(
                                  label: AppStrings.t('se_connecter', lang),
                                  isLoading: authVM.isLoading,
                                  onPressed: authVM.isLoading ? null : () => _handleLogin(authVM, lang),
                                  borderRadius: 16,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                // ── Divider ───────────────────────────────
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        AppStrings.t('ou', lang),
                                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textHint),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08))),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.base),
                                // ── Glass Google button ───────────────────
                                _GlassGoogleButton(
                                  isLoading: authVM.isLoading,
                                  lang: lang,
                                  isDark: isDark,
                                  onPressed: () async {
                                    final success = await authVM.loginWithGoogle();
                                    if (!success && authVM.errorMessage != null) {
                                      final msg = authVM.errorMessage!;
                                      if (!mounted) return;
                                      _showGlassSnack(msg, isError: true);
                                    }
                                  },
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                                // ── Register link ─────────────────────────
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppStrings.t('pas_de_compte', lang),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const RegisterScreen())),
                                      child: Text(
                                        AppStrings.t('creer_compte', lang),
                                        style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// GLASS INPUT FIELD — translucent field on glass background
// ═══════════════════════════════════════════════════════════════════════════
class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffix;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final bool isDark;
  const _GlassField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.validator,
  });
  @override
  Widget build(BuildContext context) {
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.35);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textHint),
            prefixIcon: Icon(icon, size: 22, color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textHint),
            suffixIcon: suffix,
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.35), width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.35), width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// GLASS GOOGLE BUTTON — translucent with multi-color G
// ═══════════════════════════════════════════════════════════════════════════
class _GlassGoogleButton extends StatelessWidget {
  final bool isLoading;
  final String lang;
  final bool isDark;
  final VoidCallback onPressed;
  const _GlassGoogleButton({
    required this.isLoading,
    required this.lang,
    required this.isDark,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF4285F4), Color(0xFF34A853), Color(0xFFFBBC05), Color(0xFFEA4335)],
                  ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: const Text('G', style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.t('continue_with_google', lang),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
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
// ═══════════════════════════════════════════════════════════════════════════
// GLASS FORGOT PASSWORD BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════
class _GlassForgotPasswordSheet extends StatefulWidget {
  final AuthViewModel authVM;
  final String lang;
  const _GlassForgotPasswordSheet({required this.authVM, required this.lang});
  @override
  State<_GlassForgotPasswordSheet> createState() => _GlassForgotPasswordSheetState();
}
class _GlassForgotPasswordSheetState extends State<_GlassForgotPasswordSheet> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _sent = false;
  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }
  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final success = await widget.authVM.sendPasswordResetEmail(_emailCtrl.text.trim());
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (success) {
      setState(() => _sent = true);
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
      child: LiquidGlass(
        blur: 30,
        opacity: isDark ? 0.2 : 0.6,
        borderRadius: 28,
        padding: const EdgeInsets.all(24),
        child: _sent ? _buildSuccess(isDark) : _buildForm(isDark),
      ),
    );
  }
  Widget _buildForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GlassDragHandle(isDark: isDark),
          Text(
            AppStrings.t('forgot_password_title', widget.lang),
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.t('forgot_password_description', widget.lang),
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 24),
          _GlassField(
            controller: _emailCtrl,
            label: AppStrings.t('email', widget.lang),
            hint: AppStrings.t('email_hint', widget.lang),
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
            validator: (v) => Validators.email(
              v,
              requiredMsg: AppStrings.t('email', widget.lang),
              invalidMsg: AppStrings.t('login_invalid_email', widget.lang),
            ),
          ),
          const SizedBox(height: 24),
          LiquidButton(
            label: AppStrings.t('forgot_password_send', widget.lang),
            isLoading: _isLoading,
            onPressed: _sendResetLink,
          ),
        ],
      ),
    );
  }
  Widget _buildSuccess(bool isDark) {
    final email = _emailCtrl.text.trim();
    final message = AppStrings.t('forgot_password_success_message', widget.lang).replaceAll('{email}', email);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
            child: const Icon(Icons.mark_email_read_outlined, size: 36, color: AppColors.success),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.t('forgot_password_success_title', widget.lang),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.t('ok', widget.lang)),
        ),
      ],
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// GLASS VERIFY EMAIL BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════
class _GlassVerifyEmailSheet extends StatefulWidget {
  final AuthViewModel authVM;
  final String email;
  final String lang;
  const _GlassVerifyEmailSheet({required this.authVM, required this.email, required this.lang});
  @override
  State<_GlassVerifyEmailSheet> createState() => _GlassVerifyEmailSheetState();
}
class _GlassVerifyEmailSheetState extends State<_GlassVerifyEmailSheet> {
  bool _isResending = false;
  Future<void> _resendVerification() async {
    setState(() => _isResending = true);
    await widget.authVM.resendVerification();
    setState(() => _isResending = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.t('verify_email_sheet_resent', widget.lang)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final description = AppStrings.t('verify_email_sheet_description', widget.lang).replaceAll('{email}', widget.email);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
      child: LiquidGlass(
        blur: 30,
        opacity: isDark ? 0.2 : 0.6,
        borderRadius: 28,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GlassDragHandle(isDark: isDark),
            Text(
              AppStrings.t('verify_email_sheet_title', widget.lang),
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textPrimary, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            LiquidButton(
              label: AppStrings.t('verify_email_sheet_resend', widget.lang),
              isLoading: _isResending,
              onPressed: _resendVerification,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.t('cancel', widget.lang)),
            ),
          ],
        ),
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// GLASS DRAG HANDLE
// ═══════════════════════════════════════════════════════════════════════════
class _GlassDragHandle extends StatelessWidget {
  final bool isDark;
  const _GlassDragHandle({required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36, height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
