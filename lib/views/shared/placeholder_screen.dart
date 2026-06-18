
import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String body;

  const PlaceholderScreen({
    super.key,
    required this.title,
    this.body = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE65100), Color(0xFFBF360C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Icon(_iconForTitle(title), size: 48, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Text(
                body.isNotEmpty ? body : 'Cette fonctionnalité sera disponible prochainement.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700], fontSize: 16, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForTitle(String title) {
    if (title.toLowerCase().contains('param')) return Icons.settings;
    if (title.toLowerCase().contains('condition')) return Icons.description_outlined;
    if (title.toLowerCase().contains('confidential')) return Icons.lock_outline;
    if (title.toLowerCase().contains('propos')) return Icons.info_outline;
    return Icons.info_outline;
  }
}