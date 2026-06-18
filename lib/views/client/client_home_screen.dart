
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/config/category_config.dart';
import 'package:hirfahome/models/demande.dart';
import 'package:hirfahome/repositories/demande_repository.dart';
import 'package:hirfahome/services/rating_service.dart';
import 'package:hirfahome/services/category_service.dart';
import 'package:hirfahome/services/notification_service.dart';
import 'package:hirfahome/utils/validators.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/views/profile/profile_screen.dart';
import 'package:hirfahome/views/client/artisan_search_screen.dart';
import 'package:hirfahome/widgets/skeleton_loader.dart';

// ─── Status helpers ────────────────────────────────────────────────────────────

Color _statutColor(String s) {
  switch (s) {
    case 'envoye':
      return AppColors.warning;
    case 'accepte':
      return const Color(0xFF1565C0);
    case 'en_cours':
      return const Color(0xFF6A1B9A);
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

IconData _statutIcon(String s) {
  switch (s) {
    case 'envoye':
      return Icons.schedule_rounded;
    case 'accepte':
      return Icons.handshake_outlined;
    case 'en_cours':
      return Icons.directions_run_rounded;
    case 'termine':
      return Icons.check_circle_outline_rounded;
    case 'refuse':
      return Icons.cancel_outlined;
    default:
      return Icons.help_outline_rounded;
  }
}

// ─── Root Shell — BottomNavigationBar ─────────────────────────────────────────

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _navIndex = 0;

  late final DemandeRepository _service;
  final _ratingService = RatingService();

  // Cache for demandes stream, shared across tabs
  List<Demande> _cached = [];

  @override
  void initState() {
    super.initState();
    _service = context.read<DemandeRepository>();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      NotificationService.initialize(user.uid);
    }
  }

  void _annuler(String id, String statut, String lang) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t('confirmer_annulation', lang),
            style: AppTextStyles.titleLarge),
        content: Text(AppStrings.t('confirmer_annulation_msg', lang),
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.t('non', lang)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
            ),
            child: Text(AppStrings.t('oui_annuler', lang)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    final msg = await _service.delete(id, statut);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(_snack(
      msg,
      msg.contains('Erreur') ? AppColors.error : AppColors.success,
      msg.contains('Erreur') ? Icons.error_outline : Icons.check_circle_outline,
    ));
  }

  SnackBar _snack(String msg, Color color, IconData icon, {int duration = 2}) =>
      SnackBar(
        content: Row(children: [
          Icon(icon, color: AppColors.surface, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        margin: const EdgeInsets.all(AppSpacing.base),
        duration: Duration(seconds: duration),
      );

  Future<void> _showRatingDialog(Demande demande, String lang) async {
    double selectedRating = 5;
    final commentCtrl = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(AppStrings.t('noter_artisan', lang),
              style: AppTextStyles.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppStrings.t('noter_msg', lang),
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.base),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      icon: Icon(
                        i < selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 40,
                      ),
                      onPressed: () => setState(() => selectedRating = i + 1.0),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                TextField(
                  controller: commentCtrl,
                  decoration: InputDecoration(
                    labelText: AppStrings.t('votre_avis_commentaire', lang),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.t('plus_tard', lang)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, {
                'rating': selectedRating,
                'comment': commentCtrl.text.trim(),
              }),
              child: Text(AppStrings.t('envoyer_note', lang)),
            ),
          ],
        ),
      ),
    );

    if (result != null && demande.id != null && mounted) {
      final success = await _ratingService.submitRating(
        demandeId: demande.id!,
        clientId: demande.clientId,
        artisanId: demande.artisanId,
        rating: (result['rating'] as double),
        comment: result['comment'] as String? ?? '',
        raterRole: 'client',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? AppStrings.t('note_envoye', lang)
              : AppStrings.t('erreur_envoi_note', lang)),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openForm(String lang, bool isRtl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: _FormSheet(
          service: _service,
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          lang: lang,
          onSuccess: () => setState(() => _navIndex = 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langVM = context.watch<LanguageViewModel>();
    final lang = langVM.lang;
    final isRtl = langVM.isRtl;
    final user = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: StreamBuilder<List<Demande>>(
        stream: _service.getByClientId(user?.uid ?? ''),
        builder: (ctx, snap) {
          if (snap.hasData) _cached = snap.data!;
          final all = _cached;
          final isLoading =
              snap.connectionState == ConnectionState.waiting && _cached.isEmpty;

          final List<Widget> tabs = [
            _HomeTab(
              lang: lang,
              langVM: langVM,
              demandes: all,
              isLoading: isLoading,
              onNewRequest: () => _openForm(lang, isRtl),
            ),
            const ArtisanSearchScreen(),
            _DemandesTab(
              lang: lang,
              demandes: all,
              isLoading: isLoading,
              onAnnuler: (id, statut, l) async => _annuler(id, statut, l),
              onRate: _showRatingDialog,
              onNewRequest: () => _openForm(lang, isRtl),
            ),
            _ProfileTab(lang: lang, langVM: langVM),
          ];

          return Scaffold(
            backgroundColor: AppColors.background,
            body: IndexedStack(index: _navIndex, children: tabs),
            bottomNavigationBar: _AppBottomNav(
              currentIndex: _navIndex,
              lang: lang,
              onTap: (i) => setState(() => _navIndex = i),
            ),
          );
        },
      ),
    );
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────

class _AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final String lang;
  final ValueChanged<int> onTap;

  const _AppBottomNav({
    required this.currentIndex,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: lang == 'ar' ? 'الرئيسية' : 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search_outlined),
              activeIcon: const Icon(Icons.search_rounded),
              label: lang == 'ar' ? 'بحث' : 'Rechercher',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.assignment_outlined),
              activeIcon: const Icon(Icons.assignment_rounded),
              label: lang == 'ar' ? 'طلباتي' : 'Demandes',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              activeIcon: const Icon(Icons.person_rounded),
              label: lang == 'ar' ? 'الملف' : 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── TAB 0 — Home ─────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final String lang;
  final LanguageViewModel langVM;
  final List<Demande> demandes;
  final bool isLoading;
  final VoidCallback onNewRequest;

  const _HomeTab({
    required this.lang,
    required this.langVM,
    required this.demandes,
    required this.isLoading,
    required this.onNewRequest,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Gradient Hero Header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroHeader(
              user: user,
              lang: lang,
              langVM: langVM,
            ),
          ),

          // ── Stats Row ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _StatsRow(demandes: demandes, lang: lang),
          ),

          // ── Category Section ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: lang == 'ar' ? 'الفئات' : 'Catégories',
            ),
          ),
          SliverToBoxAdapter(
            child: _CategoryScroll(lang: lang),
          ),

          // ── Nearby Artisans Section ───────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: lang == 'ar' ? 'حرفيون قريبون' : 'Artisans à proximité',
              actionLabel: lang == 'ar' ? 'عرض الكل' : 'Voir tout',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArtisanSearchScreen()),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: isLoading
                ? _ArtisanCardRowSkeleton()
                : _ArtisanCardRow(lang: lang),
          ),

          // ── Quick Action CTA ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, AppSpacing.base, AppSpacing.base, AppSpacing.xl),
              child: ElevatedButton.icon(
                onPressed: onNewRequest,
                icon: const Icon(Icons.add_rounded),
                label: Text(lang == 'ar' ? 'طلب جديد' : 'Nouvelle demande'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.buttonRadius),
                  textStyle: AppTextStyles.buttonText,
                  elevation: 0,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.base)),
        ],
      ),
    );
  }
}

