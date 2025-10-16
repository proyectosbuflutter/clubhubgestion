// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamListScreen extends StatelessWidget {
  const TeamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('teams')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar equipos: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _EmptyTeams();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final data = docs[i].data();
              return Card(
                child: ListTile(
                  leading:
                      const CircleAvatar(child: Icon(Icons.shield_outlined)),
                  title: Text(data['name'] ?? 'Equipo'),
                  subtitle: Text(data['category'] ?? 'Categoría'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Detalle de equipo — próximamente')));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ctrl = TextEditingController();
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Nuevo equipo'),
              content: TextField(
                controller: ctrl,
                decoration:
                    const InputDecoration(labelText: 'Nombre del equipo'),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar')),
                FilledButton(
                  onPressed: () async {
                    final name = ctrl.text.trim();
                    if (name.isNotEmpty) {
                      await FirebaseFirestore.instance.collection('teams').add({
                        'name': name,
                        'category': 'General',
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Crear'),
                ),
              ],
            ),
          );
        },
        label: const Text('Crear equipo'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyTeams extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.groups_2_outlined, size: 64),
            const SizedBox(height: 12),
            Text('Aún no hay equipos',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Crea tu primer equipo con el botón inferior.'),
          ],
        ),
      ),
    );
  }
}
