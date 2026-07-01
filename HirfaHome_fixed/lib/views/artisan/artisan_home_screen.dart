// lib/views/artisan/artisan_home_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// HirfaHome — Artisan Home Screen (4-tab BottomNavigationBar shell)
// All business logic (accept, refuse, start, finish, rate) preserved intact.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/models/app_user.dart';
import 'package:hirfahome/models/demande.dart';
import 'package:hirfahome/repositories/demande_repository.dart';
import 'package:hirfahome/services/rating_service.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/utils/status_style.dart';
import 'package:hirfahome/views/profile/profile_screen.dart';
import 'package:hirfahome/views/artisan/artisan_stats_screen.dart';
import 'package:hirfahome/views/artisan/artisan_availability_screen.dart';
import 'package:hirfahome/views/shared/chat_inbox_screen.dart';
import 'package:hirfahome/widgets/skeleton_loader.dart';
import 'package:hirfahome/services/user_service.dart';
import 'package:hirfahome/widgets/glass_container.dart';
import 'package:hirfahome/widgets/liquid_glass.dart';
// ─── Helpers (delegating to centralized StatusStyle) ─────────────────────────
Color _statusColor(String statut) => StatusStyle.forStatus(statut).foreground;
String _statusLabel(String statut, String lang) =>
    AppStrings.t(statut, lang);
