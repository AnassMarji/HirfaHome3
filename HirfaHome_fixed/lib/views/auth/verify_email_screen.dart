// ═══ FILE: lib/views/auth/verify_email_screen.dart ═══
//
// HirfaHome — Verify Email Screen
// iOS 26 Liquid Glass redesign matching login + register.
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/viewmodels/auth_viewmodel.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/widgets/liquid_glass.dart';
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}
class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;
  bool _resendJustSent = false;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus());
  }
  Future<void> _checkStatus() async {
    final authVm = context.read<AuthViewModel>();
    final navigator = Navigator.of(context);
    final isVerified = await authVm.checkEmailVerification();
    if (!mounted) return;
    if (isVerified) {
      _timer?.cancel();
      navigator.pushReplacementNamed('/');
    }
  }
  Future<void> _resendEmail() async {
    final authVm = context.read<AuthViewModel>();
    await authVm.resendVerification();
    if (!mounted) return;
    setState(() => _resendJustSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.t('verify_email_resent', context.read<LanguageViewModel>().lang)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _resendJustSent = false);
    });
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageViewModel>().lang;
    final authVm = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Container(
        decoration: AppDecorations.heroGradient,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: topPad > 0 ? AppSpacing.xxl : AppSpacing.xxxl),
                  // ── Glass icon container ──────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // ── Title ─────────────────────────────────────────────
                  Text(
                    AppStrings.t('verify_email_title', lang),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // ── Description ───────────────────────────────────────
                  Text(
                    AppStrings.t('verify_email_description', lang),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl * 2),
                  // ── Liquid Glass card with actions ────────────────────
                  LiquidGlass(
                    blur: 25,
                    opacity: isDark ? 0.15 : 0.5,
                    borderRadius: 28,
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        LiquidButton(
                          label: authVm.isLoading
                              ? '...'
                              : AppStrings.t('verify_email_resend', lang),
                          isLoading: authVm.isLoading,
                          onPressed: authVm.isLoading ? null : _resendEmail,
                        ),
                        if (_resendJustSent) ...[
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.t('verify_email_resent_hint', lang),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.success,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () async {
                            final nav = Navigator.of(context);
                            await authVm.logout();
                            if (mounted) nav.pop();
                          },
                          child: Text(
                            AppStrings.t('cancel', lang),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
