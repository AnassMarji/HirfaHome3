// ═══ FILE: lib/views/artisan/artisan_availability_screen.dart ═══
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/widgets/skeleton_loader.dart';
import 'package:hirfahome/widgets/glass_scaffold.dart';
import 'package:hirfahome/widgets/glass_container.dart';

class ArtisanAvailabilityScreen extends StatefulWidget {
  const ArtisanAvailabilityScreen({super.key});

  @override
  State<ArtisanAvailabilityScreen> createState() =>
      _ArtisanAvailabilityScreenState();
}

class _ArtisanAvailabilityScreenState
    extends State<ArtisanAvailabilityScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser;
  bool _loading = true;
  bool _saving = false;
  final Map<String, bool> _availability = {
    'lundi': true,
    'mardi': true,
    'mercredi': true,
    'jeudi': true,
    'vendredi': true,
    'samedi': false,
    'dimanche': false,
  };
  final Map<String, String> _daysLabels = {
    'lundi': 'Lundi',
    'mardi': 'Mardi',
    'mercredi': 'Mercredi',
    'jeudi': 'Jeudi',
    'vendredi': 'Vendredi',
    'samedi': 'Samedi',
    'dimanche': 'Dimanche',
  };
  final Map<String, IconData> _daysIcons = {
    'lundi': Icons.calendar_view_week_outlined,
    'mardi': Icons.calendar_view_week_outlined,
    'mercredi': Icons.calendar_view_week_outlined,
    'jeudi': Icons.calendar_view_week_outlined,
    'vendredi': Icons.calendar_view_week_outlined,
    'samedi': Icons.weekend_outlined,
    'dimanche': Icons.weekend_outlined,
  };

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['availability'] != null) {
          final loadedMap =
              Map<String, bool>.from(data['availability'] as Map);
          setState(() {
            _availability.addAll(loadedMap);
          });
        }
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _saveAvailability() async {
    if (_currentUser == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .update({
        'availability': _availability,
      });
      if (mounted) {
        final lang = context.read<LanguageViewModel>().lang;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.t('artisan_availability_saved', lang)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final lang = context.read<LanguageViewModel>().lang;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.t('artisan_availability_save_error', lang)
                .replaceAll('{error}', e.toString())),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'Mes disponibilités',
      ),
      body: _loading
          ? ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) => const SkeletonListTile())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Info card ────────────────────────────────────────
                  GlassContainer(
                    borderRadius: AppRadius.md,
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Sélectionnez les jours où vous êtes disponible pour intervenir.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  // ── Planification title ───────────────────────────────
                  Text(
                    'Planification hebdomadaire',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // ── Day tiles ─────────────────────────────────────────
                  GlassContainer(
                    borderRadius: AppRadius.lg,
                    child: Column(
                      children: _availability.keys.toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final dayKey = entry.value;
                        final isAvailable = _availability[dayKey] ?? false;
                        final isWeekend =
                            dayKey == 'samedi' || dayKey == 'dimanche';
                        final isLast = index == _availability.keys.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.base, vertical: 2),
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                secondary: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isWeekend
                                        ? AppColors.surfaceVariant
                                        : AppColors.primarySurface,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Icon(
                                    _daysIcons[dayKey] ??
                                        Icons.calendar_today_outlined,
                                    size: 18,
                                    color: isWeekend
                                        ? AppColors.textSecondary
                                        : AppColors.primary,
                                  ),
                                ),
                                title: Text(_daysLabels[dayKey] ?? dayKey),
                                subtitle: Text(isAvailable ? 'Disponible' : 'Indisponible'),
                                value: isAvailable,
                                activeThumbColor: AppColors.primary,
                                onChanged: (val) {
                                  setState(() {
                                    _availability[dayKey] = val;
                                  });
                                },
                              ),
                            ),
                            if (!isLast)
                              Divider(
                                  height: 1,
                                  indent: AppSpacing.xl * 3,
                                  color: AppColors.divider),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // ── Save button ───────────────────────────────────────
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _saveAvailability,
                    icon: _saving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.onPrimary))
                        : const Icon(Icons.save_outlined),
                    label: Text(AppStrings.t('artisan_availability_save',
                        context.watch<LanguageViewModel>().lang)),
                  ),
                  const SizedBox(height: AppSpacing.base),
                ],
              ),
            ),
    );
  }
}
