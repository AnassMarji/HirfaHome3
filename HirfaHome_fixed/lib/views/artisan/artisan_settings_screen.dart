// ═══ FILE: lib/views/artisan/artisan_settings_screen.dart ═══
//
// HirfaHome — Artisan Settings Screen
// Mirrors client settings_screen.dart with artisan-specific fields.
// Includes dark mode toggle, language switch, and all artisan preferences.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/viewmodels/theme_viewmodel.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/widgets/glass_scaffold.dart';
import 'package:hirfahome/views/artisan/artisan_availability_screen.dart';
import 'package:hirfahome/widgets/glass_container.dart';
class ArtisanSettingsScreen extends StatefulWidget {
  const ArtisanSettingsScreen({super.key});
  @override
  State<ArtisanSettingsScreen> createState() =>
      _ArtisanSettingsScreenState();
}
class _ArtisanSettingsScreenState extends State<ArtisanSettingsScreen> {
  bool _notificationsEnabled = true;
  Future<void> _confirmDeleteAccount() async {
    final lang = context.read<LanguageViewModel>().lang;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t('artisan_settings_delete_title', lang)),
        content: Text(
          AppStrings.t('artisan_settings_delete_warning', lang),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.t('cancel', lang)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
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
      final artisanDoc = await FirebaseFirestore.instance
          .collection('artisans').doc(user.uid).get();
      if (artisanDoc.exists) {
        await FirebaseFirestore.instance
            .collection('artisans').doc(user.uid).delete();
      }
      await FirebaseFirestore.instance
          .collection('users').doc(user.uid).delete();
      await user.delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.t('artisan_settings_error', lang)
                .replaceAll('{error}', e.toString())),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final langVM = context.watch<LanguageViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    final lang = langVM.lang;
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      
      appBar: GlassAppBar(
        title: AppStrings.t('artisan_settings_title', lang),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: user != null
            ? FirebaseFirestore.instance
                .collection('users').doc(user.uid).snapshots()
            : const Stream.empty(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final name = data?['nom'] as String? ?? user?.displayName ?? '—';
          final phone = data?['telephone'] as String? ?? '—';
          final metier = data?['specialite'] as String? ?? '—';
          final tarif = data?['tarifs'] != null
              ? '${(data!['tarifs'] as num).toStringAsFixed(0)} DH/h'
              : '—';
          final photoUrl = data?['photoUrl'] as String?;
          return ListView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base, vertical: AppSpacing.base),
            children: [
              // ── COMPTE ──────────────────────────────────────────────
              _SectionHeader(
                label: AppStrings.t('settings_account', lang),
              ),
              _SettingsCard(children: [
                _SettingsTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? const Icon(Icons.person,
                            color: AppColors.primary, size: 22)
                        : null,
                  ),
                  title: AppStrings.t('settings_profile_photo', lang),
                  trailing: Icon(Icons.camera_alt_outlined,
                      color: AppColors.textHint, size: 20),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                _Divider(),
                _SettingsTile(
                  leading: _IconBox(Icons.person_outline),
                  title: AppStrings.t('settings_full_name', lang),
                  trailing: Text(name,
                      style: AppTextStyles.bodyMedium,
                      overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                _Divider(),
                _SettingsTile(
                  leading: _IconBox(Icons.phone_android_outlined),
                  title: AppStrings.t('settings_phone', lang),
                  trailing: Text(phone,
                      style: AppTextStyles.bodyMedium,
                      overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                _Divider(),
                _SettingsTile(
                  leading: _IconBox(Icons.work_outline_rounded),
                  title: AppStrings.t('artisan_nav_dashboard', lang),
                  trailing: Text(metier,
                      style: AppTextStyles.bodyMedium,
                      overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                _Divider(),
                _SettingsTile(
                  leading: _IconBox(Icons.payments_outlined),
                  title: AppStrings.t('artisan_tarif', lang),
                  trailing: Text(tarif,
                      style: AppTextStyles.bodyMedium,
                      overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
              ]),
              const SizedBox(height: AppSpacing.xl),
              // ── PRÉFÉRENCES ─────────────────────────────────────────
              _SectionHeader(
                label: AppStrings.t('settings_preferences', lang),
              ),
              _SettingsCard(children: [
                // Language
                _SettingsTile(
                  leading: _IconBox(Icons.language_rounded),
                  title: AppStrings.t('settings_language', lang),
                  trailing: GestureDetector(
                    onTap: langVM.cycle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        langVM.flagLabel,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  onTap: langVM.cycle,
                ),
                _Divider(),
                // ── DARK MODE TOGGLE ───────────────────────────────────
                _SettingsTile(
                  leading: _IconBox(
                    themeVM.isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                  ),
                  title: AppStrings.t('settings_dark_mode', lang),
                  trailing: Switch(
                    value: themeVM.isDark,
                    onChanged: (val) => themeVM.setThemeMode(
                        val ? ThemeMode.dark : ThemeMode.light),
                  ),
                  onTap: themeVM.toggle,
                ),
                _Divider(),
                // Notifications
                _SettingsTile(
                  leading: _IconBox(Icons.notifications_outlined),
                  title: AppStrings.t('settings_notifications', lang),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (val) =>
                        setState(() => _notificationsEnabled = val),
                  ),
                  onTap: () => setState(
                      () => _notificationsEnabled = !_notificationsEnabled),
                ),
              ]),
              const SizedBox(height: AppSpacing.xl),
              // ── DISPONIBILITÉ ───────────────────────────────────────
              _SectionHeader(
                label: AppStrings.t('artisan_disponibilite', lang),
              ),
              _SettingsCard(children: [
                _SettingsTile(
                  leading: _IconBox(Icons.schedule_rounded),
                  title: AppStrings.t('artisan_availability_save', lang),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: AppColors.textHint),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ArtisanAvailabilityScreen(),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: AppSpacing.xl),
              // ── DANGER ZONE ─────────────────────────────────────────
              _SectionHeader(
                label: AppStrings.t('settings_danger_zone', lang),
                isRed: true,
              ),
              _SettingsCard(children: [
                _SettingsTile(
                  leading: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.delete_forever_rounded,
                        color: AppColors.error, size: 20),
                  ),
                  title: AppStrings.t('settings_delete_account', lang),
                  titleStyle: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.error),
                  trailing: null,
                  onTap: _confirmDeleteAccount,
                ),
              ]),
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
  final bool isRed;
  const _SectionHeader({required this.label, this.isRed = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSpacing.xs, bottom: AppSpacing.sm),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isRed ? AppColors.error : AppColors.textHint,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
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
  final Widget leading;
  final String title;
  final TextStyle? titleStyle;
  final Widget? trailing;
  final VoidCallback onTap;
  const _SettingsTile({
    required this.leading,
    required this.title,
    required this.trailing,
    required this.onTap,
    this.titleStyle,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.md),
        child: Row(
          children: [
            leading,
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: titleStyle ?? AppTextStyles.bodyLarge,
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
  const _IconBox(this.icon);
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
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1, thickness: 1,
      color: AppColors.divider,
      indent: 56,
    );
  }
}
