import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:club_hub/src/core/theme/app_theme_controller.dart';

/// Pantalla de Ajustes: permite cambiar el color de marca de la app.
/// - Muestra paleta de colores predefinidos.
/// - Permite pegar un HEX manual (p. ej. #123ABC).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandColorProvider);
    final notifier = ref.read(brandColorProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    final ctrl = TextEditingController(
        text: '#'
            '${brand.red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
            '${brand.green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
            '${brand.blue.toRadixString(16).padLeft(2, '0').toUpperCase()}');

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Color de marca',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final c in presetBrandColors)
                GestureDetector(
                  onTap: () => notifier.setColor(c),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: brand == c
                            ? cs.onPrimaryContainer
                            : cs.outlineVariant,
                        width: brand == c ? 3 : 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('HEX personalizado (#RRGGBB)',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.tag),
                    hintText: '#123ABC',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () async {
                  final v = ctrl.text.trim();
                  if (RegExp(r'^#?[0-9A-Fa-f]{6}$').hasMatch(v)) {
                    await notifier.setHex(v.startsWith('#') ? v : '#$v');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Color actualizado')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('HEX inválido. Usa formato #RRGGBB')),
                    );
                  }
                },
                child: const Text('Aplicar'),
              )
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Acerca de'),
            subtitle: Text('Gestor de entidades deportivas — Club Hub'),
          ),
        ],
      ),
    );
  }
}
