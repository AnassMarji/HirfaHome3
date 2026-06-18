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

import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/services/user_service.dart';
import 'package:hirfahome/widgets/skeleton_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _metierCtrl = TextEditingController();
  final _tarifCtrl = TextEditingController();
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _uploadProfilePhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Choisir depuis la galerie'),
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
          const SnackBar(
            content: Text('Photo de profil mise à jour !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du transfert : $e'),
            backgroundColor: AppColors.error,
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
          const SnackBar(
            content: Text('Fichier enregistré avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur d'envoi : $e"),
            backgroundColor: AppColors.error,
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
        title: const Text('Supprimer cette image ?'),
        content: const Text(
            "Cette action supprimera définitivement l'image de votre portfolio."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
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
          const SnackBar(
            content: Text('Image retirée avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression : $e'),
            backgroundColor: AppColors.error,
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
          const SnackBar(
            content: Text('Profil mis à jour avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: AppColors.error,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text('Mon Profil', style: AppTextStyles.titleLarge),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Profile Photo Section ──────────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: _showAvatarPickerSheet,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primarySurface,
                    backgroundImage:
                        _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                    child: _photoUrl == null
                        ? const Icon(Icons.person,
                            size: 50, color: AppColors.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: _uploading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Rating badge (if artisan has reviews)
          if (_isArtisan && (_noteMoyenne ?? 0) > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_noteMoyenne!.toStringAsFixed(1)} / 5  •  $_nombreAvis avis',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),

          // ── Form fields ───────────────────────────────────────────────
          _SectionLabel('Informations personnelles'),
          const SizedBox(height: AppSpacing.md),

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
            controller: _descCtrl,
            label: 'Description',
            prefixIcon: Icons.notes_rounded,
            maxLines: 3,
          ),

          if (_isArtisan) ...[
            const SizedBox(height: AppSpacing.xl),
            _SectionLabel('Informations artisan'),
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

            const SizedBox(height: AppSpacing.xl),
            _SectionLabel('Compétences'),
            const SizedBox(height: AppSpacing.md),
            _buildCompetencesSection(),

            const SizedBox(height: AppSpacing.xl),
            _SectionLabel('Justificatif professionnel'),
            const SizedBox(height: AppSpacing.md),
            _buildDocumentCard(),

            const SizedBox(height: AppSpacing.xl),
            _SectionLabel('Mon Portfolio'),
            const SizedBox(height: AppSpacing.md),
            _buildPortfolioSection(),
          ],

          const SizedBox(height: AppSpacing.xl),

          // ── Save Button ───────────────────────────────────────────────
          SizedBox(
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
                  : const Text('Enregistrer'),
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
                backgroundColor: AppColors.primarySurface,
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
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
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  _cinUrl != null ? 'Vérification en cours' : 'Justificatif requis',
                  style: AppTextStyles.bodyMedium,
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
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Center(
              child: Text(
                'Aucune image dans votre portfolio.\nAjoutez vos réalisations !',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          )
        else
          SizedBox(
            height: 100,
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
                            backgroundColor: Colors.white70,
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
          label: const Text('Ajouter une réalisation'),
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

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
      );
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
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: AppColors.surfaceVariant,
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}