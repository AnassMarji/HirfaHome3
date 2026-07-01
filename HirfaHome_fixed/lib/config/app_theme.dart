// ═══ FILE: lib/config/app_theme.dart ═══
//
// HirfaHome Design System — Professional Grade
//
// Inspired by Uber, DoorDash, and inDrive.
// Supports light and dark modes via Material 3 ColorScheme.
//
// Architecture:
//   - AppColors: brand palette (constant, mode-independent)
//   - AppSpacing: spacing scale (4px base)
//   - AppRadius: border radius scale
//   - AppShadows: elevation shadow presets
//   - AppTextStyles: typography scale (Inter via Google Fonts)
//   - AppDecorations: reusable BoxDecoration presets
//   - AppTheme: light + dark ThemeData with Material 3

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════════
// BRAND PALETTE — constant colors that define the HirfaHome identity
// ═══════════════════════════════════════════════════════════════════════════

abstract final class AppColors {
  // ── Primary (Warm Orange — evokes Moroccan craftsmanship) ──
  static const Color primary = Color(0xFFE65100);
  static const Color primaryDark = Color(0xFFBF360C);
  static const Color primaryLight = Color(0xFFFF8A50);
  static const Color primarySurface = Color(0xFFFFF3E0);

  // ── Accent (Deep Navy — trust, premium) ──
  static const Color accent = Color(0xFF1A237E);
  static const Color accentLight = Color(0xFF534BAE);

  // ── Semantic ──
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color info = Color(0xFF0277BD);
  static const Color infoLight = Color(0xFFE1F5FE);

  // ── Gradients (for hero sections) ──
  static const List<Color> heroGradient = [
    Color(0xFF1A1A1A),
    Color(0xFF3D1F00),
    AppColors.primary,
  ];

  // ── Status Colors (for demande lifecycle) ──
  static const Color statusEnvoye = Color(0xFF0EA5E9);
  static const Color statusAccepte = Color(0xFF16A34A);
  static const Color statusEnCours = Color(0xFFF59E0B);
  static const Color statusTermine = Color(0xFF1E3A8A);
  static const Color statusRefuse = Color(0xFFDC2626);

  // ── Legacy aliases — DYNAMIC (theme-aware via updateForTheme)
  //    These are mutable static fields that change when the theme changes.
  //    Call AppColors.updateForTheme(brightness) from MaterialApp.builder.
  //    Brand constants above remain const; only surface/text colors are dynamic.
  static Color background = const Color(0xFFFAFAFA);
  static Color surface = const Color(0xFFFFFFFF);
  static Color surfaceVariant = const Color(0xFFF2F2F2);
  static Color onPrimary = const Color(0xFFFFFFFF);
  static Color onBackground = const Color(0xFF1A1A1A);
  static Color textPrimary = const Color(0xFF1A1A1A);
  static Color textSecondary = const Color(0xFF666666);
  static Color textHint = const Color(0xFFAAAAAA);
  static Color divider = const Color(0xFFEEEEEE);
  static Color shadow = const Color(0x14000000);
  static Color shadowMedium = const Color(0x1F000000);
  static Color shimmerBase = const Color(0xFFE0E0E0);
  static Color shimmerHighlight = const Color(0xFFF5F5F5);

  /// Updates the legacy aliases to match the given brightness.
  /// Called from MaterialApp.builder on every rebuild.
  static void updateForTheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      background = const Color(0xFF121212);
      surface = const Color(0xFF1E1E1E);
      surfaceVariant = const Color(0xFF2A2A2A);
      onPrimary = const Color(0xFFFFFFFF);
      onBackground = const Color(0xFFECECEC);
      textPrimary = const Color(0xFFECECEC);
      textSecondary = const Color(0xFFAAAAAA);
      textHint = const Color(0xFF777777);
      divider = const Color(0xFF333333);
      shadow = const Color(0x40000000);
      shadowMedium = const Color(0x60000000);
      shimmerBase = const Color(0xFF2A2A2A);
      shimmerHighlight = const Color(0xFF3A3A3A);
    } else {
      background = const Color(0xFFFAFAFA);
      surface = const Color(0xFFFFFFFF);
      surfaceVariant = const Color(0xFFF2F2F2);
      onPrimary = const Color(0xFFFFFFFF);
      onBackground = const Color(0xFF1A1A1A);
      textPrimary = const Color(0xFF1A1A1A);
      textSecondary = const Color(0xFF666666);
      textHint = const Color(0xFFAAAAAA);
      divider = const Color(0xFFEEEEEE);
      shadow = const Color(0x14000000);
      shadowMedium = const Color(0x1F000000);
      shimmerBase = const Color(0xFFE0E0E0);
      shimmerHighlight = const Color(0xFFF5F5F5);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SPACING — 4px base unit
// ═══════════════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════════════
// RADIUS
// ═══════════════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════════════
// SHADOWS — layered for premium depth
// ═══════════════════════════════════════════════════════════════════════════

abstract final class AppShadows {
  /// Subtle card shadow
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Premium elevated card — Uber style with layered depth
  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Floating elements (FABs, bottom sheets)
  static List<BoxShadow> get floating => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  /// Colored glow for primary CTAs
  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  /// App bar shadow
  static List<BoxShadow> get appBar => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}

// ═══════════════════════════════════════════════════════════════════════════
// TYPOGRAPHY — Inter (Google Fonts)
// ═══════════════════════════════════════════════════════════════════════════

abstract final class AppTextStyles {
  // Display — for hero sections, large numbers
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 42,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
        height: 1.0,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.1,
      );

  // Headline — for screen titles
  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.1,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      );

  // Title — for section headers, card titles
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.2,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.3,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  // Body — for paragraphs, descriptions
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  // Label — for buttons, chips, captions
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      );

  // Caption — for timestamps, meta info
  // Overline — for small uppercase labels
  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.3,
      );

  // Button text
  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// DECORATIONS — reusable BoxDecoration presets
