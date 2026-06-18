// ═══ FILE: lib/views/client/historique_screen.dart ═══
// CDC §6.1.5 + §11.1 — Historique des demandes client
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/config/category_config.dart';
import 'package:hirfahome/models/demande.dart';
import 'package:hirfahome/repositories/demande_repository.dart';
import 'package:hirfahome/services/rating_service.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/widgets/skeleton_loader.dart';

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RatingService _ratingService = RatingService();

  /// Tracks demande IDs that have an existing review (from Firestore or just submitted).
  final Set<String> _ratedDemandeIds = {};

  /// Cache for review-existence checks to avoid repeated queries.
  final Map<String, Future<bool>> _reviewCheckCache = {};

  // ── Couleur du badge statut ──
  static Color _statutColor(String s) {
    switch (s) {
      case 'envoye':
        return AppColors.textHint;
      case 'accepte':
        return const Color(0xFF1565C0);
      case 'en_cours':
        return AppColors.primary;
      case 'termine':
        return AppColors.success;
      case 'refuse':
        return AppColors.error;
      case 'annule':
        return AppColors.textHint;
      default:
        return AppColors.textHint;
    }
  }

  static String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  // ── Check if a review already exists for this demande ──
  Future<bool> _hasExistingReview(Demande demande) {
    final key = demande.id!;
    return _reviewCheckCache.putIfAbsent(key, () async {
      final snap = await _firestore
          .collection('reviews')
          .where('artisanId', isEqualTo: demande.artisanId)
          .where('clientId', isEqualTo: demande.clientId)
          .where('requestId', isEqualTo: demande.id)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    });
  }

  // ── Show rating bottom sheet ──
  void _showRatingSheet(Demande demande) {
    int selectedRating = 0;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xxl)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Handle bar ──
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Title ──
                  Text(
                    'Noter cette intervention',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    demande.titre,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Star rating row ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedRating = starIndex),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            starIndex <= selectedRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Comment field ──
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Commentaire (optionnel)',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Submit button ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonRadius,
                        ),
                        disabledBackgroundColor: AppColors.divider,
                      ),
                      onPressed: selectedRating == 0 || isSubmitting
                          ? null
                          : () async {
                              setSheetState(() => isSubmitting = true);

                              final nav = Navigator.of(ctx);
                              final commentText =
                                  commentController.text.trim();

                              // Save to 'reviews' collection
                              await _firestore.collection('reviews').add({
                                'artisanId': demande.artisanId,
                                'clientId': demande.clientId,
                                'requestId': demande.id,
                                'rating': selectedRating,
                                'comment': commentText,
                                'timestamp': FieldValue.serverTimestamp(),
                              });

                              // Also call RatingService for denormalized updates
                              await _ratingService.submitRating(
                                demandeId: demande.id!,
                                clientId: demande.clientId,
                                artisanId: demande.artisanId,
                                rating: selectedRating.toDouble(),
                                raterRole: 'client',
                                comment: commentText,
                              );

                              commentController.dispose();
                              nav.pop();

                              if (mounted) {
                                setState(() {
                                  _ratedDemandeIds.add(demande.id!);
                                  _reviewCheckCache.remove(demande.id!);
                                });
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Envoyer'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final langVM = context.watch<LanguageViewModel>();
    final lang = langVM.lang;
    final isRtl = langVM.isRtl;
    final repo = context.read<DemandeRepository>();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          title: Text(
            AppStrings.t('mes_interventions', lang),
            style: AppTextStyles.titleLarge,
          ),
        ),
        body: StreamBuilder<List<Demande>>(
          stream: repo.getByClientId(uid),
          builder: (context, snapshot) {
            // ── Loading: skeleton ──
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.base, AppSpacing.base, 0),
                children: const [
                  SkeletonListTile(),
                  SkeletonListTile(),
                  SkeletonListTile(),
                  SkeletonListTile(),
                ],
              );
            }

            final demandes = snapshot.data ?? [];

            // ── Empty state ──
            if (demandes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      AppStrings.t('aucune_intervention', lang),
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // ── Liste des demandes ──
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, AppSpacing.base, AppSpacing.base, 32),
              itemCount: demandes.length,
              itemBuilder: (context, index) {
                final demande = demandes[index];
                final cat = CategoryConfig.findByKey(demande.categorie);
                final sColor = _statutColor(demande.statut);
                final sLabel = AppStrings.t(demande.statut, lang);

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.card,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Titre + badge statut ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icône catégorie
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: cat.color.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              child: Icon(cat.icon,
                                  color: cat.color, size: 22),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            // Titre + catégorie
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    demande.titre,
                                    style: AppTextStyles.titleMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppStrings.t(
                                        demande.categorie, lang),
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            // Badge statut (chip)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: sColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                    AppRadius.full),
                              ),
                              child: Text(
                                sLabel,
                                style: GoogleFonts.inter(
                                  color: sColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // ── Date de création ──
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(demande.dateCreation),
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),

                        // ── "Noter" button or "Merci" chip (for terminé demandes) ──
                        if (demande.statut == 'termine' &&
                            demande.id != null)
                          _buildRatingSection(demande),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ── Rating section: shows button, "merci" chip, or nothing ──
  Widget _buildRatingSection(Demande demande) {
    // If just rated this session → show "Merci" chip immediately
    if (_ratedDemandeIds.contains(demande.id)) {
      return _buildMerciChip();
    }

    // Otherwise check Firestore
    return FutureBuilder<bool>(
      future: _hasExistingReview(demande),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final alreadyRated = snapshot.data ?? false;

        if (alreadyRated) {
          return _buildMerciChip();
        }

        // No review yet → show small outlined "Noter" button
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.star_outline_rounded, size: 16),
            label: const Text('Noter',
                style: TextStyle(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base, vertical: AppSpacing.sm),
            ),
            onPressed: () => _showRatingSheet(demande),
          ),
        );
      },
    );
  }

  Widget _buildMerciChip() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Chip(
        avatar: const Icon(Icons.check_circle,
            color: AppColors.success, size: 18),
        label: const Text(
          'Merci pour votre avis !',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.successLight,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full)),
      ),
    );
  }
}
