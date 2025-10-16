// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Dashboard conectado a Firestore:
/// - KPIs reales: Próx. eventos (7 días) y Pagos pendientes
/// - Lista de próximos 5 eventos
/// - Acción "Nuevo evento" con diálogo (guarda en collection 'events')
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final isTablet = MediaQuery.of(context).size.width >= 700;

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Panel de control',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        'Resumen rápido del club • Hoy',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isTablet)
                  FilledButton.icon(
                    onPressed: () => _showCreateEventDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo evento'),
                  ),
              ],
            ),
          ),
        ),

        // KPIs en píldoras
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _KpiPillAggregateCount(
                  icon: Icons.event_available,
                  title: 'Próx. eventos',
                  query: _eventsNext7DaysQuery(),
                ),
                _KpiPillAggregateCount(
                  icon: Icons.payments_outlined,
                  title: 'Pagos pendientes',
                  query: FirebaseFirestore.instance
                      .collection('payments')
                      .where('status', isEqualTo: 'pending'),
                ),
                const _KpiPill(
                    icon: Icons.how_to_reg_outlined,
                    title: 'Asistencias hoy',
                    value: '—'),
                const _KpiPill(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Alertas bienestar',
                    value: '—'),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Contenido principal 2 columnas (si hay ancho)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna izquierda
                Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                      _SectionCard(
                        title: 'Próximos eventos',
                        actionText: 'Ver calendario',
                        onAction: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Calendario — próximamente')),
                          );
                        },
                        child: _UpcomingEventsList(),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Pagos y cuotas',
                        actionText: 'Ir a Finanzas',
                        onAction: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Finanzas — próximamente')),
                          );
                        },
                        child: _PaymentsHint(),
                      ),
                    ],
                  ),
                ),
                if (isWide) const SizedBox(width: 12),
                // Columna derecha
                Flexible(
                  flex: 1,
                  child: Column(
                    children: [
                      _SectionCard(
                        title: 'Accesos rápidos',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _QuickActionChip(
                                icon: Icons.group_add, label: 'Añadir miembro'),
                            _QuickActionChip(
                              icon: Icons.calendar_month,
                              label: 'Nuevo evento',
                              onTap: () => _showCreateEventDialog(context),
                            ),
                            _QuickActionChip(
                                icon: Icons.groups_2, label: 'Crear equipo'),
                            _QuickActionChip(
                                icon: Icons.campaign_outlined,
                                label: 'Comunicado'),
                            _QuickActionChip(
                                icon: Icons.sports, label: 'Pizarra táctica'),
                            _QuickActionChip(
                                icon: Icons.favorite_outline,
                                label: 'Bienestar'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Consejos',
                        child: Column(
                          children: const [
                            _TipTile(
                              icon: Icons.insights_outlined,
                              title: 'Conecta el módulo de bienestar',
                              subtitle:
                                  'Recibe alertas si hay riesgo de fatiga.',
                            ),
                            Divider(height: 8),
                            _TipTile(
                              icon: Icons.emoji_events_outlined,
                              title: 'Activa la gamificación',
                              subtitle: 'Medallas automáticas por asistencia.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  static Query<Map<String, dynamic>> _eventsNext7DaysQuery() {
    final now = Timestamp.now();
    final in7d = Timestamp.fromDate(
      DateTime.now().add(const Duration(days: 7)),
    );
    return FirebaseFirestore.instance
        .collection('events')
        .where('start', isGreaterThanOrEqualTo: now)
        .where('start', isLessThan: in7d);
  }

  Future<void> _showCreateEventDialog(BuildContext context) async {
    final titleCtrl = TextEditingController();
    DateTime? date;
    TimeOfDay? time;
    int durationMinutes = 90;

    Future<void> pickDateTime() async {
      final pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDate: DateTime.now(),
      );
      if (pickedDate == null) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 18, minute: 0),
      );
      if (pickedTime == null) return;
      date = pickedDate;
      time = pickedTime;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nuevo evento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Entrenamiento Senior A',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await pickDateTime();
                        setState(() {});
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        (date == null || time == null)
                            ? 'Fecha y hora'
                            : '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')} • ${time!.format(context)}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Duración'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: durationMinutes,
                    items: const [
                      DropdownMenuItem(value: 60, child: Text('60 min')),
                      DropdownMenuItem(value: 90, child: Text('90 min')),
                      DropdownMenuItem(value: 120, child: Text('120 min')),
                    ],
                    onChanged: (v) => setState(() => durationMinutes = v ?? 90),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                if (title.isEmpty || date == null || time == null) return;
                final start = DateTime(date!.year, date!.month, date!.day,
                    time!.hour, time!.minute);
                final end = start.add(Duration(minutes: durationMinutes));
                await FirebaseFirestore.instance.collection('events').add({
                  'title': title,
                  'type': 'training', // MVP
                  'start': Timestamp.fromDate(start),
                  'end': Timestamp.fromDate(end),
                  'createdAt': FieldValue.serverTimestamp(),
                });
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Evento creado')));
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- Widgets auxiliares ----------

/// KPI con valor estático (placeholder)
class _KpiPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _KpiPill({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
        color: cs.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: cs.primary.withOpacity(0.08),
            ),
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// KPI con count() de Firestore (Aggregate query)
class _KpiPillAggregateCount extends StatelessWidget {
  final IconData icon;
  final String title;
  final Query<Map<String, dynamic>> query;

  const _KpiPillAggregateCount({
    required this.icon,
    required this.title,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<AggregateQuerySnapshot>(
      future: query.count().get(),
      builder: (context, snap) {
        final value = (snap.hasData) ? snap.data!.count.toString() : '…';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
            color: cs.surface,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: cs.primary.withOpacity(0.08),
                ),
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Lista de próximos 5 eventos (próximos 30 días)
class _UpcomingEventsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = Timestamp.now();
    final in30d =
        Timestamp.fromDate(DateTime.now().add(const Duration(days: 30)));

    final query = FirebaseFirestore.instance
        .collection('events')
        .where('start', isGreaterThanOrEqualTo: now)
        .where('start', isLessThan: in30d)
        .orderBy('start')
        .limit(5);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(minHeight: 2),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return _EmptyListPlaceholder(
            icon: Icons.event_note,
            title: 'Sin eventos programados',
            subtitle:
                'Crea tu primer entrenamiento o partido desde “Nuevo evento”.',
          );
        }
        return Column(
          children: [
            for (final d in docs) _EventTile(data: d.data()),
          ],
        );
      },
    );
  }
}

class _EventTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _EventTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final ts = data['start'] as Timestamp?;
    final dt = ts?.toDate();
    final dateText = (dt == null)
        ? '—'
        : '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} • ${TimeOfDay.fromDateTime(dt).format(context)}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.4)),
        ),
        child: const Icon(Icons.calendar_today, size: 18),
      ),
      title: Text(data['title'] ?? 'Evento'),
      subtitle: Text(data['type'] ?? '—'),
      trailing: Text(dateText),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detalle de evento — próximamente')),
        );
      },
    );
  }
}

class _PaymentsHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _EmptyListPlaceholder(
      icon: Icons.account_balance_wallet_outlined,
      title: 'No hay pagos pendientes',
      subtitle: 'Configura cuotas y gestiona cobros desde aquí (próximamente).',
    );
  }
}

// Contenedor de sección reutilizable
class _SectionCard extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final border =
        BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.4));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(border),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleMedium)),
              if (actionText != null && onAction != null)
                TextButton(onPressed: onAction, child: Text(actionText!)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// Placeholder para listas vacías
class _EmptyListPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyListPlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.4)),
            ),
            child: Icon(icon, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Chip de acción rápida
class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickActionChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label — próximamente')),
            );
          },
    );
  }
}

// Tip/Consejo
class _TipTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TipTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.4)),
        ),
        child: Icon(icon, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title — próximamente')),
        );
      },
    );
  }
}
