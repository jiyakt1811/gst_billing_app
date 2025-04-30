import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/invoice_provider.dart';
import 'invoice_details_screen.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: invoicesAsync.when(
        data: (invoices) => ListView.builder(
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('Invoice #${invoice.id.substring(0, 8)}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${invoice.date.toString().split(' ')[0]}',
                    ),
                    if (invoice.customerName != null)
                      Text('Customer: ${invoice.customerName}'),
                  ],
                ),
                trailing: Text(
                  '₹${invoice.totalPayable.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvoiceDetailsScreen(invoice: invoice),
                    ),
                  );
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
} 