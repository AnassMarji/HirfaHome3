
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/views/auth/auth_wrapper.dart';

class ArtisanOnboardingScreen extends StatefulWidget {
  const ArtisanOnboardingScreen({super.key});

  @override
  State<ArtisanOnboardingScreen> createState() =>
      _ArtisanOnboardingScreenState();
}

class _ArtisanOnboardingScreenState extends State<ArtisanOnboardingScreen> {
  final _descCtrl = TextEditingController();
  final _tarifsCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  String _selectedSpecialite = 'plomberie';
  bool _submitting = false;
  final List<String> _selectedCompetences = [];

  final List<String> _specialites = [
    'plomberie',
    'electricite',
    'peinture',
    'maconnerie',
    'menuiserie',
    'climatisation',
    'nettoyage',
    'autre'
  ];

  final Map<String, IconData> _specialiteIcons = {
    'plomberie': Icons.water_drop_outlined,
    'electricite': Icons.bolt_outlined,
    'peinture': Icons.brush_outlined,
    'maconnerie': Icons.home_work_outlined,
    'menuiserie': Icons.chair_outlined,
    'climatisation': Icons.ac_unit_outlined,
    'nettoyage': Icons.cleaning_services_outlined,
    'autre': Icons.handyman_outlined,
  };

  final Map<String, List<String>> _competencesMap = {
    'plomberie': [
      'Fuite d eau',
      'Chauffe-eau',
      'Robinetterie',
      'Evacuation',
      'Tuyauterie'
    ],
    'electricite': [
      'Tableau électrique',
      'Prises',
      'Éclairage',
      'Climatisation',
      'Domotique'
    ],
    'peinture': [
      'Peinture intérieure',
      'Peinture extérieure',
      'Enduit',
      'Décoration',
      'Ravalement'
    ],
    'maconnerie': [
      'Carrelage',
      'Plâtrerie',
      'Construction',
      'Rénovation',
      'Démolition'
    ],
    'menuiserie': ['Portes', 'Fenêtres', 'Cuisines', 'Placards', 'Parquet'],
    'climatisation': [
      'Installation',
      'Maintenance',
      'Réparation',
      'Nettoyage',
      'Recharge gaz'
    ],
    'nettoyage': [
      'Appartement',
      'Bureau',
      'Après chantier',
      'Vitres',
      'Moquette'
    ],
    'autre': [
      'Jardinage',
      'Déménagement',
      'Assemblage meubles',
      'Serrurerie',
      'Informatique'
    ],
  };

  @override
  void dispose() {
    _descCtrl.dispose();
    _tarifsCtrl.dispose();
    _villeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitOnboarding(String lang) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_descCtrl.text.trim().isEmpty || _villeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.t('information_manquante', lang)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'specialite': _selectedSpecialite,
        'description': _descCtrl.text.trim(),
        'tarifs': double.tryParse(_tarifsCtrl.text.trim()) ?? 0.0,
        'ville': _villeCtrl.text.trim(),
        'competences': _selectedCompetences,
      });
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur: $e'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langVM = Provider.of<LanguageViewModel>(context);
    final lang = langVM.lang;

    // Progress: step 1 of 1 (onboarding)
    const double progress = 0.5;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Linear progress indicator at very top ──────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.primarySurface,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 3,
                ),
                // AppBar-style row
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.sm, AppSpacing.base, 0),
                  child: Row(
                    children: [
                      Text(
                        AppStrings.t('profil', lang),
                        style: AppTextStyles.titleLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable content ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.base),

                  // ── Hero card ─────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: AppShadows.card,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        // Orange icon circle
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.handyman_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          'Votre métier',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Sélectionnez votre spécialité',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Specialty grid ────────────────────────────────────
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.6,
                    children: _specialites.map((spec) {
                      final isSelected = _selectedSpecialite == spec;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedSpecialite = spec;
                          _selectedCompetences.clear();
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primarySurface
                                : AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.divider,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: AppShadows.card,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _specialiteIcons[spec] ??
                                    Icons.handyman_outlined,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 26,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                AppStrings.t(spec, lang),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Competences ───────────────────────────────────────
                  Text(AppStrings.t('choisir_competences', lang),
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children:
                        (_competencesMap[_selectedSpecialite] ?? []).map((skill) {
                      final isSelected = _selectedCompetences.contains(skill);
                      return FilterChip(
                        label: Text(skill,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontSize: 13,
                            )),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceVariant,
                        checkmarkColor: Colors.white,
                        side: BorderSide.none,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedCompetences.add(skill);
                            } else {
                              _selectedCompetences.remove(skill);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Bio ───────────────────────────────────────────────
                  Text(AppStrings.t('bio', lang),
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: AppStrings.t('bio_hint', lang),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.base),

                  // ── Ville ─────────────────────────────────────────────
                  Text(AppStrings.t('votre_ville', lang),
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _villeCtrl,
                    decoration: InputDecoration(
                      hintText: AppStrings.t('ville_hint', lang),
                      prefixIcon: const Icon(Icons.location_city_outlined,
                          color: AppColors.textHint),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.base),

                  // ── Tarif ─────────────────────────────────────────────
                  Text(AppStrings.t('tarif_horaire', lang),
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _tarifsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Ex: 100',
                      prefixIcon: Icon(Icons.payments_outlined,
                          color: AppColors.textHint),
                      suffixText: 'DH/h',
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),

          // ── Sticky bottom "Continuer" button ───────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.md,
              AppSpacing.base,
              AppSpacing.base +
                  MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: AppShadows.appBar,
            ),
            child: ElevatedButton(
              onPressed: _submitting ? null : () => _submitOnboarding(lang),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(AppStrings.t('commencer', lang)),
            ),
          ),
        ],
      ),
    );
  }
}