// ─── Hero Header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final User? user;
  final String lang;
  final LanguageViewModel langVM;

  const _HeroHeader({required this.user, required this.lang, required this.langVM});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: user != null
          ? FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .snapshots()
          : const Stream.empty(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final userName = data?['nom'] as String? ??
            user?.displayName ??
            (lang == 'ar' ? 'مستخدم' : 'vous');

        return Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A1A), AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30, right: -30,
                child: _DecorCircle(size: 160, opacity: 0.06),
              ),
              Positioned(
                bottom: 40, left: -20,
                child: _DecorCircle(size: 100, opacity: 0.05),
              ),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.base, AppSpacing.base, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: greeting + language pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppStrings.t('bonjour', lang)}, $userName',
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang == 'ar'
                                    ? 'ما الخدمة التي تبحث عنها؟'
                                    : 'Quel service cherchez-vous ?',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.70),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: langVM.cycle,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                langVM.flagLabel,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // White search bar — tappable, pushes to search screen
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ArtisanSearchScreen()),
                        ),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.inputRadius,
                            boxShadow: AppShadows.card,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.base),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded,
                                  color: AppColors.textHint, size: 20),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                lang == 'ar'
                                    ? 'سباك، كهربائي...'
                                    : 'Plombier, électricien...',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<Demande> demandes;
  final String lang;
  const _StatsRow({required this.demandes, required this.lang});

  @override
  Widget build(BuildContext context) {
    final active = demandes
        .where((d) => ['envoye', 'accepte', 'en_cours'].contains(d.statut))
        .length;
    final done =
        demandes.where((d) => d.statut == 'termine').length;
    final total = demandes.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.base, AppSpacing.base, 0),
      child: Row(
        children: [
          _StatCard(
            count: active,
            label: lang == 'ar' ? 'نشطة' : 'Actives',
            color: AppColors.warning,
            icon: Icons.radio_button_checked_rounded,
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatCard(
            count: done,
            label: lang == 'ar' ? 'منتهية' : 'Terminées',
            color: AppColors.success,
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatCard(
            count: total,
            label: lang == 'ar' ? 'المجموع' : 'Total',
            color: AppColors.primary,
            icon: Icons.list_alt_rounded,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;
  const _StatCard(
      {required this.count,
      required this.label,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: AppDecorations.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$count',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader(
      {required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.xl, AppSpacing.base, AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.titleLarge),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppColors.primary,
              ),
              child: Text(actionLabel!, style: AppTextStyles.labelLarge),
            ),
        ],
      ),
    );
  }
}

