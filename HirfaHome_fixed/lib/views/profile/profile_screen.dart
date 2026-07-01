// lib/views/profile/profile_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// HirfaHome — Profile Edit Screen (DoorDash / Uber redesign)
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:provider/provider.dart";
import "package:hirfahome/viewmodels/language_viewmodel.dart";
import "package:hirfahome/strings/app_strings.dart";
import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/widgets/glass_scaffold.dart';
import 'package:hirfahome/services/user_service.dart';
import 'package:hirfahome/widgets/skeleton_loader.dart';
import 'package:hirfahome/widgets/glass_container.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  String get lang => context.read<LanguageViewModel>().lang;
  final _userService = UserService();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _metierCtrl = TextEditingController();
  final _tarifCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _picker = ImagePicker();
  bool _loading = true;
  bool _saving = false;
  bool _uploading = false;
  String? _error;
  double? _noteMoyenne;
  int? _nombreAvis;
  bool _isArtisan = false;
  String? _cinUrl;
  String? _photoUrl;
  List<String> _portfolioUrls = [];
  List<String> _competences = [];
  final _compCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _expCtrl.dispose();
    _descCtrl.dispose();
    _metierCtrl.dispose();
    _tarifCtrl.dispose();
    _emailCtrl.dispose();
    _adresseCtrl.dispose();
    _compCtrl.dispose();
    super.dispose();
  }
  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final data = await _userService.getProfile(user.uid);
      if (mounted && data != null) {
        setState(() {
          _nameCtrl.text = data['nom'] ?? '';
          _phoneCtrl.text = data['telephone'] ?? '';
          _emailCtrl.text = user.email ?? '';
          _adresseCtrl.text = data['adresse'] ?? '';
          _expCtrl.text = (data['yearsExperience'] != null)
              ? data['yearsExperience'].toString()
              : '';
          _descCtrl.text = data['description'] ?? '';
          _metierCtrl.text = data['specialite'] ?? '';
          _tarifCtrl.text =
              data['tarifs'] != null ? data['tarifs'].toString() : '';
          _isArtisan = data['role'] == 'artisan';
          _noteMoyenne = (data['noteMoyenne'] ?? 0.0).toDouble();
          _nombreAvis = data['nombreAvis'] ?? 0;
          _cinUrl = data['cinUrl'] as String?;
          _photoUrl = data['photoUrl'] as String?;
          _portfolioUrls = List<String>.from(data['portfolioUrls'] ?? []);
          _competences = List<String>.from(data['competences'] ?? []);
          _loading = false;
          _error = null;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des données.';
        _loading = false;
      });
    }
  }
  void _showAvatarPickerSheet() {
    showModalBottomSheet(
      context: context,
      
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: Text(AppStrings.t('profile_take_photo', lang)),
              onTap: () {
                Navigator.pop(context);
                _uploadProfilePhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: Text(AppStrings.t('profile_choose_gallery', lang)),
              onTap: () {
                Navigator.pop(context);
                _uploadProfilePhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _uploadProfilePhoto(ImageSource source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (image == null) return;
    setState(() => _uploading = true);
    try {
      final file = File(image.path);
      final uploadRef = FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/profile/avatar.jpg');
      await uploadRef.putFile(file);
      final downloadUrl = await uploadRef.getDownloadURL();
      await _userService.updateProfile(user.uid, {'photoUrl': downloadUrl});
      setState(() => _photoUrl = downloadUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.t('profile_photo_updated', lang)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.t('profile_transfer_error', lang).replaceAll('{error}', e.toString())),
          ),
        );
      }
    } finally {
      setState(() => _uploading = false);
    }
  }
  Future<void> _uploadFile(String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;
    setState(() => _uploading = true);
    try {
      final file = File(image.path);
      String path;
      if (type == 'cin') {
        path = 'users/${user.uid}/documents/cin.jpg';
      } else {
        path =
            'users/${user.uid}/portfolio/${DateTime.now().millisecondsSinceEpoch}.jpg';
      }
      final uploadRef = FirebaseStorage.instance.ref().child(path);
      await uploadRef.putFile(file);
      final downloadUrl = await uploadRef.getDownloadURL();
      if (type == 'cin') {
        await _userService.updateProfile(user.uid, {'cinUrl': downloadUrl});
        setState(() => _cinUrl = downloadUrl);
      } else {
        final updatedPortfolio = List<String>.from(_portfolioUrls)
          ..add(downloadUrl);
        await _userService
            .updateProfile(user.uid, {'portfolioUrls': updatedPortfolio});
        setState(() => _portfolioUrls = updatedPortfolio);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.t('profile_saved', lang)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur d'envoi : $e"),
          ),
        );
      }
    } finally {
      setState(() => _uploading = false);
    }
  }
  Future<void> _deletePortfolioImage(String url) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t('profile_delete_image_title', lang)),
        content: const Text(
            "Cette action supprimera définitivement l'image de votre portfolio."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppStrings.t('cancel', lang))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.t('common_delete', lang)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _uploading = true);
    try {
      final storageRef = FirebaseStorage.instance.refFromURL(url);
      await storageRef.delete();
      await _userService.updateProfile(user.uid, {
        'portfolioUrls': FieldValue.arrayRemove([url]),
      });
      setState(() => _portfolioUrls.remove(url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.t('profile_image_removed', lang)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.t('profile_delete_error', lang).replaceAll('{error}', e.toString())),
          ),
        );
      }
    } finally {
      setState(() => _uploading = false);
    }
  }
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      final Map<String, dynamic> updates = {
        'nom': _nameCtrl.text.trim(),
        'telephone': _phoneCtrl.text.trim(),
        'adresse': _adresseCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
      };
      if (_isArtisan) {
        updates['yearsExperience'] =
            int.tryParse(_expCtrl.text.trim()) ?? 0;
        updates['specialite'] = _metierCtrl.text.trim();
        updates['tarifs'] =
            double.tryParse(_tarifCtrl.text.trim());
        updates['competences'] = _competences;
      }
      await _userService.updateProfile(user.uid, updates);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.t('profile_updated', lang)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.t('artisan_settings_error', lang).replaceAll('{error}', e.toString())),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: AppStrings.t('profile_title', lang),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.check_rounded, color: AppColors.primary),
            onPressed: _saving || _uploading ? null : _saveProfile,
            tooltip: 'Enregistrer',
          ),
        ],
      ),
      body: _loading
          ? const _LoadingBody()
          : _error != null
              ? _ErrorBody(
                  error: _error!,
                  onRetry: () {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    _loadProfile();
                  },
                )
              : _buildBody(),
    );
  }
  Widget _buildBody() {
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
                  // Avatar (tap to edit)
                  GestureDetector(
                    onTap: _showAvatarPickerSheet,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                            width: 3),
                      ),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                colorScheme.onSurface.withValues(alpha: 0.1),
                            backgroundImage: _photoUrl != null
                                ? NetworkImage(_photoUrl!)
                                : null,
                            child: _photoUrl == null
                                ? Icon(Icons.person,
                                    size: 44, color: colorScheme.onSurface)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: colorScheme.primary,
                              child: _uploading
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : Icon(Icons.camera_alt_rounded,
                                      size: 16, color: colorScheme.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Name
                  Text(
                    _nameCtrl.text.isNotEmpty ? _nameCtrl.text : '—',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Email chip
                  if (_emailCtrl.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        _emailCtrl.text,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  // Rating row (artisan with reviews only)
                  if (_isArtisan && (_noteMoyenne ?? 0) > 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            i < (_noteMoyenne ?? 0).round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: AppColors.warning,
                            size: 20,
                          );
                        }),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${_noteMoyenne!.toStringAsFixed(1)} (${_nombreAvis ?? 0})',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          // ── Form card ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: GlassContainer(
              borderRadius: AppRadius.lg,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _AppTextField(
                    controller: _nameCtrl,
                    label: 'Nom complet',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _AppTextField(
                    controller: _phoneCtrl,
                    label: 'Téléphone',
                    prefixIcon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _AppTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _AppTextField(
                    controller: _adresseCtrl,
                    label: 'Adresse',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _AppTextField(
                    controller: _descCtrl,
                    label: 'Description',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                  if (_isArtisan) ...[
                    const SizedBox(height: AppSpacing.md),
                    _AppTextField(
                      controller: _metierCtrl,
                      label: 'Métier / Spécialité',
                      prefixIcon: Icons.work_outline_rounded,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _AppTextField(
                      controller: _expCtrl,
                      label: "Années d'expérience",
                      prefixIcon: Icons.timeline_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _AppTextField(
                      controller: _tarifCtrl,
                      label: 'Tarif / heure (DH) — optionnel',
                      prefixIcon: Icons.payments_outlined,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isArtisan) ...[
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: GlassContainer(
                borderRadius: AppRadius.lg,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _buildCompetencesSection(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: _buildDocumentCard(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: GlassContainer(
                borderRadius: AppRadius.lg,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _buildPortfolioSection(),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          // ── Save Button ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving || _uploading ? null : _saveProfile,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(AppStrings.t('profile_save', lang)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
  Widget _buildCompetencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing chips
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ..._competences.map(
              (c) => InputChip(
                label: Text(c, style: AppTextStyles.bodyMedium),
                side: BorderSide.none,
                onDeleted: () => setState(() => _competences.remove(c)),
                deleteIconColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Add new competence
        Row(
          children: [
            Expanded(
              child: _AppTextField(
                controller: _compCtrl,
                label: 'Ajouter une compétence',
                prefixIcon: Icons.add_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () {
                final val = _compCtrl.text.trim();
                if (val.isNotEmpty && !_competences.contains(val)) {
                  setState(() {
                    _competences.add(val);
                    _compCtrl.clear();
                  });
                }
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildDocumentCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.base),
      borderRadius: 16,
      child: Row(
        children: [
          Icon(
            _cinUrl != null
                ? Icons.verified_user_rounded
                : Icons.pending_actions_rounded,
            color: _cinUrl != null ? AppColors.success : AppColors.warning,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Carte d'identité Nationale (CIN)",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  _cinUrl != null ? 'Vérification en cours' : 'Justificatif requis',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: _uploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.upload_file_rounded, color: AppColors.primary),
            onPressed: _uploading ? null : () => _uploadFile('cin'),
          ),
        ],
      ),
    );
  }
  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_portfolioUrls.isEmpty)
          Center(
            child: Text(
              'Aucune image dans votre portfolio.\nAjoutez vos réalisations !',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          )
        else
          SizedBox(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _portfolioUrls.length,
              itemBuilder: (context, index) {
                final url = _portfolioUrls[index];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.network(url,
                            width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _deletePortfolioImage(url),
                          child: const CircleAvatar(
                            radius: 12,
                            child: Icon(Icons.close_rounded,
                                size: 14, color: AppColors.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: _uploading ? null : () => _uploadFile('portfolio'),
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(AppStrings.t('profile_add_realization', lang)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md)),
          ),
        ),
      ],
    );
  }
}
// ─── App Text Field ───────────────────────────────────────────────────────────
class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  const _AppTextField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.keyboardType,
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(prefixIcon,
            color: colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.md),
      ),
    );
  }
}
// ─── Loading Body ─────────────────────────────────────────────────────────────
class _LoadingBody extends StatelessWidget {
  const _LoadingBody();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        children: [
          const Center(child: SkeletonCircle(size: 100)),
          const SizedBox(height: AppSpacing.xl),
          const SkeletonBox(
              width: double.infinity, height: 52, borderRadius: AppRadius.md),
          const SizedBox(height: AppSpacing.md),
          const SkeletonBox(
              width: double.infinity, height: 52, borderRadius: AppRadius.md),
          const SizedBox(height: AppSpacing.md),
          const SkeletonBox(
              width: double.infinity, height: 90, borderRadius: AppRadius.md),
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(
              3,
              (_) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: SkeletonListTile(),
                  )),
        ],
      ),
    );
  }
}
// ─── Error Body ───────────────────────────────────────────────────────────────
class _ErrorBody extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorBody({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    final lang = context.read<LanguageViewModel>().lang;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 48),
            const SizedBox(height: AppSpacing.base),
            Text(error,
                style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppStrings.t('profile_retry', lang)),
            ),
          ],
        ),
      ),
    );
  }
}