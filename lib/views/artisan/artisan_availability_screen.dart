// ═══ FILE: lib/views/artisan/artisan_availability_screen.dart ═══
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/widgets/skeleton_loader.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disponibilités sauvegardées !'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde : $e'),
            backgroundColor: AppColors.error,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          'Mes disponibilités',
          style: AppTextStyles.titleLarge,
        ),
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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
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
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: _availability.keys.mapIndexed((index, dayKey) {
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
                                title: Text(
                                  _daysLabels[dayKey] ?? dayKey,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isWeekend
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  isAvailable ? 'Disponible' : 'Indisponible',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isAvailable
                                        ? AppColors.success
                                        : AppColors.textHint,
                                  ),
                                ),
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
                              const Divider(
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
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined),
                    label: const Text('Enregistrer le planning'),
                  ),

                  const SizedBox(height: AppSpacing.base),
                ],
              ),
            ),
    );
  }
}

extension<T> on Iterable<T> {
  Iterable<E> mapIndexed<E>(E Function(int index, T item) f) sync* {
    var i = 0;
    for (final item in this) {
      yield f(i++, item);
    }
  }
}