// ─── Category Scroll ──────────────────────────────────────────────────────────

class _CategoryScroll extends StatelessWidget {
  final String lang;
  const _CategoryScroll({required this.lang});

  @override
  Widget build(BuildContext context) {
    final cats = CategoryConfig.categories.take(8).toList();
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        itemCount: cats.length,
        itemBuilder: (context, i) {
          final cat = cats[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ArtisanSearchScreen(targetCategory: cat.key),
              ),
            ),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              decoration: AppDecorations.card,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 22),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppStrings.t(cat.key, lang),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Artisan Mini-Card Row ────────────────────────────────────────────────────

class _ArtisanCardRow extends StatelessWidget {
  final String lang;
  const _ArtisanCardRow({required this.lang});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'artisan')
          .where('verifie', isEqualTo: true)
          .limit(10)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _ArtisanCardRowSkeleton();
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base, vertical: AppSpacing.md),
            child: Text(
              lang == 'ar' ? 'لا يوجد حرفيون' : 'Aucun artisan disponible',
              style: AppTextStyles.bodyMedium,
            ),
          );
        }
        return SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return _ArtisanMiniCard(data: data, lang: lang);
            },
          ),
        );
      },
    );
  }
}

class _ArtisanMiniCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String lang;
  const _ArtisanMiniCard({required this.data, required this.lang});

  @override
  Widget build(BuildContext context) {
    final name = data['nom'] as String? ?? '—';
    final metier = data['metier'] as String? ?? data['categorie'] as String? ?? '';
    final photoUrl = data['photoUrl'] as String?;
    final rating =
        (data['noteMoyenne'] as num?)?.toDouble() ?? 0.0;
    final distance = data['distance'] as String?;
    final verifie = data['verifie'] as bool? ?? false;

    return GestureDetector(
      onTap: () {
        // Navigate to detail if desired
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo top half
            Container(
              height: 110,
              width: double.infinity,
              color: AppColors.surfaceVariant,
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? Image.network(photoUrl, fit: BoxFit.cover,
                   errorBuilder: (e, o, s) => _AvatarPlaceholder(name))
                  : _AvatarPlaceholder(name),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + verified badge row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (verifie)
                        const Icon(Icons.verified_rounded,
                            color: Color(0xFF1565C0), size: 14),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metier,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Rating + distance
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 13),
                      const SizedBox(width: 2),
                      Text(
                        rating > 0 ? rating.toStringAsFixed(1) : '—',
                        style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      if (distance != null) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            distance,
                            style: AppTextStyles.labelSmall
                                .copyWith(fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  final String name;
  const _AvatarPlaceholder(this.name);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySurface,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _ArtisanCardRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        itemCount: 4,
        itemBuilder: (ctx, i) => Padding(
          padding:
              const EdgeInsets.only(right: AppSpacing.md),
          child: SkeletonBox(
              width: 160,
              height: 220,
              borderRadius: AppRadius.lg),
        ),
      ),
    );
  }
}

// ─── TAB 2 — Demandes ─────────────────────────────────────────────────────────

class _DemandesTab extends StatefulWidget {
  final String lang;
  final List<Demande> demandes;
  final bool isLoading;
  final Future<void> Function(String, String, String) onAnnuler;
  final Future<void> Function(Demande, String) onRate;
  final VoidCallback onNewRequest;

  const _DemandesTab({
    required this.lang,
    required this.demandes,
    required this.isLoading,
    required this.onAnnuler,
    required this.onRate,
    required this.onNewRequest,
  });

  @override
  State<_DemandesTab> createState() => _DemandesTabState();
}

class _DemandesTabState extends State<_DemandesTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<Demande> _filter(List<Demande> all, int tab) {
    switch (tab) {
      case 1:
        return all
            .where((d) =>
                ['envoye', 'accepte', 'en_cours'].contains(d.statut))
            .toList();
      case 2:
        return all
            .where((d) =>
                ['termine', 'refuse', 'annule'].contains(d.statut))
            .toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          lang == 'ar' ? 'طلباتي' : 'Mes Demandes',
          style: AppTextStyles.titleLarge,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabs,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w400, fontSize: 13),
            tabs: [
              Tab(text: AppStrings.t('toutes', lang)),
              Tab(text: AppStrings.t('en_cours', lang)),
              Tab(text: AppStrings.t('terminees', lang)),
            ],
          ),
        ),
      ),
      body: widget.isLoading
          ? const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Column(
                children: [
                  SizedBox(height: AppSpacing.base),
                  SkeletonArtisanCard(),
                  SizedBox(height: AppSpacing.md),
                  SkeletonArtisanCard(),
                ],
              ),
            )
          : TabBarView(
              controller: _tabs,
              children: List.generate(3, (tab) {
                final items = _filter(widget.demandes, tab);
                if (items.isEmpty) {
                  return _EmptyState(lang: lang, tab: tab);
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      0,
                      AppSpacing.base,
                      AppSpacing.xl),
                  itemCount: items.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                        child: ElevatedButton.icon(
                          onPressed: widget.onNewRequest,
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Nouvelle demande'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      );
                    }
                    final idx = i - 1;
                    return _DemandeCard(
                      key: ValueKey(items[idx].id),
                      demande: items[idx],
                      lang: lang,
                      onAnnuler:
                          (items[idx].statut == 'en_attente')
                              ? () => widget.onAnnuler(
                                  items[idx].id!,
                                  items[idx].statut,
                                  lang)
                              : null,
                      onRate: (items[idx].statut == 'termine' &&
                              items[idx].artisanId.isNotEmpty)
                          ? () => widget.onRate(items[idx], lang)
                          : null,
                    );
                  },
                );
              }),
            ),
    );
  }
}

