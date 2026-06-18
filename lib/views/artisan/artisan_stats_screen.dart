// lib/views/artisan/artisan_stats_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// HirfaHome — Artisan Stats Screen (DoorDash / Uber redesign)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/widgets/skeleton_loader.dart';

class ArtisanStatsScreen extends StatelessWidget {
  final String artisanId;

  const ArtisanStatsScreen({super.key, required this.artisanId});

  String _formatRelativeTime(DateTime? date, String lang) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return lang == 'ar' ? 'الآن' : lang == 'en' ? 'Just now' : "À l'instant";
        }
        return lang == 'ar'
            ? 'منذ ${difference.inMinutes} دقيقة'
            : lang == 'en'
                ? '${difference.inMinutes}m ago'
                : "Il y a ${difference.inMinutes} min";
      }
      return lang == 'ar'
          ? 'منذ ${difference.inHours} ساعة'
          : lang == 'en'
              ? '${difference.inHours}h ago'
              : "Il y a ${difference.inHours} h";
    } else if (difference.inDays == 1) {
      return lang == 'ar' ? 'أمس' : lang == 'en' ? 'Yesterday' : "Hier";
    } else {
      return lang == 'ar'
          ? 'منذ ${difference.inDays} أيام'
          : lang == 'en'
              ? '${difference.inDays} days ago'
              : "Il y a ${difference.inDays} jours";
    }
  }

  @override
  Widget build(BuildContext context) {
    final langVM = context.watch<LanguageViewModel>();
    final lang = langVM.lang;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          AppStrings.t('statistiques', lang),
          style: AppTextStyles.titleLarge,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(artisanId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const _StatsLoadingSkeleton();
          }

          final userData =
              userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
          final double rating = (userData['noteMoyenne'] ?? 0.0).toDouble();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('demandes')
                .where('artisanId', isEqualTo: artisanId)
                .snapshots(),
            builder: (context, demandesSnapshot) {
              if (demandesSnapshot.connectionState == ConnectionState.waiting) {
                return const _StatsLoadingSkeleton();
              }

              final demandes = demandesSnapshot.data?.docs ?? [];

              final totalAccepted = demandes.where((doc) {
                final status = doc['statut'] as String;
                return ['accepte', 'en_cours', 'termine'].contains(status);
              }).length;

              final totalCompleted = demandes.where((doc) {
                return doc['statut'] == 'termine';
              }).length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 3 Stat Cards Row ────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: AppColors.primary,
                            value: '$totalAccepted',
                            label: lang == 'ar'
                                ? 'طلبات مقبولة'
                                : lang == 'en'
                                    ? 'Accepted'
                                    : 'Demandes\nacceptées',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.done_all_rounded,
                            iconColor: AppColors.success,
                            value: '$totalCompleted',
                            label: lang == 'ar'
                                ? 'مهام منجزة'
                                : lang == 'en'
                                    ? 'Completed'
                                    : 'Missions\nterminées',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.star_rounded,
                            iconColor: AppColors.warning,
                            value: rating > 0
                                ? rating.toStringAsFixed(1)
                                : '—',
                            label: lang == 'ar'
                                ? 'التقييم'
                                : lang == 'en'
                                    ? 'Avg Rating'
                                    : 'Note\nmoyenne',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Conversion rate card ─────────────────────────────────
                    _ConversionCard(
                      demandes: demandes,
                      lang: lang,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Reviews section ──────────────────────────────────────
                    Text(
                      lang == 'ar'
                          ? 'آخر الآراء المستلمة'
                          : lang == 'en'
                              ? 'Latest Reviews'
                              : 'Avis reçus',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _ReviewsList(
                      artisanId: artisanId,
                      lang: lang,
                      formatTime: _formatRelativeTime,
                    ),

                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.base, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ─── Conversion Rate Card ─────────────────────────────────────────────────────

class _ConversionCard extends StatelessWidget {
  final List<QueryDocumentSnapshot<Object?>> demandes;
  final String lang;

  const _ConversionCard({required this.demandes, required this.lang});

  @override
  Widget build(BuildContext context) {
    final totalAccepted = demandes.where((doc) {
      final status = doc['statut'] as String;
      return ['accepte', 'en_cours', 'termine'].contains(status);
    }).length;

    final totalRefused = demandes.where((doc) {
      return doc['statut'] == 'refuse';
    }).length;

    final totalProcessed = totalAccepted + totalRefused;
    final double rate =
        totalProcessed == 0 ? 0.0 : totalAccepted / totalProcessed;
    final percentage = (rate * 100).toStringAsFixed(0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'ar'
                      ? 'معدل قبول الطلبات'
                      : lang == 'en'
                          ? 'Acceptance rate'
                          : "Taux d'acceptation",
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  lang == 'ar'
                      ? 'نسبة الطلبات المقبولة من إجمالي الطلبات.'
                      : lang == 'en'
                          ? 'Percentage of accepted requests.'
                          : 'Pourcentage des demandes acceptées.',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: CircularProgressIndicator(
                  value: rate,
                  strokeWidth: 7,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              Text(
                '$percentage%',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Reviews List ─────────────────────────────────────────────────────────────

class _ReviewsList extends StatelessWidget {
  final String artisanId;
  final String lang;
  final String Function(DateTime?, String) formatTime;

  const _ReviewsList({
    required this.artisanId,
    required this.lang,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ratings')
          .where('artisanId', isEqualTo: artisanId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: SkeletonListTile(),
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final clientReviews = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['raterRole'] == 'client';
        }).toList();

        clientReviews.sort((a, b) {
          final aTime =
              (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          final bTime =
              (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        final lastReviews = clientReviews.take(5).toList();

        if (lastReviews.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Center(
              child: Text(
                lang == 'ar'
                    ? 'لا توجد آراء مستلمة بعد.'
                    : lang == 'en'
                        ? 'No reviews received yet.'
                        : 'Aucun avis reçu pour le moment.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lastReviews.length,
          itemBuilder: (context, index) {
            final data = lastReviews[index].data() as Map<String, dynamic>;
            final double ratingVal = (data['rating'] ?? 0.0).toDouble();
            final String comment = data['comment'] as String? ?? '';
            final String clientName =
                data['raterName'] as String? ?? 'Client';
            final Timestamp? ts = data['timestamp'] as Timestamp?;
            final dateStr = formatTime(ts?.toDate(), lang);

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: avatar + name + date
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primarySurface,
                        child: Text(
                          clientName.isNotEmpty
                              ? clientName[0].toUpperCase()
                              : 'C',
                          style: AppTextStyles.labelLarge,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clientName,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (dateStr.isNotEmpty)
                              Text(
                                dateStr,
                                style: AppTextStyles.caption,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Star row
                  Row(
                    children: List.generate(5, (starIdx) {
                      return Icon(
                        starIdx < ratingVal
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: starIdx < ratingVal
                            ? AppColors.warning
                            : AppColors.divider,
                        size: 18,
                      );
                    }),
                  ),

                  if (comment.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      comment,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Loading Skeleton ─────────────────────────────────────────────────────────

class _StatsLoadingSkeleton extends StatelessWidget {
  const _StatsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? AppSpacing.sm : 0),
                  child: const SkeletonBox(
                    width: double.infinity,
                    height: 100,
                    borderRadius: AppRadius.lg,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SkeletonBox(
            width: double.infinity,
            height: 96,
            borderRadius: AppRadius.lg,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SkeletonBox(width: 120, height: 18, borderRadius: AppRadius.xs),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(
            3,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: SkeletonListTile(),
            ),
          ),
        ],
      ),
    );
  }
}