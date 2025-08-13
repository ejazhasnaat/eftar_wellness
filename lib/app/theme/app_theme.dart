import 'dart:ui' show lerpDouble;
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

    final isLight = brightness == Brightness.light;

    return base.copyWith(
      // Pure white in light mode
      scaffoldBackgroundColor: isLight ? Colors.white : scheme.surface,
      // Align surfaces with white in light mode
      colorScheme: isLight ? scheme.copyWith(surface: Colors.white) : scheme,

      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? Colors.white : scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),

      // Cards (keep flat look)
      cardTheme: CardThemeData(
        color: isLight ? Colors.white : scheme.surface,
        elevation: 0,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),

      // Buttons
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

      // Text fields (no fill, grey outline; text auto black/white per theme)
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _outline(scheme.outline),
        enabledBorder: _outline(scheme.outline),
        disabledBorder: _outline(scheme.outline.withOpacity(0.5)),
        focusedBorder: _outline(scheme.primary, 2),
        errorBorder: _outline(scheme.error),
        focusedErrorBorder: _outline(scheme.error, 2),
      ),

      // Selection controls
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: scheme.outline),
        fillColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? scheme.primary : null),
        checkColor: MaterialStateProperty.all(scheme.onPrimary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? scheme.onPrimary : scheme.outline),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? scheme.primary : scheme.outlineVariant),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? scheme.primary : scheme.outline),
        overlayColor: MaterialStateProperty.all(Colors.transparent), // no highlight glow
        visualDensity: VisualDensity.standard,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isLight ? Colors.white : scheme.surface,
        elevation: 0,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: MaterialStateProperty.all(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      sliderTheme: const SliderThemeData(showValueIndicator: ShowValueIndicator.always),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),

      // Theme extension for consistent outlined boxes (no fill)
      extensions: <ThemeExtension<dynamic>>[
        AppDecorations(
          radius: 16,
          outline: scheme.outline,
          selectedOutline: scheme.primary,
        ),
      ],
    );
  }

  static OutlineInputBorder _outline(Color c, [double w = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c, width: w),
      );
}

/// Extension to theme consistent outlined containers/tiles across the app.
class AppDecorations extends ThemeExtension<AppDecorations> {
  final double radius;
  final Color outline;
  final Color selectedOutline;

  const AppDecorations({
    required this.radius,
    required this.outline,
    required this.selectedOutline,
  });

  // Unified outlined tile style (no background, only border)
  BoxDecoration outlinedTile({required bool selected}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: selected ? selectedOutline : outline,
        width: selected ? 2 : 1,
      ),
      color: Colors.transparent,
    );
  }

  @override
  AppDecorations copyWith({
    double? radius,
    Color? outline,
    Color? selectedOutline,
  }) {
    return AppDecorations(
      radius: radius ?? this.radius,
      outline: outline ?? this.outline,
      selectedOutline: selectedOutline ?? this.selectedOutline,
    );
  }

  @override
  AppDecorations lerp(ThemeExtension<AppDecorations>? other, double t) {
    if (other is! AppDecorations) return this;
    return AppDecorations(
      radius: lerpDouble(radius, other.radius, t) ?? radius,
      outline: Color.lerp(outline, other.outline, t) ?? outline,
      selectedOutline: Color.lerp(selectedOutline, other.selectedOutline, t) ?? selectedOutline,
    );
  }
}

