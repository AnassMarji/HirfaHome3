// ═══ FILE: lib/views/auth/register_screen.dart ═══
//
// HirfaHome — Register Screen
// iOS 26 Liquid Glass redesign matching the login screen.
// Full-bleed gradient, glass form card, glass inputs, glass role selector,
// LiquidButton CTA, fully localized, dark mode ready.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/viewmodels/auth_viewmodel.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/utils/validators.dart';
import 'verify_email_screen.dart';
import 'package:hirfahome/widgets/liquid_glass.dart';
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
  final _formKey = GlobalKey<FormState>();
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
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }
  Future<void> _handleRegister(AuthViewModel authVM, String lang) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final success = await authVM.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nomController.text.trim(),
      _role,
      _telephoneController.text.trim(),
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
    final lang = context.watch<LanguageViewModel>().lang;
    final authVM = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
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
                    SizedBox(height: topPad > 0 ? AppSpacing.sm : AppSpacing.lg),
                    // ── Back button ────────────────────────────────────────
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    // ── Title ──────────────────────────────────────────────
                    Text(
                      AppStrings.t('creer_un_compte', lang),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppStrings.t('rejoindre_communaute', lang),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl * 2),
                    // ── Liquid Glass form card ──────────────────────────────
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
                                // ── Nom complet ─────────────────────────────
                                _GlassField(
                                  controller: _nomController,
                                  label: AppStrings.t('nom_complet', lang),
                                  hint: AppStrings.t('nom_hint', lang),
                                  icon: Icons.person_outline_rounded,
                                  isDark: isDark,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => Validators.required(v, message: AppStrings.t('nom_complet', lang)),
                                ),
                                const SizedBox(height: AppSpacing.base),
                                // ── Téléphone ───────────────────────────────
                                _GlassField(
                                  controller: _telephoneController,
                                  label: AppStrings.t('phone_label', lang),
                                  hint: '06XXXXXXXX',
                                  icon: Icons.phone_outlined,
                                  isDark: isDark,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => Validators.phone(
                                    v,
                                    requiredMsg: AppStrings.t('phone_label', lang),
                                    invalidMsg: AppStrings.t('phone_invalid', lang),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.base),
                                // ── Email ───────────────────────────────────
                                _GlassField(
                                  controller: _emailController,
                                  label: AppStrings.t('email', lang),
                                  hint: AppStrings.t('email_hint', lang),
                                  icon: Icons.mail_outline_rounded,
                                  isDark: isDark,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => Validators.email(
                                    v,
                                    requiredMsg: AppStrings.t('email', lang),
                                    invalidMsg: AppStrings.t('login_invalid_email', lang),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.base),
                                // ── Mot de passe ────────────────────────────
                                _GlassField(
                                  controller: _passwordController,
                                  label: AppStrings.t('mot_de_passe', lang),
                                  hint: '••••••••',
                                  icon: Icons.lock_outline_rounded,
                                  isDark: isDark,
                                  obscure: _obscure,
                                  textInputAction: TextInputAction.done,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return AppStrings.t('mot_de_passe', lang);
                                    if (v.length < 6) return AppStrings.t('login_password_too_short', lang);
                                    return null;
                                  },
                                  suffix: GestureDetector(
                                    onTap: () => setState(() => _obscure = !_obscure),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Icon(
                                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        size: 22,
                                        color: isDark ? Colors.black.withValues(alpha: 0.06) : AppColors.textHint,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.base),
                                // ── Role selector (glass segmented control) ─
                                Text(
                                  AppStrings.t('je_suis', lang),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.05)
                                            : Colors.black.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                                          width: 0.5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _GlassSegment(
                                              label: AppStrings.t('option_client', lang),
                                              isSelected: _role == 'client',
                                              isDark: isDark,
                                              onTap: () => setState(() => _role = 'client'),
                                            ),
                                          ),
                                          Expanded(
                                            child: _GlassSegment(
                                              label: AppStrings.t('option_artisan', lang),
                                              isSelected: _role == 'artisan',
                                              isDark: isDark,
                                              onTap: () => setState(() => _role = 'artisan'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                // ── Error message ───────────────────────────
                                if (authVM.errorMessage != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorLight.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            authVM.errorMessage!,
                                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.error),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // ── Liquid Glass CTA ────────────────────────
                                LiquidButton(
                                  label: AppStrings.t('sinscrire', lang),
                                  isLoading: authVM.isLoading,
                                  onPressed: authVM.isLoading ? null : () => _handleRegister(authVM, lang),
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                                // ── Login link ──────────────────────────────
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppStrings.t('deja_compte', lang),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        AppStrings.t('se_connecter', lang),
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
// GLASS INPUT FIELD (same as login screen)
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
            prefixIcon: Icon(icon, size: 22, color: isDark ? Colors.black.withValues(alpha: 0.06) : AppColors.textHint),
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
// GLASS SEGMENT — for the role selector
// ═══════════════════════════════════════════════════════════════════════════
class _GlassSegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  const _GlassSegment({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
