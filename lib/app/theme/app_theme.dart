import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'brand.dart';

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: kBrandSeed,
      brightness: brightness,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
      labelLarge:  GoogleFonts.inter(fontWeight: FontWeight.w600),
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      // ✅ Use CardThemeData (not CardTheme)
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: scheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceVariant.withOpacity(
          brightness == Brightness.light ? 0.5 : 0.2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _outline(scheme.outlineVariant),
        enabledBorder: _outline(scheme.outlineVariant),
        focusedBorder: _outline(scheme.primary, 2),
        errorBorder: _outline(scheme.error),
        focusedErrorBorder: _outline(scheme.error, 2),
      ),
      // ✅ Prefer MaterialStateProperty for wider SDK compatibility
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: scheme.outline),
        fillColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected) ? scheme.primary : null),
        checkColor: MaterialStateProperty.all(scheme.onPrimary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected) ? scheme.onPrimary : scheme.outline),
        trackColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected) ? scheme.primary : scheme.outlineVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: MaterialStateProperty.all(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      sliderTheme: const SliderThemeData(showValueIndicator: ShowValueIndicator.always),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
      // (Optional) splashFactory can be left default for broader compatibility
    );
  }

  static OutlineInputBorder _outline(Color c, [double w = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c, width: w),
      );
}