// ─── TAB 3 — Profile ──────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final String lang;
  final LanguageViewModel langVM;
  const _ProfileTab({required this.lang, required this.langVM});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(lang == 'ar' ? 'الملف الشخصي' : 'Mon Profil',
            style: AppTextStyles.titleLarge),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: user != null
            ? FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots()
            : const Stream.empty(),
        builder: (context, snapshot) {
          final data =
              snapshot.data?.data() as Map<String, dynamic>?;
          final name =
              data?['nom'] as String? ?? user?.displayName ?? '—';
          final email = user?.email ?? '';
          final photoUrl = data?['photoUrl'] as String?;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── Uber-style gradient header card ────────────────────────
              Container(
                margin: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: AppShadows.card,
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xl, horizontal: AppSpacing.base),
                child: Column(
                  children: [
                    // Avatar with white border
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primarySurface,
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl == null
                            ? Text(
                                name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        lang == 'ar' ? 'عميل' : 'Client',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      email,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),

              // ── White card with list tiles ──────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.cardRadius,
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    _ModernProfileTile(
                      icon: Icons.person_outline,
                      label: lang == 'ar' ? 'ملفي الشخصي' : 'Mon profil',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()),
                      ),
                    ),
                    const Divider(height: 1, indent: 72),
                    _ModernProfileTile(
                      icon: Icons.history_rounded,
                      label: AppStrings.t('mes_interventions', lang),
                      onTap: () =>
                          Navigator.pushNamed(context, '/historique'),
                    ),
                    const Divider(height: 1, indent: 72),
                    _ModernProfileTile(
                      icon: Icons.notifications_outlined,
                      label: lang == 'ar' ? 'الإشعارات' : 'Notifications',
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 72),
                    _ModernProfileTile(
                      icon: Icons.settings_outlined,
                      label: lang == 'ar' ? 'الإعدادات' : 'Paramètres',
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                    const Divider(height: 1, indent: 72),
                    _ModernProfileTileWithTrailing(
                      icon: Icons.language_outlined,
                      label: AppStrings.t('langue', lang),
                      trailing: GestureDetector(
                        onTap: langVM.cycle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs),
                          decoration: AppDecorations.chip(),
                          child: Text(
                            langVM.flagLabel,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                        ),
                      ),
                      onTap: langVM.cycle,
                    ),
                    const Divider(height: 1, indent: 72),
                    _ModernProfileTile(
                      icon: Icons.help_outline_rounded,
                      label: lang == 'ar' ? 'المساعدة' : 'Aide',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _ModernProfileTile(
                      icon: Icons.logout_rounded,
                      label: AppStrings.t('deconnexion', lang),
                      isDestructive: true,
                      onTap: () => FirebaseAuth.instance.signOut(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }
}

// ── Modern profile tile with icon square ─────────────────────────────────────

class _ModernProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ModernProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconBg = isDestructive
        ? Colors.red.shade50
        : AppColors.primary.withValues(alpha: 0.10);
    final iconColor =
        isDestructive ? Colors.red : AppColors.primary;
    final labelStyle = isDestructive
        ? AppTextStyles.bodyLarge.copyWith(color: Colors.red)
        : AppTextStyles.bodyLarge;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(label, style: labelStyle),
      trailing: isDestructive
          ? null
          : const Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint),
      onTap: onTap,
    );
  }
}