// ═══════════════════════════════════════════════════════════════════════════

abstract final class AppDecorations {
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      );

  static BoxDecoration get elevatedCard => BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.elevated,
      );

  static BoxDecoration get input => BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.inputRadius,
      );

  static BoxDecoration chip({Color? color, Color? border}) => BoxDecoration(
        color: color ?? Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: border != null ? Border.all(color: border, width: 1) : null,
      );

  static BoxDecoration statusBadge(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      );

  static BoxDecoration get heroGradient => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
          stops: [0.0, 0.4, 1.0],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// THEME DATA — light and dark
// ═══════════════════════════════════════════════════════════════════════════

abstract final class AppTheme {
  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySurface,
      onPrimaryContainer: AppColors.primaryDark,
      surface: const Color(0xFFFAFAFA),
      onSurface: const Color(0xFF1A1A1A),
      surfaceContainerHighest: const Color(0xFFF2F2F2),
      error: AppColors.error,
      onError: Colors.white,
    );

    return _buildTheme(base, colorScheme);
  }

  // ── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF3D2710),
      onPrimaryContainer: AppColors.primaryLight,
      surface: const Color(0xFF121212),
      onSurface: const Color(0xFFECECEC),
      surfaceContainerHighest: const Color(0xFF1E1E1E),
      error: AppColors.error,
      onError: Colors.white,
    );

    return _buildTheme(base, colorScheme);
  }

  static ThemeData _buildTheme(ThemeData base, ColorScheme colorScheme) {
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      // ── Typography ───────────────────────────────────────────────────────
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: colorScheme.onSurface),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: colorScheme.onSurface),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: colorScheme.onSurface),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: colorScheme.onSurface),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: colorScheme.onSurface),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: colorScheme.onSurface),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurface),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurface),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: colorScheme.onPrimary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurface),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurface),
      ),
      // ── AppBar ───────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: colorScheme.onSurface),
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
        centerTitle: false,
        systemOverlayStyle: colorScheme.brightness == Brightness.light
            ? SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: colorScheme.surface,
              )
            : SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: colorScheme.surface,
              ),
      ),
      // ── ElevatedButton ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
          textStyle: AppTextStyles.buttonText,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 14),
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
        ),
      ),
      // ── OutlinedButton ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          textStyle: AppTextStyles.labelMedium,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 14),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
      // ── TextButton ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelMedium,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 10),
        ),
      ),
      // ── Input Decoration ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
        hintStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: colorScheme.onSurface.withValues(alpha: 0.4)),
        labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onSurface.withValues(alpha: 0.6)),
        floatingLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: AppRadius.buttonRadius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: AppRadius.buttonRadius, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: AppRadius.buttonRadius, borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: AppRadius.buttonRadius, borderSide: BorderSide(color: colorScheme.error, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: AppRadius.buttonRadius, borderSide: BorderSide(color: colorScheme.error, width: 1.5)),
      ),
      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        margin: EdgeInsets.zero,
      ),
      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: AppColors.primarySurface,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
        secondaryLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
        shape: const StadiumBorder(),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      ),
      // ── BottomNavigationBar ──────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.4),
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      // ── NavigationBar (Material 3) ────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: AppColors.primarySurface,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return IconThemeData(color: colorScheme.onSurface.withValues(alpha: 0.4), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary);
          }
          return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: colorScheme.onSurface.withValues(alpha: 0.4));
        }),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.15),
        thickness: 1,
        space: 1,
      ),
      // ── ListTile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurface),
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        iconColor: colorScheme.onSurface.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),
      // ── Dialog ───────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: colorScheme.onSurface),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
        elevation: 8,
      ),
      // ── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.onSurface,
        contentTextStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: colorScheme.surface),
        actionTextColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),
      // ── FloatingActionButton ─────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      // ── ProgressIndicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primarySurface,
      ),
      // ── Switches & Checkboxes ────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return colorScheme.onSurface.withValues(alpha: 0.4);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return colorScheme.surfaceContainerHighest;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.4), width: 1.5),
      ),
      // ── Tab Bar ──────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.4),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
        dividerColor: Colors.transparent,
      ),
      // ── BottomSheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
