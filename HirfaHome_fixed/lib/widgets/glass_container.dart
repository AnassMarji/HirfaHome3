// ═══ FILE: lib/widgets/glass_container.dart ═══
//
// GlassContainer — the standard glass surface for the entire app.
// Uses BackdropFilter for real frosted blur, semi-transparent gradient,
// glassy border, specular shine, and soft shadow.
//
// CRITICAL: For blur to be visible, the parent Scaffold MUST have
// backgroundColor: Colors.transparent (set globally in app_theme.dart).
// The gradient from main.dart's MaterialApp.builder provides the
// colorful background that the blur can actually blur.

import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurStrength;
  final Color tintColor;
  final double borderOpacity;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.blurStrength = 18,
    this.tintColor = Colors.white,
    this.borderOpacity = 0.35,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? Colors.white : tintColor;
    final borderCol = isDark ? Colors.white : tintColor;

    final bgGradient = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tint.withValues(alpha: 0.12),
              tint.withValues(alpha: 0.04),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tint.withValues(alpha: 0.25),
              tint.withValues(alpha: 0.08),
            ],
          );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurStrength,
              sigmaY: blurStrength,
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: bgGradient,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderCol.withValues(alpha: isDark ? 0.1 : borderOpacity),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