// ─── Main Widget ─────────────────────────────────────────────────────────────
class ArtisanHomeScreen extends StatefulWidget {
  final AppUser artisan;
  const ArtisanHomeScreen({super.key, required this.artisan});
  @override
  State<ArtisanHomeScreen> createState() => _ArtisanHomeScreenState();
}
class _ArtisanHomeScreenState extends State<ArtisanHomeScreen> {
  late final DemandeRepository _demandeRepository;
  final RatingService _ratingService = RatingService();
  final UserService _userService = UserService();
  int _currentIndex = 0;
  // ── Portfolio state ─────────────────────────────────────────────────────
  List<String> _portfolioUrls = [];
  bool _portfolioLoading = true;
  bool _portfolioUploading = false;
  @override
  void initState() {
    super.initState();
    _demandeRepository = context.read<DemandeRepository>();
    _loadPortfolio();
  }
  Future<void> _loadPortfolio() async {
    try {
      final data = await _userService.getProfile(widget.artisan.uid);
      if (mounted && data != null) {
        setState(() {
          _portfolioUrls = List<String>.from(data['portfolioUrls'] ?? []);
          _portfolioLoading = false;
        });
      } else {
        if (mounted) setState(() => _portfolioLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _portfolioLoading = false);
    }
  }
  // ── Business Logic — preserved 100% from original ──────────────────────
  Future<void> _accepterDemande(Demande demande, String lang) async {
    if (demande.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.t('accepter_demande_confirm_title', lang)),
        content: Text(
            '${AppStrings.t('accepter_demande_confirm_msg', lang)} "${demande.titre}".'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.t('annuler', lang))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.t('confirmer', lang)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _demandeRepository.accept(demande.id!, widget.artisan.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.t('succes_acceptation', lang)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
        setState(() => _currentIndex = 1);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.t('erreur_generique', lang)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
  Future<void> _refuserDemande(Demande demande, String lang) async {
    if (demande.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.t('refuser_demande', lang)),
        content: Text(AppStrings.t('refuser_demande', lang)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.t('annuler', lang))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error, foregroundColor: AppColors.onPrimary),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.t('refuser', lang)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _demandeRepository.refuse(demande.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.t('succes_refus', lang)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.t('erreur_generique', lang)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
  Future<void> _abandonnerDemande(Demande demande, String lang) async {
    if (demande.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.t('abandonner_confirm_title', lang)),
        content: Text(AppStrings.t('abandonner_confirm_msg', lang)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.t('non_garder', lang))),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.t('oui_abandonner', lang)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _demandeRepository.abandon(demande.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.t('succes_abandon', lang)),
          backgroundColor: AppColors.textHint,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.t('erreur_generique', lang)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
  Future<void> _demarrerDemande(Demande demande, String lang) async {
    if (demande.id == null) return;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: lang == 'ar'
          ? 'متى تبدأ؟ (اختر يوماً)'
          : lang == 'en'
              ? 'When do you start? (Select a day)'
              : 'Quand commencez-vous ? (Sélectionnez un jour)',
    );
    if (pickedDate == null || !mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: lang == 'ar'
          ? 'اختر وقت البدء'
          : lang == 'en'
              ? 'Select start time'
              : 'Sélectionnez une heure de début',
    );
    if (pickedTime == null || !mounted) return;
    final DateTime startDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    try {
      await _demandeRepository.startWork(demande.id!,
          dateIntervention: startDateTime);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.t('artisan_dash_started_toast', lang)),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('${AppStrings.t('erreur_generique', lang)} : $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
  Future<void> _terminerDemande(Demande demande, String lang) async {
    if (demande.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.t('marquer_terminee_titre', lang)),
        content: Text(AppStrings.t('marquer_terminee_msg', lang)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.t('annuler', lang))),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppStrings.t('terminer', lang))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _demandeRepository.terminate(demande.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.t('succes_acceptation', lang)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('${AppStrings.t('erreur_generique', lang)} : $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
  Future<void> _showRatingDialog(Demande demande, String lang) async {
    double selectedRating = 5;
    final commentCtrl = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: Text(AppStrings.t('noter_client_titre', lang)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppStrings.t('noter_client_msg', lang)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      icon: Icon(
                        i < selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.warning,
                        size: 40,
                      ),
                      onPressed: () =>
                          setLocalState(() => selectedRating = i + 1.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentCtrl,
                  decoration: InputDecoration(
                    labelText:
                        AppStrings.t('votre_avis_commentaire', lang),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppStrings.t('plus_tard', lang))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary),
              onPressed: () => Navigator.pop(ctx,
                  {'rating': selectedRating, 'comment': commentCtrl.text.trim()}),
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
        artisanId: widget.artisan.uid,
        rating: result['rating'] as double,
        comment: result['comment'] as String? ?? '',
        raterRole: 'artisan',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? AppStrings.t('note_envoye', lang)
            : AppStrings.t('erreur_envoi_note', lang)),
        backgroundColor:
            success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
  // ── Tab 0: Accueil ─────────────────────────────────────────────────────
  Widget _buildAccueilTab(String lang) {
    return StreamBuilder<List<Demande>>(
      stream: _demandeRepository.getAcceptedByArtisanId(widget.artisan.uid),
      builder: (context, snapshot) {
        final allMissions = snapshot.data ?? [];
        final pendingStream = _demandeRepository.getPending();
        return CustomScrollView(
          slivers: [
            // ── Dramatic gradient hero with greeting ──────────────────────
            SliverToBoxAdapter(child: _ArtisanHeroHeader(artisan: widget.artisan, lang: lang)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.base,
                    AppSpacing.base, AppSpacing.sm),
                child: _buildStatsRow(allMissions),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                child: Text(AppStrings.t('artisan_dash_pending_title', lang),
                    style: AppTextStyles.titleMedium),
              ),
            ),
            StreamBuilder<List<Demande>>(
              stream: pendingStream,
              builder: (context, pendingSnap) {
                if (pendingSnap.connectionState ==
                    ConnectionState.waiting) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const SkeletonListTile(),
                      childCount: 4,
                    ),
                  );
                }
                final pending = pendingSnap.data ?? [];
                if (pending.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 56,
                              color: AppColors.divider),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            AppStrings.t('aucune_disponible', lang),
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _DemandeCard(
                      key: ValueKey(pending[i].id),
                      demande: pending[i],
                      isAcceptedTab: false,
                      lang: lang,
                      onAccepter: _accepterDemande,
                      onRefuser: _refuserDemande,
                      onAbandonner: _abandonnerDemande,
                      onDemarrer: _demarrerDemande,
                      onTerminer: _terminerDemande,
                      onRate: _showRatingDialog,
                    ),
                    childCount: pending.length,
                  ),
                );
              },
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        );
      },
    );
  }
  Widget _buildStatsRow(List<Demande> missions) {
    final pendingCount =
        missions.where((d) => d.statut == 'envoye').length;
    final activeCount = missions
        .where((d) => d.statut == 'accepte' || d.statut == 'en_cours')
        .length;
    final rating = widget.artisan.noteMoyenne;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.inbox_rounded,
            value: '$pendingCount',
            label: 'Demandes reçues',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.directions_run_rounded,
            value: '$activeCount',
            label: 'En cours',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.star_rounded,
            value: rating.toStringAsFixed(1),
            label: 'Note moyenne',
          ),
        ),
      ],
    );
  }
  // ── Tab 1: Demandes ────────────────────────────────────────────────────
  Widget _buildDemandesTab(String lang) {
    return _AllDemandesView(
      artisanId: widget.artisan.uid,
      demandeRepository: _demandeRepository,
      lang: lang,
      onAccepter: _accepterDemande,
      onRefuser: _refuserDemande,
      onAbandonner: _abandonnerDemande,
      onDemarrer: _demarrerDemande,
      onTerminer: _terminerDemande,
      onRate: _showRatingDialog,
    );
  }
  // ── Tab 2: Portfolio ───────────────────────────────────────────────────
  Widget _buildPortfolioTab(String lang) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          
          foregroundColor: AppColors.textPrimary,
          floating: true,
          snap: true,
          elevation: 0,
          scrolledUnderElevation: 1,
          title: Text(AppStrings.t('artisan_portfolio_title', lang), style: AppTextStyles.titleLarge),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_rounded),
              onPressed: _portfolioUploading ? null : _addPortfolioPhoto,
              tooltip: AppStrings.t('artisan_portfolio_add_photo', lang),
            ),
          ],
        ),
        if (_portfolioLoading)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const SkeletonListTile(hasTrailing: false),
              childCount: 6,
            ),
          )
        else if (_portfolioUrls.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 64, color: AppColors.divider),
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    'Aucune image dans votre portfolio.\nAjoutez vos réalisations !',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.base),
            sliver: SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final url = _portfolioUrls[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppRadius.lg),
                        child: Image.network(url,
                            fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _deletePortfolioPhoto(url),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 14, color: AppColors.error),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                childCount: _portfolioUrls.length,
              ),
            ),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
  Future<void> _addPortfolioPhoto() async {
    // Delegate to ProfileScreen's logic via UserService
    setState(() => _portfolioUploading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      // Refresh from Firestore after push to profile
      await _loadPortfolio();
    } finally {
      if (mounted) setState(() => _portfolioUploading = false);
    }
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    _loadPortfolio();
  }
  Future<void> _deletePortfolioPhoto(String url) async {
    final lang = context.read<LanguageViewModel>().lang;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t('artisan_portfolio_delete_title', lang)),
        content: Text(
            AppStrings.t('artisan_portfolio_delete_confirm', lang)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppStrings.t('cancel', lang))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onPrimary),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.t('common_delete', lang)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.artisan.uid)
          .update({
        'portfolioUrls': FieldValue.arrayRemove([url]),
      });
      if (mounted) {
        setState(() => _portfolioUrls.remove(url));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.t('artisan_portfolio_delete_success', lang)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.t('artisan_portfolio_error', lang).replaceAll('{error}', e.toString())),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
  // ── Tab 3: Profil ──────────────────────────────────────────────────────
  Widget _buildProfilTab(String lang, LanguageViewModel langVM) {
    final artisan = widget.artisan;
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
        // ── Orange glass header card ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: GlassContainer(
            borderRadius: AppRadius.xl,
            padding: const EdgeInsets.all(AppSpacing.xl),
            tintColor: AppColors.primary,
            child: Column(
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                        width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        colorScheme.onSurface.withValues(alpha: 0.1),
                    backgroundImage: artisan.photoUrl != null
                        ? NetworkImage(artisan.photoUrl!)
                        : null,
                    child: artisan.photoUrl == null
                        ? Icon(Icons.person,
                            size: 44, color: colorScheme.onSurface)
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Name
                Text(
                  artisan.nom,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // Métier chip
                if (artisan.specialite != null &&
                    artisan.specialite!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      artisan.specialite!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                // Star rating row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(5, (i) {
                      return Icon(
                        i < artisan.noteMoyenne.round()
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: AppColors.warning,
                        size: 20,
                      );
                    }),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${artisan.noteMoyenne.toStringAsFixed(1)} (${artisan.nombreAvis})',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // ── Menu card ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: GlassContainer(
            borderRadius: AppRadius.lg,
            child: Column(
              children: [
                _ProfileMenuItem(
                  icon: Icons.edit_rounded,
                  label: 'Mon profil',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProfileScreen()),
                  ),
                ),
                const _MenuDivider(),
                _ProfileMenuItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Statistiques',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ArtisanStatsScreen(artisanId: artisan.uid)),
                  ),
                ),
                const _MenuDivider(),
                _ProfileMenuItem(
                  icon: Icons.schedule_rounded,
                  label: 'Disponibilités',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const ArtisanAvailabilityScreen()),
                  ),
                ),
                const _MenuDivider(),
                // Langue — inline toggle
                _ProfileMenuItemTrailing(
                  icon: Icons.language_outlined,
                  label: 'Langue',
                  trailing: Text(
                    langVM.flagLabel,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  onTap: () => Provider.of<LanguageViewModel>(context,
                          listen: false)
                      .cycle(),
                ),
                const _MenuDivider(),
                _ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Paramètres',
                  onTap: () =>
                      Navigator.pushNamed(context, '/artisan-settings'),
                ),
                const _MenuDivider(),
                _ProfileMenuItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Aide',
                  onTap: () {},
                ),
                Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider,
                    indent: AppSpacing.base,
                    endIndent: AppSpacing.base),
                _ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Se déconnecter',
                  isDestructive: true,
                  onTap: () => FirebaseAuth.instance.signOut(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
      ),
    );
  }

  /// Returns a stream of the total unread message count for the current artisan.
  ///
  /// Avoids collectionGroup (which requires a composite index that doesn't
  /// exist on Spark plan). Instead, fetches all chat_rooms, filters client-
  /// side for rooms containing the artisan's UID, then counts unread messages
  /// per room using .where('lu', isEqualTo: false).where('receiverId', ...).
  Stream<int> _unreadCountStream(String uid) {
    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .snapshots()
        .asyncMap((roomsSnap) async {
          final myRooms = roomsSnap.docs
              .where((doc) => doc.id.contains(uid))
              .toList();
          int total = 0;
          for (final room in myRooms) {
            final messages = await room.reference
                .collection('messages')
                .where('lu', isEqualTo: false)
                .where('receiverId', isEqualTo: uid)
                .get();
            total += messages.docs.length;
          }
          return total;
        });
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final langVM = context.watch<LanguageViewModel>();
    final lang = langVM.lang;
    final isRtl = langVM.isRtl;
    final tabs = [
      _buildAccueilTab(lang),
      _buildDemandesTab(lang),
      _buildPortfolioTab(lang),
      _buildProfilTab(lang, langVM),
    ];
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
        extendBody: true,
        floatingActionButton: _currentIndex != 3
            ? StreamBuilder<int>(
                stream: _unreadCountStream(widget.artisan.uid),
                builder: (context, unreadSnap) {
                  final unreadCount = unreadSnap.data ?? 0;
                  return GestureDetector(
                    onTap: () {
                      final uid = widget.artisan.uid;
                      debugPrint(
                          'ChatInboxScreen: artisan bubble tapped, uid: $uid');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatInboxScreen(currentUid: uid),
                        ),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.85),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.chat_bubble_outline,
                              color: Colors.white, size: 24),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: LiquidBottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            LiquidNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: AppStrings.t('artisan_nav_dashboard', lang)),
            LiquidNavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: AppStrings.t('artisan_nav_demandes', lang)),
            LiquidNavItem(icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library_rounded, label: AppStrings.t('artisan_nav_portfolio', lang)),
            LiquidNavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: AppStrings.t('artisan_nav_profile', lang)),
          ],
        ),
      ),
    );
  }
}
// ─── Stat Card ────────────────────────────────────────────────────────────────
class _ArtisanHeroHeader extends StatelessWidget {
  final AppUser artisan;
  final String lang;
  const _ArtisanHeroHeader({required this.artisan, required this.lang});
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final hour = DateTime.now().hour;
    final greetingKey = hour < 12
        ? 'home_greeting_morning'
        : hour < 18
            ? 'home_greeting_afternoon'
            : 'home_greeting_evening';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            AppColors.primaryDark,
            AppColors.primary,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 40, left: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl, topPad > 0 ? AppSpacing.lg : AppSpacing.xxl,
                  AppSpacing.xl, AppSpacing.xxl),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      backgroundImage: artisan.photoUrl != null
                          ? NetworkImage(artisan.photoUrl!)
                          : null,
                      child: artisan.photoUrl == null
                          ? const Icon(Icons.person, size: 28, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppStrings.t(greetingKey, lang)},',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          artisan.nom,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (artisan.specialite != null &&
                            artisan.specialite!.isNotEmpty &&
                            artisan.specialite != 'Non défini') ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm + 2, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              AppStrings.t(artisan.specialite!, lang),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Verified badge
                  if (artisan.verifie)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 16,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            textAlign: TextAlign.center, maxLines: 2,
          ),
        ],
      ),
    );
  }
}
// ─── All Demandes View (Tab 1) ────────────────────────────────────────────────
typedef _DemandeCallbackEx = Future<void> Function(Demande, String);
class _AllDemandesView extends StatefulWidget {
  final String artisanId;
  final DemandeRepository demandeRepository;
  final String lang;
  final _DemandeCallbackEx onAccepter;
  final _DemandeCallbackEx onRefuser;
  final _DemandeCallbackEx onAbandonner;
  final _DemandeCallbackEx onDemarrer;
  final _DemandeCallbackEx onTerminer;
  final _DemandeCallbackEx onRate;
  const _AllDemandesView({
    required this.artisanId,
    required this.demandeRepository,
    required this.lang,
    required this.onAccepter,
    required this.onRefuser,
    required this.onAbandonner,
    required this.onDemarrer,
    required this.onTerminer,
    required this.onRate,
  });
  @override
  State<_AllDemandesView> createState() => _AllDemandesViewState();
}
class _AllDemandesViewState extends State<_AllDemandesView> {
  String _filter = 'all';
  List<(String, String)> _filters(String lang) => [
    ('all', AppStrings.t('filter_all', lang)),
    ('envoye', AppStrings.t('envoye', lang)),
    ('en_cours', AppStrings.t('en_cours', lang)),
    ('termine', AppStrings.t('terminees', lang)),
  ];
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Demande>>(
      stream:
          widget.demandeRepository.getAcceptedByArtisanId(widget.artisanId),
      builder: (context, snapshot) {
        // Also combine pending (envoye) stream
        return StreamBuilder<List<Demande>>(
          stream: widget.demandeRepository.getPending(),
          builder: (context, pendingSnap) {
            final accepted = snapshot.data ?? [];
            final pending = pendingSnap.data ?? [];
            // Merge: pending + accepted (avoid duplicates by id)
            final allIds = accepted.map((d) => d.id).toSet();
            final merged = [
              ...pending.where((d) => !allIds.contains(d.id)),
              ...accepted,
            ];
            // Filter
            List<Demande> filtered;
            if (_filter == 'all') {
              filtered = merged;
            } else if (_filter == 'en_cours') {
              filtered = merged
                  .where((d) =>
                      d.statut == 'en_cours' || d.statut == 'accepte')
                  .toList();
            } else {
              filtered = merged
                  .where((d) => d.statut == _filter)
                  .toList();
            }
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting ||
                    pendingSnap.connectionState ==
                        ConnectionState.waiting;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  
                  foregroundColor: AppColors.textPrimary,
                  floating: true,
                  snap: true,
                  elevation: 0,
                  scrolledUnderElevation: 1,
                  title: Text(AppStrings.t('artisan_nav_demandes', widget.lang),
                      style: AppTextStyles.titleLarge),
                ),
                // Filter chips
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                      itemCount: _filters(widget.lang).length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final (key, label) = _filters(widget.lang)[i];
                        final selected = _filter == key;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _filter = key),
                          child: GlassContainer(
                            borderRadius: AppRadius.full,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.base,
                                vertical: AppSpacing.xs),
                            tintColor: selected
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : Colors.white,
                            child: Text(
                              label,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? AppColors.primaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (isLoading)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const SkeletonListTile(),
                      childCount: 5,
                    ),
                  )
                else if (filtered.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        children: [
                          Icon(Icons.assignment_outlined,
                              size: 56, color: AppColors.divider),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Aucune demande dans cette catégorie.',
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final d = filtered[i];
                        final isAccepted = d.statut != 'envoye';
                        return _DemandeCard(
                          key: ValueKey(d.id),
                          demande: d,
                          isAcceptedTab: isAccepted,
                          lang: widget.lang,
                          onAccepter: widget.onAccepter,
                          onRefuser: widget.onRefuser,
                          onAbandonner: widget.onAbandonner,
                          onDemarrer: widget.onDemarrer,
                          onTerminer: widget.onTerminer,
                          onRate: widget.onRate,
                          showDate: true,
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                const SliverPadding(
                    padding: EdgeInsets.only(bottom: 24)),
              ],
            );
          },
        );
      },
    );
  }
}
// ─── Demande Card ─────────────────────────────────────────────────────────────
class _DemandeCard extends StatefulWidget {
  final Demande demande;
  final bool isAcceptedTab;
  final String lang;
  final _DemandeCallbackEx onAccepter;
  final _DemandeCallbackEx onRefuser;
  final _DemandeCallbackEx onAbandonner;
  final _DemandeCallbackEx onDemarrer;
  final _DemandeCallbackEx onTerminer;
  final _DemandeCallbackEx onRate;
  final bool showDate;
  const _DemandeCard({
    required Key key,
    required this.demande,
    required this.isAcceptedTab,
    required this.lang,
    required this.onAccepter,
    required this.onRefuser,
    required this.onAbandonner,
    required this.onDemarrer,
    required this.onTerminer,
    required this.onRate,
    this.showDate = false,
  }) : super(key: key);
  @override
  State<_DemandeCard> createState() => _DemandeCardState();
}
class _DemandeCardState extends State<_DemandeCard> {
  Map<String, dynamic>? _clientData;
  bool _loadingClient = true;
  @override
  void initState() {
    super.initState();
    _loadClientData();
  }
  Future<void> _loadClientData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.demande.clientId)
          .get();
      if (mounted) {
        setState(() {
          _clientData = doc.data();
          _loadingClient = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingClient = false);
    }
  }
  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  }
  String _formatInterventionDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year} à $hour:$minute';
  }
  @override
  Widget build(BuildContext context) {
    final demande = widget.demande;
    final lang = widget.lang;
    final statut = demande.statut;
    final sColor = _statusColor(statut);
    final sLabel = _statusLabel(statut, lang);
    final clientName = _loadingClient
        ? null
        : (_clientData?['nom'] as String? ?? 'Client');
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.xs),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.base),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: client name + status chip ──────────────────
            Row(
              children: [
                // Client name
                Expanded(
                  child: _loadingClient
                      ? const SkeletonBox(
                          width: 120,
                          height: 14,
                        )
                      : Text(
                          clientName ?? 'Client',
                          style: AppTextStyles.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: sColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    sLabel,
                    style: GoogleFonts.inter(
                      color: sColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // ── Title ──────────────────────────────────────────────────
            Text(
              demande.titre,
              style: AppTextStyles.bodyLarge
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            // ── Description (2 lines max) ──────────────────────────────
            Text(
              demande.description,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // ── Date if requested ──────────────────────────────────────
            if (widget.showDate) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _formatDate(demande.dateCreation),
                style: AppTextStyles.caption,
              ),
            ],
            // ── Images ─────────────────────────────────────────────────
            if (demande.images.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: demande.images.length,
                  itemBuilder: (context, idx) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        child: Image.network(
                            demande.images[idx],
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),
            ],
            // ── Address (if accepted) ──────────────────────────────────
            if (widget.isAcceptedTab && demande.adresse.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(demande.adresse,
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ] else if (!widget.isAcceptedTab) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.map_outlined,
                      size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    _clientData?['ville'] ?? 'Secteur d\'intervention',
                    style: AppTextStyles.caption
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],
            // ── Intervention date ──────────────────────────────────────
            if (demande.dateIntervention != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(Icons.event_note_outlined,
                      size: 14, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    'Intervention : ${_formatInterventionDate(demande.dateIntervention!)}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.warning),
                  ),
                ],
              ),
            ],
            // ── Client info (accepted tab) ─────────────────────────────
            if (widget.isAcceptedTab) ...[
              if (_loadingClient)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm),
                  child: SizedBox(
                      height: 3, child: LinearProgressIndicator()),
                )
              else if (_clientData != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person,
                          size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _clientData!['nom'] as String? ?? 'Client',
                            style: AppTextStyles.bodyLarge
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          if ((_clientData!['noteMoyenne'] as num?)
                                  ?.toDouble() !=
                              null)
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 12, color: AppColors.warning),
                                const SizedBox(width: 2),
                                Text(
                                  '${(_clientData!['noteMoyenne'] as num).toStringAsFixed(1)} (${_clientData!['nombreAvis'] ?? 0} avis)',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.sm),
            // ── Action buttons row ─────────────────────────────────────
            Row(
              children: [
                if (widget.isAcceptedTab) ...[
                  if (demande.clientEmail.isNotEmpty)
                    _ContactButton(
                      icon: Icons.email_outlined,
                      label: AppStrings.t('email', lang),
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: demande.clientEmail));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              AppStrings.t('email_copie', lang)),
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                    ),
                  if (demande.clientTelephone.isNotEmpty)
                    _ContactButton(
                      icon: Icons.phone_outlined,
                      label: lang == 'ar'
                          ? 'اتصل'
                          : lang == 'en'
                              ? 'Call'
                              : 'Appeler',
                      onTap: () async {
                        final uri = Uri.parse(
                            'tel:${demande.clientTelephone}');
                        if (await canLaunchUrl(uri)) {
                          launchUrl(uri);
                        }
                      },
                    ),
                ],
                const Spacer(),
                if (widget.isAcceptedTab) ...[
                  if (statut == 'accepte') ...[
                    TextButton.icon(
                      icon: const Icon(Icons.play_circle_fill,
                          color: AppColors.info),
                      label: Text(AppStrings.t('demarrer', lang),
                          style:
                              const TextStyle(color: AppColors.info)),
                      onPressed: () =>
                          widget.onDemarrer(demande, lang),
                    ),
                    IconButton(
                      icon: Icon(Icons.undo,
                          color: AppColors.error),
                      tooltip: AppStrings.t('abandonner', lang),
                      onPressed: () =>
                          widget.onAbandonner(demande, lang),
                    ),
                  ],
                  if (statut == 'en_cours')
                    TextButton.icon(
                      icon: const Icon(Icons.check_circle,
                          color: AppColors.success),
                      label: Text(AppStrings.t('terminer', lang),
                          style:
                              const TextStyle(color: AppColors.success)),
                      onPressed: () =>
                          widget.onTerminer(demande, lang),
                    ),
                  if (statut == 'termine')
                    TextButton.icon(
                      icon: const Icon(Icons.star,
                          color: AppColors.warning),
                      label: Text(AppStrings.t('noter', lang),
                          style:
                              const TextStyle(color: AppColors.warning)),
                      onPressed: () => widget.onRate(demande, lang),
                    ),
                ] else ...[
                  if (statut == 'envoye') ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onPressed: () =>
                          widget.onRefuser(demande, lang),
                      child: Text(AppStrings.t('refuser', lang),
                          style:
                              const TextStyle(color: AppColors.error)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton.icon(
                      icon: const Icon(
                          Icons.check_circle_outline,
                          size: 16),
                      label: Text(AppStrings.t('accepter', lang)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.onPrimary,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10)),
                      ),
                      onPressed: () =>
                          widget.onAccepter(demande, lang),
                    ),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// ─── Contact Button ───────────────────────────────────────────────────────────
class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.inter(
                    color: AppColors.primary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
// ─── Profile Menu Item ────────────────────────────────────────────────────────
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.errorLight
                    : AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color:
                    isDestructive ? AppColors.error : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (!isDestructive)
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}
class _ProfileMenuItemTrailing extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;
  const _ProfileMenuItemTrailing({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
class _MenuDivider extends StatelessWidget {
  const _MenuDivider();
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.divider,
      indent: 72,
    );
  }
}