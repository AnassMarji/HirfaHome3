// ═══ FILE: lib/widgets/status_badge.dart ═══
//
// Reusable status badge widget for demandes (requests).
// Uses StatusStyle for consistent colors across all screens.
//
// Usage:
//   StatusBadge(status: 'accepte')
//   StatusBadge(status: 'termine', lang: 'ar')

import 'package:flutter/material.dart';
import 'package:hirfahome/config/app_theme.dart';
import 'package:hirfahome/utils/status_style.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? lang;
  final bool showIcon;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.lang,
    this.showIcon = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.forStatus(status);
    final label = style.label(lang ?? 'fr');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? 2 : AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              style.icon,
              size: compact ? 12 : 14,
              color: style.foreground,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              color: style.foreground,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
