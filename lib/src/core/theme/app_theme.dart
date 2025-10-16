import 'package:flutter/material.dart';

/// AppTheme — estilo “SetPoint HQ” aplicado a Club Hub (dark pro)
/// Paleta base:
/// - Fondo: 0xFF0f172a (slate muy oscuro)
/// - Superficie: 0xFF1e293b
/// - Primario: 0xFF3b82f6 (azul)
/// - Secundario: 0xFF8b5cf6 (violeta)
class AppTheme {
  static const _scaffold = Color(0xFF0f172a);
  static const _surface = Color(0xFF1e293b);
  static const _primary = Color(0xFF3b82f6);
  static const _secondary = Color(0xFF8b5cf6);
  static const _fillInput = Color(0xFF334155);
  static const _borderInput = Color(0xFF475569);
  static const _labelText = Color(0xFF94a3b8);
  static const _hintText = Color(0xFF64748b);

  /// Tema oscuro principal (idéntico en espíritu a SetPoint HQ)
  static ThemeData setpointDark() {
    final base = ThemeData.dark(useMaterial3: true);
    final scheme = const ColorScheme.dark(
      primary: _primary,
      secondary: _secondary,
      surface: _surface,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: _scaffold,

      // Tipografía: mayor legibilidad sobre fondo oscuro
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: _surface,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _surface,
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 2,
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _borderInput),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _fillInput,
        labelStyle: const TextStyle(color: _labelText),
        hintStyle: const TextStyle(color: _hintText),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderInput),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderInput),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
      ),

      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(const Color(0xFF334155)),
        dataRowMinHeight: 56,
        dataRowMaxHeight: 72,
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: _primary,
        ),
        dataTextStyle: const TextStyle(color: Colors.white),
        dividerThickness: 0.6,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle:
            base.textTheme.titleLarge?.copyWith(color: Colors.white),
        contentTextStyle:
            base.textTheme.bodyMedium?.copyWith(color: Colors.white70),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        indicatorShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelTextStyle: WidgetStatePropertyAll(
          base.textTheme.labelMedium?.copyWith(color: Colors.white70),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.08),
        thickness: 1,
        space: 16,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: Colors.white70,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Si en el futuro quieres mantener el cambio de color dinámico,
  /// puedes construir a partir del esquema oscuro y alterar primary/secondary.
  static ThemeData fromBrandDark(Color brandPrimary, {Color? brandSecondary}) {
    final base = setpointDark();
    final newScheme = base.colorScheme.copyWith(
      primary: brandPrimary,
      secondary: brandSecondary ?? base.colorScheme.secondary,
    );
    return base.copyWith(colorScheme: newScheme);
  }
}
