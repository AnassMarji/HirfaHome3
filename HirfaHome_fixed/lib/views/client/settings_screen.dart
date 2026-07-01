// ═══ FILE: lib/views/client/settings_screen.dart ═══
//
// HirfaHome — Client Settings Screen
// Theme-aware (light/dark mode) with dark mode toggle.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/viewmodels/theme_viewmodel.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/widgets/app_components.dart';
import 'package:hirfahome/widgets/glass_scaffold.dart';
import 'package:hirfahome/widgets/glass_container.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  Future<void> _confirmDeleteAccount() async {
    final lang = context.read<LanguageViewModel>().lang;
    final cs = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppStrings.t('artisan_settings_delete_title', lang),
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.error),
        ),
        content: Text(
          AppStrings.t('artisan_settings_delete_warning', lang),
          style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.t('cancel', lang)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.t('artisan_settings_delete_account', lang)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Erreur : $e', isError: true);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final langVM = context.watch<LanguageViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    final lang = langVM.lang;
    final user = FirebaseAuth.instance.currentUser;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: GlassAppBar(title: AppStrings.t('artisan_settings_title', lang)),
      body: StreamBuilder<DocumentSnapshot>(
        stream: user != null
            ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
            : const Stream.empty(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final name = data?['nom'] as String? ?? user?.displayName ?? '—';
          final email = user?.email ?? '—';
          final phone = data?['telephone'] as String? ?? '—';
          final photoUrl = data?['photoUrl'] as String?;
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.base),
            children: [
              // ── COMPTE ──────────────────────────────────────────────────
              _SectionHeader(label: AppStrings.t('settings_account', lang), cs: cs),
              _SettingsCard(
                cs: cs,
                children: [
                  _SettingsTile(
                    cs: cs,
                    leading: AppAvatar(imageUrl: photoUrl, name: name, radius: 20),
                    title: AppStrings.t('settings_profile_photo', lang),
                    trailing: Icon(Icons.camera_alt_outlined, color: cs.onSurface.withValues(alpha: 0.4), size: 20),
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  _Divider(cs: cs),
                  _SettingsTile(
                    cs: cs,
                    leading: _IconBox(Icons.person_outline, cs: cs),
                    title: AppStrings.t('settings_full_name', lang),
                    trailing: Text(name, style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.6)), overflow: TextOverflow.ellipsis),
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  _Divider(cs: cs),
                  _SettingsTile(
                    cs: cs,
                    leading: _IconBox(Icons.alternate_email_rounded, cs: cs),
                    title: AppStrings.t('email', lang),
                    trailing: Text(email, style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.6)), overflow: TextOverflow.ellipsis),
                    onTap: () {},
                  ),
                  _Divider(cs: cs),
                  _SettingsTile(
                    cs: cs,
                    leading: _IconBox(Icons.phone_android_outlined, cs: cs),
                    title: AppStrings.t('settings_phone', lang),
                    trailing: Text(phone, style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.6)), overflow: TextOverflow.ellipsis),
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // ── PRÉFÉRENCES ─────────────────────────────────────────────
              _SectionHeader(label: AppStrings.t('settings_preferences', lang), cs: cs),
              _SettingsCard(
                cs: cs,
                children: [
                  // Language
                  _SettingsTile(
                    cs: cs,
                    leading: _IconBox(Icons.language_rounded, cs: cs),
                    title: AppStrings.t('settings_language', lang),
                    trailing: GestureDetector(
                      onTap: langVM.cycle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          langVM.flagLabel,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                        ),
                      ),
                    ),
                    onTap: langVM.cycle,
                  ),
                  _Divider(cs: cs),
                  // ── DARK MODE TOGGLE ────────────────────────────────────
                  _SettingsTile(
                    cs: cs,
                    leading: _IconBox(
                      themeVM.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      cs: cs,
                    ),
                    title: AppStrings.t('settings_dark_mode', lang),
                    trailing: Switch(
                      value: themeVM.isDark,
                      onChanged: (val) => themeVM.setThemeMode(val ? ThemeMode.dark : ThemeMode.light),
                    ),
                    onTap: themeVM.toggle,
                  ),
                  _Divider(cs: cs),
                  // Notifications
                  _SettingsTile(
                    cs: cs,
                    leading: _IconBox(Icons.notifications_outlined, cs: cs),
                    title: AppStrings.t('settings_notifications', lang),
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                    ),
                    onTap: () => setState(() => _notificationsEnabled = !_notificationsEnabled),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // ── SÉCURITÉ ────────────────────────────────────────────────
              _SectionHeader(label: AppStrings.t('settings_security', lang), cs: cs),
              _SettingsCard(
                cs: cs,
                children: [
                  _SettingsTile(
                    cs: cs,
                    leading: _IconBox(Icons.lock_outline_rounded, cs: cs),
                    title: AppStrings.t('settings_change_password', lang),
                    trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.3)),
                    onTap: () => AppSnackbar.show(context, AppStrings.t('coming_soon', lang)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // ── DANGER ZONE ─────────────────────────────────────────────
              _SectionHeader(label: AppStrings.t('settings_danger_zone', lang), cs: cs, isRed: true),
              _SettingsCard(
                cs: cs,
                children: [
                  _SettingsTile(
                    cs: cs,
                    leading: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 20),
                    ),
                    title: AppStrings.t('settings_delete_account', lang),
                    titleColor: AppColors.error,
                    onTap: _confirmDeleteAccount,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          );
        },
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  final bool isRed;
  const _SectionHeader({required this.label, required this.cs, this.isRed = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isRed ? AppColors.error : cs.onSurface.withValues(alpha: 0.4),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final ColorScheme cs;
  const _SettingsCard({required this.children, required this.cs});
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Column(children: children),
    );
  }
}
class _SettingsTile extends StatelessWidget {
  final ColorScheme cs;
  final Widget leading;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback onTap;
  const _SettingsTile({
    required this.cs,
    required this.leading,
    required this.title,
    required this.onTap,
    this.trailing,
    this.titleColor,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
        child: Row(
          children: [
            leading,
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? cs.onSurface,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
class _IconBox extends StatelessWidget {
  final IconData icon;
  final ColorScheme cs;
  const _IconBox(this.icon, {required this.cs});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}
class _Divider extends StatelessWidget {
  final ColorScheme cs;
  const _Divider({required this.cs});
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1, thickness: 1,
      color: cs.outline.withValues(alpha: 0.15),
      indent: 56,
    );
  }
}
