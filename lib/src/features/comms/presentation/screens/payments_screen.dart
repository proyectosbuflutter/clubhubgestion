import 'package:flutter/material.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pagos', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
            ),
            child: Row(
              children: const [
                Icon(Icons.account_balance_wallet_outlined, size: 20),
                SizedBox(width: 8),
                Expanded(
                    child: Text(
                        'Cuotas, inscripciones y recordatorios automáticos (próximamente).')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
