import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clave donde guardamos el color elegido.
const _kBrandColorKey = 'brandColorHex';

/// Paleta de colores sugeridos (puedes añadir los del club aquí).
const presetBrandColors = <Color>[
  Color(0xFF2563EB), // azul
  Color(0xFF0EA5A8), // teal
  Color(0xFF8B5CF6), // violeta
  Color(0xFFF97316), // naranja
  Color(0xFF16A34A), // verde
  Color(0xFFE11D48), // rojo frambuesa
  Color(0xFF111827), // casi negro
];

/// Convierte Color a hex tipo #RRGGBB.
String _colorToHex(Color c) =>
    '#${c.red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
    '${c.green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
    '${c.blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';

/// Parsea hex #RRGGBB a Color.
Color _hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  final r = int.parse(h.substring(0, 2), radix: 16);
  final g = int.parse(h.substring(2, 4), radix: 16);
  final b = int.parse(h.substring(4, 6), radix: 16);
  return Color.fromARGB(255, r, g, b);
}

/// Notifier que mantiene el color de marca actual y lo guarda en SharedPrefs.
class BrandColorController extends Notifier<Color> {
  @override
  Color build() {
    // Valor por defecto (teal).
    _load();
    return const Color(0xFF0EA5A8);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final hex = prefs.getString(_kBrandColorKey);
    if (hex != null && hex.length >= 7) {
      state = _hexToColor(hex);
    }
  }

  Future<void> setColor(Color c) async {
    state = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBrandColorKey, _colorToHex(c));
  }

  /// Permite escribir un hex manual (#RRGGBB).
  Future<void> setHex(String hex) => setColor(_hexToColor(hex));
}

/// Provider global para el color de marca.
final brandColorProvider =
    NotifierProvider<BrandColorController, Color>(BrandColorController.new);
