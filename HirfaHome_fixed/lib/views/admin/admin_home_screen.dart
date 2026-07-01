import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:hirfahome/config/app_theme.dart";
import "package:hirfahome/viewmodels/language_viewmodel.dart";
import "package:hirfahome/strings/app_strings.dart";
import "package:provider/provider.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hirfahome/config/category_config.dart';
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}
class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String get lang => context.read<LanguageViewModel>().lang;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _newCategoryController = TextEditingController();
  // ── Statistics future (Feature A) ──────────────────────────────────────
  late Future<Map<String, dynamic>> _statsFuture;
  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchGlobalStats();
    _seedCategoriesIfEmpty();
  }
  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }
  // ── A — Fetch global statistics ────────────────────────────────────────
  Future<Map<String, dynamic>> _fetchGlobalStats() async {
    final usersSnap = await _firestore.collection('users').get();
    final users = usersSnap.docs;
    final activeArtisans = users.where((doc) {
      final d = doc.data();
      return d['role'] == 'artisan' && (d['verifie'] ?? false) == true;
    }).length;
    final activeClients = users.where((doc) => doc['role'] == 'client').length;
    // Missions this month
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final demandesSnap = await _firestore
        .collection('demandes')
        .where('dateCreation', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
        .get();
    final missionsThisMonth = demandesSnap.docs.length;
    // Average satisfaction from reviews collection
    final reviewsSnap = await _firestore.collection('reviews').get();
    double satisfaction = 0.0;
    if (reviewsSnap.docs.isNotEmpty) {
      final total = reviewsSnap.docs.fold<double>(0.0, (acc, doc) {
        final r = doc.data()['rating'];
        return acc + (r is num ? r.toDouble() : 0.0);
      });
      satisfaction = total / reviewsSnap.docs.length;
    }
    return {
      'artisans': activeArtisans,
      'clients': activeClients,
      'missions': missionsThisMonth,
      'satisfaction': satisfaction,
    };
  }
  // ── C — Seed categories collection if empty ────────────────────────────
  Future<void> _seedCategoriesIfEmpty() async {
    final snap = await _firestore.collection('categories').limit(1).get();
    if (snap.docs.isEmpty) {
      final batch = _firestore.batch();
      for (final cat in CategoryConfig.categories) {
        batch.set(_firestore.collection('categories').doc(), {'nom': cat.key});
      }
      await batch.commit();
    }
  }
  Future<void> _addCategory(String nom) async {
    final trimmed = nom.trim();
    if (trimmed.isEmpty) return;
    await _firestore.collection('categories').add({'nom': trimmed});
    _newCategoryController.clear();
  }
  Future<void> _deleteCategory(String docId) async {
    await _firestore.collection('categories').doc(docId).delete();
  }
  // ── B — Delete fraudulent artisan ──────────────────────────────────────
  Future<void> _supprimerArtisan(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t('admin_delete_title', lang)),
        content: Text(AppStrings.t('admin_delete_warning', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.t('cancel', lang)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.t('common_delete', lang), style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _firestore.collection('users').doc(uid).delete();
      await _firestore.collection('artisans').doc(uid).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.t('admin_artisan_deleted', lang)), backgroundColor: AppColors.error),
        );
        // Refresh stats after deletion
        setState(() {
          _statsFuture = _fetchGlobalStats();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.t('artisan_settings_error', lang).replaceAll('{error}', e.toString())), backgroundColor: AppColors.error),
        );
      }
    }
  }
  // ── D — Existing validation features (untouched) ──────────────────────
  Future<void> _validerArtisan(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'verifie': true,
      });
      await _firestore.collection('notifications').doc(uid).set({
        'type': 'account_verified',
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.t('admin_artisan_validated', lang)), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.t('admin_validation_error', lang).replaceAll('{error}', e.toString())), backgroundColor: AppColors.error),
        );
      }
    }
  }
  Future<void> _bannirArtisan(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t('admin_ban_title', lang)),
        content: Text(AppStrings.t('admin_ban_warning', lang)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t('cancel', lang))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.t('admin_ban', lang), style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _firestore.collection('users').doc(uid).update({
        'banned': true,
        'role': 'banni',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.t('admin_banned', lang)), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.t('artisan_settings_error', lang).replaceAll('{error}', e.toString())), backgroundColor: AppColors.error),
        );
      }
    }
  }
  void _showVerificationDialog(Map<String, dynamic> data, String uid) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${AppStrings.t('admin_verification', lang)}: ${data['nom']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${AppStrings.t('admin_city', lang)}: ${data['ville'] ?? '—'}'),
              Text('${AppStrings.t('settings_phone', lang)}: ${data['telephone'] ?? '—'}'),
              Text('${AppStrings.t('email', lang)}: ${data['email'] ?? '—'}'),
              const SizedBox(height: 16),
              Text(AppStrings.t('admin_cin_label', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              data['cinUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        data['cinUrl'],
                        height: 200,
                        width: double.maxFinite,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(AppStrings.t('admin_no_cin', lang), style: TextStyle(color: AppColors.error, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.t('admin_close', lang), style: TextStyle(color: AppColors.textHint)),
          ),
          if (data['cinUrl'] != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
              onPressed: () {
                _validerArtisan(uid);
                Navigator.pop(ctx);
              },
              child: Text(AppStrings.t('admin_validate', lang)),
            ),
        ],
      ),
    );
  }
  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppStrings.t('admin_title', lang),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les statistiques',
            onPressed: () => setState(() => _statsFuture = _fetchGlobalStats()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── A — Global Statistics Dashboard ──────────────────────
            const Text(
              'Statistiques Globales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 12),
            _buildGlobalStats(),
            const SizedBox(height: 28),
            // ── D — Existing artisan validation section ──────────────
            const Text(
              'Demandes de Validation Artisans',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 12),
            _buildPendingArtisansList(),
            const SizedBox(height: 28),
            // ── B — Verified artisans with delete button ─────────────
            const Text(
              'Artisans Vérifiés Actifs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 12),
            _buildVerifiedArtisansSection(),
            const SizedBox(height: 28),
            // ── C — Category Management Section ──────────────────────
            const Text(
              'Catégories Métiers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 12),
            _buildCategoryManagementSection(),
          ],
        ),
      ),
    );
  }
  // ══════════════════════════════════════════════════════════════════════
  // A — GLOBAL STATISTICS DASHBOARD (FutureBuilder)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildGlobalStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data;
        final artisans = isLoading ? '--' : '${data?['artisans'] ?? 0}';
        final clients = isLoading ? '--' : '${data?['clients'] ?? 0}';
        final missions = isLoading ? '--' : '${data?['missions'] ?? 0}';
        final satisfaction = isLoading
            ? '--'
            : '${(data?['satisfaction'] as double? ?? 0.0).toStringAsFixed(1)} / 5';
        return GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            _buildStatTile('Artisans actifs', artisans, Icons.handyman_outlined, AppColors.primary),
            _buildStatTile('Clients actifs', clients, Icons.person_outline, AppColors.info),
            _buildStatTile('Missions ce mois', missions, Icons.calendar_month_outlined, AppColors.success),
            _buildStatTile('Satisfaction', satisfaction, Icons.star_outline_rounded, AppColors.warning),
          ],
        );
      },
    );
  }
  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const Spacer(),
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: AppColors.textHint, fontSize: 11)),
          ],
        ),
      ),
    );
  }
  // ══════════════════════════════════════════════════════════════════════
  // D — PENDING ARTISANS LIST (existing — untouched)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildPendingArtisansList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').where('role', isEqualTo: 'artisan').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allArtisans = snapshot.data?.docs ?? [];
        final pendingArtisans = allArtisans.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (data['verifie'] ?? false) == false;
        }).toList();
        if (pendingArtisans.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(AppStrings.t('admin_no_pending', lang), style: TextStyle(color: AppColors.textHint)),
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pendingArtisans.length,
          itemBuilder: (context, index) {
            final doc = pendingArtisans[index];
            final data = doc.data() as Map<String, dynamic>;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: data['cinUrl'] != null ? AppColors.primary.withValues(alpha: 0.1) : AppColors.textHint.withValues(alpha: 0.1),
                  child: Icon(
                    data['cinUrl'] != null ? Icons.assignment_late_rounded : Icons.person_off_rounded,
                  ),
                ),
                title: Text(data['nom'] ?? 'Artisan anonyme', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  data['cinUrl'] != null ? 'CIN soumise (Analyse requise)' : 'En attente de justificatifs',
                  style: TextStyle(fontSize: 12, color: data['cinUrl'] != null ? AppColors.primaryDark : AppColors.textHint),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => _bannirArtisan(doc.id),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ],
                ),
                onTap: () => _showVerificationDialog(data, doc.id),
              ),
            );
          },
        );
      },
    );
  }
  // ══════════════════════════════════════════════════════════════════════
  // B — VERIFIED ARTISANS WITH DELETE BUTTON
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildVerifiedArtisansSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .where('role', isEqualTo: 'artisan')
          .where('verifie', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(AppStrings.t('admin_no_verified', lang), style: TextStyle(color: AppColors.textHint, fontSize: 13)),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final uid = docs[index].id;
            final note = ((data['noteMoyenne'] ?? 0.0) as num).toDouble();
            final avis = (data['nombreAvis'] ?? 0) as int;
            final spec = data['specialite'] ?? 'Artisan';
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: data['photoUrl'] != null ? NetworkImage(data['photoUrl']) : null,
                  child: data['photoUrl'] == null
                      ? const Icon(Icons.person, color: Color(0xFFE65100))
                      : null,
                ),
                title: Text(data['nom'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.warning, size: 16),
                    const SizedBox(width: 4),
                    Text('${note.toStringAsFixed(1)} ($avis avis)', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(
                        spec.toString().toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    // ── B: Red delete button ──
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: AppColors.error),
                      tooltip: 'Supprimer cet artisan',
                      onPressed: () => _supprimerArtisan(uid),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  // ══════════════════════════════════════════════════════════════════════
  // C — CATEGORY MANAGEMENT SECTION (Firestore 'categories' collection)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildCategoryManagementSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Add new category row ──
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCategoryController,
                    decoration: InputDecoration(
                      hintText: 'Nouvelle catégorie...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFFE65100)),
                  tooltip: 'Ajouter une catégorie',
                  onPressed: () async {
                    await _addCategory(_newCategoryController.text);
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ── Category chips from Firestore ──
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('categories').orderBy('nom').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(AppStrings.t('admin_no_categories', lang), style: TextStyle(color: AppColors.textHint)),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: docs.map((doc) {
                    final nom = (doc.data() as Map<String, dynamic>)['nom'] ?? '';
                    return Chip(
                      label: Text(
                        nom.toString()[0].toUpperCase() + nom.toString().substring(1),
                        style: const TextStyle(fontSize: 13),
                      ),
                      
                      deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.error),
                      onDeleted: () => _deleteCategory(doc.id),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}