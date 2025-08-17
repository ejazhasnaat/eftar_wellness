import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

class AppTheme {
  // Design tokens
  static const kOutlineRadius = 14.0;
  static const kFillGrey = Color(0xFFF7F7F7);
  static const kSoftShadow = Color(0x1A000000); // ~6% black

  static ThemeData get light => _light();
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00A980),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.black,
      );

  static ThemeData _light() {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF00A980), // tweak to your brand
      brightness: Brightness.light,
    );

    final cs = base.colorScheme;

    // Shared rounded shape
    final rounded14 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kOutlineRadius),
    );

    // Reusable outline border for inputs
    OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(kOutlineRadius),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      // Remove Material3 tint on surfaces so our grey fill looks exact.
      applyElevationOverlayColor: false,
      splashFactory: InkSparkle.splashFactory,

      // --- TEXT FIELDS ---
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: kFillGrey, // ✅ light grey background (app-wide)
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: _border(base.colorScheme.outlineVariant, 1.1),
        enabledBorder: _border(base.colorScheme.outlineVariant, 1.1),
        focusedBorder: _border(cs.primary, 1.8),
        errorBorder: _border(cs.error, 1.4),
        focusedErrorBorder: _border(cs.error, 1.4),
        labelStyle: base.textTheme.bodyMedium,
        hintStyle: base.textTheme.bodyMedium?.copyWith(
          color: base.textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
      ),

      // --- ELEVATED BUTTONS (Primary) ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(rounded14),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          elevation: const WidgetStatePropertyAll(2), // subtle lift
          shadowColor: const WidgetStatePropertyAll(kSoftShadow),
          backgroundColor: WidgetStatePropertyAll(cs.primary),
          foregroundColor: WidgetStatePropertyAll(cs.onPrimary),
          overlayColor: WidgetStatePropertyAll(cs.onPrimary.withOpacity(0.08)),
        ),
      ),

      // --- OUTLINED BUTTONS (Neutral, matches outline field) ---
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(rounded14),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          // We mimic the outline field look by giving the button a grey fill + border.
          backgroundColor: const WidgetStatePropertyAll(kFillGrey),
          side: WidgetStatePropertyAll(
            BorderSide(color: base.colorScheme.outlineVariant, width: 1.1),
          ),
          elevation: const WidgetStatePropertyAll(2), // subtle lift to echo shadow
          shadowColor: const WidgetStatePropertyAll(kSoftShadow),
          foregroundColor: WidgetStatePropertyAll(base.colorScheme.onSurface),
          overlayColor: WidgetStatePropertyAll(cs.primary.withOpacity(0.08)),
        ),
      ),

      // --- SEGMENTED BUTTONS ---
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(rounded14),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return selected ? cs.primary.withOpacity(0.10) : kFillGrey;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return BorderSide(
              color: selected ? cs.primary : base.colorScheme.outlineVariant,
              width: selected ? 1.6 : 1.1,
            );
          }),
          elevation: const WidgetStatePropertyAll(2),
          shadowColor: const WidgetStatePropertyAll(kSoftShadow),
          foregroundColor: WidgetStatePropertyAll(base.colorScheme.onSurface),
        ),
      ),

      // --- RADIO (colors only; tile container styling is layout-level) ---
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? cs.primary : base.colorScheme.outline;
        }),
        visualDensity: VisualDensity.compact,
      ),

      // --- PROGRESS INDICATORS ---
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: base.colorScheme.surfaceContainerHighest,
        // Note: rounded corners require a ClipRRect in usage; not themeable.
      ),

      // --- CARDS (match outline surface) ---
      cardTheme: CardThemeData(
        color: kFillGrey, // ✅ same light grey
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: base.colorScheme.outlineVariant, width: 1.1),
        ),
        elevation: 2,
        shadowColor: kSoftShadow,
        margin: const EdgeInsets.all(0),
        surfaceTintColor: Colors.transparent, // keep the grey exact
      ),

      // --- CHIPS (optional: to match outline look) ---
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: base.colorScheme.outlineVariant, width: 1.1),
        shape: StadiumBorder(side: BorderSide(color: base.colorScheme.outlineVariant, width: 1.1)),
        backgroundColor: kFillGrey,
        selectedColor: cs.primary.withOpacity(0.10),
        disabledColor: kFillGrey,
        elevation: 2,
        shadowColor: kSoftShadow,
      ),

      // Reduce default Material surface tinting so our colors feel consistent.
      dividerColor: base.colorScheme.outlineVariant,
      scaffoldBackgroundColor: Colors.white,
      canvasColor: Colors.white,

      extensions: <ThemeExtension<dynamic>>[
        AppDecorations(
          radius: kOutlineRadius,
          outline: base.colorScheme.outlineVariant,
          selectedOutline: cs.primary,
        ),
      ],
    );
  }
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
        width: selected ? 1.6 : 1.1,
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
