// lib/views/client/artisan_search_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// HirfaHome — Artisan Search Screen (DoorDash / Uber redesign)
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/config/category_config.dart';
import 'package:hirfahome/models/app_user.dart';
import 'package:hirfahome/repositories/artisan_repository.dart';
import 'package:hirfahome/services/category_service.dart';
import 'package:hirfahome/viewmodels/language_viewmodel.dart';
import 'package:hirfahome/strings/app_strings.dart';
import 'package:hirfahome/widgets/skeleton_loader.dart';
import 'package:hirfahome/views/client/artisan_detail_screen.dart';
import 'package:hirfahome/widgets/glass_container.dart';
class ArtisanSearchScreen extends StatefulWidget {
  final String? targetCategory;
  const ArtisanSearchScreen({super.key, this.targetCategory});
  @override
  State<ArtisanSearchScreen> createState() => _ArtisanSearchScreenState();
}
class _ArtisanSearchScreenState extends State<ArtisanSearchScreen> {
  late final ArtisanRepository _artisanRepository;
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'toutes';
  bool _verifiedOnly = false;
  // ── Filtres CDC §6.1.2 ──
  RangeValues _budgetRange = const RangeValues(0, 1000);
  String? _selectedDay;
  static const List<String> _dayChipLabels = [
    'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'
  ];
  static const Map<String, String> _dayChipToFirestore = {
    'Lun': 'lundi',
    'Mar': 'mardi',
    'Mer': 'mercredi',
    'Jeu': 'jeudi',
    'Ven': 'vendredi',
    'Sam': 'samedi',
    'Dim': 'dimanche',
  };
  @override
  void initState() {
    super.initState();
    _artisanRepository = context.read<ArtisanRepository>();
    if (widget.targetCategory != null) {
      _selectedCategory = widget.targetCategory!;
    }
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  void _resetFilters() {
    setState(() {
      _budgetRange = const RangeValues(0, 1000);
      _selectedDay = null;
      _verifiedOnly = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }
  @override
  Widget build(BuildContext context) {
    final langVM = context.watch<LanguageViewModel>();
    final lang = langVM.lang;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          // ── Sticky header: AppBar + Search + Filters ──────────────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: AppColors.shadow,
            title: Text(
              AppStrings.t('search_title', lang),
              style: AppTextStyles.titleLarge,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(116),
              child: Column(
                  children: [
                    // ── Search bar ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.base, 0, AppSpacing.base, AppSpacing.sm),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.trim().toLowerCase()),
                        style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: AppStrings.t('search_hint', lang),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: AppSpacing.base),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.textHint,
                            size: 22,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close_rounded,
                                      color: AppColors.textHint, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    // ── Category chips ──────────────────────────────────────
                    StreamBuilder<Map<String, bool>>(
                      stream: _categoryService.getEnabledCategories(),
                      builder: (context, catSnapshot) {
                        final enabledMap = catSnapshot.data ?? {};
                        final visibleCategories = CategoryConfig.categories
                            .where((cat) => enabledMap[cat.key] ?? true)
                            .toList();
                        return SizedBox(
                          height: 44,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.base),
                            itemCount: visibleCategories.length + 1,
                            itemBuilder: (context, index) {
                              final isFirst = index == 0;
                              final catKey = isFirst
                                  ? 'toutes'
                                  : visibleCategories[index - 1].key;
                              final label = isFirst
                                  ? AppStrings.t('toutes', lang)
                                  : AppStrings.t(catKey, lang);
                              final isSelected = _selectedCategory == catKey;
                              return Padding(
                                padding:
                                    const EdgeInsets.only(right: AppSpacing.sm),
                                child: GlassContainer(
                                  borderRadius: 20,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.xs + 2),
                                  tintColor: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.3)
                                      : Colors.white,
                                  onTap: () => setState(
                                      () => _selectedCategory = catKey),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
            ),
            actions: [
              // ── Advanced filter icon ──────────────────────────────────────
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                color: _verifiedOnly || _selectedDay != null ||
                        _budgetRange.start > 0 || _budgetRange.end < 1000
                    ? AppColors.primary
                    : AppColors.textSecondary,
                onPressed: () => _showAdvancedFilters(context, lang),
              ),
            ],
          ),
        ],
        // ── Artisan list ────────────────────────────────────────────────────
        body: StreamBuilder<List<AppUser>>(
          stream: _artisanRepository.getArtisans(),
          builder: (context, snapshot) {
            // ── Loading: 4 skeleton cards ──────────────────────────────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.base, AppSpacing.base, 0),
                itemCount: 4,
                itemBuilder: (ctx, i) => const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: SkeletonArtisanCard(),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(isNoData: true);
            }
            // ── Apply filters ──────────────────────────────────────────────
            final filtered = snapshot.data!.where((artisan) {
              final nom = artisan.nom.toLowerCase();
              final ville = (artisan.ville ?? '').toLowerCase();
              final matchQuery =
                  _searchQuery.isEmpty ||
                  nom.contains(_searchQuery) ||
                  ville.contains(_searchQuery);
              final matchCategory = _selectedCategory == 'toutes' ||
                  (artisan.specialite ?? '').toLowerCase() ==
                      _selectedCategory.toLowerCase();
              final matchBudget = artisan.tarifs == null ||
                  (artisan.tarifs! >= _budgetRange.start &&
                      artisan.tarifs! <= _budgetRange.end);
              final matchVerified = !_verifiedOnly || artisan.verifie;
              bool matchDay = true;
              if (_selectedDay != null) {
                final key = _dayChipToFirestore[_selectedDay!];
                matchDay = key != null &&
                    artisan.availability != null &&
                    (artisan.availability![key] ?? false);
              }
              return matchQuery &&
                  matchCategory &&
                  matchBudget &&
                  matchVerified &&
                  matchDay;
            }).toList();
            if (filtered.isEmpty) return _buildEmptyState(isNoData: false);
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, AppSpacing.base, AppSpacing.base, 96),
              itemCount: filtered.length,
              itemBuilder: (context, index) =>
                  _ArtisanCard(artisan: filtered[index]),
            );
          },
        ),
      ),
    );
  }
  // ── Empty state ──────────────────────────────────────────────────────────
  Widget _buildEmptyState({required bool isNoData}) {
    final lang = context.read<LanguageViewModel>().lang;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: const Icon(Icons.search_off_rounded,
                  color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppStrings.t('search_no_results', lang),
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isNoData
                  ? AppStrings.t('search_no_data', lang)
                  : AppStrings.t('search_adjust_filters', lang),
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (!isNoData) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppStrings.t('search_filters', lang)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  // ── Advanced filter bottom sheet ────────────────────────────────────────
  void _showAdvancedFilters(BuildContext context, String lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        // Use local state via StatefulBuilder
        RangeValues localBudget = _budgetRange;
        String? localDay = _selectedDay;
        bool localVerified = _verifiedOnly;
        return StatefulBuilder(
          builder: (ctx, setLocal) => GlassContainer(
            borderRadius: AppRadius.xxl,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xl + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin:
                        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
                Text(AppStrings.t('search_filters', lang), style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.xl),
                // Budget
                Text(
                  'Budget : ${localBudget.start.toInt()} – ${localBudget.end.toInt()} DH',
                  style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                RangeSlider(
                  values: localBudget,
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.surfaceVariant,
                  labels: RangeLabels(
                    '${localBudget.start.toInt()} DH',
                    '${localBudget.end.toInt()} DH',
                  ),
                  onChanged: (v) => setLocal(() => localBudget = v),
                ),
                const SizedBox(height: AppSpacing.base),
                // Disponibilité
                Text(AppStrings.t('disponibilite', lang),
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: _dayChipLabels.map((label) {
                    final sel = localDay == label;
                    return ChoiceChip(
                      label: Text(label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                sel ? FontWeight.w700 : FontWeight.w500,
                            color: sel
                                ? Colors.white
                                : AppColors.textSecondary,
                          )),
                      selected: sel,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceVariant,
                      side: BorderSide.none,
                      onSelected: (v) =>
                          setLocal(() => localDay = v ? label : null),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.base),
                // Verified only
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.t('verifie_seulement', lang),
                      style: AppTextStyles.bodyLarge),
                  value: localVerified,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primaryLight,
                  onChanged: (v) => setLocal(() => localVerified = v),
                ),
                const SizedBox(height: AppSpacing.base),
                // Apply / Reset
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setLocal(() {
                            localBudget = const RangeValues(0, 1000);
                            localDay = null;
                            localVerified = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md)),
                        ),
                        child: Text(AppStrings.t('search_reset', lang)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _budgetRange = localBudget;
                            _selectedDay = localDay;
                            _verifiedOnly = localVerified;
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md)),
                        ),
                        child: Text(AppStrings.t('search_apply', lang)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
// ─── ARTISAN CARD ─────────────────────────────────────────────────────────────
class _ArtisanCard extends StatelessWidget {
  const _ArtisanCard({required this.artisan});
  final AppUser artisan;
  bool get _isAvailableToday {
    if (artisan.availability == null) return false;
    const keys = [
      'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'
    ];
    final key = keys[DateTime.now().weekday - 1];
    return artisan.availability![key] ?? false;
  }
  @override
  Widget build(BuildContext context) {
    final lang = context.read<LanguageViewModel>().lang;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ArtisanDetailScreen(artisan: artisan)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // ── Top section ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar with availability dot ──────────────────────
                  Stack(
                    children: [
                      Hero(
                        tag: 'avatar_${artisan.uid}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primarySurface,
                            image: artisan.photoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(artisan.photoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: artisan.photoUrl == null
                              ? const Icon(Icons.person,
                                  color: AppColors.primary, size: 38)
                              : null,
                        ),
                      ),
                      // Availability dot
                      if (_isAvailableToday)
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // ── Name / métier / rating ────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + verified badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                artisan.nom,
                                style: AppTextStyles.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (artisan.verifie) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Métier
                        Text(
                          artisan.specialite ?? 'Artisan',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Rating • Expérience
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppColors.warning, size: 16),
                            const SizedBox(width: 3),
                            Text(
                              artisan.noteMoyenne > 0
                                  ? artisan.noteMoyenne.toStringAsFixed(1)
                                  : AppStrings.t('search_new', lang),
                              style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                            if (artisan.nombreAvis > 0) ...[
                              Text(
                                ' (${artisan.nombreAvis})',
                                style: AppTextStyles.caption,
                              ),
                            ],
                            if (artisan.yearsExperience != null) ...[
                              Text(
                                '  •  ${artisan.yearsExperience} ans',
                                style: AppTextStyles.bodyMedium,
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
            // ── Divider ────────────────────────────────────────────────────
            Divider(height: 1, thickness: 1, color: AppColors.divider),
            // ── Bottom: competences + tarif + arrow ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.base,
                  AppSpacing.sm, AppSpacing.base, AppSpacing.base),
              child: Row(
                children: [
                  // Competence chips — shown from specialite as fallback
                  Expanded(
                    child: _buildCompetenceChips(artisan),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Tarif + arrow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (artisan.tarifs != null)
                        Text(
                          '${artisan.tarifs!.toInt()} DH/h',
                          style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primary),
                        ),
                      const SizedBox(height: 2),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 16, color: AppColors.textHint),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
  Widget _buildCompetenceChips(AppUser artisan) {
    // Fallback: show city + specialite as chips when competences aren't in model
    final tags = <String>[
      if (artisan.specialite != null) artisan.specialite!,
      if (artisan.ville != null) artisan.ville!,
    ].take(2).toList();
    if (tags.isEmpty) return const SizedBox();
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                tag,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}