// lib/views/client/artisan_detail_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// HirfaHome — Artisan Detail Screen (DoorDash / Uber redesign)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/models/app_user.dart';
import 'package:hirfahome/models/demande.dart';
import 'package:hirfahome/repositories/demande_repository.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/views/shared/chat_screen.dart';
import 'package:hirfahome/models/portfolio_item.dart';

class ArtisanDetailScreen extends StatefulWidget {
  final AppUser artisan;

  const ArtisanDetailScreen({super.key, required this.artisan});

  @override
  State<ArtisanDetailScreen> createState() => _ArtisanDetailScreenState();
}

class _ArtisanDetailScreenState extends State<ArtisanDetailScreen>
    with SingleTickerProviderStateMixin {
  AppUser get artisan => widget.artisan;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Open Google Maps ──────────────────────────────────────────────────────
  Future<void> _openItinerary() async {
    if (artisan.ville == null) return;
    final uri = Uri.parse('https://maps.google.com/?q=${artisan.ville}');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── Share artisan profile ─────────────────────────────────────────────────
  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partage bientôt disponible')),
    );
  }

  // ── Send request bottom sheet ─────────────────────────────────────────────
  void _openRequestFormDirect(BuildContext context, String lang) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        List<File> selectedImages = [];
        bool isUploading = false;
        GeoPoint? selectedLocation;
        bool isLocating = false;

        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) => Container(
            height: MediaQuery.of(context).size.height * 0.93,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    '${AppStrings.t('nouvelle_demande', lang)} – ${artisan.nom}',
                    style: AppTextStyles.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Demande d\'intervention directe',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pre-selected specialty chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.category_rounded,
                                    color: AppColors.primary, size: 18),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Spécialité : ${artisan.specialite ?? "Artisan"}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Photo picker
                          Text('Photos du problème (optionnel)',
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton.icon(
                            onPressed: selectedImages.length >= 3
                                ? null
                                : () async {
                                    final picker = ImagePicker();
                                    final picked = await picker.pickMultiImage(imageQuality: 70);
                                    if (picked.isNotEmpty) {
                                      final toAdd = picked
                                          .take(3 - selectedImages.length)
                                          .map((xf) => File(xf.path))
                                          .toList();
                                      setSheetState(() => selectedImages.addAll(toAdd));
                                    }
                                  },
                            icon: const Icon(Icons.add_photo_alternate_rounded,
                                color: AppColors.primary),
                            label: Text(
                              selectedImages.length >= 3
                                  ? 'Maximum atteint (3/3)'
                                  : 'Ajouter photo (${selectedImages.length}/3)',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.base, vertical: AppSpacing.md),
                            ),
                          ),
                          if (selectedImages.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              height: 90,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedImages.length,
                                itemBuilder: (_, i) => Padding(
                                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        child: Image.file(selectedImages[i],
                                            width: 80, height: 80, fit: BoxFit.cover),
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () => setSheetState(
                                              () => selectedImages.removeAt(i)),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(Icons.close,
                                                color: Colors.white, size: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),

                          // Geolocation
                          Text('Ma position (optionnel)',
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Icon(
                                Icons.my_location_rounded,
                                color: selectedLocation != null
                                    ? AppColors.success
                                    : AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  selectedLocation != null
                                      ? 'Position obtenue'
                                      : 'Position non définie',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: selectedLocation != null
                                        ? AppColors.success
                                        : AppColors.textHint,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: isLocating
                                    ? null
                                    : () async {
                                        setSheetState(() => isLocating = true);
                                        try {
                                          bool svc =
                                              await Geolocator.isLocationServiceEnabled();
                                          if (!svc) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content:
                                                        Text('Activez le GPS'),
                                                    backgroundColor: Colors.red),
                                              );
                                            }
                                            setSheetState(() => isLocating = false);
                                            return;
                                          }
                                          LocationPermission perm =
                                              await Geolocator.checkPermission();
                                          if (perm == LocationPermission.denied) {
                                            perm =
                                                await Geolocator.requestPermission();
                                          }
                                          if (perm == LocationPermission.denied ||
                                              perm ==
                                                  LocationPermission.deniedForever) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Autorisez la localisation'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                            setSheetState(() => isLocating = false);
                                            return;
                                          }
                                          final pos =
                                              await Geolocator.getCurrentPosition(
                                            locationSettings:
                                                const LocationSettings(
                                                    accuracy:
                                                        LocationAccuracy.high),
                                          );
                                          setSheetState(() {
                                            selectedLocation = GeoPoint(
                                                pos.latitude, pos.longitude);
                                            isLocating = false;
                                          });
                                        } catch (e) {
                                          setSheetState(() => isLocating = false);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Erreur localisation : $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                icon: isLocating
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Icon(Icons.gps_fixed_rounded,
                                        size: 16),
                                label: Text(
                                    isLocating ? 'Recherche…' : 'Localiser',
                                    style: const TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.sm)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxl),

                          // Confirm button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isUploading
                                  ? null
                                  : () async {
                                      final navigator =
                                          Navigator.of(sheetCtx);
                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      final repository =
                                          context.read<DemandeRepository>();
                                      setSheetState(
                                          () => isUploading = true);

                                      List<String> uploadedUrls = [];
                                      try {
                                        for (int i = 0;
                                            i < selectedImages.length;
                                            i++) {
                                          final ref = FirebaseStorage.instance
                                              .ref()
                                              .child(
                                                  'demandes/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
                                          await ref.putFile(selectedImages[i]);
                                          uploadedUrls.add(
                                              await ref.getDownloadURL());
                                        }
                                      } catch (e) {
                                        debugPrint('Photo upload skipped: $e');
                                        // Firebase Storage unavailable —
                                        // continue and save demande with images: []
                                        uploadedUrls = [];
                                      }

                                      assert(artisan.uid.isNotEmpty,
                                          'artisan uid cannot be empty');

                                      final demande = Demande(
                                        clientId: user.uid,
                                        artisanId: artisan.uid,
                                        titre: 'Intervention planifiée',
                                        description:
                                            'Demande directe auprès de ${artisan.nom}.',
                                        categorie:
                                            artisan.specialite ?? 'autre',
                                        adresse:
                                            artisan.ville ?? 'Maroc',
                                        dateCreation: DateTime.now(),
                                        images: uploadedUrls,
                                        localisation: selectedLocation,
                                      );

                                      try {
                                        final success =
                                            await repository.create(demande);
                                        if (!mounted) return;
                                        setSheetState(
                                            () => isUploading = false);
                                        if (success) {
                                          navigator.pop();
                                          messenger.showSnackBar(const SnackBar(
                                            content: Text(
                                                'Demande envoyée avec succès !'),
                                            backgroundColor: AppColors.success,
                                          ));
                                        } else {
                                          messenger.showSnackBar(const SnackBar(
                                            content: Text(
                                                'Erreur : la demande n\'a pas pu être envoyée. Réessayez.'),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      } catch (e) {
                                        if (!mounted) return;
                                        setSheetState(
                                            () => isUploading = false);
                                        messenger.showSnackBar(SnackBar(
                                          content: Text('Erreur : $e'),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppColors.primary.withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.md)),
                              ),
                              child: isUploading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white),
                                    )
                                  : const Text(
                                      'Confirmer la demande',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
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
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final langVM = context.watch<LanguageViewModel>();
    final lang = langVM.lang;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(artisan.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // While loading, show a slim progress bar under the hero
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          final data =
              snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final cinUrl = data['cinUrl'] as String?;
          final isVerified = cinUrl != null || artisan.verifie;

          final List<dynamic>? rawItems =
              data['portfolioItems'] as List<dynamic>?;
          final List<PortfolioItem> portfolioItems = rawItems != null
              ? rawItems
                  .map((item) => PortfolioItem.fromMap(
                      Map<String, dynamic>.from(item as Map)))
                  .toList()
              : const [];
          final List<String> portfolioUrls =
              List<String>.from(data['portfolioUrls'] ?? []);

          final telephone = data['telephone'] as String? ?? '';
          final double rating =
              (data['noteMoyenne'] ?? artisan.noteMoyenne).toDouble();
          final int reviewsCount =
              (data['nombreAvis'] ?? artisan.nombreAvis) as int;
          final int? yearsExp =
              (data['yearsExperience'] ?? artisan.yearsExperience) as int?;
          final String? photoUrl =
              (data['photoUrl'] ?? artisan.photoUrl) as String?;
          final List<String> competences =
              List<String>.from(data['competences'] ?? []);
          final Map<String, dynamic>? availability =
              data['availability'] as Map<String, dynamic>?;
          final String? description =
              (data['description'] ?? artisan.description) as String?;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // ── Hero Image AppBar ──────────────────────────────────
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                    // Back + Share buttons
                    leading: _circleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    actions: [
                      _circleButton(
                        icon: Icons.share_rounded,
                        onTap: _shareProfile,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Profile photo full-width
                          Hero(
                            tag: 'avatar_${artisan.uid}',
                            child: photoUrl != null
                                ? Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx2, err, st) =>
                                        _heroFallback(),
                                  )
                                : _heroFallback(),
                          ),
                          // Gradient overlay (bottom half)
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.72),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.35, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Name + métier + rating on gradient
                          Positioned(
                            left: AppSpacing.xl,
                            right: AppSpacing.xl,
                            bottom: AppSpacing.xl,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  artisan.nom,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  artisan.specialite ?? 'Artisan',
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.85),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: Color(0xFFFFC107), size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating > 0
                                          ? rating.toStringAsFixed(1)
                                          : 'Nouveau',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (reviewsCount > 0)
                                      Text(
                                        '  ($reviewsCount avis)',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.75),
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── White rounded content card ─────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppRadius.xxl)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.xl),

                          // ── Verified badge ───────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl),
                            child: _buildVerifiedBadge(isVerified),
                          ),
                          const SizedBox(height: AppSpacing.base),

                          // ── Info row: expérience • tarif • note ──────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl),
                            child: _buildInfoRow(
                                rating, reviewsCount, yearsExp, artisan.tarifs),
                          ),
                          const SizedBox(height: AppSpacing.base),

                          // ── Itinerary button ─────────────────────────
                          if (artisan.ville != null &&
                              artisan.ville!.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl),
                              child: OutlinedButton.icon(
                                onPressed: _openItinerary,
                                icon: const Icon(Icons.navigation_outlined,
                                    color: AppColors.primary, size: 18),
                                label: Text(
                                  '${artisan.ville} — Voir l\'itinéraire',
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.md)),
                                  minimumSize:
                                      const Size(double.infinity, 44),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.base),
                          ],

                          // ── Competences chips ────────────────────────
                          if (competences.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl),
                              child: Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: competences
                                    .map(
                                      (c) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
                                            vertical: 6),
                                        decoration: AppDecorations.chip(
                                            color: AppColors.primarySurface),
                                        child: Text(
                                          c,
                                          style:
                                              AppTextStyles.caption.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.base),
                          ],

                          const Divider(
                              color: AppColors.divider, height: 1),

                          // ── Tabs ─────────────────────────────────────
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'À propos'),
                              Tab(text: 'Portfolio'),
                              Tab(text: 'Avis'),
                            ],
                            labelColor: AppColors.primary,
                            unselectedLabelColor: AppColors.textHint,
                            indicatorColor: AppColors.primary,
                            indicatorSize: TabBarIndicatorSize.label,
                            dividerColor: AppColors.divider,
                          ),

                          // ── Tab content ───────────────────────────────
                          SizedBox(
                            height: 500, // inner scroll in tab views
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Tab 1 — À propos
                                _buildAboutTab(
                                  context: context,
                                  description: description,
                                  telephone: telephone,
                                  availability: availability,
                                ),
                                // Tab 2 — Portfolio
                                _buildPortfolioTab(
                                    context, portfolioUrls, portfolioItems),
                                // Tab 3 — Avis (placeholder)
                                _buildAvisTab(rating, reviewsCount),
                              ],
                            ),
                          ),

                          // Bottom padding for sticky button
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ── Sticky "Envoyer une demande" bottom button ─────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildStickyBottomBar(context, lang),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Loading state ──────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Stack(
      children: [
        // Gradient hero placeholder
        Container(
          height: 250,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 600,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xxl)),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ),
        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + AppSpacing.sm,
          left: AppSpacing.md,
          child: _circleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  // ── Hero fallback ──────────────────────────────────────────────────────────
  Widget _heroFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.person, color: Colors.white54, size: 80),
      ),
    );
  }

  // ── Overlaid circle button ─────────────────────────────────────────────────
  Widget _circleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.sm,
            right: AppSpacing.sm),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Verified badge ─────────────────────────────────────────────────────────
  Widget _buildVerifiedBadge(bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isVerified ? AppColors.successLight : AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: isVerified ? AppColors.success : AppColors.warning,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified
                ? Icons.verified_rounded
                : Icons.gpp_maybe_rounded,
            color: isVerified ? AppColors.success : AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            isVerified
                ? 'Artisan Vérifié'
                : 'Vérification en cours…',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isVerified ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  // ── Info row ───────────────────────────────────────────────────────────────
  Widget _buildInfoRow(
      double rating, int reviews, int? yearsExp, double? tarifs) {
    return Row(
      children: [
        _infoChip(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFC107),
            label: rating > 0 ? rating.toStringAsFixed(1) : 'Nouveau'),
        if (yearsExp != null) ...[
          const SizedBox(width: AppSpacing.sm),
          _infoChip(
              icon: Icons.work_history_rounded,
              iconColor: AppColors.primaryLight,
              label: '$yearsExp ans'),
        ],
        if (tarifs != null) ...[
          const SizedBox(width: AppSpacing.sm),
          _infoChip(
              icon: Icons.payments_rounded,
              iconColor: AppColors.success,
              label: '${tarifs.toInt()} DH/h'),
        ],
      ],
    );
  }

  Widget _infoChip(
      {required IconData icon,
      required Color iconColor,
      required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ── À propos tab ───────────────────────────────────────────────────────────
  Widget _buildAboutTab({
    required BuildContext context,
    required String? description,
    required String telephone,
    required Map<String, dynamic>? availability,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null && description.isNotEmpty) ...[
            Text('À propos', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(description, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
          ],

          Text('Disponibilité', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _buildAvailabilitySection(availability),
          const SizedBox(height: AppSpacing.xl),

          Text('Contact', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _buildContactTile(Icons.phone_iphone_rounded,
              telephone.isNotEmpty ? telephone : 'Non renseigné'),
          _buildContactTile(
              Icons.alternate_email_rounded, artisan.email),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(Map<String, dynamic>? availability) {
    const Map<String, String> daysMap = {
      'lundi': 'Lun',
      'mardi': 'Mar',
      'mercredi': 'Mer',
      'jeudi': 'Jeu',
      'vendredi': 'Ven',
      'samedi': 'Sam',
      'dimanche': 'Dim',
    };
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: daysMap.entries.map((entry) {
        final isAvail = availability != null &&
            (availability[entry.key] as bool? ?? false);
        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isAvail ? AppColors.successLight : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color:
                  isAvail ? AppColors.success : AppColors.divider,
            ),
          ),
          child: Text(
            entry.value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isAvail
                  ? AppColors.success
                  : AppColors.textHint,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactTile(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text(value, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }

  // ── Portfolio tab ──────────────────────────────────────────────────────────
  Widget _buildPortfolioTab(BuildContext context, List<String> oldUrls,
      List<PortfolioItem> newItems) {
    if (newItems.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: newItems.length,
        itemBuilder: (_, i) {
          final item = newItems[i];
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.base),
            decoration: AppDecorations.card,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text('AVANT',
                                style: AppTextStyles.overline
                                    .copyWith(color: AppColors.textHint)),
                            const SizedBox(height: AppSpacing.xs),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                              child: Image.network(item.beforeUrl,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          children: [
                            Text('APRÈS',
                                style: AppTextStyles.overline
                                    .copyWith(color: AppColors.success)),
                            const SizedBox(height: AppSpacing.xs),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                              child: Image.network(item.afterUrl,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (item.caption.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(item.caption,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }

    if (oldUrls.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.photo_library_outlined,
                  size: 56, color: AppColors.textHint),
              const SizedBox(height: AppSpacing.base),
              Text('Aucune réalisation pour l\'instant',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: oldUrls.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => _openFullScreenImage(context, oldUrls[i]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Image.network(oldUrls[i], fit: BoxFit.cover),
        ),
      ),
    );
  }

  // ── Avis tab (placeholder) ─────────────────────────────────────────────────
  Widget _buildAvisTab(double rating, int reviews) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => Icon(
                  Icons.star_rounded,
                  color: i < rating.round()
                      ? const Color(0xFFFFC107)
                      : AppColors.divider,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              rating > 0 ? rating.toStringAsFixed(1) : 'Pas encore noté',
              style: AppTextStyles.headlineMedium,
            ),
            Text(
              '$reviews avis client${reviews != 1 ? "s" : ""}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Les avis détaillés seront disponibles prochainement.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Full screen image ──────────────────────────────────────────────────────
  void _openFullScreenImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  // ── Sticky bottom bar ──────────────────────────────────────────────────────
  Widget _buildStickyBottomBar(BuildContext context, String lang) {
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
      padding: EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.md,
        AppSpacing.base,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          // Chat button (icon only)
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    receiverId: artisan.uid,
                    receiverName: artisan.nom,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Main CTA — full width orange
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _openRequestFormDirect(context, lang),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Envoyer une demande',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}