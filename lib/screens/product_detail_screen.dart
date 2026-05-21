import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.eco, size: 96, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(fmt.format(product.price),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(label: Text('Stock: ${product.stock}')),
                const SizedBox(width: 8),
                Chip(
                  label: Text(product.isActive ? 'Activo' : 'Inactivo'),
                  backgroundColor: product.isActive ? Colors.green.shade100 : Colors.grey.shade300,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Descripción', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              (product.description ?? '').isEmpty ? 'Sin descripción.' : product.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Creado por: ${product.creator?.name ?? "—"}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('ID: ${product.id}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
