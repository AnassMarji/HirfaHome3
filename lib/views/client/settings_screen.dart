// lib/views/client/settings_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// HirfaHome — Client Settings Screen
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  // ── Delete account ────────────────────────────────────────────────────────
  Future<void> _confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Supprimer mon compte',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.error),
        ),
        content: Text(
          'Cette action est irréversible. Toutes vos données seront définitivement supprimées.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Delete Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // Delete Auth account
      await user.delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langVM = context.watch<LanguageViewModel>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text('Paramètres', style: AppTextStyles.titleLarge),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: user != null
            ? FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots()
            : const Stream.empty(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final name = data?['nom'] as String? ?? user?.displayName ?? '—';
          final email = user?.email ?? '—';
          final phone = data?['telephone'] as String? ?? '—';
          final photoUrl = data?['photoUrl'] as String?;

          return ListView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base, vertical: AppSpacing.base),
            children: [
              // ── COMPTE section ──────────────────────────────────────────
              _SectionHeader(label: 'COMPTE'),
              _SettingsCard(
                children: [
                  // Photo de profil
                  _SettingsTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primarySurface,
                      backgroundImage:
                          photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? const Icon(Icons.person,
                              color: AppColors.primary, size: 22)
                          : null,
                    ),
                    title: 'Photo de profil',
                    trailing: const Icon(Icons.camera_alt_outlined,
                        color: AppColors.textHint, size: 20),
                    onTap: () {
                      // Navigate to profile edit
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  _Divider(),
                  // Nom
                  _SettingsTile(
                    leading: _IconBox(Icons.person_outline),
                    title: 'Nom complet',
                    trailing: Text(name,
                        style: AppTextStyles.bodyMedium,
                        overflow: TextOverflow.ellipsis),
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  _Divider(),
                  // Email
                  _SettingsTile(
                    leading: _IconBox(Icons.alternate_email_rounded),
                    title: 'Email',
                    trailing: Text(email,
                        style: AppTextStyles.bodyMedium,
                        overflow: TextOverflow.ellipsis),
                    onTap: () {},
                  ),
                  _Divider(),
                  // Téléphone
                  _SettingsTile(
                    leading: _IconBox(Icons.phone_android_outlined),
                    title: 'Téléphone',
                    trailing: Text(phone,
                        style: AppTextStyles.bodyMedium,
                        overflow: TextOverflow.ellipsis),
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── PRÉFÉRENCES section ─────────────────────────────────────
              _SectionHeader(label: 'PRÉFÉRENCES'),
              _SettingsCard(
                children: [
                  // Langue
                  _SettingsTile(
                    leading: _IconBox(Icons.language_rounded),
                    title: 'Langue',
                    trailing: GestureDetector(
                      onTap: langVM.cycle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          langVM.flagLabel,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    onTap: langVM.cycle,
                  ),
                  _Divider(),
                  // Notifications
                  _SettingsTile(
                    leading: _IconBox(Icons.notifications_outlined),
                    title: 'Notifications',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) =>
                          setState(() => _notificationsEnabled = val),
                    ),
                    onTap: () =>
                        setState(() => _notificationsEnabled = !_notificationsEnabled),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── SÉCURITÉ section ────────────────────────────────────────
              _SectionHeader(label: 'SÉCURITÉ'),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    leading: _IconBox(Icons.lock_outline_rounded),
                    title: 'Changer le mot de passe',
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textHint),
                    onTap: () {
                      // Navigate to change password screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bientôt disponible'),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── DANGER ZONE section ─────────────────────────────────────
              _SectionHeader(label: 'DANGER ZONE', isRed: true),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(Icons.delete_forever_rounded,
                          color: AppColors.error, size: 20),
                    ),
                    title: 'Supprimer mon compte',
                    titleStyle: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.error),
                    trailing: null,
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

// ─── Section Header ───────────────────────────────────────────────────────────

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
          fontWeight: FontWeight.w600,
          color: isRed ? AppColors.error : AppColors.textHint,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Settings Card ────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────────────────────

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

// ─── Icon Box ─────────────────────────────────────────────────────────────────

class _IconBox extends StatelessWidget {
  final IconData icon;

  const _IconBox(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

// ─── Divider ─────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.divider,
      indent: 56,
    );
  }
}