class _ModernProfileTileWithTrailing extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  const _ModernProfileTileWithTrailing({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(Icons.language_outlined,
            color: AppColors.primary, size: 20),
      ),
      title: Text(label, style: AppTextStyles.bodyLarge),
      trailing: trailing,
      onTap: onTap,
    );
  }
}


// ─── _FormSheet ────────────────────────────────────────────────────────────────

class _FormSheet extends StatefulWidget {
  final DemandeRepository service;
  final String userId;
  final String lang;
  final VoidCallback onSuccess;
  const _FormSheet({
    required this.service,
    required this.userId,
    required this.lang,
    required this.onSuccess,
  });

  @override
  State<_FormSheet> createState() => _FormSheetState();
}

class _FormSheetState extends State<_FormSheet> {
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _picker = ImagePicker();

  String _selectedCat = 'plomberie';
  bool _submitting = false;
  List<File> _problemImages = [];
  bool _uploadingImages = false;
  GeoPoint? _locMap;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    _adresseCtrl.dispose();
    _prixCtrl.dispose();
    _telephoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> selected =
        await _picker.pickMultiImage(imageQuality: 70);
    setState(() {
      _problemImages =
          selected.map((xFile) => File(xFile.path)).toList();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Le service de localisation est désactivé.';
      }

      LocationPermission permission =
          await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Permission GPS refusée.';
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _locMap =
            GeoPoint(position.latitude, position.longitude);
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        setState(() {
          _adresseCtrl.text =
              '${pm.street ?? ""}, ${pm.locality ?? ""}, ${pm.country ?? ""}';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Géolocalisation échouée : $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  Future<void> _soumettre(String lang) async {
    final phone = _telephoneCtrl.text.trim();

    if (_titreCtrl.text.trim().isEmpty ||
        _descCtrl.text.trim().isEmpty ||
        _adresseCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.t('erreur_champs', lang)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.cardRadius),
          margin: const EdgeInsets.all(AppSpacing.base),
        ),
      );
      return;
    }

    if (phone.isNotEmpty && !Validators.isValidMoroccanPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Veuillez entrer un numéro de téléphone marocain valide.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.cardRadius),
          margin: const EdgeInsets.all(AppSpacing.base),
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    List<String> uploadedUrls = [];

    if (_problemImages.isNotEmpty) {
      setState(() => _uploadingImages = true);
      try {
        for (int i = 0; i < _problemImages.length; i++) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child(
                  'demandes/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
          await storageRef.putFile(_problemImages[i]);
          final url = await storageRef.getDownloadURL();
          uploadedUrls.add(url);
        }
      } catch (_) {
      } finally {
        setState(() => _uploadingImages = false);
      }
    }

    if (phone.isNotEmpty && widget.userId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'telephone': phone});
    }

    final demande = Demande(
      clientId: widget.userId,
      titre: _titreCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      categorie: _selectedCat,
      adresse: _adresseCtrl.text.trim(),
      prixPropose: double.tryParse(_prixCtrl.text) ?? 0,
      dateCreation: DateTime.now(),
      clientEmail:
          FirebaseAuth.instance.currentUser?.email ?? '',
      clientTelephone: phone,
      images: uploadedUrls,
      localisation: _locMap,
    );

    final ok = await widget.service.create(demande);
    if (!mounted) return;

    setState(() => _submitting = false);

    if (ok) {
      _titreCtrl.clear();
      _descCtrl.clear();
      _adresseCtrl.clear();
      _prixCtrl.clear();
      _telephoneCtrl.clear();
      Navigator.pop(context);
      widget.onSuccess();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.t('succes', lang)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: AppRadius.cardRadius),
            margin: const EdgeInsets.all(AppSpacing.base),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final categoryService = CategoryService();

    return StreamBuilder<Map<String, bool>>(
      stream: categoryService.getEnabledCategories(),
      builder: (context, catSnapshot) {
        final enabledMap = catSnapshot.data ?? {};
        final visibleCategories =
            CategoryConfig.categories.where((cat) {
          return enabledMap[cat.key] ?? true;
        }).toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.93,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Sheet header
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                          Icons.home_repair_service,
                          color: AppColors.primary,
                          size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                              AppStrings.t(
                                  'nouvelle_demande', lang),
                              style: AppTextStyles.titleLarge),
                          Text(AppStrings.t('tagline', lang),
                              style: AppTextStyles.labelSmall),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 4,
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom +
                            20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _FormLabel(
                          AppStrings.t('categorie', lang)),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.82,
                        children:
                            visibleCategories.map((cat) {
                          final sel = _selectedCat == cat.key;
                          return GestureDetector(
                            onTap: () => setState(
                                () => _selectedCat = cat.key),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              decoration: BoxDecoration(
                                color: sel
                                    ? cat.color
                                    : AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(
                                        AppRadius.md),
                                border: Border.all(
                                  color: sel
                                      ? cat.color
                                      : AppColors.divider,
                                  width: sel ? 2 : 1,
                                ),
                                boxShadow: sel
                                    ? [
                                        BoxShadow(
                                          color: cat.color
                                              .withValues(
                                                  alpha: 0.3),
                                          blurRadius: 8,
                                          offset:
                                              const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(cat.icon,
                                      color: sel
                                          ? Colors.white
                                          : cat.color,
                                      size: 26),
                                  const SizedBox(height: 5),
                                  Text(
                                    AppStrings.t(cat.key, lang),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: sel
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontWeight: sel
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      _FormLabel(AppStrings.t('titre', lang)),
                      const SizedBox(height: 8),
                      _FormField(
                          controller: _titreCtrl,
                          hint: AppStrings.t('titre_hint', lang),
                          icon: Icons.title_rounded),
                      const SizedBox(height: 16),
                      _FormLabel(
                          AppStrings.t('description', lang)),
                      const SizedBox(height: 8),
                      _FormField(
                        controller: _descCtrl,
                        hint: AppStrings.t(
                            'description_hint', lang),
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      _FormLabel(
                          'Photos d\'illustration du problème'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.inputRadius,
                            border: Border.all(
                                color: AppColors.divider),
                          ),
                          child: _problemImages.isNotEmpty
                              ? ListView.builder(
                                  scrollDirection:
                                      Axis.horizontal,
                                  itemCount:
                                      _problemImages.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.all(4),
                                      child: ClipRRect(
                                        borderRadius:
                                            AppRadius.inputRadius,
                                        child: Image.file(
                                          _problemImages[index],
                                          width: 130,
                                          height: 130,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        Icons
                                            .add_a_photo_outlined,
                                        size: 36,
                                        color: AppColors.primary),
                                    SizedBox(height: 8),
                                    Text(
                                      'Ajouter des photos (Optionnel)',
                                      style: TextStyle(
                                          color:
                                              AppColors.textHint,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          _FormLabel(
                              AppStrings.t('adresse', lang)),
                          TextButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(
                                Icons.my_location_outlined,
                                color: AppColors.primary,
                                size: 16),
                            label: Text(
                              'Ma position GPS',
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _FormField(
                          controller: _adresseCtrl,
                          hint: AppStrings.t(
                              'adresse_hint', lang),
                          icon: Icons.location_on_outlined),
                      const SizedBox(height: 16),
                      _FormLabel(AppStrings.t('prix', lang)),
                      const SizedBox(height: 8),
                      _FormField(
                        controller: _prixCtrl,
                        hint: AppStrings.t('prix_hint', lang),
                        icon: Icons.payments_outlined,
                        keyboard: TextInputType.number,
                        suffix:
                            AppStrings.t('mad', lang),
                      ),
                      const SizedBox(height: 16),
                      _FormLabel(
                          AppStrings.t('telephone', lang)),
                      const SizedBox(height: 8),
                      _FormField(
                        controller: _telephoneCtrl,
                        hint: '+212 6 12 34 56 78',
                        icon: Icons.phone_android_rounded,
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _submitting ||
                                  _uploadingImages
                              ? null
                              : () => _soumettre(lang),
                          icon: _submitting || _uploadingImages
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                          label: Text(
                            AppStrings.t('envoyer', lang),
                            style: AppTextStyles.buttonText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Form helpers ─────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.titleMedium.copyWith(fontSize: 13));
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboard;
  final String? suffix;

  const _FormField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboard = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.inputRadius,
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyLarge
              .copyWith(color: AppColors.textHint),
          prefixIcon: Icon(icon,
              size: 20, color: AppColors.textHint),
          suffixText: suffix,
          suffixStyle: AppTextStyles.labelLarge,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.md),
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String lang;
  final int tab;
  const _EmptyState({required this.lang, required this.tab});

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.inbox_outlined,
      Icons.hourglass_empty_rounded,
      Icons.task_alt_rounded
    ];
    final keys = [
      'aucune_demande',
      'aucune_en_cours',
      'aucune_terminee'
    ];

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
              child: Icon(icons[tab],
                  size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(AppStrings.t(keys[tab], lang),
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(AppStrings.t('empty_sub', lang),
                style: AppTextStyles.bodyMedium),
          ]),
    );
  }
}

// ─── Demande Card ──────────────────────────────────────────────────────────────

class _DemandeCard extends StatefulWidget {
  final Demande demande;
  final String lang;
  final VoidCallback? onAnnuler;
  final VoidCallback? onRate;

  const _DemandeCard({
    super.key,
    required this.demande,
    required this.lang,
    this.onAnnuler,
    this.onRate,
  });

  @override
  State<_DemandeCard> createState() => _DemandeCardState();
}

class _DemandeCardState extends State<_DemandeCard> {
  Map<String, dynamic>? _artisanData;
  bool _loadingArtisan = false;

  @override
  void initState() {
    super.initState();
    if ((widget.demande.statut == 'accepte' ||
            widget.demande.statut == 'termine' ||
            widget.demande.statut == 'en_cours') &&
        widget.demande.artisanId.isNotEmpty) {
      _loadArtisan();
    }
  }

  Future<void> _loadArtisan() async {
    setState(() => _loadingArtisan = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.demande.artisanId)
          .get();
      if (mounted) {
        setState(() {
          _artisanData = doc.data();
          _loadingArtisan = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingArtisan = false);
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final demande = widget.demande;
    final cat = CategoryConfig.findByKey(demande.categorie);
    final sColor = _statutColor(demande.statut);
    final sIcon = _statutIcon(demande.statut);
    final sLabel =
        AppStrings.t(demande.statut, widget.lang);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Category color stripe
          Container(height: 3, color: cat.color),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cat.color
                            .withValues(alpha: 0.10),
                        borderRadius: AppRadius.inputRadius,
                      ),
                      child: Icon(cat.icon,
                          color: cat.color, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(demande.titre,
                              style: AppTextStyles.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.t(demande.categorie,
                                widget.lang),
                            style: GoogleFonts.inter(
                              color: cat.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color:
                            sColor.withValues(alpha: 0.10),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(sIcon,
                                size: 11, color: sColor),
                            const SizedBox(width: 4),
                            Text(sLabel,
                                style: GoogleFonts.inter(
                                    color: sColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ]),
                    ),
                  ],
                ),

                if (demande.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    demande.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium
                        .copyWith(height: 1.4),
                  ),
                ],

                if (demande.images.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: demande.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: AppRadius.inputRadius,
                            child: Image.network(
                              demande.images[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),

                Row(
                  children: [
                    if (demande.adresse.isNotEmpty) ...[
                      const Icon(Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(demande.adresse,
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontSize: 12)),
                      ),
                    ] else
                      const Spacer(),
                    if (demande.prixPropose > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(
                              AppRadius.full),
                        ),
                        child: Text(
                          '${demande.prixPropose.toStringAsFixed(0)} ${AppStrings.t('mad', widget.lang)}',
                          style: AppTextStyles.labelLarge
                              .copyWith(fontSize: 12),
                        ),
                      ),
                  ],
                ),

                if (_loadingArtisan)
                  const Padding(
                    padding:
                        EdgeInsets.only(top: AppSpacing.sm),
                    child: LinearProgressIndicator(
                        color: AppColors.primary),
                  )
                else if (_artisanData != null) ...[
                  const Divider(
                      height: 20, color: AppColors.divider),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primarySurface,
                        child: Text(
                          ((_artisanData!['nom'] as String?) ??
                                  'A')
                              .isNotEmpty
                              ? (_artisanData!['nom'] as String)
                                  [0]
                                  .toUpperCase()
                              : 'A',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _artisanData!['nom'] ?? 'Artisan',
                              style: AppTextStyles.titleMedium
                                  .copyWith(fontSize: 13),
                            ),
                            if (_artisanData!['noteMoyenne'] !=
                                null)
                              Row(children: [
                                const Icon(Icons.star_rounded,
                                    size: 13,
                                    color: Colors.amber),
                                const SizedBox(width: 3),
                                Text(
                                  (_artisanData!['noteMoyenne']
                                          as num)
                                      .toStringAsFixed(1),
                                  style: AppTextStyles.labelSmall,
                                ),
                              ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                // Action row
                if (widget.onRate != null ||
                    widget.onAnnuler != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.onRate != null)
                        TextButton.icon(
                          onPressed: widget.onRate,
                          icon: const Icon(
                              Icons.star_border_rounded,
                              size: 18),
                          label: Text(AppStrings.t(
                              'noter', widget.lang)),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.amber.shade700,
                          ),
                        ),
                      if (widget.onAnnuler != null)
                        TextButton.icon(
                          onPressed: widget.onAnnuler,
                          icon: const Icon(
                              Icons.cancel_outlined,
                              size: 18),
                          label: Text(AppStrings.t(
                              'annuler_demande', widget.lang)),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                        ),
                    ],
                  ),
                ],

                // Date footer
                Padding(
                  padding:
                      const EdgeInsets.only(top: AppSpacing.xs),
                  child: Row(children: [
                    const Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(demande.dateCreation),
                      style: AppTextStyles.labelSmall,
                    ),
                  ]),
                ),

                if (demande.clientRating != null &&
                    demande.clientRating! > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${demande.clientRating!.toStringAsFixed(0)}/5',
                        style: AppTextStyles.labelSmall
                            .copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                      ),
                    ]),
                  ),

                if (demande.clientComment != null &&
                    !(demande.clientComment!
                        .startsWith('http')))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '"${demande.clientComment}"',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}