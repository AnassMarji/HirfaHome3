// ─────────────────────────────────────────────────────────────────────────────
// HirfaHome Skeleton Loaders — skeleton_loader.dart
// Uses the shimmer package to provide smooth loading placeholders
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/app_theme.dart';

// ─── BASE SKELETON BOX ────────────────────────────────────────────────────────

/// A single shimmer-animated rectangle. The building block for all skeleton
/// loading widgets. Use [borderRadius] to match the real widget's shape.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppRadius.sm,
  });

  /// Pass [double.infinity] to stretch to parent width.
  final double width;
  final double height;

  /// Corner radius — default matches small-radius cards.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ─── SKELETON CIRCLE ──────────────────────────────────────────────────────────

/// Shimmer-animated circle — typically used for avatars.
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }
}

// ─── SKELETON ARTISAN CARD ────────────────────────────────────────────────────

/// Mimics an artisan card while the real data is loading.
/// Matches the standard artisan card layout:
///   ┌──────────────────────────────────┐
///   │  [avatar]  [name line]           │
///   │            [specialty line]      │
///   │  ─────────────────────────────  │
///   │  [rating]     [price]   [btn]    │
///   └──────────────────────────────────┘
class SkeletonArtisanCard extends StatelessWidget {
  const SkeletonArtisanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar + name / specialty
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SkeletonCircle(size: 52),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(
                      width: double.infinity,
                      height: 14,
                      borderRadius: AppRadius.xs,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SkeletonBox(
                      width: 120,
                      height: 12,
                      borderRadius: AppRadius.xs,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Divider line
          SkeletonBox(
            width: double.infinity,
            height: 1,
            borderRadius: 0,
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Footer: rating + price + CTA chip
          Row(
            children: [
              // Rating stars placeholder
              SkeletonBox(width: 80, height: 14, borderRadius: AppRadius.xs),
              const Spacer(),
              // Price placeholder
              SkeletonBox(width: 60, height: 14, borderRadius: AppRadius.xs),
              const SizedBox(width: AppSpacing.md),
              // Button chip placeholder
              SkeletonBox(
                width: 72,
                height: 32,
                borderRadius: AppRadius.full,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── SKELETON LIST TILE ───────────────────────────────────────────────────────

/// Mimics a standard list item (leading icon + title + subtitle + trailing)
/// while real data loads.
///   ┌──────────────────────────────────────────┐
///   │  [icon]  [title line]            [trail] │
///   │          [subtitle line]                 │
///   └──────────────────────────────────────────┘
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = true,
  });

  final bool hasLeading;
  final bool hasTrailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // ── Leading
          if (hasLeading) ...[
            const SkeletonCircle(size: 44),
            const SizedBox(width: AppSpacing.md),
          ],

          // ── Text lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: double.infinity,
                  height: 14,
                  borderRadius: AppRadius.xs,
                ),
                const SizedBox(height: AppSpacing.sm),
                SkeletonBox(
                  width: 180,
                  height: 12,
                  borderRadius: AppRadius.xs,
                ),
              ],
            ),
          ),

          // ── Trailing
          if (hasTrailing) ...[
            const SizedBox(width: AppSpacing.md),
            SkeletonBox(width: 40, height: 14, borderRadius: AppRadius.xs),
          ],
        ],
      ),
    );
  }
}

// ─── SKELETON CATEGORY CHIP ───────────────────────────────────────────────────

/// Mimics a horizontal scrollable category chip row while loading.
class SkeletonCategoryChip extends StatelessWidget {
  const SkeletonCategoryChip({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: 80,
      height: 36,
      borderRadius: AppRadius.full,
    );
  }
}

// ─── SKELETON BANNER / HERO ───────────────────────────────────────────────────

/// Mimics a full-width hero image or banner card.
class SkeletonBanner extends StatelessWidget {
  const SkeletonBanner({super.key, this.height = 180});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: double.infinity,
      height: height,
      borderRadius: AppRadius.lg,
    );
  }
}

// ─── SKELETON PAGE ────────────────────────────────────────────────────────────

/// Convenience widget that stacks multiple skeleton loaders to fill a screen.
/// Use this as a drop-in replacement while the entire page is loading.
class SkeletonPage extends StatelessWidget {
  const SkeletonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.base),
            // Hero banner
            const SkeletonBanner(height: 160),
            const SizedBox(height: AppSpacing.xl),

            // Section title
            SkeletonBox(width: 140, height: 16, borderRadius: AppRadius.xs),
            const SizedBox(height: AppSpacing.base),

            // Category chips row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: const SkeletonCategoryChip(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Section title 2
            SkeletonBox(width: 160, height: 16, borderRadius: AppRadius.xs),
            const SizedBox(height: AppSpacing.base),

            // Artisan cards
            ...List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: const SkeletonArtisanCard(),
              ),
            ),

            // List tiles
            const Divider(),
            ...List.generate(
              4,
              (i) => const SkeletonListTile(),
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}
