
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hirfahome/config/category_config.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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
        title: const Text('Supprimer cet artisan ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
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
          const SnackBar(content: Text('Artisan supprimé'), backgroundColor: Colors.red),
        );
        // Refresh stats after deletion
        setState(() {
          _statsFuture = _fetchGlobalStats();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
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
          const SnackBar(content: Text('Artisan validé avec succès !'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de validation : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _bannirArtisan(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bannir l\'artisan ?'),
        content: const Text('Cette action bloquera ses accès et marquera l\'utilisateur comme banni.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bannir', style: TextStyle(color: Colors.white)),
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
          const SnackBar(content: Text('Artisan banni avec succès.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showVerificationDialog(Map<String, dynamic> data, String uid) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vérification : ${data['nom']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              Text('Ville : ${data['ville'] ?? 'Non spécifiée'}'),
              Text('Téléphone : ${data['telephone'] ?? 'Non renseigné'}'),
              Text('Email : ${data['email'] ?? 'Non renseigné'}'),
              const SizedBox(height: 16),
              const Text('Justificatif d\'Identité (CIN) :', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              data['cinUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        data['cinUrl'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Text('Aucun justificatif uploadé par l\'artisan.', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Fermer', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  if (data['cinUrl'] != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () {
                        _validerArtisan(uid);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Valider le compte'),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: const Text('Back-office Administrateur'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
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
            _buildStatTile('Artisans actifs', artisans, Icons.handyman_outlined, const Color(0xFFE65100)),
            _buildStatTile('Clients actifs', clients, Icons.person_outline, Colors.blue),
            _buildStatTile('Missions ce mois', missions, Icons.calendar_month_outlined, Colors.green),
            _buildStatTile('Satisfaction', satisfaction, Icons.star_outline_rounded, Colors.amber),
          ],
        );
      },
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text('Aucun artisan en attente de vérification.', style: TextStyle(color: Colors.grey)),
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

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: data['cinUrl'] != null ? Colors.orange.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                  child: Icon(
                    data['cinUrl'] != null ? Icons.assignment_late_rounded : Icons.person_off_rounded,
                    color: data['cinUrl'] != null ? Colors.orange : Colors.grey,
                  ),
                ),
                title: Text(data['nom'] ?? 'Artisan anonyme', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  data['cinUrl'] != null ? 'CIN soumise (Analyse requise)' : 'En attente de justificatifs',
                  style: TextStyle(fontSize: 12, color: data['cinUrl'] != null ? Colors.orange.shade800 : Colors.grey),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
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
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Aucun artisan vérifié et actif pour le moment.', style: TextStyle(color: Colors.grey, fontSize: 13)),
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

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE65100).withValues(alpha: 0.1),
                  backgroundImage: data['photoUrl'] != null ? NetworkImage(data['photoUrl']) : null,
                  child: data['photoUrl'] == null
                      ? const Icon(Icons.person, color: Color(0xFFE65100))
                      : null,
                ),
                title: Text(data['nom'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
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
                      backgroundColor: const Color(0xFFE65100),
                    ),
                    const SizedBox(width: 4),
                    // ── B: Red delete button ──
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
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
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
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
                  return const Center(
                    child: Text('Aucune catégorie. Ajoutez-en une !', style: TextStyle(color: Colors.grey)),
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
                      backgroundColor: const Color(0xFFF5F0EB),
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.red),
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