// ═══ FILE: lib/utils/status_style.dart ═══
//
// Centralized status colors and labels for demandes (requests).
//
// Previously, three different screens had their own helpers returning
// different colors for the same status (e.g. 'envoye' was yellow in one
// screen and grey in another). This file is the single source of truth.
//
// Usage:
//   final style = StatusStyle.forStatus('accepte');
//   Container(
//     decoration: BoxDecoration(color: style.background, ...),
//     child: Text(style.label, style: TextStyle(color: style.foreground)),
//   );

import 'package:flutter/material.dart';
import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/strings/app_strings.dart';

/// Visual style for a given demande status.
class StatusStyle {
  final Color foreground;
  final Color background;
  final String labelKey; // key into AppStrings
  final IconData icon;

  const StatusStyle({
    required this.foreground,
    required this.background,
    required this.labelKey,
    required this.icon,
  });

  /// Localized label (French or Arabic based on current language).
  String label([String lang = 'fr']) => AppStrings.t(labelKey, lang);

  /// Returns the StatusStyle matching the given demande status string.
  /// Falls back to a neutral grey style for unknown statuses.
  static StatusStyle forStatus(String status) {
    switch (status) {
      case 'envoye':
        return const StatusStyle(
          foreground: Color(0xFF0EA5E9), // azure
          background: Color(0xFFE0F2FE), // sky tint
          labelKey: 'envoye',
          icon: Icons.send_rounded,
        );
      case 'accepte':
        return const StatusStyle(
          foreground: Color(0xFF16A34A), // forest
          background: Color(0xFFDCFCE7), // mint
          labelKey: 'accepte',
          icon: Icons.check_circle_outline_rounded,
        );
      case 'en_cours':
        return const StatusStyle(
          foreground: Color(0xFFF59E0B), // amber
          background: Color(0xFFFEF3C7), // honey
          labelKey: 'en_cours',
          icon: Icons.hourglass_top_rounded,
        );
      case 'termine':
        return const StatusStyle(
          foreground: Color(0xFF1E3A8A), // navy
          background: Color(0xFFDBEAFE), // sky tint
          labelKey: 'termine',
          icon: Icons.task_alt_rounded,
        );
      case 'refuse':
        return const StatusStyle(
          foreground: Color(0xFFDC2626), // brick red
          background: Color(0xFFFEE2E2), // rose tint
          labelKey: 'refuse',
          icon: Icons.cancel_rounded,
        );
      default:
        return StatusStyle(
          foreground: AppColors.textSecondary,
          background: AppColors.surfaceVariant,
          labelKey: 'en_attente',
          icon: Icons.help_outline_rounded,
        );
    }
  }
}
