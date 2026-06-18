// ─────────────────────────────────────────────────────────────────────────────
// HirfaHome Design System — app_theme.dart
// Inspired by Uber, DoorDash, and Careem visual quality
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── COLOR PALETTE ────────────────────────────────────────────────────────────

abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFFE65100);
  static const Color primaryDark = Color(0xFFBF360C);
  static const Color primaryLight = Color(0xFFFF8A50);
  static const Color primarySurface = Color(0xFFFFF3E0); // 8 % primary tint

  // Backgrounds
  static const Color background = Color(0xFFF8F8F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F2F2);

  // On-colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1A1A1A);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFFAAAAAA);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFF8E1);

  // Structural
  static const Color divider = Color(0xFFEEEEEE);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Shadows
  static const Color shadow = Color(0x14000000); // 8 % black
  static const Color shadowMedium = Color(0x1F000000); // 12 % black
}

// ─── SPACING SYSTEM ───────────────────────────────────────────────────────────

abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

// ─── RADIUS SYSTEM ────────────────────────────────────────────────────────────

abstract final class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;

  static BorderRadius get cardRadius => BorderRadius.circular(lg);
  static BorderRadius get inputRadius => BorderRadius.circular(md);
  static BorderRadius get buttonRadius => BorderRadius.circular(14.0);
  static BorderRadius get chipRadius => BorderRadius.circular(full);
}

// ─── SHADOWS ──────────────────────────────────────────────────────────────────

abstract final class AppShadows {
  /// Subtle card shadow — DoorDash style
  static List<BoxShadow> get card => const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ];

  /// Stronger shadow for floating elements (FABs, bottom sheets)
  static List<BoxShadow> get floating => const [
        BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ];

  /// Extra-subtle divider-like shadow for app bars
  static List<BoxShadow> get appBar => const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ];
}

// ─── TYPOGRAPHY ───────────────────────────────────────────────────────────────

abstract final class AppTextStyles {
  // Inter — Google Fonts
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textHint,
      );

  // Utility overrides
  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onPrimary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textHint,
        letterSpacing: 0.8,
      );
}

// ─── THEME DATA ───────────────────────────────────────────────────────────────

abstract final class AppTheme {
  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      // ── Colors ──────────────────────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primarySurface,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        error: AppColors.error,
        onError: AppColors.onPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // ── Typography ───────────────────────────────────────────────────────
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: AppTextStyles.displayLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.labelLarge,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // ── AppBar ───────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.shadow,
        titleTextStyle: AppTextStyles.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
        actionsIconTheme:
            const IconThemeData(color: AppColors.textPrimary, size: 24),
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.surface,
        ),
      ),

      // ── ElevatedButton ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.textHint,
          disabledForegroundColor: AppColors.surface,
          textStyle: AppTextStyles.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: 14),
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shadowColor: Colors.transparent,
        ).copyWith(
          // Pressed state — darker shade
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryDark;
            }
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textHint;
            }
            return AppColors.primary;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryDark.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: 14),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── TextButton ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base, vertical: 10),
        ),
      ),

      // ── Input Decoration ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textHint,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        // No border in resting state
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
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide.none,
        ),
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        margin: EdgeInsets.zero,
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primarySurface,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        shape: const StadiumBorder(),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      ),

      // ── BottomNavigationBar ───────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ── NavigationBar (Material 3) ────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySurface,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textHint, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.textHint,
          );
        }),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── ListTile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        titleTextStyle: AppTextStyles.bodyLarge,
        subtitleTextStyle: AppTextStyles.bodyMedium,
        iconColor: AppColors.textSecondary,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),

      // ── Dialog ───────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        titleTextStyle: AppTextStyles.titleLarge,
        contentTextStyle: AppTextStyles.bodyMedium,
        elevation: 8,
        shadowColor: AppColors.shadowMedium,
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.surface,
        ),
        actionTextColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),

      // ── FloatingActionButton ─────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── ProgressIndicator ─────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primarySurface,
      ),

      // ── Switches & Checkboxes ─────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.onPrimary;
          return AppColors.textHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.surfaceVariant;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: AppColors.textHint, width: 1.5),
      ),

      // ── Tab Bar ───────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textHint,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        dividerColor: AppColors.divider,
      ),
    );
  }
}

// ─── REUSABLE DECORATION HELPERS ──────────────────────────────────────────────

abstract final class AppDecorations {
  /// Standard card container — no Flutter Card widget needed
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      );

  /// Pressed / highlighted card
  static BoxDecoration get cardHighlighted => BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      );

  /// Input-like container (no border)
  static BoxDecoration get input => BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.inputRadius,
      );

  /// Chip / badge
  static BoxDecoration chip({
    Color? color,
    Color? border,
  }) =>
      BoxDecoration(
        color: color ?? AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border:
            border != null ? Border.all(color: border, width: 1) : null,
      );

  /// Semantic status badges
  static BoxDecoration statusBadge(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      );
}
